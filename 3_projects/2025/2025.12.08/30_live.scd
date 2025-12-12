/////////////////////////////////////////////////////////////
// BD1
/////////////////////////////////////////////////////////////
// Pdefn(\bd1_bufs, ~fbufs[\bass_drums][0] );

// words
Pdefn(\bd1_durm,  1/4);
Pdefn(\bd1_dur0, Pseq([1/2 ! 3, Pn(Rest(), 1/2), 1/4 ! 2].flat, 1));
Pdefn(\bd1_dur2, Pseq([1/8 ! 8, Rest() ! 2].flat, 1));
Pdefn(\bd1_dur3, Pbjorklund2(5, 8,  1));
// SC only
Pdefn(\bd1_idx, Pseq([1!3,  2,  ].flat, inf), 2);

// phrases
(
Pdefn(\bd1_phr1,
    Pseq([
        Pn(Pdefn(\bd1_durm), 4), 
        Pn(Pdefn(\bd1_dur0), 2),
        Pn(Pdefn(\bd1_dur3), 1),
    ], 1)
);

Pdefn(\bd1_phr2,
    Pseq([
        Pn(Pdefn(\bd1_dur0), 1),
        Pn(Pdefn(\bd1_dur1), 1),
        Pn(Pdefn(\bd1_dur2), 1)
    ], 1)
);

// sentences
Pdefn(\bd1_phr, Pseq([Pdefn(\bd1_phr1), Pdefn(\bd1_phr2)],  inf));
)
