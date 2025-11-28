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
    [12, \,  \], [\, \,  \], [\,  \,  \], [\,  2,  \], [\,  2,  \], 
    Pseq([[\,  2,  \], [\,  2,  \,]], 1),
    [12, \,  \], [0,  \,  \], 
  ]
),  inf );
)

Pdefn(\kit_durg3, Pseq([1/2!5,  Pseq([1/4!2].flat,  1), 1/2!2  ].flat),  inf );
[1/2!5,  Pseq([1/4!2].flat,  inf), 1/2!2  ].flat

(
Pdefn(\kit_01_deg, Pseq(
  [
    Pn(Pdefn(\kit_deg3),  1), 
    Pn(Pdefn(\kit_deg1),  4),
    Pn(Pdefn(\kit_deg2), 4),
    Pn(Pdefn(\kit_deg3),  1) 
  ],  inf));
)
(
Pdefn(\kit_01_dur, Pseq(
  [
    Pn(Pdefn(\kit_durg3),  1), 
    Pn(Pdefn(\kit_dur1),  4),
    Pn(Pdefn(\kit_dur3), 4),
    Pn(Pdefn(\kit_durg3),   1),  
  ],  inf));
)
// duration
Pdefn(\kit_dur1,  Pseq([1/2],   2));
Pdefn(\kit_dur2,  Pseq([1/2!8,   1/4!8].flat,  2));
Pdefn(\kit_dur3,  Pbjorklund2(5,  8,  2)/4);
(
Pdefn(\kit_01_dur,   Pseq(
  [
    Pn(Pdefn(\kit_dur1),  1),
    Pn(Pdefn(\kit_dur2),  1),
    Pn(Pdefn(\kit_dur3),  1),
  ],  inf));
)
(
Pbindef(\kit, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      0,
  \scale,     Scale.chromatic,  
  \amp,       Pwhite(0.6,  0.8,  inf),
  \octave,    3,
  \degree,    Pdefn(\kit_01_deg),  
  // \dur,       Pseq([Pn(Pdefn(\kit_dur1),   inf),  Pn(Pdefn(\kit_dur2),  inf), Pn(Pdefn(\kit_durg3),  inf)],  inf),  
  \dur,       Pdefn(\kit_01_dur), 
);
)
Pbindef(\kit,  \dur,   1/2);
Pbindef(\kit,  \dur,   Pn(Pdefn(\kit_dur3),  inf));
Pbindef(\kit,  \dur,   Pn(Pdefn(\kit_01_dur), inf));
Pbindef(\kit).play(~link,  quant:4);
Pbindef(\kit).stop;
Pbindef(\kit).clear;

