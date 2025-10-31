/* 2025-10-31 08:22 America-Chicago — APC40 mkII ALL-IN-ONE v7
   - Typed pad binds: ~apcAssignPad.(note, key, kind) where kind is \p Pdef or \n Ndef
   - Grid uses MIDIFunc with strict source and channel filtering, press only when vel 127
   - Ndefs toggle on press, LEDs update after state change
   - Keeps your banks, faders, knob rows, scenes, stop, repaint, panic recovery */

/* single block start */
(
/* ---------- helpers to normalize state ---------- */
var ensureID, ensureArray;

ensureID = { |sym|
    var val, tmp;
    val = currentEnvironment.at(sym);
    if(val.isNil) {
        currentEnvironment.put(sym, IdentityDictionary.new);
    }{
        if(val.isKindOf(IdentityDictionary).not) {
            if(val.respondsTo(\keysValuesDo)) {
                tmp = IdentityDictionary.new;
                val.keysValuesDo { |k, v| tmp[k] = v };
                currentEnvironment.put(sym, tmp);
            }{
                currentEnvironment.put(sym, IdentityDictionary.new);
            };
        };
    };
};

ensureArray = { |sym, fallback|
    var val;
    val = currentEnvironment.at(sym);
    if(val.isNil) { currentEnvironment.put(sym, fallback) }{
        if(val.respondsTo(\asArray)) { currentEnvironment.put(sym, val.asArray) }{
            currentEnvironment.put(sym, fallback)
        };
    };
};

/* ensure bags used below */
ensureID.(\apcPadMap);         // note -> key
ensureID.(\apcPadTypes);       // note -> \p or \n
ensureID.(\apcIsDown);         // note -> Bool
ensureID.(\apcLedState);       // note -> color velocity
ensureID.(\apcSceneMap);       // scene button note -> row index
ensureID.(\apcStopColChanMap); // chan -> col
ensureID.(\apcParamBindings);  // param key -> Function

/* color table */
if(~apcColors.isNil or: { ~apcColors.isKindOf(IdentityDictionary).not }) {
    ~apcColors = IdentityDictionary[
        \off -> 0,   // black
        \amber -> 126,
        \green -> 21
    ];
};

/* config */
ensureID.(\apcCfg);
if(~apcCfg[\gridChan].isNil) { ~apcCfg[\gridChan] = 0 };   // grid is on MIDI channel 0 by default

/* ---------- base state ---------- */
~apcStopAllNote   = ~apcStopAllNote   ? nil;
~apcBank          = ~apcBank          ? 0;

/* knob row mapping */
~apcKnobRow       = ~apcKnobRow       ? 1;         // 1 pan, 2 sends, 3 user
~apcKnobRowNotes  = ~apcKnobRowNotes  ? [87, 88, 89];
~apcKnobCCBase    = ~apcKnobCCBase    ? 48;        // CC 48..55
~apcKnobCCCount   = ~apcKnobCCCount   ? 8;

/* grid rows 0..4 top to bottom */
~apcRowNotes = ~apcRowNotes ? [
    [32,33,34,35,36,37,38,39],
    [24,25,26,27,28,29,30,31],
    [16,17,18,19,20,21,22,23],
    [ 8, 9,10,11,12,13,14,15],
    [ 0, 1, 2, 3, 4, 5, 6, 7]
];

/* columns 0..7 derived from rows */
~apcColNotes = ~apcColNotes ? Array.fill(8, { Array.fill(5, { 0 }) });
8.do { |c| 5.do { |r| ~apcColNotes[c][r] = ~apcRowNotes[r][c] } };

/* bank button and faders */
~apcBankBtnNote     = ~apcBankBtnNote     ? 50;
ensureArray.(\apcBankBtnChans, (0..7).asArray);
~apcStripFaderCC    = ~apcStripFaderCC    ? 7;
~apcMasterFaderCC   = ~apcMasterFaderCC   ? 14;
~apcMasterFaderChan = ~apcMasterFaderChan ? 0;

/* ---------- MIDI Out and APC source detection ---------- */
~apcForceAPCOut = {
    var out, dev, nam;
    if(MIDIClient.initialized.not) { MIDIClient.init };
    MIDIIn.connectAll;
    out = nil;
    MIDIClient.destinations.do { |ep|
        dev = ep.device !? { ep.device.asString } ?? "";
        nam = ep.name !? { ep.name.asString } ?? "";
        if(out.isNil and: { (dev == "APC40 mkII") and: { nam == "APC40 mkII" } }) {
            out = MIDIOut.newByName(ep.device, ep.name);
        };
    };
    if(out.isNil) {
        MIDIClient.destinations.do { |ep|
            dev = ep.device !? { ep.device.asString } ?? "";
            nam = ep.name !? { ep.name.asString } ?? "";
            if(out.isNil and: { dev.contains("APC") or: { nam.contains("APC") } }) {
                out = MIDIOut.newByName(ep.device, ep.name);
            };
        };
    };
    if(out.isNil) { "[APC] could not open APC MIDIOut".warn } { ~apcOut = out };
    ~apcOut
};

/* find the APC input endpoint uid so we can bind precisely */
~apcEnsureSrc = {
    var uid;
    if(MIDIClient.initialized.not) { MIDIClient.init };
    MIDIIn.connectAll;
    uid = nil;
    MIDIClient.sources.do { |ep|
        var dev, nam;
        dev = ep.device !? { ep.device.asString } ?? "";
        nam = ep.name !? { ep.name.asString } ?? "";
        if(uid.isNil and: { (dev == "APC40 mkII") and: { nam == "APC40 mkII" } }) {
            uid = ep.uid;
        };
    };
    if(uid.isNil) {
        MIDIClient.sources.do { |ep|
            var dev, nam;
            dev = ep.device !? { ep.device.asString } ?? "";
            nam = ep.name !? { ep.name.asString } ?? "";
            if(uid.isNil and: { dev.contains("APC") or: { nam.contains("APC") } }) {
                uid = ep.uid;
            };
        };
    };
    if(uid.isNil) {
        "[APC] WARNING could not find APC input source uid, falling back to nil src filter".warn;
    }{
        ["[APC] using src uid", uid].postln;
    };
    ~apcSrc = uid;
    uid
};

/* basic LED out for grid */
~apcPadLED = { |note, color, chan = (~apcCfg[\gridChan] ? 0)|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.notNil) {
        out.latency = 0.0;
        out.noteOn(chan, note, color);
    };
};

