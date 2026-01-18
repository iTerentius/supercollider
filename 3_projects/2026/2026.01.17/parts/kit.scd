// Percussion patterns - kick and hats
(
// Kick patterns
Pdefn(\kit_deg_0,
    Pseq([
        [0], [\], [\], [0], [\], [\], [\], [\],
        [\], [\], [\], [0], [1], [\], [\], [\],
    ], 1));

Pdefn(\kit_deg_1,
    Pseq([
        [0], [\], [\], [0], [0], [4], [1], [4],
        [\], [1], [\], [\], [0], [1], [0], [3],
    ], 1));

Pdefn(\kit_deg_2,
    Pseq([
        [0], [\], [\], [\], [0], [\], [\], [\],
        [\], [\], [\], [\], [0], [\], [0], [\],
    ], 1));

// Hat patterns
Pdefn(\hats_deg_0,
    Pseq([
        [2], [\], [2], [\],
        [\], [2], [\], [3],
    ], 1));

Pdefn(\hats_deg_1,
    Pseq([
        [2], [2], [3], [\],
        [\], [\], [2], [2],
    ], 1));

Pdefn(\hats_deg_2,
    Pseq([
        [2], [\], [\], [\],
        [2], [\], [\], [\],
    ], 1));

// Combined sequences
Pdefn(\kit_degs, Pseq([
    Pn(Pdefn(\kit_deg_1), 4),
    Pn(Pdefn(\kit_deg_0), 4),
    Pn(Pdefn(\kit_deg_2), 4),
], 1));

Pdefn(\hats_degs, Pseq([
    Pn(Pdefn(\hats_deg_2), 16),
    Pn(Pdefn(\hats_deg_0), 4),
    Pn(Pdefn(\hats_deg_1), 16),
], 1));

// Kit instrument
Pdef(\kit_1,
    Pbindef(\kit_1_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.kit,
        \scale, Scale.chromatic,
        \root, 0,
        \octave, 3,
        \degree, Pn(Pdefn(\kit_degs), inf),
        \amp, Pn(Pseq([0.99, 0.6, 0.8, 0.7], 1), inf),
        \dur, 1/2,
    )
);

// Hats instrument
Pdef(\hats_1,
    Pbindef(\hats_1_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.kit,
        \scale, Scale.chromatic,
        \root, 0,
        \octave, 3,
        \degree, Pn(Pdefn(\hats_degs), inf),
        \amp, Pn(Pseq([0.8, 0.6, 0.8, 0.7], inf), inf),
        \dur, 1/4,
    )
);

// Combined percussion
Pdef(\perc_1_m, Ppar([
    Pdef(\kit_1),
    Pdef(\hats_1),
], inf));
)
