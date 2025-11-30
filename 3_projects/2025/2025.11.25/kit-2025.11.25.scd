// kit hits
(
Pdefn(\kit_deg1, Pseq(
  [
    [0, \,  6], [\, \,  6], [0,  2,  6], [\,  2,  6], [0,  \,  6], [\,  \,  6], [0, \,  6], [\,  \,  6], 
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
    [12, \,  \], [\, \,  \], [\,  \,  \], [\,  \,  \], [\,  2,  \], 
    Pseq([[\,  2,  \], [\,  2,  \,]], 1),
    [12, \,  \], [0,  \,  \], 
  ]
),  inf );
)

Pdefn(\kit_durg3, Pseq([1/2!5,  Pseq([1/4!2].flat,  1), 1/2!2  ].flat),  inf );
(
~kit_1_len = 4;
~kit_2_len = 8;
~kit_3_len = 1;

Pdefn(\kit_01_deg, Pseq(
  [
    Pn(Pdefn(\kit_deg3),  ~kit_3_len),
    Pn(Pdefn(\kit_deg1),  ~kit_1_len),
    Pn(Pdefn(\kit_deg2),  ~kit_2_len),
    Pn(Pdefn(\kit_deg3),  ~kit_3_len),
  ],  inf));


Pdefn(\kit_01_dur, Pseq(
  [
    Pn(Pdefn(\kit_durg3),  ~kit_3_len),
    Pn(Pdefn(\kit_dur1),   ~kit_1_len),
    Pn(Pdefn(\kit_dur2),   ~kit_2_len),
    Pn(Pdefn(\kit_durg3),  ~kit_3_len),
  ],  inf));
)
// duration
(
Pdefn(\kit_dur1,  Pseq([1/2],   2));
Pdefn(\kit_dur2,  Pseq([1/2!8,   1/4!8].flat,  2));
Pdefn(\kit_dur3,  Pbjorklund2(5,  8,  2)/4);
)
Pdefn(\rhythm,   Pn(Pdefn(\kit_01_dur),  inf));
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
Pbindef(\kit,  \dur,   Pn(Pdefn(\kit_dur2),  inf));
Pbindef(\kit,  \dur,   Pdefn(\rhythm));
Pbindef(\kit, \sustain,  2);
Pbindef(\kit).play(~link,  quant:1);
Pbindef(\kit).stop;
Pbindef(\kit).clear;


