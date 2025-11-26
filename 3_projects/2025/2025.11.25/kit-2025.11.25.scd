// kit hits
(
Pdefn(\kit_deg1, Pseq(
  [
    [0, \,  6], [\, \,  6], [0,  2,  6], [\,  2,  6], [0,  \,  6], [\,  \,  6], [0, \,  6], [12,  2,  6], 
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
Pdefn(\kit_deg3, Pseq(
  [
    [12, \,  \], [\, \,  \], [\,  \,  \], [\,  2,  \], [\,  2,  \], [\,  \,  \], [12, \,  \], [0,  \,  \], 
  ]
),  inf );
)

(
Pdefn(\kit_01_deg, Pseq(
  [
    Pn(Pdefn(\kit_deg3),  1), 
    Pn(Pdefn(\kit_deg1),  4),
    Pn(Pdefn(\kit_deg2), 4),
    Pn(Pdefn(\kit_deg3),  1) 
  ],  inf));
)
// duration
Pdefn(\kit_dur1,  Pseq([1/2],   inf));
Pdefn(\kit_dur2,  Pseq([1/2!4,   1/4!4].flat,  inf));
Pdefn(\kit_dur3,  Pbjorklund2(3,  8,  inf)/4);
(
Pbindef(\kit, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      0,
  \scale,     Scale.chromatic,  
  \amp,       Pwhite(0.6,  0.8,  inf),
  \octave,    3,
  \degree,    Pdefn(\kit_01_deg),  
  \dur,       Pn(Pdefn(\kit_dur1),  inf),  
);
)
Pbindef(\kit,  \dur,   1/2);
Pbindef(\kit,  \dur,   Pdefn(\kit_dur3));
Pbindef(\kit).play(~link,  quant:1);
Pbindef(\kit).stop;

