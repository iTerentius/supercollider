(
Pdefn(\bass_deg1 , Pseq(
  [
  0,   0,    0,    \,    \,    \,    \,    \,    
  \,   \,    \,    \,    7,    4,    2,    \,    
  0,   0,    0,    \,    \,    \,    \,    \,    
  \,   \,    \,    \,    \,    \,    \,    \,    
  ],inf));
)
Pdefn(\bass_deg2, Pseq([Pwhite(0, 7, inf),  \,  \,  \],  inf));
(
Pbindef(\bass, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      1,
  \scale,     Scale.minor,  
  \amp,       0.8,
  // \octave,    Prand([4, 3,   ], inf),
  \octave,   3, 
  \degree,    Pdefn(\bass_deg1),
  // \sustain,   Pseq([1/2!16,  1/4!2, 1/8!4 ].flat, inf),   
  \sustain,  1, 
  \dur,      1/2, 
);
)
Pbindef(\bass,   \degree, Pdefn(\bass_deg1));
Pbindef(\bass,  \dur,  Pn(Pdefn(\kit_01_dur),  inf)); 
Pbindef(\bass).play(~link,  quant: 4);
Pbindef(\bass).stop;
