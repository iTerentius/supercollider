// Bass patterns
(
Pdef(\bass_1,
    Pbindef(\bass_1_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.bass,

        // Inherit from conductor
        \root, Pkey(\root),
        \scale, Pkey(\scale),

        // Bass-specific
        \octave, 3,
        \degree, 0,
        \legato, Pkey(\div) * Pseq([0.1, 1.0], inf).stutter(4),
        \amp, Pwhite(0.2, 0.6, inf),
        \vel, Pkey(\amp),
        \dur, Pbjorklund2(Pkey(\step1), 8, inf) / Pkey(\div),
    )
);
)
