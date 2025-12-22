~link.tempo = 120/60;
(
Pdefn(\b000_durs, Pn(Pdefn(\a000_durs), 1));
Pdef(\b000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.minor,
  \root,  0,
  \octave,  Pn(Pseq([4!2,   5].flat, 1),  inf),
  // \octave,  Pn(Pseq([4].flat, 1),  inf),
  \amp,     Pn(Pseq([0.8, 0.7],   1),  inf).stutter(4),
  // \degree,  Place([0,[7,  4,  2,  ],  1,  4,  \,  ].stutter(8), inf),
  \degree,  Pseq([0,  2,   4, ],  inf).stutter(12),
  \legato,  Pkey(\dur)*Pkey(\amp).stutter(8), 
  // \dur,     Pn(Pseq([1/4!2, 1/2,  1,  1/8!2,  1/2,   1/4].flat,   1), inf),
  // \dur,     Pn(Pseq([1/4!2, 1/2!2, Pn(Rest(), 1.25)].flat,   1)*2, inf),
  \dur_mult,  Pseq([4, 2  ],  inf).stutter(1), 
  \dur,     Pn(Pdefn(\b000_durs)
  *Pkey(\dur_mult)
  , inf), 
));

Pdef(\m000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  3,  \scale,  Scale.minor,
  \root,    Pstep(Pseq([0,  -2, -4, 5], inf), j), 
  \octave,  Pn(Pseq([4!3, 5,  ].flat, 1).stutter(4),  inf),
  \amp,     Pn(Pxrand([0.7, 0.6],   1),  inf),
  \degree,  Pn(Place([0, [4,  2,  7]], inf).stutter(8), inf),
  // \legato,  Pn(Pdefn(\a000_dur1)*(Pkey(\amp)+2), inf), 
  // \dur,     Pn(Pseq([1/3!2, 3/4,  2,  1/6!2,  Pn(Rest(), 1.75)].flat,   1), inf)/3,
  \dur,     Pn(Pdefn(\b000_durs)*2, inf), 
));

// Pdefn(\a000_deg0, Pseq([[4, 2], [0,  15,  6],  [0, 4,  15], [0, 6, 15]], 4));
// Pdefn(\a000_deg1, Place([5, [0, 6],  [1,  8,  ],  [0, 5, ],  [3, 4, 0]], 1));
Pdefn(\a000_deg0, Pseq([[0, 2], [8,  12,  6],  [8, 13,  7,  0], [8, 6, 12,  ]], 4));
Pdefn(\a000_deg1, Place([6, [8, 6],  [0,  8,  6],  [8, 6, 13],  [13, 9, ]], 1));

Pdefn(\a000_duri0, Pseq([1/4!2, Rest(1/2), 1/2, 1/8!4].flat,  1));
Pdefn(\a000_durm0, Pseq([1/4].flat,   1));
Pdefn(\a000_durm1, Pseq([1/2].flat,   8)/Pseq([4,  2,  1], 1).stutter(4));
Pdefn(\a000_durm2, Pseq([1/4].flat,   8)*Pseq([1,  2,  4], 1).stutter(4));
Pdefn(\a000_dur0, Pser([1/4,  1/2,  1,  Pn(Rest(),  1)].flat,   Pseq([1, 3,  4], 1).stutter(4))/Pseq([1,  2,  4], 1)); 
Pdefn(\a000_dur1, Pseq([1/4!2, 1/8!4, 1/2, Rest(1/2)].flat,   1)); 

Pdefn(\a000_degs,  Pseq([
  Pn(Pdefn(\a000_deg0), 4), 
  Pn(Pdefn(\a000_deg1), 1), 
], 1));

Pdefn(\a000_durs,  Pseq([
  // Pn(Pdefn(\a000_duri0), 1),  
  // Pn(Pdefn(\a000_durm0), 8), 
  Pn(Pdefn(\a000_durm1), 4), 
  Pn(Pdefn(\a000_durm0), 1), 
  Pn(Pdefn(\a000_durm2), 4), 
  // Pn(Pdefn(\a000_dur0), 1), 
], 1));

Pdefn(\a000_phr0,
    Pseq([
        Pn(Pdefn(\a000_dur0), 2), 
        Pn(Pdefn(\a000_dur1), 2),
        Pn(Pdefn(\a000_dur3), 1),
    ], 1));  

Pdefn(\a000_phr1,
    Pseq([
        Pn(Pdefn(\a000_dur0), 4), 
        Pn(Pdefn(\a000_durm), 2), 
        Pn(Pdefn(\a000_dur1), 2),
        Pn(Pdefn(\a000_dur3), 1),
    ], 1));  

Pdefn(\a000_phr2,
    Pseq([
        Pn(Pdefn(\a000_durm), 1),
        // Pn(Pdefn(\a000_dur1), 1),
        Pn(Pdefn(\a000_dur2), 1)
    ], 1));

// sentences
Pdefn(\a000_phr, Pseq([
  Pn(Pdefn(\a000_phr0), 1),   
//   Pn(Pdefn(\a000_phr1), 1),   
//   Pn(Pdefn(\a000_phr2), 1),   
],  1));

Pdef(\a000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  0,  \scale,  Scale.chromatic,
  \octave,  3,  
  \amp,     Pn(Pseq([0.8, 0.7],   1),  inf),
  \degree,  Pn(Pdefn(\a000_degs),  inf),  
  \dur,     Pn(Pdefn(\a000_durs)*2, inf), 
));

Pdef(\a100_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  5,  \scale,  Scale.chromatic,
  \octave,  Pseq([4,3], inf).stutter(2),   
  \amp,     Pn(Pseq([0.8, 1.0],   1),  inf),
  \degree,  Pn(Place([0, 6,  [1,  5,  ],  [0, 5, ]], 3,  4, 0,  0, 1, 0, inf).stutter(3),  inf),  
  \timeOffset,  1/4,  
  // \dur,     Pn(Pseq([1/4!2, 1/8!4, 1/2, Rest(1/2)].flat,   1), inf), 
  \dur, Pn(Pdefn(\a000_durm0)*2, inf), 
));

Pdef(\a000, Pdef(\a000_m));
Pdef(\a100, Pdef(\a100_m));
Pdef(\b000, Pdef(\b000_m));
~apcAssignPad.(35, \b000);
~lcxlBindPdef.(\b1_s5_p, \b000);
~lcxlBindPdef.(\b1_s6_p, \m000);
~lcxlBindPdef.(\b1_s1_p, \a000);
~lcxlBindPdef.(\b1_s7_p, \a100);
Pdef(\m000, Pdef(\m000_m));
)
~link.tempo = 110/60;
~link.tempo * 60;
Pdef(\a000_m).clear;
Pdef(\a000).play(~link);
Pdef(\a000).stop;
Pdef(\a100).play(~link);
Pdef(\a100).stop;
Pdef(\b000).play(~link);
Pdef(\b000).stop;
Pdef(\m000).play(~link);
Pdef(\m000).stop;
