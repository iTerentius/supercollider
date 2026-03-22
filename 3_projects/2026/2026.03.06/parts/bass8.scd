// model_d — Minimoog Model D
// Re-eval this file to update Pdefns while preserving playback sync.
// _0 = sane default (use to reset). Add _1, _2 for variations.
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\bass,
    Pbindef(\pbd_bass,  
    // Pbind(
        \instrument,   \bass8,
        \out,          Pn(Pdefn(\bass_out),  inf),

        // --- pitch / gate ---
        \scale,        Pn(Pdefn(\bass_scale),  inf),
        \root,        0,  
        \degree,       Pn(Pdefn(\bass_degs),   inf),
        \octave,       Pn(Pdefn(\bass_octs),   inf),
        \dur,          Pn(Pdefn(\bass_durs),   inf),
        \stretch,      Pn(Pdefn(\bass_strs),   inf),
        \legato,       Pn(Pdefn(\bass_legs),   inf),
        \amp,          Pn(Pdefn(\bass_amps),   inf),
        \timeOffset,  1/4,  

        // --- glide ---
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\bass_out,   ~t9.inbus.index);
Pdefn(\bass_scale, Scale.minor);

// OCTAVE
Pdefn(\bass_oct_0, 4);              // 0..8
Pdefn(\bass_oct_1, Pseq([5, 4], 1));
Pdefn(\bass_octs, Pseq([
    Pn(Pdefn(\bass_oct_0), 4),
    // Pn(Pdefn(\bass_oct_1), 4),
], 1));

// Pslide.new(list, repeats: 1, len: 3, step: 1, start: 0, wrapAtEnd: true) ~
// DEGREE — words
Pdefn(\bass_deg_0, 0);
Pdefn(\bass_deg_1, Pslide([-3, 7, 4,  0], 2, 2, 2, 0));
Pdefn(\bass_deg_2, Pslide((0..3), 1, 3, 1, 0));
Pdefn(\bass_deg_3, Pslide((0..7), 2, 3, 1, 0));
// sentences
Pdefn(\bass_degs_a, Pseq([Pn(Pdefn(\bass_deg_0), 4)], 1));          // root pedal
Pdefn(\bass_degs_b, Pseq([Pn(Pdefn(\bass_deg_1), 1)], 1));          // slide phrase
Pdefn(\bass_degs_c, Pseq([Pn(Pdefn(\bass_deg_2), 2), Pn(Pdefn(\bass_deg_3), 2)], 1));
// story
Pdefn(\bass_degs, Pseq([Pn(Pdefn(\bass_degs_0), 1)], 1));

// DUR — words
Pdefn(\bass_dur_0, 1/4);
Pdefn(\bass_dur_1, Pseq([1/4!3, Rest(0.25), 1/4,  1/2, Rest(2.25)].flat, 1));
// sentences
Pdefn(\bass_durs_a, Pseq([Pn(Pdefn(\bass_dur_0), 4), Pn(Rest(), 4)], 1));  // sparse
Pdefn(\bass_durs_b, Pseq([Pn(Pdefn(\bass_dur_1), 4)], 1));                  // syncopated
// story
Pdefn(\bass_durs, Pseq([Pn(Pdefn(\bass_durs_b), 1)], 1));

// STRETCH
Pdefn(\bass_str_0, 1);
Pdefn(\bass_strs, Pseq([
    Pn(Pdefn(\bass_str_0), 4),
], 1));

// LEGATO
Pdefn(\bass_leg_0, 1.3);            // 0..2+
Pdefn(\bass_leg_1, Pwhite(0.6, 1.0, 1));
Pdefn(\bass_legs, Pseq([
    Pn(Pdefn(\bass_leg_0), 4),
    // Pn(Pdefn(\bass_leg_1), 4),
], 1));

// AMP
Pdefn(\bass_amp_0, 0.3);            // 0..1
Pdefn(\bass_amp_1, 0.8);
Pdefn(\bass_amps, Pseq([
    Pn(Pdefn(\bass_amp_0), 4),
    // Pn(Pdefn(\bass_amp_1), 4),
], 1));

)
