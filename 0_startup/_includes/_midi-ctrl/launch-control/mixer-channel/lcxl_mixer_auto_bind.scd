(
// =====================================================================
// Launch Control XL ↔ mixer auto-binder (dB faders, robust map lookups)
// Faders (77..84) → level via dB law; Row 3 (49..56) → pan
// =====================================================================

// ---------- clean re-eval ----------
(1..8).do { |i| MIDIdef.free(("lcxl_mix_f"   ++ i).asSymbol) };
(1..8).do { |i| MIDIdef.free(("lcxl_mix_pan" ++ i).asSymbol) };

// ---------- env ----------
~lcxlMix = ~lcxlMix ? ();
~lcxlMix[\cfg] = ~lcxlMix[\cfg] ? ();

// MIDI channel (your LCXL sends on 9 → 0-based 8)
~lcxlMix[\cfg].put(\chan1,    (~lcxlMix[\cfg][\chan1] ?? { 9 }));
~lcxlMix[\chan0] = (~lcxlMix[\cfg][\chan1] - 1).clip(0, 15);

// dB fader law
~lcxlMix[\cfg].put(\faderBottom_dB, (~lcxlMix[\cfg][\faderBottom_dB] ?? { -80 }));
~lcxlMix[\cfg].put(\faderTop_dB,    (~lcxlMix[\cfg][\faderTop_dB]    ?? { 12 }));   // set to 6 for +6 dB top

~lcxlMix[\to01] = { |v| v / 127.0 };
~lcxlMix[\ampFrom01] = { |x|
    var db = x.clip(0,1).linlin(0, 1, ~lcxlMix[\cfg][\faderBottom_dB], ~lcxlMix[\cfg][\faderTop_dB]);
    db.dbamp
};

// detect LCXL (not HUI)
~lcxlMix[\srcID] = ~lcxlMix[\srcID] ? {
    var s = MIDIClient.sources.detect { |d|
        d.device.asString.contains("Launch Control XL")
        and: { d.device.asString.contains("HUI").not }
    };
    if(s.notNil) { s.uid } { nil };
}.value;

// bank state: follow AB env if present, else local
~lcxlMix[\getBankIdx] = {
    var bi;
    if(~lcxlAB_BTN.notNil and: { ~lcxlAB_BTN[\bankIdx].notNil }) {
        bi = ~lcxlAB_BTN[\bankIdx];
    } {
        bi = (~lcxlMix[\bankIdx] ? 0);
        ~lcxlMix[\bankIdx] = bi;   // persist local state
    };
    bi.asInteger.clip(0, 3)   // 4 banks for LCXL mixer layer
};

// map per bank: 1=MASTER, others = trN or nil
~lcxlMix[\bankMaps] = (
    b0: [\master, 0,1,2,3,4,5,6],            // MASTER + tr1..tr7
    b1: [\master, 7,8, nil,nil,nil,nil,nil], // MASTER + tr8..tr9
    b2: [\master, nil,nil,nil,nil,nil,nil,nil],
    b3: [\master, nil,nil,nil,nil,nil,nil,nil]
);

// resolve current map safely (always returns Array[8])
~lcxlMix[\resolveMap] = {
    |bi|
    var key = ("b" ++ bi.asString).asSymbol;
    var m = ~lcxlMix[\bankMaps][key];
    if(m.isNil) { Array.fill(8, { nil }) } {
        // ensure length 8
        (m.size < 8).if({ m ++ Array.fill(8 - m.size, { nil }) }, { m.copy });
    }
};

// pretty print on arm
~lcxlMix[\showBank] = {
    var bi  = ~lcxlMix[\getBankIdx].value;
    var m   = ~lcxlMix[\resolveMap].(bi);
    var cols = (1..8).collect { |i|
        var t = m[i-1];
        if(t == \master) { "MASTER" } { if(t.isNil) { "--" } { "tr" ++ (t+1) } }
    };
    ("=== LCXL BANK % ===\n" ++ ("1:%  2:%  3:%  4:%  5:%  6:%  7:%  8:%\n"
        .format(bi, cols[0],cols[1],cols[2],cols[3],cols[4],cols[5],cols[6],cols[7]))).postln;
};

// ---------- MIDI bindings (wrapped so we can use 'var') ----------
{
    var srcID   = ~lcxlMix[\srcID];
    var chan0   = ~lcxlMix[\chan0];
    var faders  = (77..84);   // 8 faders
    var pansR3  = (49..56);   // row-3 encoders

    // FADERS → level (dB law)
    (0..7).do { |i|
        var defKey = ("lcxl_mix_f" ++ (i+1)).asSymbol;
        MIDIdef.cc(defKey, { |val, cc, chan, src|
            var bi   = ~lcxlMix[\getBankIdx].value;
            var map  = ~lcxlMix[\resolveMap].(bi);
            var dest = map[i];
            var amp  = ~lcxlMix[\ampFrom01].( ~lcxlMix[\to01].(val) );
            if(dest == \master) {
                ~m36_master.notNil.if({ ~m36_master.level_(amp) });
            }{
                if(dest.isInteger and: { ~m36_tracks.notNil and: { dest < ~m36_tracks.size } }) {
                    ~m36_tracks[dest].level_(amp);
                };
            };
        }, faders[i], chan0, srcID);
    };

    // ROW 3 → pan (-1..+1)
    (0..7).do { |i|
        var defKey = ("lcxl_mix_pan" ++ (i+1)).asSymbol;
        MIDIdef.cc(defKey, { |val, cc, chan, src|
            var bi   = ~lcxlMix[\getBankIdx].value;
            var map  = ~lcxlMix[\resolveMap].(bi);
            var dest = map[i];
            var x    = ~lcxlMix[\to01].(val);
            var pan  = x.linlin(0,1, -1, 1);
            if(dest.isInteger and: { ~m36_tracks.notNil and: { dest < ~m36_tracks.size } }) {
                ~m36_tracks[dest].pan_(pan);
            };
        }, pansR3[i], chan0, srcID);
    };
}.value;

// ---------- banner ----------
("[lcxl↔mixer] armed on chan % (0-based).".format(~lcxlMix[\chan0])).postln;
~lcxlMix[\showBank].();
)

