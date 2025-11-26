TempoClock.default.tempo = 80/60;
Pdefn(\k1_01 , Pseq([ 0,   \,    \,    \,     0,    \,    \,    0s,   ], 3));
Pdefn(\k1_02 , Pseq([ 0,   0,    \,    \,     0,    0,    \,          ], 1));
Pdefn(\h1_01 , Pseq([ \,   \,    1,    \,     \,    \,    1,    1s,    ], 8));
Pdefn(\h1_02 , Pseq([ \,   \,    1,    \,     \,    \,    1,    \,    ], 4));
(
Pbindef(\k1_01, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      0,
  \amp,       1,
  \octave,    3,
  \degree,    Pseq([Pdefn(\k1_01), Pdefn(\k1_02)]), 
  \dur,       0.25,
);
)
(
Pbindef(\h1_01, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      0,
  \amp,       1,
  \octave,    3,
  \degree,    Pseq([Pdefn(\h1_01)]), 
  \dur,       1/8,
);
)
(
Pdef(\k1, Ppar([
  Pbindef(\k1_01),  
  Pbindef(\h1_01),  
],  inf));
~apcAssignPad.(32, \k1);
~lcxlBindPdef.(\b1_s1_p, \k1);
)
Pdef(\k1).play();
Pdef(\k1).stop;
