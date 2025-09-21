
(
// =====================================================================
// Launch Control XL → MixerChannel binder (levels + pan, banked)
//   - Bank 0 strip 1 = master, then tracks 1..7; remaining tracks spill
//     over to next banks of 8 physical strips.
//   - Faders 77..84  => level  (0..1)
//   - Row-3  49..56  => pan    (-1..1)
//   - Bank prev/next: CC106 / CC107, with banner + strip assignments
//   - Filters to "Launch Control XL (Launch Control XL)" (non-HUI)
//   - Assumes: ~m36_master (level_), ~m36_tracks[i] (level_), optionally pan_
//     If pan_ is missing, we try .set(\pan, x). If still missing, we skip.
// =====================================================================

// ---------- free old defs ----------
MIDIdef.free(\lcxl_bank_prev);
MIDIdef.free(\lcxl_bank_next);
(0..7).do { |i|
    MIDIdef.free(("lcxl_fader_" ++ (i+1)).asSymbol);
    MIDIdef.free(("lcxl_r3_"    ++ (i+1)).asSymbol);
};

// ---------- locate Launch Control XL (prefer non-HUI) ----------
~lcxlAB = ~lcxlAB ? ();
~lcxlAB[\srcID] = {
    var primary, fallback, src;
    primary  = MIDIClient.sources.detect({ |s|
        s.device.asString.contains("Launch Control XL")
        and: { s.name.asString.contains("(Launch Control XL)") } // non-HUI
    });
    fallback = MIDIClient.sources.detect({ |s|
        s.device.asString.contains("Launch Control XL")
        or:    { s.name.asString.contains("Launch Control XL") }
    });
    src = primary ?? { fallback };
    if(src.notNil) { src.uid } { nil }
}.value;

if(~lcxlAB[\srcID].isNil) {
    "⚠️ LCXL source not found; bindings will accept any source (not filtered).".postln;
};

// ---------- config ----------
~lcxlAB[\chan1]   = 9;          // learned 1-based channel (LCXL template)
~lcxlAB[\chan0]   = ~lcxlAB[\chan1] - 1;  // SC is 0-based
~lcxlAB[\ccF]     = (77..84);   // 8 faders
~lcxlAB[\ccR3]    = (49..56);   // row-3 knobs
~lcxlAB[\bankIdx] = 0;          // start at bank 0
~lcxlAB[\defs]    = Array.new;

// ---------- helpers ----------
~lcxlAB[\to01]  = { |v| v / 127 };
~lcxlAB[\toPan] = { |v| (v / 127) * 2 - 1 };

// Resolve mixer object + call setter(s)
~lcxlAB[\setLevel] = { |target, x|
    var obj;
    switch(target,
        \master, { obj = ~m36_master; },
        { // else track index (0-based)
            if(target.isInteger) {
                obj = (~m36_tracks.notNil and: { target < ~m36_tracks.size })
                    .if({ ~m36_tracks[target] }, { nil });
            };
        }
    );
    if(obj.notNil) {
        if(obj.respondsTo(\level_)) { obj.level_(x) }
        { if(obj.respondsTo(\set)) { obj.set(\level, x) }
          { ("[warn] level setter missing for %".format(target)).postln } };
    }{
        ("[warn] target missing: %".format(target)).postln;
    };
};

~lcxlAB[\setPan] = { |target, p|
    var obj;
    switch(target,
        \master, { obj = ~m36_master; },   // master pan applied only if supported
        { if(target.isInteger) {
            obj = (~m36_tracks.notNil and: { target < ~m36_tracks.size })
                .if({ ~m36_tracks[target] }, { nil });
        } }
    );
    if(obj.notNil) {
        if(obj.respondsTo(\pan_)) { obj.pan_(p) }
        { if(obj.respondsTo(\set)) { obj.set(\pan, p) }
          { /* silently ignore if no pan */ } };
    };
};

// Build flat control list: [\master, 0, 1, 2, ... tracks]
~lcxlAB[\targets] = {
    var list = [\master];
    if(~m36_tracks.notNil) {
        list = list ++ (0..(~m36_tracks.size-1));
    };
    list
};

// How many banks are needed (ceil(len/8))
~lcxlAB[\bankCount] = {
    var n = ~lcxlAB[\targets].().size;
    (((n + 7) / 8).ceil).asInteger
};

// For a bank index, return 8-element array of assignments (\master | Int | \none)
~lcxlAB[\assignForBank] = { |b|
    var src = ~lcxlAB[\targets].();
    var out = Array.fill(8, { \none });
    8.do { |i|
        var idx = (b * 8) + i;
        if(idx < src.size) { out[i] = src[idx] };
    };
    out
};

// Pretty label for banner
~lcxlAB[\label] = { |t|
    if(t == \master) { "MASTER" } { "tr" ++ (t+1) } // t is 0-based track
};

// Banner & per-strip map
~lcxlAB[\showBanner] = {
    var b = ~lcxlAB[\bankIdx];
    var map = ~lcxlAB[\assignForBank].(b);
    var line = map.collect({ |t, i|
        var lab = (t == \none).if({ "--" }, { ~lcxlAB[\label].(t) });
        (i+1).asString ++ ":" ++ lab
    }).join("  ");
    ("\n=== LCXL BANK % ===\n% \n".format(b, line)).postln;
};

// ---------- (re)bind ----------
~lcxlAB[\unbind] = {
    ~lcxlAB[\defs].do { |k| MIDIdef.free(k) };
    ~lcxlAB[\defs] = Array.new;
};

~lcxlAB[\bind] = {
    var srcID = ~lcxlAB[\srcID], chan0 = ~lcxlAB[\chan0];

    ~lcxlAB[\unbind].();

    // bank prev (CC106) / next (CC107)
    MIDIdef.cc(\lcxl_bank_prev, { |val, cc, chan, src|
        if(val >= 64) {
            var count = ~lcxlAB[\bankCount].();
            ~lcxlAB[\bankIdx] = ((~lcxlAB[\bankIdx] - 1) % count);
            ~lcxlAB[\showBanner].();
        };
    }, 106, nil, srcID);  ~lcxlAB[\defs].add(\lcxl_bank_prev);

    MIDIdef.cc(\lcxl_bank_next, { |val, cc, chan, src|
        if(val >= 64) {
            var count = ~lcxlAB[\bankCount].();
            ~lcxlAB[\bankIdx] = ((~lcxlAB[\bankIdx] + 1) % count);
            ~lcxlAB[\showBanner].();
        };
    }, 107, nil, srcID);  ~lcxlAB[\defs].add(\lcxl_bank_next);

    // one def per strip for fader & row-3; we look up the active bank at runtime
    (0..7).do { |i|
        var keyF = ("lcxl_fader_" ++ (i+1)).asSymbol;
        var keyK = ("lcxl_r3_"    ++ (i+1)).asSymbol;

        MIDIdef.cc(keyF, { |val, cc, chan, src|
            var tgt = ~lcxlAB[\assignForBank].(~lcxlAB[\bankIdx])[i];
            if(chan == chan0 and: { tgt != \none }) {
                ~lcxlAB[\setLevel].(tgt, ~lcxlAB[\to01].(val));
            };
        }, ~lcxlAB[\ccF][i], chan0, srcID);
        ~lcxlAB[\defs].add(keyF);

        MIDIdef.cc(keyK, { |val, cc, chan, src|
            var tgt = ~lcxlAB[\assignForBank].(~lcxlAB[\bankIdx])[i];
            if(chan == chan0 and: { tgt != \none }) {
                ~lcxlAB[\setPan].(tgt, ~lcxlAB[\toPan].(val));
            };
        }, ~lcxlAB[\ccR3][i], chan0, srcID);
        ~lcxlAB[\defs].add(keyK);
    };

    "[lcxl↔mixer] armed on chan % (0-based).".format(chan0).postln;
    ~lcxlAB[\showBanner].();
};

// ---------- go ----------
~lcxlAB[\bind].();
)
