/* 2025-10-18 16:35 — APC40 mkII boot: pads + scenes + stop-by-channel, sticky LEDs, panic recovery */
/* rules: single () block, declare vars at top of funcs, no ) in comments */

(
/* ---------- base state ---------- */
~apcParam      = ~apcParam      ? IdentityDictionary.new;
~apcPadMap     = ~apcPadMap     ? IdentityDictionary.new;      // note -> Pdef key
~apcIsDown     = ~apcIsDown     ? IdentityDictionary.new;      // note -> bool
~apcLedState   = ~apcLedState   ? IdentityDictionary.new;      // note -> last color
~apcSceneMap   = ~apcSceneMap   ? IdentityDictionary.new;      // sceneNote -> row index
~apcStopColMap = ~apcStopColMap ? IdentityDictionary.new;      // optional note-mapped column stops
~apcStopColChanMap = ~apcStopColChanMap ? IdentityDictionary.new;  // chan -> column index
~apcStopAllNote = ~apcStopAllNote ? nil;

~apcParam[\gridChan] = (~apcParam[\gridChan] ? 0);
~apcParam[\colors]   = (~apcParam[\colors]   ? IdentityDictionary[\off -> 0, \amber -> 126, \green -> 21]);

/* grid rows 0..4 top→bottom as provided */
~apcRowNotes = ~apcRowNotes ? [
    [32,33,34,35,36,37,38,39],  // row 0
    [24,25,26,27,28,29,30,31],  // row 1
    [16,17,18,19,20,21,22,23],  // row 2
    [ 8, 9,10,11,12,13,14,15],  // row 3
    [ 0, 1, 2, 3, 4, 5, 6, 7]   // row 4
];

/* columns 0..7 derived from rows */
~apcColNotes = ~apcColNotes ? Array.fill(8, { Array.fill(5, { 0 }) });
8.do { |c| 5.do { |r| ~apcColNotes[c][r] = ~apcRowNotes[r][c] } };

/* ---------- MIDI out + Generic Mode ---------- */
~apcForceAPCOut = {
    var out, dev, nam;
    if(MIDIClient.initialized.not) { MIDIClient.init; };
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
    if(out.isNil) { "[APC] could not open APC out".warn } { ~apcOut = out };
    ~apcOut
};

~apcPadLED = { |note, color, chan = (~apcParam[\gridChan] ? 0)|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.notNil) {
        out.latency = 0.0;
        out.noteOn(chan, note, color);
        out.noteOn(1, note, color);  // some firmwares prefer ch 1
    };
};

~apcPadLEDch = { |note, color, chan|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.notNil) {
        out.latency = 0.0;
        out.noteOn(chan, note, color);
    };
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

/* ---------- Pads: play helpers (no custom group) ---------- */
~apcPadPlay = { |key| Pdef(key).play };
~apcPadStop = { |key| Pdef(key).stop };

/* ---------- Pads: LED painter from Pdef state ---------- */
~apcLEDByState = { |note, key|
    var colors, want;
    colors = ~apcParam[\colors];
    want = Pdef(key).isPlaying.if(colors[\green], colors[\amber]);
    ~apcLEDSet.(note, want);
};

/* ---------- Assign pad to Pdef ---------- */
~apcAssignPad = { |note, key|
    var colors;
    colors = ~apcParam[\colors];
    ~apcPadMap[note] = key;
    ~apcLEDSet.(note, colors[\amber]);
    ["map[" ++ note ++ "], " ++ key].postln;
};

/* ---------- Rows: helpers ---------- */
~apcPadsInRow = { |row| var notes; notes = ~apcRowNotes.wrapAt(row); notes };

~apcRowPlaying = { |row|
    var notes, anyOn;
    anyOn = false;
    notes = ~apcPadsInRow.(row);
    notes.do { |n|
        var key = ~apcPadMap[n];
        if(key.notNil and: { Pdef(key).isPlaying }) { anyOn = true };
    };
    anyOn
};

