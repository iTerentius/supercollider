// ms20 — MS-20 Bass
// Re-eval this file to reset voice to defaults (story overrides live in arrangement.scd).
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\ms20,
    Pbind(
        \instrument,   \ms20Bass,
        \scale,        Pn(Pdefn(\ms20_scale),   inf),
        \degree,       Pn(Pdefn(\ms20_degs),    inf),
        \octave,       Pn(Pdefn(\ms20_octs),    inf),
        \amp,          Pn(Pdefn(\ms20_amps),    inf),
        \dur,          Pn(Pdefn(\ms20_durs),    inf),
        \stretch,      Pn(Pdefn(\ms20_strs),    inf),
        \legato,       Pn(Pdefn(\ms20_legs),    inf),
        \hpfCutoff,    Pn(Pdefn(\ms20_hpcut),   inf),
        \lpfCutoff,    Pn(Pdefn(\ms20_lpcut),   inf),
        \lpfRes,       Pn(Pdefn(\ms20_lpRes),   inf),
        \filterEnvAmt, Pn(Pdefn(\ms20_fEamt),   inf),
        \ringMod,      Pn(Pdefn(\ms20_ringMod), inf),
        \out,          Pn(Pdefn(\ms20_out),     inf),
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\ms20_out,   ~t5.inbus.index);
Pdefn(\ms20_scale, Scale.minor);

// OCTS — words
Pdefn(\ms20_oct_0, 5);
Pdefn(\ms20_oct_1, Pstep(Pseq([3, 4], 1), 7));
// story
Pdefn(\ms20_octs, Pseq([Pn(Pdefn(\ms20_oct_0), 4)], 1));

// AMPS — words
Pdefn(\ms20_amp_0, 0.5);
Pdefn(\ms20_amp_1, Pwhite(0.5, 0.7, 1));
// story
Pdefn(\ms20_amps, Pseq([Pn(Pdefn(\ms20_amp_0), 4)], 1));

// DEGS — words
Pdefn(\ms20_deg_0, 0);
Pdefn(\ms20_deg_1, Place([0, [2, 1, 0, -4]], 1));
Pdefn(\ms20_deg_2, Pseq([0, 0, 3, 5, Pn(Rest(), 8)], 1));
// sentences
Pdefn(\ms20_degs_a, Pseq([Pn(Pdefn(\ms20_deg_0), 4)], 1));      // root pedal
Pdefn(\ms20_degs_b, Pseq([Pn(Pdefn(\ms20_deg_1), 4)], 1));      // chord tones
Pdefn(\ms20_degs_c, Pseq([Pn(Pdefn(\ms20_deg_2), 4)], 1));      // sparse line
// story (default: borrow bd1's rhythm as pitch input)
Pdefn(\ms20_degs, Pseq([Pn(Pdefn(\ms20_degs_1), 1)], 1));

// DURS — words
Pdefn(\ms20_dur_0, 1);
Pdefn(\ms20_dur_1, Pseq([1/4!7].flat, 1));
Pdefn(\ms20_dur_2, Pbjorklund(5, 8, 1)/4);
// sentences
Pdefn(\ms20_durs_a, Pseq([Pn(Pdefn(\ms20_dur_0), 4)], 1));      // quarter notes
Pdefn(\ms20_durs_b, Pseq([Pn(Pdefn(\ms20_dur_1), 4)], 1));      // 16th runs
Pdefn(\ms20_durs_c, Pseq([Pn(Pdefn(\ms20_dur_2), 4)], 1));      // euclidean
// story (default: borrow bd1's rhythm)
Pdefn(\ms20_durs, Pseq([Pn(Pdefn(\ms20_dur_c), 4)], 1));

// STRS — words
Pdefn(\ms20_str_0, 1/4);
// story
Pdefn(\ms20_strs, Ppatlace([
    Pn(Pdefn(\ms20_str_0), 4),
    // Pn(Pdefn(\bd1_strs),   4),
], 1));

// LEGATO — words
Pdefn(\ms20_leg_0, 1);
Pdefn(\ms20_leg_1, Place([0.6, [1, 0.8]], 1));
// story
Pdefn(\ms20_legs, Pseq([Pn(Pdefn(\ms20_leg_1), 4)], 1));

// FILTER — words
Pdefn(\ms20_hpcut_0, 80);
Pdefn(\ms20_hpcut, Pseq([Pn(Pdefn(\ms20_hpcut_0), 4)], 1));

Pdefn(\ms20_lpcut_0, 800);
Pdefn(\ms20_lpcut_2, Pseg([80, 800, 1880], [2, 4], \sin, 1));
Pdefn(\ms20_lpcut, Pseq([Pn(Pdefn(\ms20_lpcut_2), 4)], 1));

Pdefn(\ms20_lpRes_0, 0.8);
Pdefn(\ms20_lpRes_2, Pwhite(0.4, 0.9, 1));
Pdefn(\ms20_lpRes, Pseq([Pn(Pdefn(\ms20_lpRes_0), 4)], 1));

Pdefn(\ms20_fEamt_0, 800);
Pdefn(\ms20_fEamt_3, Pseg([100, 2000, 100], [2, 2], \step, 1));
Pdefn(\ms20_fEamt, Pseq([Pn(Pdefn(\ms20_fEamt_3), 4)], 1));

Pdefn(\ms20_ringMod_0, 0.2);
Pdefn(\ms20_ringMod_2, Pseg([0.2, 1.0], [1], \sin, 1));
Pdefn(\ms20_ringMod, Pseq([Pn(Pdefn(\ms20_ringMod_2), 4)], 1));
)
