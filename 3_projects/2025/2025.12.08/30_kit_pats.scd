/////////////////////////////////////////////////////////////
// BD1
/////////////////////////////////////////////////////////////
// Pdefn(\bd1_bufs, ~fbufs[\bass_drums][0] );
(
// words
Pdefn(\bd1_durm,  Pseq([1/4].flat, 1));
Pdefn(\bd1_dur0, Pseq([1].flat, 1));
Pdefn(\bd1_dur1, Pseq([1/2 ! 3, Pn(Rest(), 1/2), 1/4 ! 2].flat, 1));
Pdefn(\bd1_dur2, Pseq([1/8 ! 8, Rest() ! 2].flat, 1));
Pdefn(\bd1_dur3, Pbjorklund2(5, 8,  1));
// SC only
// Pdefn(\bd1_idx, Pseq([1!3,  2,  ].flat, inf), 2);
);
// phrases
(
Pdefn(\bd1_phr0,
    Pseq([
        Pn(Pdefn(\bd1_durm), 4), 
        // Pn(Pdefn(\bd1_durm), 2), 
        // Pn(Pdefn(\bd1_dur1), 2),
        // Pn(Pdefn(\bd1_dur3), 1),
    ], 1));  

Pdefn(\bd1_phr1,
    Pseq([
        Pn(Pdefn(\bd1_dur0), 4), 
        Pn(Pdefn(\bd1_durm), 2), 
        Pn(Pdefn(\bd1_dur1), 2),
        Pn(Pdefn(\bd1_dur3), 1),
    ], 1));  

Pdefn(\bd1_phr2,
    Pseq([
        Pn(Pdefn(\bd1_dur0), 1),
        Pn(Pdefn(\bd1_dur1), 1),
        Pn(Pdefn(\bd1_dur2), 1)
    ], 1));

// sentences
Pdefn(\bd1_phr, Pseq([
  Pn(Pdefn(\bd1_phr0), 4),   
  Pn(Pdefn(\bd1_phr1), 1),   
  Pn(Pdefn(\bd1_phr2), 1),   
],  1));
);

/////////////////////////////////////////////////////////////
// SD1
/////////////////////////////////////////////////////////////
// Pdefn(\sd1_bufs, ~fbufs[\snare_drums][0] );

// words
(
// Pdefn(\sd1_durm,  Ptpar([1/4,  Pseq([1/2],  1) ]));
Pdefn(\sd1_durm,  Pseq([1/2],  1) );
Pdefn(\sd1_dur0,  Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1));
Pdefn(\sd1_dur0,  Pseq([Pbjorklund2(3,  16,  1)/4],  1));

Pdefn(\sd1_idxt, Pseq([2, ], inf));
);
(
// phrases
Pdefn(\sd1_phr1,
    Pseq([
        Pn(Pdefn(\sd1_durm), 1), 
        Pn(Pdefn(\sd1_dur0), 2),
        // Pn(Pdefn(\sd1_dur1), 1),
    ], 1)
);

Pdefn(\sd1_phr2,
    Pseq([
        Pn(Pdefn(\sd1_dur0), 1),
        Pn(Pdefn(\sd1_dur1), 1),
        Pn(Pdefn(\sd1_dur2), 1)
    ], 1)
);

Pdefn(\sd1_phr, 
Pseq([
  Pn(Pdefn(\sd1_phr1),  2), 
  // Pn(Pdefn(\sd1_phr2),  1), 
],  1)
);
);

/////////////////////////////////////////////////////////////
// HH1
/////////////////////////////////////////////////////////////
// Pdefn(\hh1_bufs, ~fbufs[\hats][0] );

// words
(
// Pdefn(\hh1_durm,  Ptpar([1/8,  Pseq([1/8].flat,  1)));
Pdefn(\hh1_durm,  Pseq([1/2].flat,  8));
Pdefn(\hh1_dur0,  Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1));
Pdefn(\hh1_dur1,  Pseq([Pbjorklund2(13,  16,  4)]/4,  1));

Pdefn(\hh1_ampm,  Pseq([0.5!7, 0.9].flat, 4));

Pdefn(\hh1_idx,   Pseq([1,   ], 4));
);
// phrases
(
Pdefn(\hh1_phr1,
    Pseq([
        Pn(Pdefn(\hh1_durm), 4), 
        // Pn(Pdefn(\hh1_dur0), 2),
        // Pn(Pdefn(\hh1_dur1), 1),
    ], 4)
);

Pdefn(\hh1_phr2,
    Pseq([
        Pn(Pdefn(\hh1_dur0), 4),
        Pn(Pdefn(\hh1_dur1), 4),
        Pn(Pdefn(\hh1_dur2), 4)
    ], 1)
);

Pdefn(\hh1_phr, 
  Pseq([
    Pn(Pdefn(\hh1_phr1),  1), 
    // Pn(Pdefn(\hh1_phr2),  1), 
  ],  1)
);
);
