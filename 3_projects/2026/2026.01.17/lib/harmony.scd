// Harmony - root progressions and scale definitions
(
// Root progression fragments
Pdefn(\root_deg_0, Place([4], 1));
Pdefn(\root_deg_1, Pseq([2, 1, 0, 1], 1));

// Combined root progression
Pdefn(\root_degs, Pseq([
    Pn(Pdefn(\root_deg_0), 4),
    Pn(Pdefn(\root_deg_1), 4),
], 1));

// Chord voicings
Pdefn(\harms, PHarmony(
    [\minor, \minor, \major, \major],
));
)