~apcPadLEDch = { |note, color, chan|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.notNil) { out.latency = 0.0; out.noteOn(chan, note, color) };
};

~apcLEDSet = { |note, color|
    ~apcLedState[note] = color;
    ~apcPadLED.(note, color);
    AppClock.sched(0.03, { ~apcPadLED.(note, color) });
};

~apcIntroGenericMode = {
    var out, msg;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.isNil) { "[APC] no MIDIOut for SysEx".warn; ^false };
    msg = Int8Array[240, 71, 127, 41, 96, 0, 4, 64, 1, 1, 0, 247];
    out.sysex(msg);
    "[APC] set Generic Mode".postln; true
};

/* ---------- Pdef and Ndef helpers ---------- */
~apcPadPlay = { |key| Pdef(key).play };
~apcPadStop = { |key| Pdef(key).stop };

~apcLEDByState = { |note, key|
    var colors, want;
    colors = ~apcColors;
    want = Pdef(key).isPlaying.if(colors[\green], colors[\amber]);
    ~apcLEDSet.(note, want);
};

~apcLEDByStateNdef = { |note, key|
    var colors, on;
    colors = ~apcColors;
    on = try { Ndef(key).isPlaying } { false };
    ~apcLEDSet.(note, on.if(colors[\green], colors[\amber]));
};

/* typed assign, third arg kind accepts "p" or "n" or \p \n, defaults to \p */
~apcAssignPad = { |note, key, kind=\p|
    var colors, ksym, ksymKind;
    colors = ~apcColors;
    ksym = key.asSymbol;
    ksymKind = case
    { kind == "n" } { \n }
    { kind == "p" } { \p }
    { kind == \n }  { \n }
    { kind == \p }  { \p }
    { true }        { \p };
    ~apcPadMap[note]   = ksym;
    ~apcPadTypes[note] = ksymKind;
    if(ksymKind == \n) {
        ~apcLEDByStateNdef.(note, ksym);
    }{
        ~apcLEDSet.(note, colors[\amber]);
    };
    ["map[" ++ note ++ "], " ++ ksym ++ " kind " ++ ksymKind].postln;
};

