// Bass
(
Pdefn(\bass_1_deg_0,
  Pshuf([0!4].flat,  1)
);

Pdefn(\bass_1_deg_1,
  Pseq([
    0,  2,  9,  7,  
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
        // \delta, Pkey(\dur), 
        \amp, 0.6,
        \dur, Pn(Pdefn(\bass_1_durs), inf), 
    )
);
)
