
(
Pdefn(\bass_1_deg_0,
  Pshuf([0!4].flat,  1)
);

Pdefn(\bass_1_deg_1,
  Pseq([
    0,      
  ], 1));

Pdefn(\bass_1_degs, Pseq([
  Pn(Pdefn(\bass_1_deg_1), 1),
], 1));

Pdefn(\bass_1_dur_0,
  Pseq([1/2!2,  1!3].flat, 1)/2);

Pdefn(\bass_1_dur_1,
  Pbjorklund(7,  8, inf));

Pdefn(\bass_1_durs, 
  Pseq([
    Pn(Pdefn(\bass_1_dur_0),  1), 
  ],  1));

Pdef(\bass,
    Pbindef(\bass_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.bass,
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 3,
        \degree, Pn(Pdefn(\bass_1_degs),  inf),
        // \degree,  0,  
        \delta, 1, 
        \legato,  Pkey(\delta)*Pkey(\dur)+1/8, 
        \amp, 0.6,
        // \dur, Pbjorklund2(5,  8,  4), 
        // \dur, Pseq([1/3, Rest(2/3)],  inf),   
        \dur, Pn(Pdefn(\bass_1_durs), inf), 
    )
);
)
