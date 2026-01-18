// Pads - drone and chords
(
Pdef(\drone,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.drone,
        \scale, Scale.minor,
        \octave, Pseq([5], inf),
        \degree, Place([0, [2, 4, 7]], inf),
        \dur, Pn(Pseq([1/8, 1/2, 1/4!2].flat).fitToBar(4), inf),
    )
);

Pdef(\chords,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.chords,
        \scale, Scale.minor,
        \degree, Pn(Pdefn(\root_degs), inf),
        \ctranspose, Pn(Pdefn(\harms), inf),
        \delta, 2,
        \dur, 4,
    )
);
)