/* rows and scenes treat only Pdef pads to avoid side effects on Ndefs */
~apcPadsInRow = { |row| var notes; notes = ~apcRowNotes.wrapAt(row); notes };

~apcRowPlaying = { |row|
    var anyOn; anyOn = false;
    ~apcPadsInRow.(row).do { |n|
        var key = ~apcPadMap[n], kind = ~apcPadTypes[n] ? \p;
        if(kind == \p and: { key.notNil and: { Pdef(key).isPlaying } }) { anyOn = true };
    };
    anyOn
};

~apcSetRowState = { |row, wantPlay|
    var notes;
    notes = ~apcPadsInRow.(row);
    notes.do { |n|
        var key = ~apcPadMap[n], kind = ~apcPadTypes[n] ? \p;
        if(kind == \p and: { key.notNil }) {
            if(wantPlay) { if(Pdef(key).isPlaying.not) { ~apcPadPlay.(key) } } {
                if(Pdef(key).isPlaying) { ~apcPadStop.(key) }
            };
            ~apcLEDByState.(n, key);
        };
    };
};

~apcToggleRow = { |row|
    var anyOn; anyOn = ~apcRowPlaying.(row);
    ~apcSetRowState.(row, anyOn.not);
    ~apcRepaintScenes.();
};

~apcSceneLEDByState = { |sceneNote|
    var row, colors, want;
    row = ~apcSceneMap[sceneNote]; if(row.isNil) { ^nil };
    colors = ~apcColors;
    want = ~apcRowPlaying.(row).if(colors[\green], colors[\amber]);
    ~apcLEDSet.(sceneNote, want);
};

~apcAssignScene = { |sceneNote, row|
    ~apcSceneMap[sceneNote] = row;
    ~apcSceneLEDByState.(sceneNote);
    ["scene[" ++ sceneNote ++ "], row " ++ row].postln;
};

~apcRepaintScenes = {
    if(~apcSceneMap.notNil and: { ~apcSceneMap.size > 0 }) {
        ~apcSceneMap.keysDo { |sn| ~apcSceneLEDByState.(sn) };
    };
};

/* ---------- columns and stops act on Pdef pads only ---------- */
~apcPadsInCol = { |col| var notes; notes = ~apcColNotes.wrapAt(col); notes };

~apcColPlaying = { |col|
    var anyOn; anyOn = false;
    ~apcPadsInCol.(col).do { |n|
        var key = ~apcPadMap[n], kind = ~apcPadTypes[n] ? \p;
        if(kind == \p and: { key.notNil and: { Pdef(key).isPlaying } }) { anyOn = true };
    };
    anyOn
};

~apcAnyGridPlaying = {
    var anyOn; anyOn = false;
    if(~apcPadMap.notNil) {
        ~apcPadMap.keysValuesDo { |note, key|
            var kind = ~apcPadTypes[note] ? \p;
            if(kind == \p and: { key.notNil and: { Pdef(key).isPlaying } }) { anyOn = true };
        };
    };
    anyOn
};

~apcStopColumn = { |col|
    ~apcPadsInCol.(col).do { |n|
        var key = ~apcPadMap[n], kind = ~apcPadTypes[n] ? \p;
        if(kind == \p and: { key.notNil and: { Pdef(key).isPlaying } }) {
            ~apcPadStop.(key);
            ~apcLEDByState.(n, key);
        };
    };
};

~apcStopAll = {
    if(~apcPadMap.notNil) {
        ~apcPadMap.keysValuesDo { |n, k|
            var kind = ~apcPadTypes[n] ? \p;
            if(kind == \p and: { Pdef(k).isPlaying }) { ~apcPadStop.(k) };
            if(kind == \p) { ~apcLEDByState.(n, k) } { ~apcLEDByStateNdef.(n, k) };
        };
    };
    if(~apcStopAllNote.notNil) { ~apcStopAllLED.() };
};

~apcStopColLEDByChan = { |chan|
    var colors, col, want;
    col = ~apcStopColChanMap[chan]; if(col.isNil) { ^nil };
    colors = ~apcColors;
    want = ~apcColPlaying.(col).if(colors[\green], colors[\amber]);
    ~apcPadLEDch.(52, want, chan);
};

