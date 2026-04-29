
// _voice.scd — copy this file for each new voice, rename it.
// The ONLY lines to change are pfx and trk at the top.
// Everything else constructs correct symbol names automatically.
(
var cut = Pseq([7], inf).asStream;
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\v2,
  Pn(Plazy({
    Pfindur(cut.next,  
    Pbindef(\v2_pb,
    \instrument,  Pstep(Pseq([\hh808,\t1002], inf),  1), 
    \scale,   Pn(Pdefn(\v2_scale), inf),
    \octave,  Pn(Pdefn(\v2_octs),  inf),
    \stretch, Pn(Pdefn(\v2_strs),  inf),
    \degree,  Pn(Pdefn(\v2_degs),  inf),
    \legato,  0.005, 
    \dur,     Pn(Pdefn(\v2_durs),  inf),
    \amp,     Pn(Pdefn(\v2_amps),  inf),
    \out,     Pn(Pdefn(\v2_out),   inf),
    \rel,     Pn(Pdefn(\v2_rel),   inf),
  ))
  }), inf)
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\v2_out,   ~t2.inbus.index);
Pdefn(\v2_scale, Scale.major);

// BUFS — point at your sample folder
// ~sBufs = ~sTree[\myfolder].values[0..4];
// Pdefn(\v2_buf_0, Pseq(~sBufs, 1));
// Pdefn(\v2_bufs,  Pseq([Pn(Pdefn(\v2_buf_0), 4)], 1));

// OCTS
// Pdefn(\v2_oct_0, Pseq((9..10),  1));
Pdefn(\v2_oct_0, Pstep(Pseq([10,  5], 1), 3));
Pdefn(\v2_octs,  Pseq([Pn(Pdefn(\v2_oct_0), 4)], 1));

// AMPS
Pdefn(\v2_amp_0, Pstep(Pseq([0.3, 0.1], inf), 3));
Pdefn(\v2_amps,  Pseq([Pn(Pdefn(\v2_amp_0), 4)], 1));

// DEGS — words
Pdefn(\v2_deg_0, Place([0, [2, 7, 1]], 1));
Pdefn(\v2_deg_1, ~deg.("-047", 1));
// sentences
Pdefn(\v2_degs_a, Pseq([Pn(Pdefn(\v2_deg_0), 4)], 1));   // root only
Pdefn(\v2_degs_b, Pseq([Pn(Pdefn(\v2_deg_1), 4)], 1));   // short walk
// story
Pdefn(\v2_degs,  Pseq([Pn(Pdefn(\v2_degs_a), 1)], 1));

// DURS — words
Pdefn(\v2_dur_0, 1);
Pdefn(\v2_dur_1, Pbjorklund(7, 8, 1) );
// sentences
Pdefn(\v2_durs_a, Pseq([Pn(Pdefn(\v2_dur_0), 4)], 1));   // straight
Pdefn(\v2_durs_b, Pseq([Pn(Pdefn(\v2_dur_1), 4)], 1));   // euclidean
// story
Pdefn(\v2_durs,  Pseq([Pn(Pdefn(\v2_durs_a), 4)], 1));

// STRS
// Pdefn(\v2_str_0, 1/4); 
// Pdefn(\v2_str_0, Pseq([1/4, 1/8], 1));
Pdefn(\v2_str_0, Pseg([1/2, 1/8, 1], [8, 8], \exp, 1));
// Pdefn(\v2_str_0, 1); 
Pdefn(\v2_strs,  Pseq([Pn(Pdefn(\v2_str_0), 4)], 1));

Pdefn(\v2_rel_0,  Pseq([0.2!3,  0.5].flat,  1));
Pdefn(\v2_rel,  Pseq([Pn(Pdefn(\v2_rel_0),  4)],  1));


// PHRASE VARIANT FUNCTIONS
// These get referenced in bindings.scd Bank 5 toggle bindings.
// Store in ~phrFns[pfx] so bindings.scd loop can find them.
~phrFns = ~phrFns ?? { () };
~phrFns[\v2] = (
    a: {
        Pbindef(\v2_pb,
            \dur,    Pseq([Pn(Pdefn(\v2_durs_b), 4)], inf),
            \degree, Pseq([Pn(Pdefn(\v2_degs_b), 4)], inf))
    },
    b: {  // reset to defaults
        Pbindef(\v2_pb,
            \dur,    Pseq([Pn(Pdefn(\v2_durs_a), 4)], inf),
            \degree, Pseq([Pn(Pdefn(\v2_degs_a), 4)], inf))
    },
);
)

