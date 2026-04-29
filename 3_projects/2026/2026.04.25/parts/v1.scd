// _voice.scd — copy this file for each new voice, rename it.
// The ONLY lines to change are pfx and trk at the top.
// Everything else constructs correct symbol names automatically.
(
var pfx = \v1;    // ← change to your voice name (must match \n in slots.scd)
var trk = ~t1;    // ← change to your mixer track
var mk  = { |s| (pfx.asString ++ s).asSymbol };
var cut = Pgeom(3, 2,  15).asStream;
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(pfx,
  Pn(Plazy({
    Pfindur(cut.next,  
    Pbindef(mk.("_pb"),
    \instrument,  \kik808,
    \scale,   Pn(Pdefn(mk.("_scale")), inf),
    \octave,  Pn(Pdefn(mk.("_octs")),  inf),
    \stretch, Pn(Pdefn(mk.("_strs")),  inf),
    \degree,  Pn(Pdefn(mk.("_degs")),  inf),
    \dur,     Pn(Pdefn(mk.("_durs")),  inf),
    \amp,     Pn(Pdefn(mk.("_amps")),  inf),
    \dist,    Pwhite(0.2, 1.0,  inf),
    \pitchMod,  0.1,  
    \clickAmp,  0.4,  
    \rel, Pseg([0.4,  1.0], [4],  \lin, inf),  
    \pitchRel,  Pwhite(0.01,  2,  inf),  
    \out,     Pn(Pdefn(mk.("_out")),   inf),
  ))
  }), inf)
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(mk.("_out"),   trk.inbus.index);
Pdefn(mk.("_scale"), Scale.major);

// BUFS — point at your sample folder
// ~sBufs = ~sTree[\myfolder].values[0..4];
// Pdefn(mk.("_buf_0"), Pseq(~sBufs, 1));
// Pdefn(mk.("_bufs"),  Pseq([Pn(Pdefn(mk.("_buf_0")), 4)], 1));

// OCTS
Pdefn(mk.("_oct_0"), Pseq([2!6, 3,  ].flat, 1));
Pdefn(mk.("_octs"),  Pseq([Pn(Pdefn(mk.("_oct_0")), 4)], 1));

// AMPS
Pdefn(mk.("_amp_0"), 0.67);
Pdefn(mk.("_amps"),  Pseq([Pn(Pdefn(mk.("_amp_0")), 4)], 1));

// DEGS — words
Pdefn(mk.("_deg_0"), Place([0, [2, 4]], 1));
Pdefn(mk.("_deg_1"), ~deg.("0-1-212-1", 1,  1/8));
Pdefn(mk.("_deg_2"), ~deg.("0-1--01--", 1,  1/8));
// sentences
Pdefn(mk.("_degs_a"), Pseq([Pn(Pdefn(mk.("_deg_0")), 4)], 1));   // root only
Pdefn(mk.("_degs_b"), Pseq([Pn(Pdefn(mk.("_deg_1")), 4)], 1));   // short walk
// story
Pdefn(mk.("_degs"),  Pseq([Pn(Pdefn(mk.("_degs_b")), 1)], 1));

// DURS — words
Pdefn(mk.("_dur_0"), 1);
Pdefn(mk.("_dur_1"), Pbjorklund2(7, 8, 1) / 2);
// sentences
Pdefn(mk.("_durs_a"), Pseq([Pn(Pdefn(mk.("_dur_0")), 4)], 1));   // straight
Pdefn(mk.("_durs_b"), Pseq([Pn(Pdefn(mk.("_dur_1")), 4)], 1));   // euclidean
// story
Pdefn(mk.("_durs"),  Pseq([Pn(Pdefn(mk.("_durs_b")), 1),  Pn(Rest(),  4)], 1));

// STRS
Pdefn(mk.("_str_0"), Pstep(Pseq([1, 1/2], 1), 8));
Pdefn(mk.("_strs"),  Pseq([Pn(Pdefn(mk.("_str_0")), 4)], 1));

// PHRASE VARIANT FUNCTIONS
// These get referenced in bindings.scd Bank 5 toggle bindings.
// Store in ~phrFns[pfx] so bindings.scd loop can find them.
~phrFns = ~phrFns ?? { () };
~phrFns[pfx] = (
    a: {
        Pbindef(mk.("_pb"),
            \dur,    Pseq([Pn(Pdefn(mk.("_durs_b")), 4)], inf),
            \degree, Pseq([Pn(Pdefn(mk.("_degs_b")), 4)], inf))
    },
    b: {  // reset to defaults
        Pbindef(mk.("_pb"),
            \dur,    Pseq([Pn(Pdefn(mk.("_durs_a")), 4)], inf),
            \degree, Pseq([Pn(Pdefn(mk.("_degs_a")), 4)], inf))
    },
);
)
