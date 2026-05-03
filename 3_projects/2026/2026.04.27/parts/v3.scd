(
~v3_cut = Pseg([3,  7,  3], [16,  16],  \exp, inf).asStream;
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\v3,
  Pn(
    Plazy({
      Pfindur(~v3_cut.next, 
        Pbindef(\v3_pb,
          \instrument,  Pseq([\v3], inf),  
          \scale,   Pn(Pdefn(\v3_scale), inf),
          \octave,  Pn(Pdefn(\v3_octs),  inf),
          \stretch, Pn(Pdefn(\v3_strs),  inf),
          \degree,  Pn(Pdefn(\v3_degs),  inf),
          \dur,     Pn(Pdefn(\v3_durs),  inf),
          \amp,     Pn(Pdefn(\v3_amps),  inf),
          \pan,     Pseg([0.5,  -0.5],  [4],  \sin, inf), 
          // \pan,  0, 
          \out,     Pn(Pdefn(\v3_out),   inf),
        ))
    }), 
  inf)
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\v3_out,  ~t3.inbus.index);
Pdefn(\v3_scale, Scale.dorian);

// BUFS — point at your sample folder
// ~sBufs = ~sTree[\myfolder].values[0..4];
// Pdefn(\v3_buf_0, Pseq(~sBufs, 1));
// Pdefn(\v3_bufs,  Pseq([Pn(Pdefn(\v3_buf_0, 4)], 1));

// OCTS
Pdefn(\v3_oct_0,  Pseq([4,  5,  6], 1));
Pdefn(\v3_octs,  Pseq([Pn(Pdefn(\v3_oct_0), 4)], 1));

// AMPS
Pdefn(\v3_amp_0, 0.1);
Pdefn(\v3_amps,  Pseq([Pn(Pdefn(\v3_amp_0), 4)], 1));

// DEGS — words
Pdefn(\v3_deg_0, Pslide([2, Pseq([7, 4]), Pseq([4, 2])], 1,  Prand([1,  2,  3,  2],  1),  Pseq([1, 2, 3])));
// Pdefn(\v3_deg_1, Pseq([0, 1, \, 3, \, 0], 1));
Pdefn(\v3_deg_1, ~deg.("-012-40"));
// sentences
Pdefn(\v3_degs_a, Pseq([Pn(Pdefn(\v3_deg_0), 4)], 1));   // root only
Pdefn(\v3_degs_b, Pseq([Pn(Pdefn(\v3_deg_1), 4)], 1));   // short walk
// story
Pdefn(\v3_degs,  Pseq([Pn(Pdefn(\v3_degs_b), 1), Pn(Rest(),  4)], 1));
// Pdefn(\v3_degs,  Pslide([
//   // Pn(Pdefn(\v1_degs), 1),  
//   Pn(Pdefn(\v3_degs_a), 3)
// ], 1, 2, 3));

// DURS — words
Pdefn(\v3_dur_0, 1/5);
Pdefn(\v3_dur_1, Pbjorklund2(5, 8, 1));
// sentences
Pdefn(\v3_durs_a, Pseq([Pn(Pdefn(\v3_dur_0), 4)], 1));   // straight
Pdefn(\v3_durs_b, Pseq([Pn(Pdefn(\v3_dur_1), 4)], 1));   // euclidean
// story
// Pdefn(\v3_durs,  Pseq([Pn(Pdefn(\v3_durs_b, 1)], 1));
Pdefn(\v3_durs,  Pseq([Pn(Pdefn(\v3_durs_b),  1)], 1));

// STRS
Pdefn(\v3_str_0, 4);
Pdefn(\v3_strs,  Pseq([Pn(Pdefn(\v1_strs), 4)], 1));
// Pdefn(\v3_strs,  Pseq([Pn(Pdefn(\v1_strs),  4)], 1));

// PHRASE VARIANT FUNCTIONS
// These get referenced in bindings.scd Bank 5 toggle bindings.
// Store in ~phrFns[pfx] so bindings.scd loop can find them.
~phrFns = ~phrFns ?? { () };
~phrFns[\v3] = (
    a: {
        Pbindef(\v3_pb,
            \dur,    Pseq([Pn(Pdefn(\v3_durs_b), 4)], inf),
            \degree, Pseq([Pn(Pdefn(\v3_degs_b), 4)], inf))
    },
    b: {  // reset to defaults
        Pbindef(\v3_pb,
            \dur,    Pseq([Pn(Pdefn(\v3_durs_a), 4)], inf),
            \degree, Pseq([Pn(Pdefn(\v3_degs_a), 4)], inf))
    },
);
)
