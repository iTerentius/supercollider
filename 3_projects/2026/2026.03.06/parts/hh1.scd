// hh1 — Hi-Hats
// Re-eval this file to reset voice to defaults (story overrides live in arrangement.scd).
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\hh1,
    ~pBuf.(
        Pbindef(\pbd_hh1, 
        // Pbind(
            \buf,     Pn(Pdefn(\hh1_bufs), inf),
            \bufnum,  Pkey(\buf),
            \octave,  Pn(Pdefn(\hh1_octs), inf),
            \degree,  Pn(Pdefn(\hh1_degs), inf),
            \stretch, Pn(Pdefn(\hh1_strs), inf),
            \dur,     Pn(Pdefn(\hh1_durs), inf),
            \amp,     Pn(Pdefn(\hh1_amps), inf),
            \out,     Pn(Pdefn(\hh1_out),  inf),
        )
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\hh1_out,   ~t3.inbus.index);
Pdefn(\hh1_scale, Scale.minor);

// BUFS — words
~shh1 = ~sTree[\hats].values;
Pdefn(\hh1_buf_0, Pstep(Pseq(~shh1[[1]], 1), 2));
Pdefn(\hh1_buf_1, Pstep(Pseq(~shh1[[1, 1, 0]], 1), 4));
// sentences
Pdefn(\hh1_bufs_a, Pseq([Pn(Pdefn(\hh1_buf_0), 4)], 1));      // single hat
Pdefn(\hh1_bufs_b, Pseq([Pn(Pdefn(\hh1_buf_1), 4)], 1));      // open/close mix
// story
Pdefn(\hh1_bufs, Pseq([Pn(Pdefn(\hh1_bufs_a), 1)], 1));

// OCTS — words
Pdefn(\hh1_oct_0, 5);
// story
Pdefn(\hh1_octs, Pseq([Pn(Pdefn(\hh1_oct_0), 4)], 1));

// AMPS — words
Pdefn(\hh1_amp_0, 0.5);
Pdefn(\hh1_amp_1, Pwhite(0.75, 0.5, 1));
// story
Pdefn(\hh1_amps, Pseq([Pn(Pdefn(\hh1_amp_0), 4)], 1));

// DEGS — words
Pdefn(\hh1_deg_0, 0);
Pdefn(\hh1_deg_1, Pseq([-1, 0, -1, [1, 0]], inf));
// sentences
Pdefn(\hh1_degs_a, Pseq([Pn(Pdefn(\hh1_deg_1), 4)], 1));      // syncopated
Pdefn(\hh1_degs_b, Pseq([Pn(Pdefn(\hh1_deg_0), 4)], 1));      // straight
// story
Pdefn(\hh1_degs, Pseq([Pn(Pdefn(\hh1_degs_a), 1)], 1));

// DURS — words
Pdefn(\hh1_dur_0, 1/2);
Pdefn(\hh1_dur_1, Pseq([1/2, 1/4!2, 1].flat, 1));
Pdefn(\hh1_dur_2, Pbjorklund(3, 8, 1)/4);
Pdefn(\hh1_dur_3, Pseq([Pn(Rest(), 1/2), 1/2], 1));
// sentences
Pdefn(\hh1_durs_a, Pseq([Pn(Pdefn(\hh1_dur_0), 24)], 1));                             // straight 8ths
Pdefn(\hh1_durs_b, Pseq([Pn(Pdefn(\hh1_dur_0), 16), Pn(Pdefn(\hh1_dur_1), 4)], 1));  // + syncopation
Pdefn(\hh1_durs_c, Pseq([Pn(Pdefn(\hh1_dur_0), 8),  Pn(Pdefn(\hh1_dur_2), 2), Pn(Pdefn(\hh1_dur_3), 4)], 1));
// story
Pdefn(\hh1_durs, Pseq([Pn(Pdefn(\hh1_durs_a), 1)], 1));

// STRS — words
Pdefn(\hh1_str_0, 1);
Pdefn(\hh1_str_1, Pdefn(\bd1_strs));
// story
Pdefn(\hh1_strs, Pseq([Pn(Pdefn(\hh1_str_1)*4, 4)], 1));
)
