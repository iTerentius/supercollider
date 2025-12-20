~link.tempo = 120/60;
(
Pdefn(\b000_durs, Pn(Pdefn(\a000_durs), 1));
Pdef(\b000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.minor,
  \root,  5,
  \octave,  Pn(Pseq([3!2, 2 ].flat, 1),  inf),
  \amp,     Pn(Pseq([0.8, 0.7],   1),  inf).stutter(2),
  \degree,  Pseq([0,  7,  4,  2,  \,  1,  4,  \,  ], inf),
  \legato,  Pkey(\dur), 
  // \dur,     Pn(Pseq([1/4!2, 1/2,  1,  1/8!2,  1/2,   1/4].flat,   1), inf),
  \dur,     Pn(Pdefn(\b000_durs), inf), 
));

Pdef(\m000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  3,  \scale,  Scale.minor,
  \root,  5,
  \octave,  Pn(Pxrand([4!2, 6,  5,].flat, 1),  inf),
  \amp,     Pn(Pxrand([0.7, 0.6],   1),  inf),
  \degree,  Pn(Pdup(Place([0, [4,  [2,  7]]],  4),  2), inf),
  \legato,  Pn(Pdefn(\a000_dur1)*(Pkey(\amp)+2), inf), 
  \dur,     Pn(Pseq([1/3!2, 3/4,  2,  1/6!2,  Pn(Rest(), 1.75)].flat,   1), inf)/3,
));

Pdefn(\a000_deg0, Pseq([[4, 2], [0,  15,  6],  [0, 4,  15], [0, 6, 15]], 4));
Pdefn(\a000_deg1, Place([5, [0, 6],  [1,  8, 0 ],  [0, 5, ],  [3, 4, 0]], 1));

Pdefn(\a000_dur0, Pseq([1/4].flat,   4)); 
Pdefn(\a000_dur1, Pseq([1/4!2, 1/8!4, 1/2, Rest(1/2)].flat,   1)); 

Pdefn(\a000_degs,  Pseq([
  Pn(Pdefn(\a000_deg0), 12), 
  Pn(Pdefn(\a000_deg1), 1), 
], 1));

Pdefn(\a000_durs,  Pseq([
  Pn(Pseq([1/4!2, Rest(1/2), 1/2, 1/8!4].flat,  1), 1),  
  Pn(Pdefn(\a000_dur0), 12), 
  Pn(Pdefn(\a000_dur1), 1), 
], 1));


Pdef(\a000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  0,  \scale,  Scale.chromatic,
  \octave,  3,  
  \amp,     Pn(Pseq([0.8, 0.7],   1),  inf),
  \degree,  Pn(Pdefn(\a000_degs),  inf),  
  \dur,     Pn(Pdefn(\a000_durs), inf), 
));

Pdef(\a100_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  0,  \scale,  Scale.chromatic,
  \octave,  3,  
  \amp,     Pn(Pseq([0.8, 0.7],   1),  inf),
  \degree,  Pn(Place([0, 6,  [1,  5,  ],  [0, 5, ]], 3,  4, 0, inf).stutter(2),  inf),  
  \dur,     Pn(Pseq([1/4!2, 1/8!4, 1/2, Rest(1/2)].flat,   1), inf), 
));

Pdef(\a000, Pdef(\a000_m));
Pdef(\b000, Pdef(\b000_m));
~apcAssignPad.(35, \b000);
~lcxlBindPdef.(\b1_s5_p, \b000);
~lcxlBindPdef.(\b1_s1_p, \a000);
Pdef(\m000, Pdef(\m000_m));
)
~link.tempo = 85/60;
~link.tempo * 60;
Pdef(\a000_m).clear;
Pdef(\a000).play;
Pdef(\a000).stop;
Pdef(\b000).play;
Pdef(\b000).stop;
Pdef(\m000).play;
Pdef(\m000).stop;
