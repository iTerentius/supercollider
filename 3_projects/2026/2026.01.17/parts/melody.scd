// Melodic patterns
(
Pdef(\mel_1,
    Pbindef(\mel_1_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.mel1,

        // Inherit from conductor
        \root, Pkey(\root),
        \scale, Pkey(\scale),

        // Melody-specific
        \octave, Pseq([6], inf),
        \legato, 1,
        \degree, Pser([4, 2, \, 0], Pkey(\step1)),
        \amp, Pwhite(0.1, 0.1, inf),
        \vel, Pkey(\amp),
        \dur, 1 / Pkey(\div),
    )
);

Pdef(\mel_2,
    Pbindef(\mel_2_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.mel2,

        // Inherit from conductor
        \root, Pkey(\root),
        \scale, Pkey(\scale),

        // Melody-specific
        \octave, Pser([4!6, 5!2].flat, inf),
        \degree, Pseq([0!3, 4, 2].flat, inf),
        \amp, 0.3,
        \vel, Pkey(\amp),
        \dur, 1/4,
    )
);
)
