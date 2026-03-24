(
Pdef(\spectral, Pbind(
    \type,        \set,
    \id,          Pn(Pdefn(\spectral_outs),        inf),
    \args,        #[\freeze, \mix, \amp, \chunk, \smear, \freezeSmear],
    \amp,         Pn(Pdefn(\spectral_amp),          inf),
    \mix,         Pn(Pdefn(\spectral_mix),          inf),
    \dur,         Pn(Pdefn(\spectral_durs),         inf),
    \chunk,       Pn(Pdefn(\spectral_chunk),        inf),
    \freeze,      Pn(Pdefn(\spectral_freeze),       inf),
    \smear,       Pn(Pdefn(\spectral_smear),        inf),
    \freezeSmear, Pn(Pdefn(\spectral_freezeSmear),  inf),
));

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////

// DUR
Pdefn(\spectral_dur_0, 1);
Pdefn(\spectral_dur_1, Pseg([1/2, 1, 1/4], [2, 4], \sin, 1));
Pdefn(\spectral_dur_2, Pseq([1/4, 1/2, 1, 2], 1));
Pdefn(\spectral_dur_3, Pbjorklund(3, 8, 1));
// sentences
Pdefn(\spectral_durs_a, Pseq([Pn(Pdefn(\spectral_dur_1), 4)], 1));
Pdefn(\spectral_durs_b, Pseq([
    Pn(Pdefn(\spectral_dur_1), 4),
    Pn(Pdefn(\spectral_dur_2), 4),
    Pn(Pdefn(\spectral_dur_3), 4),
], 1));
// story
Pdefn(\spectral_durs, Pseq([Pn(Pdefn(\spectral_durs_a), 1)], 1));

// OUTS
Pdefn(\spectral_outs_0, ~r5_ilfx_1);
Pdefn(\spectral_outs_1, ~m1_ilfx_1);
Pdefn(\spectral_outs_2, [~r5_ilfx_1, ~m1_ilfx_1]);
// sentences
Pdefn(\spectral_outs_a, Pseq([Pn(Pdefn(\spectral_outs_0), 4)], 1));
// story
Pdefn(\spectral_outs, Pseq([Pn(Pdefn(\spectral_outs_a), 1)], 1));

// AMP
Pdefn(\spectral_amp_0, 0.1);
// sentences
Pdefn(\spectral_amp_a, Pseq([Pn(Pdefn(\spectral_amp_0), 4)], 1));
// story
Pdefn(\spectral_amp, Pseq([Pn(Pdefn(\spectral_amp_a), 1)], 1));

// MIX
Pdefn(\spectral_mix_0, 1);
// sentences
Pdefn(\spectral_mix_a, Pseq([Pn(Pdefn(\spectral_mix_0), 4)], 1));
// story
Pdefn(\spectral_mix, Pseq([Pn(Pdefn(\spectral_mix_a), 1)], 1));

// CHUNK
Pdefn(\spectral_chunk_0, 2048);
Pdefn(\spectral_chunk_1, Pseq([512, 1024, 2048, 4096], inf));
// sentences
Pdefn(\spectral_chunk_a, Pseq([Pn(Pdefn(\spectral_chunk_0), 4)], 1));
// story
Pdefn(\spectral_chunk, Pseq([Pn(Pdefn(\spectral_chunk_a), 1)], 1));

// FREEZE
Pdefn(\spectral_freeze_0, 0);
Pdefn(\spectral_freeze_1, Pwhite(0, 1, 1));
// sentences
Pdefn(\spectral_freeze_a, Pseq([Pn(Pdefn(\spectral_freeze_1), 4)], 1));
// story
Pdefn(\spectral_freeze, Pseq([Pn(Pdefn(\spectral_freeze_a), 1)], 1));

// SMEAR
Pdefn(\spectral_smear_0, 0);
Pdefn(\spectral_smear_1, Pseg([0, 16, 0], [4, 4], \sin, 1));
Pdefn(\spectral_smear_2, Pseq([0, 2, 4, 8, 16], 1));
// sentences
Pdefn(\spectral_smear_a, Pseq([Pn(Pdefn(\spectral_smear_0), 4)], 1));
// story
Pdefn(\spectral_smear, Pseq([Pn(Pdefn(\spectral_smear_a), 1)], 1));

// FREEZESMEAR
Pdefn(\spectral_freezeSmear_0, 0);
Pdefn(\spectral_freezeSmear_1, Pseg([0, 1, 0], [4, 4], \sin, 1));
Pdefn(\spectral_freezeSmear_2, Pwhite(0.0, 1.0, 1));
// sentences
Pdefn(\spectral_freezeSmear_a, Pseq([Pn(Pdefn(\spectral_freezeSmear_0), 4)], 1));
// story
Pdefn(\spectral_freezeSmear, Pseq([Pn(Pdefn(\spectral_freezeSmear_a), 1)], 1));
)
