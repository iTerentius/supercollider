// 2025-10-26 — Unified LC + LCXL Router (Bank Index + Panic Recovery)
(
var pickSrc, pickDest;
// Re-arm on language recompile
CmdPeriod.add({
    // Refresh MIDIClient and reconnect
    MIDIClient.init;
    MIDIIn.connectAll;

    // Rebuild MIDIOuts — they go stale post-panic
    ~lcOut = MIDIOut.newByName("Launch Control", "Launch Control");
    ~lcxlOut = MIDIOut.newByName("Launch Control XL", "Launch Control XL");

    // Reinstall MIDIdefs
    MIDIdef.noteOn(\lcn_banks).permanent_(true);
    MIDIdef.cc(\lcn_cc).permanent_(true);
    MIDIdef.noteOn(\lcxl_banks).permanent_(true);
    MIDIdef.cc(\lcxl_cc).permanent_(true);
    MIDIdef.noteOn(\lcxl_pdef_triggers).permanent_(true);

    // Restore LED state
    if (~lcn[\refreshLEDs].notNil) {
        ~lcn[\refreshLEDs].();
    };
    if (~lcxlParam[\refreshLEDs].notNil) {
        ~lcxlParam[\refreshLEDs].();
    };
    "[LC/LCXL rearmed after CmdPeriod, incl MIDIOut rebuild]".postln;
});

// Helper functions for robust device discovery
pickSrc = { |devName| MIDIClient.sources.detect { |ep| ep.device == devName and: { ep.name != "HUI" } } };
pickDest = { |devName| MIDIClient.destinations.detect { |ep| ep.device == devName and: { ep.name != "HUI" } } };

// Initialize MIDI system and resolve endpoints
MIDIClient.init;
MIDIIn.connectAll;

~lcSrc   = pickSrc.("Launch Control");
~lcxlSrc = pickSrc.("Launch Control XL");
~lcOut   = MIDIOut.newByName("Launch Control", "Launch Control");
~lcxlOut = MIDIOut.newByName("Launch Control XL", "Launch Control XL");

~lcUID   = ~lcSrc.tryPerform(\uid);
~lcxlUID = ~lcxlSrc.tryPerform(\uid);

// --- Launch Control Router ---
~lcn = ~lcn ? ();  // param state
~lcn[\chan0] = nil;  // nil disables channel filter
~lcn[\bankIdx] = 1;
~lcn[\noteMap] = [9,10,11,12,25,26,27,28];
~lcn[\palette] = (selected: 127, unselected: 10);

~lcn[\refreshLEDs] = {
    ~lcn[\noteMap].do { |n, i|
        var val = ((i+1) == ~lcn[\bankIdx])
            .if { ~lcn[\palette][\selected] } { ~lcn[\palette][\unselected] };
        ~lcOut.noteOn(0, n, val);
    };
};

MIDIdef.noteOn(\lcn_banks, { |vel, num, chan, src|
    var idx = ~lcn[\noteMap].indexOf(num);
    if (idx.notNil) {
        ~lcn[\bankIdx] = idx + 1;
        ~lcn[\refreshLEDs].();
    }
}, nil);

MIDIdef.cc(\lcn_cc, { |val, num, chan, src|
    var r1 = (21..28).asArray, r2 = (41..48).asArray;
    var strip, key;
    if (r1.includes(num)) {
        strip = r1.indexOf(num);
        key = ("b" ++ ~lcn[\bankIdx] ++ "_s" ++ (strip+1) ++ "_r1").asSymbol;
    } {
        if (r2.includes(num)) {
            strip = r2.indexOf(num);
            key = ("b" ++ ~lcn[\bankIdx] ++ "_s" ++ (strip+1) ++ "_r2").asSymbol;
        };
    };
    if (key.notNil and: { ~lcn[key].notNil }) { ~lcn[key].(val) };
});

// --- Launch Control XL Router ---
~lcxlParam = ~lcxlParam ? ();
~lcxlParam[\chan0] = nil;
~lcxlParam[\bankIdx] = 1;
~lcxlParam[\noteMap] = [73,74,75,76,89,90,91,92];
~lcxlParam[\palette] = (selected: 127, unselected: 10);

~lcxlParam[\refreshLEDs] = {
    ~lcxlParam[\noteMap].do { |n, i|
        var val = ((i+1) == ~lcxlParam[\bankIdx])
            .if { ~lcxlParam[\palette][\selected] } { ~lcxlParam[\palette][\unselected] };
        ~lcxlOut.noteOn(0, n, val);
    };
    if (~lcxlPdefRefresh.notNil) { ~lcxlPdefRefresh.(); };
};

MIDIdef.noteOn(\lcxl_banks, { |vel, num, chan, src|
    var idx = ~lcxlParam[\noteMap].indexOf(num);
    if (idx.notNil) {
        ~lcxlParam[\bankIdx] = idx + 1;
        ~lcxlParam[\refreshLEDs].();
    }
}, nil);

~lcxlParam[\makeKey] = { |strip, row|
    ("b" ++ ~lcxlParam[\bankIdx] ++ "_s" ++ strip ++ "_" ++ row).asSymbol;
};

MIDIdef.cc(\lcxl_cc, { |val, num, chan, src|
    var map = (
        r1: (13..20).asArray,
        r2: (29..36).asArray,
        r3: (49..56).asArray,
        f:  (77..84).asArray
    );
    map.keysValuesDo { |row, range|
        if (range.includes(num)) {
            var idx = range.indexOf(num) + 1;
            var key = ~lcxlParam[\makeKey].(idx, row);
            if (~lcxlParam[key].notNil) {
                ~lcxlParam[key].(val);
            };
        };
    };
});

// Pdef row handler (Track Focus)
~lcxlPdefMap = Dictionary.new;
~lcxlPdefPlaying = IdentitySet.new;
~lcxlPdefNotes = [41,42,43,44,57,58,59,60];

~lcxlPdefRefresh = {
    var bank = ~lcxlParam[\bankIdx];
    ~lcxlPdefNotes.do { |note, i|
        var sym = ("b" ++ bank ++ "_s" ++ (i+1) ++ "_p").asSymbol;
        var state =
            (~lcxlPdefPlaying.includes(sym)).if { 60 } {
                (~lcxlPdefMap.includesKey(sym)).if { 21 } { 0 }
            };
        ~lcxlOut.noteOn(0, note, state);
    };
};

~lcxlBindPdef = { |key, patSym|
    ~lcxlPdefMap[key] = patSym;
    ~lcxlPdefRefresh.();
};

~lcxlPdefHandle = { |key, val|
    if (~lcxlPdefMap[key].isNil) {
        var idx = ~lcxlPdefNotes.indexOf(~lcxlPdefNotes.detect { |n| key.asString.includes("s" ++ (key.asString.split("_s")[1]?.split("_")[0] ?? "1")) });
        if (idx.notNil) { ~lcxlOut.noteOn(0, ~lcxlPdefNotes[idx], 0); };
        "No pattern assigned".postln;
    } {
        var p = ~lcxlPdefMap[key];
        if (~lcxlPdefPlaying.includes(key)) {
            Pdef(p).stop;
            ~lcxlPdefPlaying.remove(key);
        } {
            Pdef(p).play;
            ~lcxlPdefPlaying.add(key);
        };
        ~lcxlPdefRefresh.();
    };
};

MIDIdef.noteOn(\lcxl_pdef_triggers, { |vel, num, chan, src|
    var idx = ~lcxlPdefNotes.indexOf(num);
    if (idx.notNil) {
        var key = ("b" ++ ~lcxlParam[\bankIdx] ++ "_s" ++ (idx+1) ++ "_p").asSymbol;
        ~lcxlPdefHandle.(key, vel);
    }
}, nil);

"[LC/LCXL routers armed]".postln;
)
