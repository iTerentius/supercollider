// Melody
(
Pdef(\mel,
    Pbindef(\mel_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.mel,
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 5,
        \degree, Pseq([0, 2, 4], inf),
        \amp, 0.5,
        \dur, 1/4,
    )
);
)
