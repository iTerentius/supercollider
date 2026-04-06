// _voice.scd — copy this file for each new voice, rename it.
// The ONLY lines to change are pfx and trk at the top.
// Everything else constructs correct symbol names automatically.
// Pdef(\v1_808k).play;
// Pdef(\v1_808k).stop;
(
var pfx = \v1_808hh;    // ← change to your voice name (must match \n in slots.scd)
var trk = ~t1;    // ← change to your mixer track
var mk  = { |s| (pfx.asString ++ s).asSymbol };
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(pfx,
  Pbindef(mk.("_pb"),
      \instrument, \hh808,    
      \scale,   Pn(Pdefn(mk.("_scale")), inf),
      \octave,  Pn(Pdefn(mk.("_octs")),  inf),
      \root,    1,  
      \stretch, Pn(Pdefn(mk.("_strs")),  inf),
      \degree,  Pn(Pdefn(mk.("_degs")),  inf),
      \dur,     Pn(Pdefn(mk.("_durs")),  inf),
      \amp,     Pn(Pdefn(mk.("_amps")),  inf),
      \out,     Pn(Pdefn(mk.("_out")),   inf),
      \rel,     Pn(Pdefn(mk.("_rel")),   inf),  
));

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(mk.("_out"),   trk.inbus.index);
Pdefn(mk.("_scale"), Scale.minor);

// BUFS — point at your sample folder
// ~sBufs = ~sTree[\myfolder].values[0..4];
// Pdefn(mk.("_buf_0"), Pseq(~sBufs, 1));
// Pdefn(mk.("_bufs"),  Pseq([Pn(Pdefn(mk.("_buf_0")), 4)], 1));

// OCTS
Pdefn(mk.("_oct_0"), 9);
Pdefn(mk.("_octs"),  Pseq([Pn(Pdefn(mk.("_oct_0")), 4)], 1));

// AMPS
Pdefn(mk.("_amp_0"), 0.8);
Pdefn(mk.("_amp_1"), Pseq([0.2!3, 0.6].flat, 4));
Pdefn(mk.("_amps"),  Pseq([Pn(Pdefn(mk.("_amp_0")), 4)], 1));

// DEGS — words
Pdefn(mk.("_deg_0"), 3);
Pdefn(mk.("_deg_1"), Pseq([\, 0], 1));
Pdefn(mk.("_deg_2"), Pseq([0, 1, \, 3, \, 0], 1));
// sentences
Pdefn(mk.("_degs_a"), Pseq([Pn(Pdefn(mk.("_deg_0")), 4)], 1));   // root only
Pdefn(mk.("_degs_b"), Pseq([Pn(Pdefn(mk.("_deg_3")), 4)], 1));   // short walk
// story
Pdefn(mk.("_degs"),  Pseq([Pn(Pdefn(mk.("_degs_b")), 1)], 1));

// DURS — words
// Pdefn(mk.("_dur_0"), 1);
Pdefn(mk.("_dur_0"), Pseq([1/2],  1));
Pdefn(mk.("_dur_1"), Pbjorklund2(7, 8, 1) / 4);
Pdefn(mk.("_dur_2"), Pseq([1/3],  1));
// sentences
Pdefn(mk.("_durs_a"), Pseq([Pn(Pdefn(mk.("_dur_0")),  4)], 1));   // straight
Pdefn(mk.("_durs_b"), Pseq([Pn(Pdefn(mk.("_dur_1")),  4)], 1));   // straight
Pdefn(mk.("_durs_c"), Pseq([Pn(Pdefn(mk.("_dur_2")), 4)], 1));   // euclidean
// story
Pdefn(mk.("_durs"),  Pseq([Pn(Pdefn(mk.("_durs_a")), 1)], 1));

// STRS
Pdefn(mk.("_str_0"), 1);
Pdefn(mk.("_strs"),  Pseq([Pn(Pdefn(mk.("_str_0")), 4)], 1));

Pdefn(mk.("_rel_0"),  Pseq([1/22!3, 1/16].flat, 4));
Pdefn(mk.("_rel"),  Pseq([Pn(Pdefn(mk.("_rel_0")),  4)],  1));

// PHRASE VARIANT FUNCTIONS
// These get referenced in bindings.scd Bank 5 toggle bindings.
// Store in ~phrFns[pfx] so bindings.scd loop can find them.
~phrFns = ~phrFns ?? { () };
~phrFns[pfx] = (
    a: {
        Pbindef(mk.("_pb"),
            \dur,    Pseq([Pn(Pdefn(mk.("_durs_b")), 4)], inf),
            \degree, Pseq([Pn(Pdefn(mk.("_degs_b")), 4)], inf)
        )
    },
    b: {  // reset to defaults
        Pbindef(mk.("_pb"),
            \dur,    Pseq([Pn(Pdefn(mk.("_durs_a")), 4)], inf),
            \degree, Pseq([Pn(Pdefn(mk.("_degs_a")), 4)], inf))
    },
    c: {  // reset to defaults
        Pbindef(mk.("_pb"),
            \dur,    Pseq([Pn(Pdefn(mk.("_durs_c")), 4)], inf),
            \degree, Pseq([Pn(Pdefn(mk.("_degs_b")), 4)], inf))
    }
);
)
