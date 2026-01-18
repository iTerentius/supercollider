// Pad
(
Pdef(\pad,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.pad,
        \scale, Scale.minor,
        \octave, 4,
        \degree, Place([0, [2, 4]], inf),
        \dur, 4,
    )
);
)