~apcSetRowState = { |row, wantPlay|
    var notes;
    notes = ~apcPadsInRow.(row);
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

/* ---------- Scenes: assign + LED ---------- */
~apcSceneLEDByState = { |sceneNote|
    var row, colors, want;
    row = ~apcSceneMap[sceneNote];
    if(row.isNil) { ^nil };
    colors = ~apcParam[\colors];
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

/* ---------- Columns: helpers ---------- */
~apcPadsInCol = { |col| var notes; notes = ~apcColNotes.wrapAt(col); notes };

~apcColPlaying = { |col|
    var anyOn;
    anyOn = false;
    ~apcPadsInCol.(col).do { |n|
        var key = ~apcPadMap[n];
        if(key.notNil and: { Pdef(key).isPlaying }) { anyOn = true };
    };
    anyOn
};

~apcAnyGridPlaying = {
    var anyOn;
    anyOn = false;
    if(~apcPadMap.notNil) {
        ~apcPadMap.values.do { |key|
            if(key.notNil and: { Pdef(key).isPlaying }) { anyOn = true };
        };
    };
    anyOn
};

/* ---------- Stop Column + Stop All ---------- */
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

~apcStopColLEDByState = { |stopNote|
    var colors, col, want;
    col = ~apcStopColMap[stopNote];
    if(col.isNil) { ^nil };
    colors = ~apcParam[\colors];
    want = ~apcColPlaying.(col).if(colors[\green], colors[\amber]);
    ~apcLEDSet.(stopNote, want);
};

~apcStopColLEDByChan = { |chan|
    var colors, col, want;
    col = ~apcStopColChanMap[chan];
    if(col.isNil) { ^nil };
    colors = ~apcParam[\colors];
    want = ~apcColPlaying.(col).if(colors[\green], colors[\amber]);
    ~apcPadLEDch.(52, want, chan);   // note 52 per-channel stop LEDs
};

~apcStopAllLED = {
    var colors, want;
    if(~apcStopAllNote.isNil) { ^nil };
    colors = ~apcParam[\colors];
    want = ~apcAnyGridPlaying.().if(colors[\green], colors[\amber]);
    ~apcLEDSet.(~apcStopAllNote, want);
};

~apcAssignStopCol = { |stopNote, col|   // note-based variant if ever needed
    ~apcStopColMap[stopNote] = col;
    ~apcStopColLEDByState.(stopNote);
    ["stopCol[" ++ stopNote ++ "], col " ++ col].postln;
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

/* ---------- Repaint everything ---------- */
~apcRepaintStops = {
    if(~apcStopColMap.notNil and: { ~apcStopColMap.size > 0 }) {
        ~apcStopColMap.keysDo { |sn| ~apcStopColLEDByState.(sn) };
    };
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
    "[APC] LEDs repainted".postln;
};

/* ---------- Listener: pads + scenes + stop-by-channel + stop-all ---------- */
~apcInstallGridListener = {
    var nameOn, nameOff;
    nameOn = \apc40_grid_any_on; nameOff = \apc40_grid_any_off;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);

    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var key, row, colByNote, colByChan;
        key = ~apcPadMap[num];
        row = ~apcSceneMap[num];
        colByNote = ~apcStopColMap[num];
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
                if(colByNote.notNil or: { colByChan.notNil }) {
                    var col;
                    col = colByNote ?? { colByChan };
                    if(vel > 0) {
                        ~apcStopColumn.(col);
                        if(colByNote.notNil) { ~apcStopColLEDByState.(num) } { ~apcStopColLEDByChan.(chan) };
                        ~apcStopAllLED.();
                    }{
                        if(colByNote.notNil) { ~apcStopColLEDByState.(num) } { ~apcStopColLEDByChan.(chan) };
                    };
                }{
                    if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) {
                        if(vel > 0) { ~apcStopAll.() } { ~apcStopAllLED.() };
                    };
                };
            };
        };
    });

    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        var key, row, colByNote, colByChan, hadDown;
        key = ~apcPadMap[num];
        row = ~apcSceneMap[num];
        colByNote = ~apcStopColMap[num];
        colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };

        if(key.notNil) {
            hadDown = ~apcIsDown[num] ? false;
            if(hadDown.not) { if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) } };
            ~apcIsDown[num] = false;
            ~apcLEDByState.(num, key);
            ~apcRepaintStops.();
        }{
            // ignore release for scenes, stop-col, and stop-all; just repaint their LEDs
            if(row.notNil) { ~apcSceneLEDByState.(num) };
            if(colByNote.notNil or: { colByChan.notNil }) {
                if(colByNote.notNil) { ~apcStopColLEDByState.(num) } { ~apcStopColLEDByChan.(chan) };
                ~apcStopAllLED.();
            };
            if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) { ~apcStopAllLED.() };
        };
    });

    "[APC grid note-mode armed]".postln; true
};

/* ---------- Auto-assign: Scenes 82..86, Stop Columns by channel, Stop All 81 ---------- */
~apcAutoAssignScenes = {
    [82,83,84,85,86].do { |sn, i| ~apcAssignScene.(sn, i) };
    "[APC] default scenes 82..86 -> rows 0..4 assigned".postln;
};

~apcAutoAssignStops = {
    8.do { |c| ~apcAssignStopColByChan.(c, c) };  // note 52 ch 0..7 -> columns 0..7
    ~apcAssignStopAll.(81);
    "[APC] stop-by-channel ch0..7 -> col0..7, stopAll 81 assigned".postln;
};

/* ---------- Panic recovery ---------- */
CmdPeriod.remove(~apcCmdPeriodHook);
~apcCmdPeriodHook = {
    AppClock.sched(0.0, {
        if(MIDIClient.initialized.not) { MIDIClient.init; };
        MIDIIn.connectAll;
        ~apcForceAPCOut.();
        ~apcIntroGenericMode.();
        ~apcInstallGridListener.();
        ~apcAutoAssignScenes.();
        ~apcAutoAssignStops.();
        ~apcRepaintAll.();
        "[APC] recovered after panic".postln; nil
    });
};
CmdPeriod.add(~apcCmdPeriodHook);

/* ---------- Boot actions ---------- */
~apcForceAPCOut.();
~apcIntroGenericMode.();
~apcInstallGridListener.();

/* clear common pads and scene/stop notes to off, then repaint after MIDI settles */
if(~apcOut.notNil) {
    0.to(127).do { |n| ~apcPadLED.(n, ~apcParam[\colors][\off]) };
    "[APC] LEDs cleared".postln;
};
~apcAutoAssignScenes.();
~apcAutoAssignStops.();
AppClock.sched(0.25, { ~apcRepaintAll.() });
)

