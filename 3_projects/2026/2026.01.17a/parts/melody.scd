// Melody
(
Pdef(\mel,
    Pbindef(\mel_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.mel,
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 5,
        \degree, Pseq([0, 2, 4, 1], inf),
        \amp, 0.5,
        \dur, Pseq([1/4!3,  Rest(1/4), 1/2, 1/4!2].flat, inf),
    )
);
)
