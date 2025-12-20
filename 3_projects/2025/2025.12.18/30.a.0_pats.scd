/////////////////////////////////////////////////////////////
// a000
/////////////////////////////////////////////////////////////
// Pdefn(\a000_bufs, ~fbufs[\bass_drums][0] );
(
// words
Pdefn(\a000_durm, Pseq((0.125 .. 1.00), 8));
Pdefn(\a000_dur0, Pseq([1].flat, 1));
Pdefn(\a000_dur1, Pseq([1/2 ! 3, Pn(Rest(), 1/2), 1/4 ! 2].flat, 1));
Pdefn(\a000_dur2, Pseq([1/8 ! 8, Rest() ! 2].flat, 1));
Pdefn(\a000_dur3, Pbjorklund2(5, 8,  1));
// SC only
// Pdefn(\a000_idx, Pseq([1!3,  2,  ].flat, inf), 2);
);
// phrases
(
Pdefn(\a000_phr0,
    Pseq([
        Pn(Pdefn(\a000_durm), 1), 
        Pn(Pdefn(\a000_dur0), 2), 
        Pn(Pdefn(\a000_dur1), 2),
        Pn(Pdefn(\a000_dur2), 2),
        Pn(Pdefn(\a000_dur3), 1),
    ], 1));  

Pdefn(\a000_phr1,
    Pseq([
        Pn(Pdefn(\a000_dur0), 4), 
        Pn(Pdefn(\a000_durm), 2), 
        Pn(Pdefn(\a000_dur1), 2),
        Pn(Pdefn(\a000_dur3), 1),
    ], 1));  

Pdefn(\a000_phr2,
    Pseq([
        Pn(Pdefn(\a000_durm), 1),
        // Pn(Pdefn(\a000_dur1), 1),
        Pn(Pdefn(\a000_dur2), 1)
    ], 1));

// sentences
Pdefn(\a000_phr, Pseq([
  Pn(Pdefn(\a000_phr0), 1),   
//   Pn(Pdefn(\a000_phr1), 1),   
//   Pn(Pdefn(\a000_phr2), 1),   
],  1));
);

/////////////////////////////////////////////////////////////
// a100
/////////////////////////////////////////////////////////////
// Pdefn(\a100_bufs, ~fbufs[\snare_drums][0] );

// words
(
// Pdefn(\a100_durm,  Ptpar([1/4,  Pseq([1/2],  1) ]));
Pdefn(\a100_durm,  Pseq([1/2],  1) );
Pdefn(\a100_dur0,  Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1));
Pdefn(\a100_dur0,  Pseq([Pbjorklund2(3,  16,  1)/4],  1));

Pdefn(\a100_idxt, Pseq([2, ], inf));
);
(
// phrases
Pdefn(\a100_phr1,
    Pseq([
        Pn(Pdefn(\a100_durm), 1), 
        Pn(Pdefn(\a100_dur0), 2),
        // Pn(Pdefn(\a100_dur1), 1),
    ], 1)
);

Pdefn(\a100_phr2,
    Pseq([
        Pn(Pdefn(\a100_dur0), 1),
        Pn(Pdefn(\a100_dur1), 1),
        Pn(Pdefn(\a100_dur2), 1)
    ], 1)
);

Pdefn(\a100_phr, 
Pseq([
  Pn(Pdefn(\a100_phr1),  2), 
  // Pn(Pdefn(\a100_phr2),  1), 
],  1)
);
);

/////////////////////////////////////////////////////////////
// a200
/////////////////////////////////////////////////////////////
// Pdefn(\a200_bufs, ~fbufs[\hats][0] );

// words
(
// Pdefn(\a200_durm,  Ptpar([1/8,  Pseq([1/8].flat,  1)));
Pdefn(\a200_durm,  Pseq([1/2].flat,  8));
Pdefn(\a200_dur0,  Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1));
Pdefn(\a200_dur1,  Pseq([Pbjorklund2(13,  16,  4)]/4,  1));

Pdefn(\a200_ampm,  Pseq([0.5!7, 0.9].flat, 4));

Pdefn(\a200_idx,   Pseq([1,   ], 4));
);
// phrases
(
Pdefn(\a200_phr1,
    Pseq([
        Pn(Pdefn(\a200_durm), 4), 
        // Pn(Pdefn(\a200_dur0), 2),
        // Pn(Pdefn(\a200_dur1), 1),
    ], 4)
);

Pdefn(\a200_phr2,
    Pseq([
        Pn(Pdefn(\a200_dur0), 4),
        Pn(Pdefn(\a200_dur1), 4),
        Pn(Pdefn(\a200_dur2), 4)
    ], 1)
);

Pdefn(\a200_phr, 
  Pseq([
    Pn(Pdefn(\a200_phr1),  1), 
    // Pn(Pdefn(\a200_phr2),  1), 
  ],  1)
);
);
