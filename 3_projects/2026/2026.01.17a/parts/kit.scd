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
    ], 2));

Pdefn(\kit_deg_0b,
    Pseq([
        [2], [\], [2], [\], [2], [\], [3], [\],
    ], 2));

Pdefn(\kit_deg_0b,
    Ptuple([
      Pser([0, 4, 0, \, 0,  \], 8), 
      Pser([\,  2, \,  3, ], 8), 
      // Pseq([5, 6, ],  4),  
    ],  1)
  );
  // Pif((Pbjorklund(3,  16,  1)*8) > 0, Pseq([[2,  4],  0], inf), Pseq([\],  inf)));
  // Place([2, [[0, ], [9, 2,  3],  [3,  1],  ], Pn(Rest(), 2)],  
  // 8));
Pdefn(\kit_deg_0c,
    Ptuple([
      Place([0, [4,  1,  6], [5, 8], [\, 4]], Pxrand((1..16), 1)), 
      Place(#[2,  [2,  3]], 1).stutter(2),  
    ], 1));

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
    // // Pn(Rest(),  4), 
    Pn(Pdefn(\kit_deg_0c), 8),
    // Pn(Pdefn(\kit_deg_1), 4), 
    // Pn(Pdefn(\kit_deg_2), 4),
], 1));

Pdefn(\kit_dur_0, Pseq([1/3], 8) * Place([4, [2,  3]], 8));
Pdefn(\kit_dur_1, Pseq([1/4], 7));

Pdefn(\kit_dur_2,  Pbjorklund(3,  8,  1)/2);

Pdefn(\kit_durs,  Prand([
  Pn(Pdefn(\kit_dur_0),  8), 
],  1));

Pdef(\perc,
    Pbindef(\perc_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.kit,
        \scale, Scale.chromatic,
        \root, 0,
        \octave, 3,
        \degree, Pn(Pdefn(\kit_degs), inf),
        \amp, Pwhite(0.5, 0.7,  inf),
        \dur, Pn(Pdefn(\kit_durs),  inf),
    )
);
)

