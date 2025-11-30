(
Pdefn(\bass_deg2 , Pseq(
  [
  0,   0,    0,    \,    \,    \,    2,    \,    
  4,   \,    \,    \,    7,    4,    2,    \,    
  0,   0,    0,    \,    \,    \,    \,    \,    
  \,   \,    \,    \,    \,    \,    \,    \,    
  ],inf));
)
Pdefn(\bass_deg2, Pseq([Pwhite(0, 7, 4), Pn(Rest(),  4)],  inf));
Pdefn(\bass_deg2, Pseq([0,  \,  4,  Pxrand([0, 7],  2),  2,  \,  0,  Pn(Rest(),  3)],  inf));
Pdefn(\bass_deg2, Pseq([0!4,  Pn(Rest(),  12)].flat, inf));
(
Pbindef(\bass, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      1,
  \root,      5, 
  \scale,     Scale.dorian,  
  \amp,       0.8,
  // \octave,    Prand([4, 3,   ], inf),
  \octave,   2, 
  \degree,    Pdefn(\bass_deg2),
  \sustain,  1, 
  \dur,      1/4, 
);
)
Pbindef(\bass, \dur,  Pseq([1/4],  inf));
Pbindef(\bass, \dur,  Pseq([1/4,   1/2],  inf));
Pbindef(\bass,   \degree, Pdefn(\bass_deg2));
Pbindef(\bass,   \root, 5);
Pbindef(\bass,   \octave, Pseq([2, 2, 3,2],   inf));
Pbindef(\bass,  \legato,   Pseq([1/2!8,  1/4!2, 1/8!4 ].flat, inf));
Pbindef(\bass,  \legato,   Pn(Pdefn(\k2_dur)/Pwhite(1.5, 2.8,  1), inf));
Pbindef(\bass,  \sustain,   Pn(Pdefn(\k2_dur)/Pwhite(0.5, 1.8,  1), inf));
Pbindef(\bass).play(~link,  quant: 1);
Pbindef(\bass).stop;

Scale.names;