~apcStopAllLED = {
    var colors, want;
    if(~apcStopAllNote.isNil) { ^nil };
    colors = ~apcColors;
    want = ~apcAnyGridPlaying.().if(colors[\green], colors[\amber]);
    ~apcLEDSet.(~apcStopAllNote, want);
};

~apcAssignStopColByChan = { |chan, col|
    ~apcStopColChanMap[chan] = col;
    ~apcStopColLEDByChan.(chan);
    ["stopCol[ch " ++ chan ++ " -> col " ++ col ++ "]"].postln;
};

~apcAssignStopAll = { |stopNote|
    ~apcStopAllNote = stopNote;
    ~apcStopAllLED.();
    ["stopAll[" ++ stopNote ++ "]"].postln;
};

/* ---------- param helpers and bindings ---------- */
~apcParamKeyFor = { |bank, strip|
    var b, s; b = bank.clip(0, 7); s = strip.clip(1, 8);
    ("b" ++ b ++ "_s" ++ s ++ "_f").asSymbol
};

~apcParamKeyForKnob = { |bank, strip, row|
    var b, s, r; b = bank.clip(0, 7); s = strip.clip(1, 8); r = row.clip(1, 3);
    ("b" ++ b ++ "_s" ++ s ++ "_r" ++ r).asSymbol
};

~apcBindParam = { |key, func|
    var f; f = func; ~apcParamBindings[key] = f;
    ["[apcBindParam] bound", key].postln;
};

~apcApplyParam = { |key, x|
    var f; f = ~apcParamBindings[key];
    if(f.notNil) { f.value(x) } { ["[apcApplyParam] no binding for", key].postln };
};

~apcNorm7 = { |val| (val.asFloat.clip(0, 127)) / 127.0 };

/* bank LED painters */
~apcPaintBankBtn = { |bankIdx|
    var colors, want, chan;
    colors = ~apcColors;
    chan = bankIdx.clip(0, 7);
    want = (bankIdx == ~apcBank).if(colors[\green], colors[\off]);
    ~apcPadLEDch.(~apcBankBtnNote, want, chan);
    AppClock.sched(0.03, { ~apcPadLEDch.(~apcBankBtnNote, want, chan) });
};

~apcPaintAllBanks = { 8.do { |i| ~apcPaintBankBtn.(i) } };

/* knob row painters and changes */
~apcPaintKnobRow = {
    var notes, colors;
    notes = ~apcKnobRowNotes; colors = ~apcColors;
    3.do { |i|
        var want;
        want = ((i + 1) == ~apcKnobRow).if(colors[\green], colors[\off]);
        ~apcPadLED.(notes[i], want);
    };
};

~apcChangeBank = { |idx|
    var old;
    old = ~apcBank; ~apcBank = idx.clip(0, 7);
    ["[APC PARAM] bank change", "old", old, "new", ~apcBank].postln;
    ~apcPaintAllBanks.();
};

~apcChangeKnobRow = { |row|
    var old;
    old = ~apcKnobRow; ~apcKnobRow = row.clip(1, 3);
    ["[APC PARAM] knob row change", "old", old, "new", ~apcKnobRow].postln;
    ~apcPaintKnobRow.();
};

/* bank buttons listener */
~apcInstallBankButtons = {
    var nameOn, nameOff, note, chans;
    nameOn = \apc_bank_on; nameOff = \apc_bank_off; note = ~apcBankBtnNote; chans = ~apcBankBtnChans.asArray;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        if(num == note and: { chans.includes(chan) }) {
            ["[BANK BTN on]", "num", num, "chan", chan, "vel", vel].postln;
            if(vel > 0) { ~apcChangeBank.(chan) } { ~apcPaintBankBtn.(chan) };
        };
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(num == note and: { chans.includes(chan) }) { ~apcPaintBankBtn.(chan) };
    });
    "[APC PARAM] bank button listener armed".postln; true
};

/* knob-row buttons listener */
~apcInstallKnobRowButtons = {
    var nameOn, nameOff, notes;
    nameOn = \apc_knobrow_on; nameOff = \apc_knobrow_off; notes = ~apcKnobRowNotes;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var idx;
        if(notes.includes(num)) {
            idx = (notes.indexOf(num) + 1);
            if(vel > 0) { ~apcChangeKnobRow.(idx) } { ~apcPaintKnobRow.() };
        };
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(notes.includes(num)) { ~apcPaintKnobRow.() };
    });
    "[APC PARAM] knob row button listener armed".postln; true
};

