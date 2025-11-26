(
Pdefn(\kit_deg1, Pseq(
  [
    [0, \,  6], [\, \,  6], [0,  2,  6], [\,  2,  6], [0,  \,  6], [\,  \,  6], [0, \,  6], [0,  2,  6], 
  ]
),  inf );
)
(
Pdefn(\kit_deg2, Pseq(
  [
    [0, \,  \], [\, 10,  \], [\,  6,  \], [\,  2,  \], [\,  \,  6], [\,  \,  \], [0, \,  \], [\,  10,  6], 
  ]
),  inf );
)
(
Pbindef(\kit, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      0,
  \scale,     Scale.chromatic,  
  \amp,       Pwhite(0.6,  0.8,  inf),
  \octave,    3,
  \degree,    Pseq([Pn(Pdefn(\kit_deg1),  4), Pn(Pdefn(\kit_deg2), 4)],  inf), 
  \dur,       1/2,
);
)
Pbindef(\kit).play(~link,  quant:1);
Pbindef(\kit).stop;
