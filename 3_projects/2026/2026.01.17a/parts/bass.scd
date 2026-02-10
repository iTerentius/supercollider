
(
Pdefn(\bass_1_deg_0,
  0
);

Pdefn(\bass_1_deg_1,
  Pseq([
    0,  -1,          
  ], 4)
);

Pdefn(\bass_1_deg_2,
  Pseq([
    Ppatlace([
      Pseries(0,  -1,  8),   
      Pseries(2,  1,  8),  
    ],  inf), 
  ],  8)
); 

Pdefn(\bass_1_degs, 
  Pseq([
    // Pn(Pdefn(\bass_1_deg_2),  8), 
    Pn(Pdefn(\bass_1_deg_0), 8),  
  ], 1)
); 

Pdefn(\bass_1_dur_0,
  // Pseq([1/2!2,  1!3].flat, 1)).stutter(4);
  Pseq([1/3], 1));

Pdefn(\bass_1_dur_1,
  Pbjorklund(5,  8, 1)/3);

Pdefn(\bass_1_durs, 
  Pseq([
    Pn(Pdefn(\bass_1_dur_0),  1), 
  ],  1));

Pdef(\bass,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.bass,
        \root, Pseq([0, Pkey(\root)], inf), 
        // \root, 0,
        \scale, Pkey(\scale),
        \octave, Pseq([4, ],  inf), 
        \degree, Pn(Pdefn(\bass_1_degs), inf),
        // \degree,  0,  
        // \delta, Pkey(\dur)*1, 
        // \legato,  Pkey(\dur)*1/Prand([1, 2,  4,  ], inf), 
        \amp, Pseq([0.8,  0.6], inf),
        // \dur, Pbjorklund2(5,  8,  4), 
        // \dur, Pseq([1/3, Rest(2/3)],  inf),   
        // \dur, Pn(Pdefn(\bass_1_durs), inf), 
        // \dur, Pn(Pdefn(\bass_1_durs), inf), 
        \delta, 1/3,  
        \dur, Pn(Pdefn(\kit_durs), inf), 
        // \dur, Pseq([
        //   Ppatlace([Pn(Pdefn(\bass_1_durs), 1), Pn(Pdefn(\kit_durs),  1)], 8), 
        //   Pn(Pdefn(\bass_1_durs), 8), 
        // ],  
        // inf), 
    )
);
)