/* faders CC listener */
~apcInstallFaderCC = {
    var name, stripCC, masterCC, masterCh;
    name = \apc_faders_cc; stripCC = ~apcStripFaderCC; masterCC = ~apcMasterFaderCC; masterCh = ~apcMasterFaderChan;
    MIDIdef.free(name);
    MIDIdef.cc(name, { |val, num, chan, src|
        var x, stripIdx, key;
        if(num == masterCC and: { chan == masterCh }) {
            x = ~apcNorm7.(val); ~apcApplyParam.(\master_f, x); ^nil;
        };
        if(num == stripCC and: { chan >= 0 } and: { chan <= 7 }) {
            stripIdx = chan + 1; key = ~apcParamKeyFor.(~apcBank, stripIdx);
            x = ~apcNorm7.(val); ~apcApplyParam.(key, x);
        };
    });
    "[APC PARAM] Fader CC listener armed".postln; true
};

/* knobs CC listener */
~apcInstallKnobCC = {
    var name, base, count;
    name = \apc_knobs_cc; base = ~apcKnobCCBase; count = ~apcKnobCCCount;
    MIDIdef.free(name);
    MIDIdef.cc(name, { |val, num, chan, src|
        var idx, stripIdx, key, x;
        if((num >= base) and: { num < (base + count) }) {
            idx = num - base; stripIdx = idx + 1;
            key = ~apcParamKeyForKnob.(~apcBank, stripIdx, ~apcKnobRow);
            x = ~apcNorm7.(val);
            ~apcApplyParam.(key, x);
        };
    });
    "[APC PARAM] Knob CC listener armed".postln; true
};

/* ---------- repaint helpers ---------- */
~apcRepaintStops = {
    if(~apcStopColChanMap.notNil and: { ~apcStopColChanMap.size > 0 }) {
        ~apcStopColChanMap.keysDo { |ch| ~apcStopColLEDByChan.(ch) };
    };
    ~apcStopAllLED.();
};

~apcRepaintAll = {
    if(~apcPadMap.notNil and: { ~apcPadMap.size > 0 }) {
        ~apcPadMap.keysValuesDo { |n, k|
            var kind = ~apcPadTypes[n] ? \p;
            if(kind == \p) { ~apcLEDByState.(n, k) } { ~apcLEDByStateNdef.(n, k) };
        };
    };
    ~apcRepaintScenes.();
    ~apcRepaintStops.();
    ~apcPaintAllBanks.();
    ~apcPaintKnobRow.();
    "[APC] LEDs repainted".postln;
};

/* ---------- GRID LISTENER with MIDIFunc, filtered by src and chan ---------- */
/* free any prior MIDIFuncs so we do not stack listeners across recompiles */
~apcFreeGridFuncs = {
    var f;
    f = ~apcNoteOnFunc;  if(f.notNil) { f.free; ~apcNoteOnFunc = nil };
    f = ~apcNoteOffFunc; if(f.notNil) { f.free; ~apcNoteOffFunc = nil };
    "[APC grid] MIDIFunc freed".postln;
};

