(
// =====================================================================
// Launch Control (non-XL) — Param Router + Bank Buttons/LEDs (8 banks)
// - Row-1 knobs CC 21..28, Row-2 knobs CC 41..48  (configurable)
// - Bottom-row buttons select banks; LEDs show selected bank
// - Prev/Next: CC 116 / 117
// - Bind with:  ~lcnBindParam.(\b0_s3_r2, { |x| ... })
// - No top-level 'var'; idempotent rebind; device-filtered by srcID.
// =====================================================================

// Clean re-eval
MIDIdef.free(\lcn_bank_prev);
MIDIdef.free(\lcn_bank_next);
MIDIdef.free(\lcn_bank_btns);
(1..8).do { |i|
    MIDIdef.free(("lcn_r1_s"++i).asSymbol);
    MIDIdef.free(("lcn_r2_s"++i).asSymbol);
};

~lcn = ~lcn ? ();

// ---- Detect Launch Control (non-XL) IN/OUT ----
~lcn[\srcID] = ~lcn[\srcID] ? {
    var s;
    s = MIDIClient.sources.detect({ |d|
        d.device.asString.contains("Launch Control")
        and: { d.device.asString.contains("XL").not }
    });
    if(s.notNil) { s.uid } { nil };
}.value;

~lcn[\out] = ~lcn[\out] ? {
    var d;
    d = MIDIClient.destinations.detect({ |t|
        t.device.asString.contains("Launch Control")
        and: { t.device.asString.contains("XL").not }
    });
    if(d.notNil) { MIDIOut.newByName(d.device, d.name) } { nil };
}.value;

// ---- CONFIG (defaults match your working setup) ----
~lcn[\config] = ~lcn[\config] ? ();
~lcn[\config].put(\chan1,   (~lcn[\config][\chan1]   ?? { 9 }));       // your input: 1-based 9
~lcn[\chan0] = (~lcn[\config][\chan1] - 1).clip(0,15);

~lcn[\config].put(\r1,      (~lcn[\config][\r1]      ?? { (21..28) }));
~lcn[\config].put(\r2,      (~lcn[\config][\r2]      ?? { (41..48) }));

~lcn[\config].put(\banks,   (~lcn[\config][\banks]   ?? { 8 }));       // use all 8 banks for params

// Your learned bottom-row notes (left→right):
~lcn[\config].put(\btnNotes,(~lcn[\config][\btnNotes]?? { [9,10,11,12,25,26,27,28] }));

// LEDs: channel 9 (0-based) worked on your unit; palette = on/off (robust)
~lcn[\config].put(\ledChan0,(~lcn[\config][\ledChan0]?? { 9 }));
~lcn[\config].put(\palette, (~lcn[\config][\palette] ?? { (selected: 127, unselected: 0) }));

// Optional clears if other templates left junk
~lcn[\config].put(\forceClearExtra,    (~lcn[\config][\forceClearExtra]    ?? { false }));
~lcn[\config].put(\extraClearChannels, (~lcn[\config][\extraClearChannels] ?? { (0..15) }));

// CC channel filtering (false = accept any channel from this device)
~lcn[\config].put(\strictChan, (~lcn[\config][\strictChan] ?? { false }));

// ---- State & registries ----
~lcn[\bankIdx]  = (~lcn[\bankIdx] ? 0).clip(0, ~lcn[\config][\banks]-1);
~lcn[\defs]     = ~lcn[\defs] ? Array.new;
~lcn[\handlers] = ~lcn[\handlers] ? IdentityDictionary.new;
~lcn[\debug]    = ~lcn[\debug] ? false;

// ---- Helpers ----
~lcn[\to01] = { |v| v / 127 };
~lcn[\keyFor] = { |bankIndex, strip1, row|
    ("b" ++ bankIndex ++ "_s" ++ strip1 ++ "_r" ++ row).asSymbol
};
~lcnBindParam   = { |key, func|  ~lcn[\handlers][key] = func; };
~lcnUnbindParam = { |key|        ~lcn[\handlers].removeAt(key) };

~lcn[\dispatch] = { |bankIndex, strip0, row, val01|
    var key = ~lcn[\keyFor].(bankIndex, strip0+1, row);
    var f = ~lcn[\handlers][key];
    if(f.notNil) { f.(val01) };
    if(~lcn[\debug]) { ("[LC] " ++ key.asString ++ " -> " ++ val01.round(0.001)).postln };
};

// LEDs
~lcn[\clearRow] = {
    var out = ~lcn[\out], ch = ~lcn[\config][\ledChan0], notes = ~lcn[\config][\btnNotes];
    if(out.isNil) { "[LC] No MIDIOut to LC (clearRow)".postln; ^nil };
    notes.do { |n| out.noteOn(ch, n, 0) };
    if(~lcn[\config][\forceClearExtra] == true) {
        ~lcn[\config][\extraClearChannels].do { |c| notes.do { |n| out.noteOn(c, n, 0) } };
    };
};

~lcn[\refreshLEDs] = {
    var out = ~lcn[\out], ch = ~lcn[\config][\ledChan0], notes = ~lcn[\config][\btnNotes];
    var banks = ~lcn[\config][\banks], b = (~lcn[\bankIdx] ? 0).clip(0, banks-1);
    var onVel  = (~lcn[\config][\palette][\selected]).asInteger;
    var offVel = (~lcn[\config][\palette][\unselected]).asInteger;
    if(out.isNil) { "[LC] No MIDIOut to LC (refreshLEDs)".postln; ^nil };
    // hard clear all 8 first
    notes.do { |nn| out.noteOn(ch, nn, 0) };
    // paint all 'banks' (8), ignore others
    (0..(banks-1)).do { |i| out.noteOn(ch, notes[i], (i == b).if(onVel, offVel)) };
};

~lcn[\showBanner] = {
    ("\n=== LC BANK % === (r1=%  r2=%, leds@ch%)"
        .format(~lcn[\bankIdx], ~lcn[\config][\r1], ~lcn[\config][\r2], ~lcn[\config][\ledChan0])).postln;
};

// Learn helper (kept, in case you ever change templates)
~lcnLearnButtons = {
    var srcID = ~lcn[\srcID];
    var captured = List.new;
    var key = \lcn_btn_learn;
    MIDIdef.noteOn(key, { |vel, note, chan, src|
        if( (vel > 0) and: { srcID.isNil or: { src == srcID } } ) {
            if(captured.size < 8) {
                captured.add(note);
                ("[LC learn] captured %".format(note)).postln;
                if(captured.size == 8) {
                    var arr = captured.asArray;
                    "~lcn btnNotes := %".format(arr).postln;
                    ~lcn[\config].put(\btnNotes, arr);
                    MIDIdef.free(key);
                    ~lcn[\clearRow].(); ~lcn[\refreshLEDs].();
                    "[LC learn] done, LEDs updated.".postln;
                };
            };
        };
    }, nil, nil, srcID);
    "[LC learn] Press your 8 bank buttons left→right…".postln;
};

// ---- Bind / Rebind ----
~lcnUnbind = {
    ~lcn[\defs].do { |k| MIDIdef.free(k) };
    ~lcn[\defs] = Array.new;
};

~lcnArm = {
    var srcID, chan0, r1, r2, notes, banks, strict;

    // locals first
    srcID  = ~lcn[\srcID];
    chan0  = ~lcn[\chan0];
    r1     = ~lcn[\config][\r1];
    r2     = ~lcn[\config][\r2];
    notes  = ~lcn[\config][\btnNotes];
    banks  = ~lcn[\config][\banks];
    strict = (~lcn[\config][\strictChan] == true);

    ~lcnUnbind.();

    // Prev / Next CCs
    MIDIdef.cc(\lcn_bank_prev, { |val, cc, chan, src|
        if(val >= 64) {
            ~lcn[\bankIdx] = ((~lcn[\bankIdx] - 1 + banks) % banks);
            ~lcn[\showBanner].(); ~lcn[\refreshLEDs].();
        };
    }, 116, nil, srcID);  ~lcn[\defs].add(\lcn_bank_prev);

    MIDIdef.cc(\lcn_bank_next, { |val, cc, chan, src|
        if(val >= 64) {
            ~lcn[\bankIdx] = ((~lcn[\bankIdx] + 1) % banks);
            ~lcn[\showBanner].(); ~lcn[\refreshLEDs].();
        };
    }, 117, nil, srcID);  ~lcn[\defs].add(\lcn_bank_next);

    // Bank buttons (note-on): filter by src only (channel-agnostic)
    MIDIdef.noteOn(\lcn_bank_btns, { |vel, note, chan, src|
        var idx = notes.indexOf(note);
        if((vel > 0)
            and: { (srcID.isNil or: { src == srcID }) }
            and: { idx.notNil }
            and: { idx < banks }) {
            ~lcn[\bankIdx] = idx;
            ~lcn[\showBanner].(); ~lcn[\refreshLEDs].();
        };
    }, nil, nil, srcID);  ~lcn[\defs].add(\lcn_bank_btns);

    // Row-1 knobs (source-filtered; optional strict channel)
    (0..7).do { |i|
        var key = ("lcn_r1_s"++(i+1)).asSymbol;
        MIDIdef.cc(key, { |val, cc, chan, src|
            if( (srcID.isNil or: { src == srcID })
                and: { (strict.not or: { chan == chan0 }) } ) {
                ~lcn[\dispatch].(~lcn[\bankIdx], i, 1, ~lcn[\to01].(val));
            };
        }, r1[i], nil, srcID);
        ~lcn[\defs].add(key);
    };

    // Row-2 knobs
    (0..7).do { |i|
        var key = ("lcn_r2_s"++(i+1)).asSymbol;
        MIDIdef.cc(key, { |val, cc, chan, src|
            if( (srcID.isNil or: { src == srcID })
                and: { (strict.not or: { chan == chan0 }) } ) {
                ~lcn[\dispatch].(~lcn[\bankIdx], i, 2, ~lcn[\to01].(val));
            };
        }, r2[i], nil, srcID);
        ~lcn[\defs].add(key);
    };

    // Initial sync
    ~lcn[\clearRow].();
    ~lcn[\showBanner].();
    ~lcn[\refreshLEDs].();
    "[LC] param router armed (banks=%  inChan=%  ledChan=%  srcID=% strict=%)"
        .format(banks, chan0, ~lcn[\config][\ledChan0], srcID, strict).postln;
};

// ---- Go on load ----
~lcnArm.();
)

