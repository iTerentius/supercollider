// Percussion
(
Pdefn(\kit_deg_0,
    Pseq([
        [0, 2], [\], [\], [\], [\], [\], [\], [\],
        [0, 2], [\], [\], [\], [4], [\], [1], [\],
    ], 1));

Pdefn(\kit_deg_0a,
    Pseq([
        [0, 2], [\], [\], [\], [2], [\], [3], [\],
    ], 1));

Pdefn(\kit_deg_0b,
    Pseq([
        [2], [\], [2], [\], [2], [\], [3], [\],
    ], 1));

Pdefn(\kit_deg_0b,
  Pif((Pbjorklund(3,  8,  1)*8) > 0, 2, [4, 0]));

Pdefn(\kit_deg_1,
    Pseq([
        [0, 2], [\], [\], [\], [2], [\], [\], [\],
        [0, 2], [\], [\], [\], [2], [\], [\], [\],
        [0, 2], [\], [\], [\], [2], [\], [\], [\],
        [0, 2], [\], [4], [\], [2], [\], [1,  3], [\],
    ], 1));

Pdefn(\kit_deg_2,
    Pseq([
        [0, 4], [\], [\], [\], [4], [\], [\], [\],
        [4], [\], [\], [\], [4], [\], [4], [\],
    ], 1));

Pdefn(\kit_degs, Pseq([
    // Pn(Pdefn(\kit_deg_0), 4),
    // Pn(Pdefn(\kit_deg_0a), 4),
    Pn(Rest(),  4), 
    Pn(Pdefn(\kit_deg_0b), 2),
    // Pn(Pdefn(\kit_deg_1), 4),
    // Pn(Pdefn(\kit_deg_2), 2),
], 1));

Pdef(\perc,
    Pbindef(\perc_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.kit,
        \scale, Scale.chromatic,
        \root, 0,
        \octave, 3,
        \degree, Pn(Pdefn(\kit_degs), inf),
        \amp, Pwhite(0.7, 0.7,  inf),
        \dur, 1/8,
    )
);
)
