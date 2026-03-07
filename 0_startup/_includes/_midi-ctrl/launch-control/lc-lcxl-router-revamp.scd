// 2025-10-26 — Unified LC + LCXL Router (Bank Index + Panic Recovery)
(
var pickSrcIdx, pickDest, connectDevice;

// Helper to connect a specific device by name
connectDevice = { |devName|
    var idx = MIDIClient.sources.detectIndex { |ep| ep.device == devName and: { ep.name != "HUI" } };
    if(idx.notNil) {
        MIDIIn.connect(idx);
        ["[LC/LCXL] Connected (index " ++ idx ++ "):", MIDIClient.sources[idx].device].postln;
    };
    idx
};

// Re-arm on language recompile
CmdPeriod.add({
    // Refresh MIDIClient and reconnect specific devices
    MIDIClient.init;
    connectDevice.("Launch Control");
    connectDevice.("Launch Control XL");

    // Rebuild MIDIOuts — they go stale post-panic
    ~lcOut = { MIDIOut.newByName("Launch Control", "Launch Control") }.try;
    ~lcxlOut = { MIDIOut.newByName("Launch Control XL", "Launch Control XL") }.try;

    // Restore LED state (defer to let MIDIOut settle)
    {
        if (~lcn[\refreshLEDs].notNil) { ~lcn[\refreshLEDs].() };
        if (~lcxlParam[\refreshLEDs].notNil) { ~lcxlParam[\refreshLEDs].() };
    }.defer(0.2);
    "[LC/LCXL rearmed after CmdPeriod, incl MIDIOut rebuild]".postln;
});

// Helper functions for robust device discovery
pickSrcIdx = { |devName| MIDIClient.sources.detectIndex { |ep| ep.device == devName and: { ep.name != "HUI" } } };
pickDest = { |devName| MIDIClient.destinations.detect { |ep| ep.device == devName and: { ep.name != "HUI" } } };

// Initialize MIDI system and connect specific devices
MIDIClient.init;
connectDevice.("Launch Control");
connectDevice.("Launch Control XL");

~lcSrc   = pickSrcIdx.("Launch Control").notNil.if { MIDIClient.sources[pickSrcIdx.("Launch Control")] } { nil };
~lcxlSrc = pickSrcIdx.("Launch Control XL").notNil.if { MIDIClient.sources[pickSrcIdx.("Launch Control XL")] } { nil };
~lcOut   = { MIDIOut.newByName("Launch Control", "Launch Control") }.try;
~lcxlOut = { MIDIOut.newByName("Launch Control XL", "Launch Control XL") }.try;

~lcUID   = ~lcSrc.tryPerform(\uid);
~lcxlUID = ~lcxlSrc.tryPerform(\uid);

// --- Launch Control Router ---
~lcn = ~lcn ? ();  // param state
~lcn[\chan0] = 8;  // factory template 1 sends on channel 8
~lcn[\bankIdx] = 1;
~lcn[\noteMap] = [9,10,11,12,25,26,27,28];
~lcn[\palette] = (selected: 127, unselected: 10);

~lcn[\refreshLEDs] = {
    if(~lcOut.notNil) {
        ~lcn[\noteMap].do { |n, i|
            var val = ((i+1) == ~lcn[\bankIdx])
                .if { ~lcn[\palette][\selected] } { ~lcn[\palette][\unselected] };
            ~lcOut.noteOn(~lcn[\chan0], n, val);
        };
    };
};

MIDIdef.noteOff(\lcn_banks, { |vel, num, chan, src|
    var idx = ~lcn[\noteMap].indexOf(num);
    if (idx.notNil) {
        ~lcn[\bankIdx] = idx + 1;
        ~lcn[\refreshLEDs].();
    }
}, nil).permanent_(true);

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
}).permanent_(true);

// --- Launch Control XL Router ---
~lcxlParam = ~lcxlParam ? ();
~lcxlParam[\chan0] = nil;
~lcxlParam[\bankIdx] = 1;
~lcxlParam[\noteMap] = [73,74,75,76,89,90,91,92];
~lcxlParam[\palette] = (selected: 127, unselected: 10);

~lcxlParam[\refreshLEDs] = {
    if(~lcxlOut.notNil) {
        ~lcxlParam[\noteMap].do { |n, i|
            var val = ((i+1) == ~lcxlParam[\bankIdx])
                .if { ~lcxlParam[\palette][\selected] } { ~lcxlParam[\palette][\unselected] };
            ~lcxlOut.noteOn(0, n, val);
        };
    };
    if (~lcxlPdefRefresh.notNil) { ~lcxlPdefRefresh.(); };
};

MIDIdef.noteOn(\lcxl_banks, { |vel, num, chan, src|
    var idx = ~lcxlParam[\noteMap].indexOf(num);
    if (idx.notNil) {
        ~lcxlParam[\bankIdx] = idx + 1;
        ~lcxlParam[\refreshLEDs].();
    }
}, nil).permanent_(true);

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
}).permanent_(true);

// Pdef row handler (Track Focus)
~lcxlPdefMap = Dictionary.new;
~lcxlPdefPlaying = IdentitySet.new;
~lcxlPdefNotes = [41,42,43,44,57,58,59,60];

~lcxlPdefRefresh = {
    if(~lcxlOut.notNil) {
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
};

~lcxlBindPdef = { |key, patSym|
    ~lcxlPdefMap[key] = patSym;
    ~lcxlPdefRefresh.();
};

~lcxlPdefHandle = { |key, val|
    if (val > 0) {
        if (~lcxlPdefMap[key].isNil) {
            var idx = ~lcxlPdefNotes.indexOf(
                ~lcxlPdefNotes.detect { |note| true }
            );
            if (idx.notNil and: { ~lcxlOut.notNil }) { ~lcxlOut.noteOn(0, ~lcxlPdefNotes[idx], 0); };
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
};

// 2025-12-11 – pad triggers only from LCXL

MIDIdef.noteOn(\lcxl_pdef_triggers, { |vel, num, chan, src|
    if(src == ~lcxlUID and: { vel > 0 }) {
        var idx = ~lcxlPdefNotes.indexOf(num);
        if(idx.notNil) {
            var key = ("b" ++ ~lcxlParam[\bankIdx] ++ "_s" ++ (idx+1) ++ "_p").asSymbol;
            ~lcxlPdefHandle.(key, vel);
        };
    };
}, nil).permanent_(true);

// Initial LED refresh (defer to let MIDIOut settle)
{
    ~lcn[\refreshLEDs].();
    ~lcxlParam[\refreshLEDs].();
}.defer(0.2);

"[LC/LCXL routers armed]".postln;
)
