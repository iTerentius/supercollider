// bd1 — Bass Drum
// Re-eval this file to reset voice to defaults (story overrides live in arrangement.scd).
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\bd1, ~pBuf.(
    Pbindef(\pbd_bd1, 
    // Pbind(
        \buf,     Pn(Pdefn(\bd1_bufs),  inf),
        \bufnum,  Pkey(\buf),
        \scale,   Pn(Pdefn(\bd1_scale), inf),
        \octave,  Pn(Pdefn(\bd1_octs),  inf),
        \stretch, Pn(Pdefn(\bd1_strs),  inf),
        \degree,  Pn(Pdefn(\bd1_degs),  inf),
        \dur,     Pn(Pdefn(\bd1_durs),  inf),
        \amp,     Pn(Pdefn(\bd1_amps),  inf),
        \out,     Pn(Pdefn(\bd1_out),   inf),
    )
));

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\bd1_out,   ~t1.inbus.index);
Pdefn(\bd1_scale, Scale.minor);

// BUFS — words
~sbd1 = ~sTree[\bass_drums].values;
Pdefn(\bd1_buf_0, Pseq(~sbd1, 1));
Pdefn(\bd1_buf_1, Pseq(~sbd1[[0,  1]], 2));
// sentences
Pdefn(\bd1_bufs_a, Pseq([Pn(Pdefn(\bd1_buf_1), 4)], 1));      // single hit
Pdefn(\bd1_bufs_b, Pseq([Pn(Pdefn(\bd1_buf_0), 4)], 1));      // all samples
Pdefn(\bd1_bufs_c, Pseq([Pn(Pdefn(\bd1_buf_1), 2), Pn(Pdefn(\bd1_buf_0), 2)], 1));
// story
Pdefn(\bd1_bufs, Pseq([Pn(Pdefn(\bd1_bufs_a), 1)], 1));

// OCTS — words
Pdefn(\bd1_oct_0, 5);
Pdefn(\bd1_oct_1, Pseq([4, 5], 1));
// story
Pdefn(\bd1_octs, Pseq([Pn(Pdefn(\bd1_oct_0), 4)], 1));

// AMPS — words
Pdefn(\bd1_amp_0, 1.0);
Pdefn(\bd1_amp_1, Pwhite(0.5, 0.7, 1));
Pdefn(\bd1_amp_2, Pseq([0.5!3, 0.8].flat, 1));
// story
Pdefn(\bd1_amps, Pseq([Pn(Pdefn(\bd1_amp_0), 4)], 1));

// DEGS — words
Pdefn(\bd1_deg_0, Place([0, [2, 4]], 1));
Pdefn(\bd1_deg_1, Pseq([0, 1, \, 3, \, 0], 1));
Pdefn(\bd1_deg_2, Pseq([0, \, \, \, 7,  \, 0, \, 0, \, \, 0, 1, \, \, \], 1));
// sentences
Pdefn(\bd1_degs_a, Pseq([Pn(Pdefn(\bd1_deg_0), 4)], 1));         // root only
Pdefn(\bd1_degs_b, Pseq([Pn(Pdefn(\bd1_deg_1), 4)], 1));         // short walk
Pdefn(\bd1_degs_c, Pseq([Pn(Pdefn(\bd1_deg_2), 4)], 1));         // sparse melody
// story
Pdefn(\bd1_degs, Pseq([Pn(Pdefn(\bd1_degs_a), 1)], 1));

// DURS — words
Pdefn(\bd1_dur_0, 1);
Pdefn(\bd1_dur_1, Pseq([1/4!2, 1/2!3].flat, 1));
Pdefn(\bd1_dur_2, Pbjorklund2(5, 8, 1)/2);
Pdefn(\bd1_dur_3, Pseq([1/4!2, Rest(1/4), 1/4].flat, 1));
Pdefn(\bd1_dur_4, 1/2);
// sentences
Pdefn(\bd1_durs_a, Pseq([Pn(Pdefn(\bd1_dur_0), 4)], 1));         // straight
Pdefn(\bd1_durs_b, Pseq([
  Pn(Pdefn(\bd1_dur_0), 2), 
  Pn(Pdefn(\bd1_dur_3), 2), 
], 1));  // + rest
Pdefn(\bd1_durs_c, Pseq([Pn(Pdefn(\bd1_dur_2), 4)], 1));         // euclidean
// story
Pdefn(\bd1_durs, Pseq([Pn(Pdefn(\bd1_durs_c), 1)], 1));

// STRS — words
Pdefn(\bd1_str_0, 1);
Pdefn(\bd1_str_1, Pstep(Pseq([1!4, 2!2].flat, 1), 1));
// story
Pdefn(\bd1_strs, Pseq([Pn(Pdefn(\bd1_str_1), 4)], 1));
)