~apcInstallGridListener = {
    var gridChan, srcUid;

    gridChan = ~apcCfg[\gridChan] ? 0;
    srcUid   = ~apcEnsureSrc.();

    ~apcFreeGridFuncs.();

    /* only react to real pad presses, per APC protocol note on vel 127 */
    ~apcNoteOnFunc = MIDIFunc.noteOn(
        { |vel, num, chan, src|
            var key, kind, row, colByChan, wasOn;

            if(vel != 127) { ^nil };
            if(chan != gridChan) { ^nil };

            key  = ~apcPadMap[num];
            kind = ~apcPadTypes[num] ? \p;

            if(kind == \n and: { key.notNil }) {
                ~apcIsDown[num] = true;
                wasOn = try { Ndef(key).isPlaying } { false };
                wasOn.if({ Ndef(key).stop }, { Ndef(key).play });
                AppClock.sched(0.02, { ~apcLEDByStateNdef.(num, key); ~apcRepaintStops.(); nil });
                ^nil
            };

            if(key.notNil) {
                ~apcIsDown[num] = true;
                if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) };
                ~apcLEDByState.(num, key);
                ~apcRepaintStops.();
            }{
                row = ~apcSceneMap[num];
                colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };
                if(row.notNil) {
                    ~apcToggleRow.(row); ~apcSceneLEDByState.(num); ~apcRepaintStops.();
                }{
                    if(colByChan.notNil) {
                        ~apcStopColumn.(colByChan); ~apcStopColLEDByChan.(chan); ~apcStopAllLED.();
                    }{
                        if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) { ~apcStopAll.() };
                    };
                };
            };
        },
        nil,                 // any note
        gridChan,            // channel filter
        srcUid               // APC source uid, may be nil if not found, which means any source
    );

    ~apcNoteOffFunc = MIDIFunc.noteOff(
        { |vel, num, chan, src|
            var key, kind, row, colByChan, hadDown;

            if(chan != gridChan) { ^nil };

            key  = ~apcPadMap[num];
            kind = ~apcPadTypes[num] ? \p;

            if(kind == \n and: { key.notNil }) {
                hadDown = ~apcIsDown[num] ? false;
                if(hadDown.not) {
                    var wasOn = try { Ndef(key).isPlaying } { false };
                    wasOn.if({ Ndef(key).stop }, { Ndef(key).play });
                };
                ~apcIsDown[num] = false;
                AppClock.sched(0.02, { ~apcLEDByStateNdef.(num, key); ~apcRepaintStops.(); nil });
                ^nil
            };

            if(key.notNil) {
                hadDown = ~apcIsDown[num] ? false;
                if(hadDown.not) { if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) } };
                ~apcIsDown[num] = false;
                ~apcLEDByState.(num, key);
                ~apcRepaintStops.();
            }{
                row = ~apcSceneMap[num];
                colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };
                if(row.notNil) { ~apcSceneLEDByState.(num) };
                if(colByChan.notNil) { ~apcStopColLEDByChan.(chan); ~apcStopAllLED.() };
                if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) { ~apcStopAllLED.() };
            };
        },
        nil, gridChan, srcUid
    );

    "[APC grid] MIDIFunc armed chan ".post; gridChan.postln;
    true
};

/* ---------- auto-assigns ---------- */
~apcAutoAssignScenes = {
    [82,83,84,85,86].do { |sn, i| ~apcAssignScene.(sn, i) };
    "[APC] default scenes 82..86 -> rows 0..4 assigned".postln;
};

~apcAutoAssignStops = {
    8.do { |c| ~apcAssignStopColByChan.(c, c) };
    ~apcAssignStopAll.(81);
    "[APC] stop-by-channel ch0..7 -> col0..7, stopAll 81 assigned".postln;
};

/* ---------- panic recovery ---------- */
CmdPeriod.remove(~apcCmdPeriodHook);
~apcCmdPeriodHook = {
    AppClock.sched(0.0, {
        if(MIDIClient.initialized.not) { MIDIClient.init };
        MIDIIn.connectAll;
        ~apcForceAPCOut.();
        ~apcIntroGenericMode.();
        ~apcInstallGridListener.();     // MIDIFunc
        ~apcInstallBankButtons.();
        ~apcInstallKnobRowButtons.();
        ~apcInstallFaderCC.();
        ~apcInstallKnobCC.();
        ~apcAutoAssignScenes.();
        ~apcAutoAssignStops.();
        ~apcRepaintAll.();
        "[APC] recovered after panic".postln; nil
    });
};
CmdPeriod.add(~apcCmdPeriodHook);

/* ---------- boot actions ---------- */
~apcForceAPCOut.();
~apcIntroGenericMode.();
~apcInstallGridListener.();    // MIDIFunc
~apcInstallBankButtons.();
~apcInstallKnobRowButtons.();
~apcInstallFaderCC.();
~apcInstallKnobCC.();

/* clear then repaint and auto-assign defaults */
if(~apcOut.notNil) {
    0.to(127).do { |n| ~apcPadLED.(n, ~apcColors[\off]) };
    "[APC] LEDs cleared".postln;
};
~apcAutoAssignScenes.();
~apcAutoAssignStops.();
AppClock.sched(0.25, { ~apcRepaintAll.() });

)

