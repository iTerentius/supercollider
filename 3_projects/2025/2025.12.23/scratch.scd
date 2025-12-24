~link.tempo = 120/60;
(
Pdefn(\b000_durs, Pn(Pdefn(\a000_durs), 1));
// Pdef(\b000_m, Pbind(
//   \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.minor,
//   \root,  0,
//   \octave,  Pn(Pstep(Pseq([4,   5], 1),  1),  inf),
//   // \octave,  Pn(Pseq([4].flat, 1),  inf),
//   \amp,     Pn(Pstep(Pseq([0.8, 0.7],   1),  1),  inf),
//   // \degree,  Place([0,[7,  4,  2,  ],  1,  4,  \,  ].stutter(8), inf),
//   \degree,  Pn(Pstep(Pseq([0,  2,   4, 2],  inf),  Pseq([4], inf), inf)),
//   \legato,  Pn(Pstep(Pkey(\dur)*Pkey(\amp), 4), inf), 
//   // \dur,     Pn(Pseq([1/4!2, 1/2,  1,  1/8!2,  1/2,   1/4].flat,   1), inf),
//   // \dur,     Pn(Pseq([1/4!2, 1/2!2, Pn(Rest(), 1.25)].flat,   1)*2, inf),
//   \dur_mult,  Pn(Pstep(Pseq([4, 2,  ],  inf),  Pseq([2],  inf)), inf), 
//   \dur,     Pn(Pdefn(\b000_durs)  
//   *Pkey(\dur_mult)
//   , inf), 
// ));
//
Pdef(\b000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.dorian,
  \root,    Pn(Pstep(Pseq([0,  -4, -2, 5], inf), 8),  inf), 
  \octave,  Pn(Pstep(Pseq([4!3, 5,  ].flat, 1),  1), inf),  
  \amp,     Pn(Pxrand([0.7, 0.6],   1),  inf),
  \degree,  Pn(Pstep(Place([0, [4,  2,  ]], 1),  8), inf),
  \legato,  Pn(Pdefn(\dur)/Pkey(\amp), inf), 
  \dur,     Pn(Pstep(Pdefn(\b000_durs)*Pseq([2, 3,  1,  0.5], inf), Pseq([8,  2,  1,  1/2], inf)), inf),  
));

Pdef(\m000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  3,  \scale,  Scale.dorian,
  \root,    Pn(Pstep(Pseq([0,  -4, -2, 5], inf), 8),  inf), 
  \octave,  Pn(Pstep(Pseq([4!3, 5,  ].flat, 1),  1), inf),  
  \amp,     Pn(Pxrand([0.7, 0.6],   1),  inf),
  \degree,  Pn(Pstep(Place([0, [4,  2,  ]], 1),  8), inf),
  // \dur,     Pn(Pseq([1/3!2, 3/4,  2,  1/6!2,  Pn(Rest(), 1.75)].flat,   1), inf)/3,
  \dur,     Pn(Pstep(Pdefn(\a000_durm0)*2, Pseq([4,  8], inf)), inf),  
  // \dur,     Pn(Pstep(Pdefn(\b000_durs)*Pseq([2, 3,  1,  0.5].reverse, inf), Pseq([8,  2,  1,  1/2].reverse, inf)), inf),  
));

Pdefn(\a000_deg0, Pseq([[4, 2], [0,  15,  6],  [0, 4,  15], [0, 6, 15]], 4));
Pdefn(\a000_deg1, Place([5, [0, 6],  [1,  8,  ],  [0, 5, ],  [3, 4, 0]], 1));
  
Pdefn(\a000_deg1, Place([6, [8, 6],  [0,  8,  6],  [8, 6, 13],  [13, 9, ]], 1));

Pdefn(\a000_duri0, Pseq([1/4!2, Rest(1/2), 1/2, 1/8!4].flat,  1));
Pdefn(\a000_durm0, Pseq([1/4].flat,   1));
Pdefn(\a000_durm1, Pseq([1/2].flat,   8)/Pseq([4,  2,  1], 1).stutter(4));
Pdefn(\a000_durm2, Pseq([1/4].flat,   8)*Pseq([1,  2,  4], 1).stutter(4));
Pdefn(\a000_dur0, Pser([1/4,  1/2,  1,  Pn(Rest(),  1)].flat,   Pseq([1, 3,  4], 1).stutter(4))/Pseq([1,  2,  4], 1)); 
Pdefn(\a000_dur1, Pseq([1/4!2, 1/8!4, 1/2, Rest(1/2)].flat,   1)); 

