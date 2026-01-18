// Percussion
(
Pdefn(\kit_deg_0,
    Pseq([
        [0], [\], [\], [\], [0], [\], [\], [\],
    ], 1));

Pdefn(\kit_degs, Pseq([
    Pn(Pdefn(\kit_deg_0), 4),
], 1));

Pdef(\perc,
    Pbindef(\perc_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.kit,
        \scale, Scale.chromatic,
        \root, 0,
        \octave, 3,
        \degree, Pn(Pdefn(\kit_degs), inf),
        \amp, 0.8,
        \dur, 1/4,
    )
);
)
