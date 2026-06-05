(
var cut = Pseq([3,  5 ], inf).asStream;
// var cut = Pseg([2,  9,  2], [4,  4],  \exp, inf).asStream;
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\v1,
  // Pn(Plazy({
    // Pfindur(cut.next,  
    Pbindef(\v1_pb,
      \instrument,  \kik808,
      \scale,   Pn(Pdefn(\v1_scale), inf),
      \octave,  Pn(Pdefn(\v1_octs),  inf),
      \stretch, Pn(Pdefn(\v1_strs),  inf),
      \degree,  Pn(Pdefn(\v1_degs),  inf),
      \dur,     Pn(Pdefn(\v1_durs),  inf),
      \amp,     Pn(Pdefn(\v1_amps),  inf),
      \dist,    0.8,  
      \pitchMod,  0.8,  
      \clickAmp,  0.5,  
      \rel, Pseg([0.2,  1.0,  0.2], [3],  \exp, inf),  
      \pitchRel,  Pstep(Pseq([0.5,  2],  inf), 3),    
      \out,     Pn(Pdefn(\v1_out),   inf),
    )
// )
  // })
  // , inf)
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\v1_out,   ~pbd2.inbus.index);
Pdefn(\v1_scale, Scale.major);

// BUFS — point at your sample folder
// ~sBufs = ~sTree[\myfolder].values[0..4];
// Pdefn(\v1_buf_0), Pseq(~sBufs, 1));
// Pdefn(\v1_bufs),  Pseq([Pn(Pdefn(\v1_buf_0)), 4)], 1));

// OCTS
Pdefn(\v1_oct_0, Pseq([2, 3 ].flat, 1));
Pdefn(\v1_octs,  Pseq([Pn(Pdefn(\v1_oct_0), 4)], 1));

// AMPS
Pdefn(\v1_amp_0, 0.67);
Pdefn(\v1_amps,  Pseq([Pn(Pdefn(\v1_amp_0), 4)], 1));

// DEGS — words
Pdefn(\v1_deg_0, Place([0, [2, 1]], 1));
Pdefn(\v1_deg_1, ~deg.("0-1-212-1", 1,  Pkey(\stretch)));
Pdefn(\v1_deg_2, ~deg.("01210-1", 1, Pkey(\stretch)));
// sentences
Pdefn(\v1_degs_a, Pseq([Pn(Pdefn(\v1_deg_0), 4)], 1));   // root only
Pdefn(\v1_degs_b, Pseq([Pn(Pdefn(\v1_deg_1), 4)], 1));   // short walk
Pdefn(\v1_degs_c, Pseq([Pn(Pdefn(\v1_deg_2), 4)], 1));   // short walk
// story
Pdefn(\v1_degs,  Pseq([Pn(Pdefn(\v1_degs_a), 1)], 1));

// DURS — words
Pdefn(\v1_dur_0, 1/3);
Pdefn(\v1_dur_1, Pbjorklund2(5, 8, 1) / 2);
// sentences
Pdefn(\v1_durs_a, Pseq([Pn(Pdefn(\v1_dur_0), 4)], 1));   // straight
Pdefn(\v1_durs_b, Pseq([Pn(Pdefn(\v1_dur_1), 4)], 1));   // euclidean
// story
Pdefn(\v1_durs,  Pseq([Pn(Pdefn(\v1_durs_b), 1)], 1));

// STRS
Pdefn(\v1_str_0, Pseg([1, 1/2,  1], [3, 7], \sin,  1));
Pdefn(\v1_strs,  Pseq([Pn(Pdefn(\v1_str_0), 4)], 1));

// PHRASE VARIANT FUNCTIONS
// These get referenced in bindings.scd Bank 5 toggle bindings.
// Store in ~phrFns[pfx] so bindings.scd loop can find them.
~phrFns = ~phrFns ?? { () };
~phrFns[\v1] = (
    a: {
        Pbindef(\v1_pb,
            \dur,    Pseq([Pn(Pdefn(\v1_durs_b), 4)], inf),
            \degree, Pseq([Pn(Pdefn(\v1_degs_b), 4)], inf))
    },
    b: {  // reset to defaults
        Pbindef(\v1_pb,
            \dur,    Pseq([Pn(Pdefn(\v1_durs_a), 4)], inf),
            \degree, Pseq([Pn(Pdefn(\v1_degs_a), 4)], inf))
    },
  );
)
