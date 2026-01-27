
(
Pdefn(\bass_1_deg_0,
  Pshuf([0].flat,  1)
);

Pdefn(\bass_1_deg_1,
  Pseq([
    0!3, Pn(Rest(), 2),        
  ].flat, 1));

Pdefn(\bass_1_degs, Pseq([
  Pn(Pdefn(\bass_1_deg_1), 1),
], 1));

Pdefn(\bass_1_dur_0,
  Pseq([1/2!2,  1!3].flat, 1)/3).stutter(4);

Pdefn(\bass_1_dur_1,
  Pbjorklund(7,  8, inf)/3);

Pdefn(\bass_1_durs, 
  Pseq([
    Pn(Pdefn(\bass_1_dur_1),  1), 
  ],  1));

Pdef(\bass,
    Pbindef(\bass_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.bass,
        \root, Pkey(\root),
        // \root, 0,
        \scale, Pkey(\scale),
        \octave, Pseq([3],  inf), 
        \degree, Pn(Pdefn(\bass_1_degs),  inf),
        // \degree,  0,  
        // \delta, 1/2, 
        // \legato,  Pkey(\delta)*Pkey(\dur), 
        \amp, Pseq([0.7,  0.4], 4),
        // \dur, Pbjorklund2(5,  8,  4), 
        // \dur, Pseq([1/3, Rest(2/3)],  inf),   
        // \dur, Pn(Pdefn(\bass_1_durs), inf), 
        \dur, Pn(Pdefn(\bass_1_durs), inf), 
    )
);
)
