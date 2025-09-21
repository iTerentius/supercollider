
(
// ============================================================
// LCXL Top-rows Param Router (Row-1 & Row-2 only; bank-aware)
// - Coexists with your LCXL→Mixer binder (faders + row3 pan).
// - Row-1: CC 13..20   Row-2: CC 29..36   (adjust if your template differs)
// - Keys you can bind to (symbols):
//     • Physical-strip based:  \b0_s3_r1  (bank 0, strip 3, row 1)
//     • Track-relative alias: \b0_t1_r2   (bank 0, row 2 on the strip that is currently mapped to track 1)
// - Handlers receive a normalized 0..1 value.
// ============================================================

// --- state ---
~lcxlParam = ~lcxlParam ? ();
~lcxlParam[\r1]      = (13..20);   // Row-1 knob CCs
~lcxlParam[\r2]      = (29..36);   // Row-2 knob CCs
~lcxlParam[\defs]    = ~lcxlParam[\defs] ? Array.new;
~lcxlParam[\handlers]= ~lcxlParam[\handlers] ? IdentityDictionary.new;
~lcxlParam[\debug]   = false;

// Use binder's device+channel+bank if available, else sane defaults
~lcxlParam[\srcID]   = ( ~lcxlAB.notNil ).if({ ~lcxlAB[\srcID] }, { nil });  // nil = accept any src
~lcxlParam[\chan0]   = ( ~lcxlAB.notNil ).if({ ~lcxlAB[\chan0] }, { 8 });    // learned 9 → incoming 8
~lcxlParam[\bankIdx] = { ( ~lcxlAB.notNil ).if({ ~lcxlAB[\bankIdx] }, { 0 }) };

// --- helpers ---
~lcxlParam[\to01] = { |v| v / 127 };

// key builders
~lcxlParam[\keyFor] = { |bankIndex, strip1, row|
    ("b" ++ bankIndex ++ "_s" ++ strip1 ++ "_r" ++ row).asSymbol
};

~lcxlParam[\trackKeyFor] = { |bankIndex, strip0, row|
    var tgt, tag;
    tgt = ( ~lcxlAB.notNil ).if({ ~lcxlAB[\assignForBank].(bankIndex)[strip0] }, { \none });
    if(tgt == \none) { nil }{
        tag = (tgt == \master).if({ "master" }, { "t" ++ (tgt+1) }); // tracks are 1-based in tag
        ("b" ++ bankIndex ++ "_" ++ tag ++ "_r" ++ row).asSymbol
    }
};

// handler registry
~lcxlBindParam = { |key, func|  ~lcxlParam[\handlers][key] = func; };
~lcxlUnbindParam = { |key| ~lcxlParam[\handlers].removeAt(key) };

// dispatch to both physical-strip key and track-relative alias (if any)
~lcxlParam[\dispatch] = { |bankIndex, strip0, row, val01|
    var keyS, keyT, f;
    keyS = ~lcxlParam[\keyFor].(bankIndex, strip0+1, row);
    f = ~lcxlParam[\handlers][keyS];
    if(f.notNil) { f.(val01) };

    keyT = ~lcxlParam[\trackKeyFor].(bankIndex, strip0, row);
    if(keyT.notNil) {
        f = ~lcxlParam[\handlers][keyT];
        if(f.notNil) { f.(val01) };
    };

    if(~lcxlParam[\debug]) {
        var label = keyT ? keyS;
        ("[param] " ++ label.asString ++ " -> " ++ val01.round(0.001)).postln;
    };
};

// clean + arm
~lcxlParam[\unbindAll] = {
    ~lcxlParam[\defs].do { |k| MIDIdef.free(k) };
    ~lcxlParam[\defs] = Array.new;
};

~lcxlParam[\arm] = {
    var srcID, chan0, getBank;
    srcID   = ~lcxlParam[\srcID];
    chan0   = ~lcxlParam[\chan0];
    getBank = ~lcxlParam[\bankIdx];

    ~lcxlParam[\unbindAll].();

    (0..7).do { |i|  // 8 strips
        var name1, name2;
        name1 = ("lcxl_param_r1_s" ++ (i+1)).asSymbol;
        name2 = ("lcxl_param_r2_s" ++ (i+1)).asSymbol;

        // Row-1
        MIDIdef.cc(name1, { |val, cc, chan, src|
            var b = getBank.();
            if(chan == chan0) { ~lcxlParam[\dispatch].(b, i, 1, ~lcxlParam[\to01].(val)) };
        }, ~lcxlParam[\r1][i], chan0, srcID);
        ~lcxlParam[\defs].add(name1);

        // Row-2
        MIDIdef.cc(name2, { |val, cc, chan, src|
            var b = getBank.();
            if(chan == chan0) { ~lcxlParam[\dispatch].(b, i, 2, ~lcxlParam[\to01].(val)) };
        }, ~lcxlParam[\r2][i], chan0, srcID);
        ~lcxlParam[\defs].add(name2);
    };

    "[lcxl param router] armed (rows 1 & 2)".postln;
};

~lcxlParam[\arm].();
)
