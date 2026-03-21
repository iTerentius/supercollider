
// Re-eval this file to reset voice to defaults (story overrides live in arrangement.scd).
(
///////////////////////////////////////////////////////////////
// PDEFS
///////////////////////////////////////////////////////////////
Pdef(\roll,
    Pbindef(\pbd_roll,  
    // Pbind(
        \instrument,  Pn(Pdefn(\roll_ins),        inf), 
        \buf,         Pn(Pdefn(\roll_bufs),       inf),
        \bufnum,      Pkey(\buf),
        \nSlices,     Pn(Pdefn(\roll_nSlices),    inf),
        \rate,        Pn(Pdefn(\roll_rates),       inf),
        \rev,         Pn(Pdefn(\roll_rev),         inf),
        \sliceDur,    Pn(Pdefn(\roll_sliceDurs),   inf),
        \stretch,     Pn(Pdefn(\roll_strs),        inf),
        \spread,      Pn(Pdefn(\roll_sprds),       inf),
        \octave,      Pn(Pdefn(\roll_octs),        inf),
        \degree,      Pn(Pdefn(\roll_degs),        inf),
        \sliceIndex,  Pn(Pdefn(\roll_sliceIdxs),   inf),
        \dur,         Pn(Pdefn(\roll_durs),        inf),
        \amp,         Pn(Pdefn(\roll_amps),        inf),
        \out,         Pn(Pdefn(\roll_out),         inf),
    )
);

// Glitch FX — controls ~roll_fx1 node (set in control.scd: ~roll_fx1 = ~t2.playfx(~exp1))
Pdef(\roll_fx_ctl, Pbindef(\roll_fx_ctl_pbd,
    \type,    \set,
    \id,      Pfunc({ ~roll_fx1.nodeID }),
    \args,    #[\mod1, \amp, \dur],
    \amp,     Pn(Pdefn(\roll_fx_amps),  inf),
    \mod1,    Pn(Pdefn(\roll_fx_mod1),  inf),
    \mod2,    Pn(Pdefn(\roll_fx_mod2),  inf),
    \dur,     Pn(Pdefn(\roll_fx_durs),  inf),
    \stretch, Pn(Pdefn(\roll_fx_strs),  inf),
));

///////////////////////////////////////////////////////////////
// ROLL PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\roll_out,   ~t4.inbus.index);
Pdefn(\roll_scale, Scale.minor);
Pdefn(\roll_ins,  \slice_m);

// BUFS — words
~sRoll = ~sTree[\jttcot].values[0..6];
// ~sRoll = ~sTree[\hoarder_mono].values[0..6];
// ~sRoll = ~sTree[\casio_mt_100].values;
// ~sRoll = ~sTree[\bass_drops].values;
// ~sRoll = ~sTree[\mm].values;
// ~sRoll = ~sTree[\neutron_12].values;
// ~sRoll = ~sTree[\drumloops].values;
// ~sRoll = ~sTree[\_mono].values;
Pdefn(\roll_buf_0, Pseq(~sRoll, 1));
Pdefn(\roll_buf_1, Pseq(~sRoll[[3,  4,  5]], 1));
// sentences
Pdefn(\roll_bufs_a, Pseq([Pn(Pdefn(\roll_buf_0), 4)], 1));      // all samples
Pdefn(\roll_bufs_b, Pseq([Pn(Pdefn(\roll_buf_1), 8)], 1));      // longer cycle
// story
Pdefn(\roll_bufs, Pseq([Pn(Pdefn(\roll_bufs_b), 1)], 1));

// OCTS — words
Pdefn(\roll_oct_0, 1);
Pdefn(\roll_oct_1, Pseq([1, 3, 7], 1));
// story
Pdefn(\roll_octs, Pseq([Pn(Pdefn(\roll_oct_0), 4)], 1));

// AMPS — words
Pdefn(\roll_amp_0, 0.8);
Pdefn(\roll_amp_1, Pwhite(0.75, 0.5, 1));
// story
Pdefn(\roll_amps, Pseq([Pn(Pdefn(\roll_amp_0), 4)], 1));

// NSLICES — words
Pdefn(\roll_nSlices_0, 32);
Pdefn(\roll_nSlices_1, Pseq([1!4, 8, 16!4].flat, 1));
// story
Pdefn(\roll_nSlices, Pseq([Pn(Pdefn(\roll_nSlices_1), 1)], 1));

// RATES — words
Pdefn(\roll_rate_0, 0.8);
Pdefn(\roll_rate_1, Pseq([1.2, 0.8], 1));
Pdefn(\roll_rate_2, Pseg([0.5, 1.5, 0.5], [2, 4], \sin, 1));
// story
Pdefn(\roll_rates, Pseq([Pn(Pdefn(\roll_rate_2), 1)], 1));

// REV — words
Pdefn(\roll_rev_0, 0);
Pdefn(\roll_rev_1, Pstep(Pseq([0, 1], 1), 4));
// story
Pdefn(\roll_rev, Pseq([Pn(Pdefn(\roll_rev_1), 1)], 1));

// SLICEDUR — words
Pdefn(\roll_sliceDur_0, 1);
Pdefn(\roll_sliceDur_1, Pseq([1/4, 1/8!2, 1.5].flat, 1));
// story
Pdefn(\roll_sliceDurs, Pseq([Pn(Pdefn(\roll_sliceDur_0), 4)], 1));

// SPREAD — words
Pdefn(\roll_sprd_0, 0.6);
// story
Pdefn(\roll_sprds, Pseq([Pn(Pdefn(\roll_sprd_0), 4)], 1));

// SLICEIDXS — words
Pdefn(\roll_sliceIdx_0, 0);
Pdefn(\roll_sliceIdx_1, Pwhite(0, 32, 1));
Pdefn(\roll_sliceIdx_2, Pseg([0, 8], [8], 1));
// story
Pdefn(\roll_sliceIdxs, Pseq([Pn(Pdefn(\roll_sliceIdx_1), 4)], 1));

// DEGS — words
Pdefn(\roll_deg_0, 2);
Pdefn(\roll_deg_1, Prand([7], 1));
// sentences
Pdefn(\roll_degs_a, Pseq([Pn(Pdefn(\roll_deg_0), 1)], 1));     // static
Pdefn(\roll_degs_b, Pseq([Pn(Pdefn(\roll_deg_1), 4)], 1));     // random
// story
Pdefn(\roll_degs, Pseq([Pn(Pdefn(\roll_degs_a), 1)], 1));

// DURS — words
Pdefn(\roll_dur_0, 2);
Pdefn(\roll_dur_1, Pseq([1/3, 1/6!2, Pn(Rest(), 1)].flat, 1));
Pdefn(\roll_dur_2, Pbjorklund2(5, 8, 1));
// sentences
Pdefn(\roll_durs_a, Pseq([Pn(Pdefn(\roll_dur_2), 4)], 1));     // euclidean
Pdefn(\roll_durs_b, Pseq([Pn(Pdefn(\roll_dur_0), 4)], 1));     // whole notes
Pdefn(\roll_durs_c, Pseq([Pn(Pdefn(\roll_dur_1), 4)], 1));     // triplet feel
// story
Pdefn(\roll_durs, Pseq([Pn(Pdefn(\roll_durs_2), 1)], 1));

// STRS — words
Pdefn(\roll_str_0, 1);
Pdefn(\roll_str_1, Pseq([1/4, 1/2, 1], 4));
// story
Pdefn(\roll_strs, Pseq([Pn(Pdefn(\roll_str_0), 32)], 1));

///////////////////////////////////////////////////////////////
// ROLL FX PDEFNS  (controls ~roll_fx1 = ~t2.playfx(~exp1))
///////////////////////////////////////////////////////////////
Pdefn(\roll_fx_amp_0, 0.8);
Pdefn(\roll_fx_amp_1, Pwhite(0.5, 0.9, 1));
Pdefn(\roll_fx_amps, Pseq([Pn(Pdefn(\roll_fx_amp_1), 4)], 1));

Pdefn(\roll_fx_mod1_0, 1);
Pdefn(\roll_fx_mod1_1, Pseq([1, 50], 1));
Pdefn(\roll_fx_mod1_2, Pseg([1, 50, 1], [Pkey(\dur) * 8, Pkey(\dur) * 2], \sin, 1));
Pdefn(\roll_fx_mod1, Pseq([
    Pn(Pdefn(\roll_fx_mod1_0), 4),
    Pn(Pdefn(\roll_fx_mod1_1), 4),
    Pn(Pdefn(\roll_fx_mod1_2), 4),
], 1));

Pdefn(\roll_fx_mod2_0, 1);
Pdefn(\roll_fx_mod2_1, Pseq([1, 50], 1));
Pdefn(\roll_fx_mod2_2, Pseg([1, 50, 1], [Pkey(\dur) * 8, Pkey(\dur) * 2], \sin, 1));
Pdefn(\roll_fx_mod2, Pseq([
    Pn(Pdefn(\roll_fx_mod2_0), 4),
    Pn(Pdefn(\roll_fx_mod2_1), 4),
    Pn(Pdefn(\roll_fx_mod2_2), 4),
], 1));

Pdefn(\roll_fx_dur_0, 1);
Pdefn(\roll_fx_dur_1, 1/8);
Pdefn(\roll_fx_dur_2, Pbjorklund2(5, 8, 1)/4);
Pdefn(\roll_fx_durs, Pseq([
    Pn(Pdefn(\roll_fx_dur_0), 4),
    Pn(Pdefn(\roll_fx_dur_1), 4),
    Pn(Pdefn(\roll_fx_dur_2), 4),
], 1));

Pdefn(\roll_fx_str_0, 1);
Pdefn(\roll_fx_str_1, Pseq([1, 2, 1/4], 1));
Pdefn(\roll_fx_strs, Pseq([
    Pn(Pdefn(\roll_fx_str_0), 4),
    Pn(Pdefn(\roll_fx_str_1), 4),
], 1));
)
