(
Pdefn(\bass_deg1 , Pseq(
  [
  0,   0,    0,    \,    \,    \,    2,    \,    
  4,   \,    \,    \,    7,    4,    2,    \,    
  0,   0,    0,    \,    \,    \,    \,    \,    
  \,   \,    \,    \,    \,    \,    \,    \,    
  ],inf));
)
Pdefn(\bass_deg2, Pseq([Pshuf([0, 5, 4],  4), Pn(Rest(),  3)],  1));
Pdefn(\bass_deg3, Pseq([0,  \,  2,  Pxrand([0, 4],  2),  2,  \,  0,  Pn(Rest(),  3)],  1));
Pdefn(\bass_deg4, Pseq([0!4,  Pn(Rest(),  12)].flat, 1));
(
Pdefn(\bass_degs, Pseq([
  Pseq([
    Pn(Pdefn(\bass_deg4),  1),  
    Pn(Pdefn(\bass_deg3), 3), 
  ],  1), 
  Pseq([
    Pn(Pdefn(\bass_deg1), 2), 
    Pn(Pdefn(\bass_deg3), 2), 
  ], 1),  
],  inf));
)
(
Pbindef(\bass, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      1,
  \root,      5, 
  \scale,     Scale.dorian,  
  \amp,       0.9,
  // \octave,    Prand([4, 3,   ], inf),
  \octave,   2, 
  \degree,    Pdefn(\bass_degs),
  \sustain,  1, 
  \dur,      1/4, 
);
)
Pbindef(\bass).play(~link,  quant: 4);
Pbindef(\bass).stop;

Pbindef(\bass, \dur,  Pseq([1/2,  1],  inf));
Pbindef(\bass, \dur,  Pseq([1/4,   1/2],  inf));
Pbindef(\bass,   \degree, Pdefn(\bass_deg2));
Pbindef(\bass,   \root, 5);
Pbindef(\bass,   \octave, Pseq([2, 2, 3,2],   inf));
Pbindef(\bass,  \legato,   Pseq([1/2!8,  1/4!2, 1/8!4 ].flat, inf));
Pbindef(\bass,  \legato,   Pn(Pdefn(\k2_dur)/Pwhite(1.5, 2.8,  1), inf));
Pbindef(\bass,  \sustain,   Pn(Pdefn(\k2_dur)/Pwhite(0.5, 1.8,  1), inf));

Scale.names;
(
Pdef(\bass,
    Pbind(
        \type,    \midi,
        \midiout, ~mOut,
        \chan,    1,
        \scale,  Scale.dorian,
        \root,  5, 
        \octave,  2,  
        \degree, Pseq([0,  4, 0,  5,  4,  2,   Pn(Rest(),  2)],  inf)),  

        \amp,     0.9,
        \dur,     2,
        \sustain, 2
    )
);

Pdef(\bass).play(~link, quant:4);
Pdef(\bass).stop;
Pdef(\chordLine).clear;
