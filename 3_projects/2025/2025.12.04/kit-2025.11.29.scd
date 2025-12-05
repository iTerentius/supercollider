(
Pdefn(\k2_kick1_deg1,   Pseq(
  [
    0,  \,  \,  \,  0,  \,  \,  \,  0,  \,  \,  \,  0,  \,  \,  \,
    0,  \,  \,  \,  0,  \,  0,   \,  0,  \,  0,   \,  0,  0,   0,   0,
  ], 1));


Pdefn(\k2_kick1_deg2,   Pseq(
  [
    0,  \,  \,  \,  \,  \,  \,  \,  \,  \,  \,    \,  0,  \,   0,  \,
    0,  \,  \,  \,  \,  \,  \,   \,  0,  \,  0,   \,  \,  \,   0,   0,
  ], 1));


Pdefn(\k2_hh1_deg1,   Pseq(
  [
    6,  6,  \,  \,    \, 6,  \,  \,    \,  6,  10,  \,    6,  \,  10,  \,
  ], inf));

Pdefn(\k2_hh1_deg2,   Pseq(
  [
    6,  \,      6,  \,  6,  \,  6,  \,  6,  \,  6,  \,  6,  \,  6,  10,
  ],  inf));
)
(
Pdefn(\k2_deg,  Pseq([
  Pn(Pdefn(\k2_kick1_deg1),  1),  
  Pn(Pdefn(\k2_kick1_deg2),  4),  
],  inf));
)
Pdefn(\k2_dur,   \dur,       Pseq([1/2],  inf));
(
Pbindef(\k2_kick1, \type, \midi, \midiout, ~mOut, \scale, Scale.chromatic, \chan, 0, \octave,    3,
  \amp,  0.7, 
  \degree,    Pdefn(\k2_deg),
  \dur,  1/2, 
);
)
Pbindef(\k2_kick1,  \degree,  Pn(Pdefn(\k2_kick1_deg1)));
Pbindef(\k2_kick1,  \degree,  Pn(Pdefn(\k2_kick1_deg2)));
(
Pbindef(\k2_hh1, \type, \midi, \midiout, ~mOut, \scale, Scale.chromatic, \chan, 0, \octave,    3,
  \amp,  0.5, 
  \degree,    Pn(Pdefn(\k2_hh1_deg2), inf),
  \dur,  1/4, 
);
)
(
Pdef(\k2_kit, 
  Ptpar([
    0,  Pbindef(\k2_kick1),
    0,  Pbindef(\k2_hh1),   
  ]), 
);
)
Pdef(\k2_kit).play(~link,   quant:4);
Pdef(\k2_kit).stop;
Pdef(\k2_kit).clear;


Pbindef(\k2_kick1,  \dur, 1/4);
Pbindef(\k2_hh1,  \dur, 1/4);
Pbindef(\k2_kit,  \degree,  Pn(Pdef(\k2_kit_deg),  inf));
Pbindef(\k2_kick1,  \degree, Pn(Pdefn(\k2_deg), inf));
Pbindef(\kit2,  \degree, Pdef(\kit1_deg));
Pbindef(\k2_kick1,     \dur,       Pseq([1/8!2, 1/4!16,  ].flat,  inf));
Pbindef(\k2_kick1,  \dur, Pbjorklund2(5, 8,  inf)/4);
[1!3,   1/4!8].flat;