Pdefn(\a000_degs,  Pseq([
  Pn(Pdef(\a000_deg0), 4), 
  // Pn(Pdefn(\a000_deg1), 1), 
], 1));

Pdefn(\a000_durs,  Pseq([
  // Pn(Pdefn(\a000_duri0), 1),  
  // Pn(Pdefn(\a000_durm0), 8), 
  // Pn(Pdefn(\a000_durm1), 4), 
  Pn(Pdefn(\a000_durm0), 1), 
  // Pn(Pdefn(\a000_durm2), 4), 
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

Pdefn(\a000_deg_k0, 
  Pseq([
    [0, 5], [0, \],  [\], [\], [0, \], [  \ ],  [3,  \], [1,  \],  
    [0, ], [ \],  [1], [\], [0, \], [\ ],  [6,  1], [5,  \],  
  ], inf));  
  
Pdefn(\a000_deg_hh0, 
  Pseq([
    [\], [3],  [\], [3],  
    [\], [3],  [3], [2],  
  ], 
  1));  

Pdef(\a000_m, Ppar([
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 0,
    \scale, Scale.chromatic, \octave, 3,
    \degree, Pn(Pdefn(\a000_deg_k0),  inf), 
    \amp,    Pn(Pseq([0.99, 0.6, 0.8, 0.7], 1), inf),  
    // \amp,  0.8, 
    \dur,    Pn(Pdefn(\a000_durm0), inf), 
  ),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 0,
    \scale, Scale.chromatic, \octave, 3,
    \degree, Pn(Pdefn(\a000_deg_hh0), inf), 
    \amp,    Pn(Pseq([0.99, 0.6, 0.8, 0.7], 1), inf),  
    \dur,    Pn(Pdefn(\a000_durm0)*2,  inf), 
  )
]));

Pdef(\a100_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  5,  \scale,  Scale.dorian,
  \root,    Pn(Pstep(Pseq([0,  -4, -2, 5], inf), 8),  inf), 
  \octave,  Pn(Pstep(Pseq([3,4], inf),  Pseq([1/2,  1], inf), 1), inf),   
  \amp,     Pn(Pstep(Place([9.0, [0.7,  0.5]], inf), 2), inf),
  \degree,  Pn(Pstep(Place([0, [4,  2,  ]], inf),  8),  inf),  
  // \timeOffset,  1/4,  
  // \dur,     Pn(Pseq([1/4!2, 1/8!4, 1/2, Rest(1/2)].flat,   1), inf), 
  // \dur, Pn(Pdefn(\b000_durs)*2, inf), 
  \sustain,  Pn(Pkey(\dur)*2, inf), 
  \dur,     Pn(Pstep(Pdefn(\b000_durs)*Pseq([1, 2,  ], 2), 3), inf),  
  // \dur,     Pn(Pstep(Pdefn(\b000_durs)*2, Pseq([7,  4, 1/2], inf)), inf),  
));

Pdef(\a000, Pdef(\a000_m));
Pdef(\a100, Pdef(\a100_m));
Pdef(\b000, Pdef(\b000_m));
~apcAssignPad.(35, \b000);
~lcxlBindPdef.(\b1_s5_p, \b000);
~lcxlBindPdef.(\b1_s6_p, \m000);
~lcxlBindPdef.(\b1_s1_p, \a000);
~lcxlBindPdef.(\b1_s7_p, \a100);
// Pdef(\m000, Pdef(\m000_m));
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

(
Pdef(\bday, Pbind(
  // \type,  \midi,  \midiout,  ~mOut, \chan,  5,  \scale,  Scale.major,
  \instrument,  \default, 
  \degree,  Pseq([
    0,  0!2,  
    1,  0,  4,  
    3,    
    ].flat,  1), 
  \dur, Pseq([
    Rest(1/2),  1/8!2, 
    1/4!3,  
    1/2,  1/8!2,  
    1/4!3,
    1/2,  1/8!2,  
  ].flat, inf),   
));
)
Pdef(\bday).play(~c);
Pdef(\bday).stop;
Pdef(\bday).clear;
~link.tempo(60/60)
~c = TempoClock.new(0.5);
