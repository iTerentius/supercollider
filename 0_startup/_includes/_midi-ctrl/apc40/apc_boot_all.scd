/* 2025-10-19 12:53 — APC40 mkII ALL-IN-ONE v6: add Pan/Sends/User knob rows + knob CCs + LEDs
   - New: knob-row buttons (Pan=87, Sends=88, User=89) select virtual row r1..r3 with LED feedback
   - New: top-row knobs CC48..55 map to \b{bank}_s{strip}_r{row} via ~apcBindParam
   - Keeps: pads, scenes, stop-by-col, stop-all, banks, faders, panic recovery */
/* single () block, vars at top, no ) in comments */

(
/* ---------- normalize APC namespaces (avoid Event put errors) ---------- */
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

/* these are all used below; make sure they are IdentityDictionary */
ensureID.(\apcPadMap);
ensureID.(\apcIsDown);
ensureID.(\apcLedState);
ensureID.(\apcSceneMap);
ensureID.(\apcStopColChanMap);
ensureID.(\apcParamBindings);

/* colors bag - APC40 MK2 supports 128 colors (0-127) via velocity */
if(~apcColors.isNil or: { ~apcColors.isKindOf(IdentityDictionary).not }) {
    ~apcColors = IdentityDictionary[
        // Basic states
        \off -> 0,
        \on -> 1,

        // Grayscale
        \dimWhite -> 1,
        \white -> 3,

        // Reds
        \dimRed -> 5,
        \red -> 6,
        \brightRed -> 7,

        // Oranges
        \dimOrange -> 9,
        \orange -> 10,
        \brightOrange -> 11,

        // Yellows
        \dimYellow -> 13,
        \yellow -> 14,
        \brightYellow -> 15,

        // Chartreuse (yellow-green)
        \dimChartreuse -> 17,
        \chartreuse -> 18,
        \brightChartreuse -> 19,

        // Greens
        \dimGreen -> 21,
        \green -> 22,
        \brightGreen -> 23,

        // Cyan/Teal
        \dimCyan -> 25,
        \cyan -> 26,
        \brightCyan -> 27,

        // Light Blue
        \dimSky -> 29,
        \sky -> 30,
        \brightSky -> 31,

        // Blue
        \dimBlue -> 33,
        \blue -> 34,
        \brightBlue -> 35,

        // Purple/Violet
        \dimPurple -> 37,
        \purple -> 38,
        \brightPurple -> 39,

        // Magenta
        \dimMagenta -> 41,
        \magenta -> 42,
        \brightMagenta -> 43,

        // Pink
        \dimPink -> 45,
        \pink -> 46,
        \brightPink -> 47,

        // Hot colors (for playing states)
        \hotRed -> 72,
        \hotOrange -> 84,
        \hotYellow -> 96,
        \hotGreen -> 87,

        // Legacy compatibility
        \amber -> 9  // was 126, now using orange for better visibility
    ];
};

/* config bag */
ensureID.(\apcCfg);
if(~apcCfg[\gridChan].isNil) { ~apcCfg[\gridChan] = 0 };

/* ---------- base state ---------- */
~apcStopAllNote   = ~apcStopAllNote   ? nil;
~apcBank          = ~apcBank          ? 0;

/* knob-row state and mapping from your probe */
~apcKnobRow       = ~apcKnobRow       ? 1;         // 1 pan, 2 sends, 3 user
~apcKnobRowNotes  = ~apcKnobRowNotes  ? [87, 88, 89];
~apcKnobCCBase    = ~apcKnobCCBase    ? 48;        // 48..55 are 8 knobs
~apcKnobCCCount   = ~apcKnobCCCount   ? 8;

/* grid rows 0..4 top→bottom */
~apcRowNotes = ~apcRowNotes ? [
    [32,33,34,35,36,37,38,39],
    [24,25,26,27,28,29,30,31],
    [16,17,18,19,20,21,22,23],
    [ 8, 9,10,11,12,13,14,15],
    [ 0, 1, 2, 3, 4, 5, 6, 7]
];

/* columns 0..7 from rows */
~apcColNotes = ~apcColNotes ? Array.fill(8, { Array.fill(5, { 0 }) });
8.do { |c| 5.do { |r| ~apcColNotes[c][r] = ~apcRowNotes[r][c] } };

/* bank button and fader mapping based on your probe */
~apcBankBtnNote     = ~apcBankBtnNote     ? 50;   // small bank buttons are note 50
ensureArray.(\apcBankBtnChans, (0..7).asArray);
~apcStripFaderCC    = ~apcStripFaderCC    ? 7;    // strips CC7 on ch 0..7
~apcMasterFaderCC   = ~apcMasterFaderCC   ? 14;   // master CC14 on ch 0
~apcMasterFaderChan = ~apcMasterFaderChan ? 0;

/* ---------- MIDI Out + Generic Mode ---------- */
~apcForceAPCOut = {
    var out, dev, nam, apcSrc, apcInport;
    if(MIDIClient.initialized.not) { MIDIClient.init; };

    if(~apcMidiInDone.isNil) { ~apcMidiInDone = false; };
    if(~apcMidiInDone.not) {
        apcInport = MIDIClient.sources.detectIndex { |ep|
            var d, n;
            d = ep.device.asString;
            n = ep.name.asString;
            d.contains("APC40") or: { n.contains("APC40") }
        };

        if(apcInport.notNil) {
            apcSrc = MIDIClient.sources[apcInport];
            MIDIIn.connect(0, apcSrc);
            ["[APC] MIDIIn connected (port 0 -> index " ++ apcInport ++ "):", apcSrc.device, apcSrc.name].postln;
            ~apcMidiInDone = true;
        } {
            "[APC] source not found for MIDIIn".warn;
        };
    };

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
    if(out.isNil) { "[APC] could not open APC out".warn } { ~apcOut = out };
    ~apcOut
};

~apcPadLED = { |note, color, chan = (~apcCfg[\gridChan] ? 0)|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.notNil) {
        out.latency = 0.0;
        out.noteOn(chan, note, color);
        out.noteOn(1, note, color);
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
    if(out.isNil) {
        "[APC] no MIDIOut for SysEx".warn;
        false
    } {
        msg = Int8Array[240, 71, 127, 41, 96, 0, 4, 64, 1, 1, 0, 247];
        out.sysex(msg);
        "[APC] set Generic Mode".postln;
        true
    }
};

/* ---------- pads and scenes helpers ---------- */
~apcPadPlay = { |key| Pdef(key).play };
~apcPadStop = { |key| Pdef(key).stop };

~apcLEDByState = { |note, key|
    var colors, want;
    colors = ~apcColors;
    want = Pdef(key).isPlaying.if(colors[\green], colors[\amber]);
    ~apcLEDSet.(note, want);
};

~apcAssignPad = { |note, key|
    var colors; colors = ~apcColors;
    ~apcPadMap[note] = key;
    ~apcLEDSet.(note, colors[\amber]);
    ["map[" ++ note ++ "], " ++ key].postln;
};

~apcPadsInRow = { |row| var notes; notes = ~apcRowNotes.wrapAt(row); notes };

~apcRowPlaying = { |row|
    var anyOn; anyOn = false;
    ~apcPadsInRow.(row).do { |n|
        var key = ~apcPadMap[n];
        if(key.notNil and: { Pdef(key).isPlaying }) { anyOn = true };
    };
    anyOn
};

~apcSetRowState = { |row, wantPlay|
    var notes; notes = ~apcPadsInRow.(row);
    notes.do { |n|
        var key = ~apcPadMap[n];
        if(key.notNil) {
            if(wantPlay) { if(Pdef(key).isPlaying.not) { ~apcPadPlay.(key) } }
            { if(Pdef(key).isPlaying) { ~apcPadStop.(key) } };
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
    row = ~apcSceneMap[sceneNote];
    if(row.notNil) {
        colors = ~apcColors;
        want = ~apcRowPlaying.(row).if(colors[\green], colors[\amber]);
        ~apcLEDSet.(sceneNote, want);
    };
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

/* ---------- columns and stops ---------- */
~apcPadsInCol = { |col| var notes; notes = ~apcColNotes.wrapAt(col); notes };

~apcColPlaying = { |col|
    var anyOn; anyOn = false;
    ~apcPadsInCol.(col).do { |n|
        var key = ~apcPadMap[n];
        if(key.notNil and: { Pdef(key).isPlaying }) { anyOn = true };
    };
    anyOn
};

~apcAnyGridPlaying = {
    var anyOn; anyOn = false;
    if(~apcPadMap.notNil) {
        ~apcPadMap.values.do { |key|
            if(key.notNil and: { Pdef(key).isPlaying }) { anyOn = true };
        };
    };
    anyOn
};

~apcStopColumn = { |col|
    ~apcPadsInCol.(col).do { |n|
        var key = ~apcPadMap[n];
        if(key.notNil and: { Pdef(key).isPlaying }) {
            ~apcPadStop.(key);
            ~apcLEDByState.(n, key);
        };
    };
};

~apcStopAll = {
    if(~apcPadMap.notNil) {
        ~apcPadMap.keysValuesDo { |n, k|
            if(Pdef(k).isPlaying) { ~apcPadStop.(k) };
            ~apcLEDByState.(n, k);
        };
    };
    if(~apcStopAllNote.notNil) { ~apcStopAllLED.() };
};

~apcStopColLEDByChan = { |chan|
    var colors, col, want;
    col = ~apcStopColChanMap[chan];
    if(col.notNil) {
        colors = ~apcColors;
        want = ~apcColPlaying.(col).if(colors[\green], colors[\amber]);
        ~apcPadLEDch.(52, want, chan);
    };
};

~apcStopAllLED = {
    var colors, want;
    if(~apcStopAllNote.notNil) {
        colors = ~apcColors;
        want = ~apcAnyGridPlaying.().if(colors[\green], colors[\amber]);
        ~apcLEDSet.(~apcStopAllNote, want);
    };
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

/* ---------- bank buttons and faders ---------- */
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

/* knob row LED painters */
~apcPaintKnobRow = {
    var notes, colors, i;
    notes = ~apcKnobRowNotes; colors = ~apcColors;
    3.do { |i|
        var want;
        want = ((i + 1) == ~apcKnobRow).if(colors[\green], colors[\off]);
        ~apcPadLED.(notes[i], want);
    };
};

~apcChangeBank = { |idx|
    var old; old = ~apcBank; ~apcBank = idx.clip(0, 7);
    ["[APC PARAM] bank change", "old", old, "new", ~apcBank].postln;
    ~apcPaintAllBanks.();
};

~apcChangeKnobRow = { |row|
    var old; old = ~apcKnobRow; ~apcKnobRow = row.clip(1, 3);
    ["[APC PARAM] knob row change", "old", old, "new", ~apcKnobRow].postln;
    ~apcPaintKnobRow.();
};

/* bank buttons listener */
~apcInstallBankButtons = {
    var nameOn, nameOff, note, chans;
    nameOn = \apc_bank_on; nameOff = \apc_bank_off;
    note = ~apcBankBtnNote; chans = ~apcBankBtnChans.asArray;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        if(num == note and: { chans.includes(chan) }) {
            ["[BANK BTN on]", "num", num, "chan", chan, "vel", vel].postln;
            if(vel > 0) { ~apcChangeBank.(chan) } { ~apcPaintBankBtn.(chan) };
        };
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(num == note and: { chans.includes(chan) }) {
            ["[BANK BTN off]", "num", num, "chan", chan, "vel", vel].postln;
            ~apcPaintBankBtn.(chan);
        };
    });
    "[APC PARAM] bank button listener armed".postln; true
};

/* knob-row buttons listener (Pan=87, Sends=88, User=89) */
~apcInstallKnobRowButtons = {
    var nameOn, nameOff, notes;
    nameOn = \apc_knobrow_on; nameOff = \apc_knobrow_off; notes = ~apcKnobRowNotes;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var idx;
        if(notes.includes(num)) {
            idx = (notes.indexOf(num) + 1);
            ["[KNOBROW on]", "note", num, "row", idx, "vel", vel].postln;
            if(vel > 0) { ~apcChangeKnobRow.(idx) } { ~apcPaintKnobRow.() };
        };
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(~apcKnobRowNotes.includes(num)) { ~apcPaintKnobRow.() };
    });
    "[APC PARAM] knob-row button listener armed".postln; true
};

/* faders CC */
~apcInstallFaderCC = {
    var name, stripCC, masterCC, masterCh;
    name = \apc_faders_cc;
    stripCC = ~apcStripFaderCC;
    masterCC = ~apcMasterFaderCC;
    masterCh = ~apcMasterFaderChan;
    MIDIdef.free(name);
    MIDIdef.cc(name, { |val, num, chan, src|
        var x, stripIdx, key;
        if(num == masterCC and: { chan == masterCh }) {
            x = ~apcNorm7.(val);
            ~apcApplyParam.(\master_f, x);
        } {
            if(num == stripCC and: { chan >= 0 } and: { chan <= 7 }) {
                stripIdx = chan + 1;
                key = ~apcParamKeyFor.(~apcBank, stripIdx);
                x = ~apcNorm7.(val);
                ~apcApplyParam.(key, x);
            };
        };
    });
    "[APC PARAM] Fader CC listener armed".postln; true
};

/* knobs CC (CC48..55 on chan 0) */
~apcInstallKnobCC = {
    var name, base, count;
    name = \apc_knobs_cc; base = ~apcKnobCCBase; count = ~apcKnobCCCount;
    MIDIdef.free(name);
    MIDIdef.cc(name, { |val, num, chan, src|
        var idx, stripIdx, key, x;
        if((num >= base) and: { num < (base + count) }) {
            idx = num - base;         // 0..7
            stripIdx = idx + 1;       // 1..8
            key = ~apcParamKeyForKnob.(~apcBank, stripIdx, ~apcKnobRow);
            x = ~apcNorm7.(val);
            ["[KNOB CC]", "cc", num, "strip", stripIdx, "row", ~apcKnobRow, "bank", ~apcBank, "x", x.round(0.001)].postln;
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
        ~apcPadMap.keysValuesDo { |n, k| ~apcLEDByState.(n, k) };
    };
    ~apcRepaintScenes.();
    ~apcRepaintStops.();
    ~apcPaintAllBanks.();
    ~apcPaintKnobRow.();
    "[APC] LEDs repainted".postln;
};

/* ---------- grid listener ---------- */
~apcInstallGridListener = {
    var nameOn, nameOff;
    nameOn = \apc40_grid_any_on; nameOff = \apc40_grid_any_off;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var key, row, colByChan;
        key = ~apcPadMap[num];
        row = ~apcSceneMap[num];
        colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };
        if(key.notNil) {
            if(vel > 0) {
                ~apcIsDown[num] = true;
                if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) };
                ~apcLEDByState.(num, key);
                ~apcRepaintStops.();
            }{
                ~apcIsDown[num] = false;
                ~apcLEDByState.(num, key);
            };
        }{
            if(row.notNil) {
                if(vel > 0) { ~apcToggleRow.(row); ~apcSceneLEDByState.(num); ~apcRepaintStops.(); }
                { ~apcSceneLEDByState.(num) };
            }{
                if(colByChan.notNil) {
                    if(vel > 0) { ~apcStopColumn.(colByChan); ~apcStopColLEDByChan.(chan); ~apcStopAllLED.(); }
                    { ~apcStopColLEDByChan.(chan) };
                }{
                    if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) {
                        if(vel > 0) { ~apcStopAll.() } { ~apcStopAllLED.() };
                    };
                };
            };
        };
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        var key, row, colByChan, hadDown;
        key = ~apcPadMap[num];
        row = ~apcSceneMap[num];
        colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };
        if(key.notNil) {
            hadDown = ~apcIsDown[num] ? false;
            if(hadDown.not) { if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) } };
            ~apcIsDown[num] = false;
            ~apcLEDByState.(num, key);
            ~apcRepaintStops.();
        }{
            if(row.notNil) { ~apcSceneLEDByState.(num) };
            if(colByChan.notNil) { ~apcStopColLEDByChan.(chan); ~apcStopAllLED.() };
            if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) { ~apcStopAllLED.() };
        };
    });
    "[APC grid note-mode armed]".postln; true
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
        if(MIDIClient.initialized.not) { MIDIClient.init; };
        ~apcForceAPCOut.();
        if(~apcOut.notNil) {
            ~apcIntroGenericMode.();
            ~apcInstallGridListener.();
            ~apcInstallBankButtons.();
            ~apcInstallKnobRowButtons.();
            ~apcInstallFaderCC.();
            ~apcInstallKnobCC.();
            ~apcAutoAssignScenes.();
            ~apcAutoAssignStops.();
            ~apcRepaintAll.();
            "[APC] recovered after panic".postln;
        };
        nil
    });
};
CmdPeriod.add(~apcCmdPeriodHook);

/* ---------- boot actions ---------- */
~apcForceAPCOut.();

/* Only install listeners and configure if APC is actually connected */
if(~apcOut.notNil) {
    ~apcIntroGenericMode.();
    ~apcInstallGridListener.();
    ~apcInstallBankButtons.();
    ~apcInstallKnobRowButtons.();
    ~apcInstallFaderCC.();
    ~apcInstallKnobCC.();

    /* clear all LEDs then repaint and auto-assign defaults */
    0.to(127).do { |n| ~apcPadLED.(n, ~apcColors[\off]) };
    "[APC] LEDs cleared".postln;
    ~apcAutoAssignScenes.();
    ~apcAutoAssignStops.();
    AppClock.sched(0.25, { ~apcRepaintAll.() });
} {
    "[APC] Not connected - skipping listener setup".postln;
};
)

