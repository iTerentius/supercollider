(
Pdefn(\r000_deg_0, Place([0, 1, [2, -1] ], 1));
// Pdefn(\a000_deg_0, Pseq([\C3, \G3, \F3, \Eb3 ].flatten, 1));
Pdefn(\r000_deg_1, Pseq([2!2, 5, 7].flat, 1));

Pdefn(\r000_root_degs,  Pseq([
  Pn(Pdefn(\r000_deg_0),  1), 
  // Pn(Pdefn(\a000_deg_1),  1), 
],  inf));
~b1 = { |e|
  var delta = e[\delta];
  var div = e[\div];
  var root = e[\root];
  var trig = e[\trig];
  Pbind(
    \type,   \midi, \midiout, ~mOut,  \chan,  1,  
    // \octave,  Pstep(Pseq([4,  3], 1), 1,  4/div),  
    \octave,  Pser([ 3!6, 4!2].flat, delta/div + 1),   
    \root, e[\root],
    \scale, e[\scale],
    // \legato,  Pkey(\dur)/(div/delta), 
    \degree, root , 
    \amp, 0.1,
    // \dur, 2/(4*div),      
    // \dur, 1/2/div,      
    \dur,  Pbjorklund2(trig, 8,  1)/2, 
  ).finDur(e[\delta]);
};

~i1 = { |e|
  var delta = e[\delta];
  var div = e[\div];
  var root = e[\root];
  var trig = e[\trig];
  Pbind(
    \type,   \midi, \midiout, ~mOut,  \chan,  2,  
    // \octave,  Pstep(Pseq([4,  3], 1), 1,  4/div),  
    \octave,  Pseq([5, ], trig +2),   
    // \root, e[\root],
    \root, 0,
    \scale, e[\scale],
    // \legato,  Pkey(\dur)/(div/delta), 
    // \sustain,  delta, 
    \degree, Pser([4, 2,  0,  -2, 0,  1,  0   ],  delta),   
    \amp, Pwhite(0.1, 0.3,  delta),
    \vel, Pkey(\amp), 
    \dur, 1/4,      
    // \dur, 1/2/div,      
  ).finDur(e[\delta]);
};
)
(
// 2. The Master Spawner
Pdef(\b_root_01, Pspawn(
  Pbindef(\b_root_pbd,  
    \root, Pn(Pdefn(\r000_root_degs), inf), 
    \scale, Scale.minor, 
    \div, Pseq([1,].flat.reverse, inf),  
    \trig,  Pseq([3,  5,  7, 9].reverse.stutter(4),  inf), 
    \delta, Pseq([8], inf),  
    \dur, 1,  
    \method, \par, 
    
    // Generate the child pattern, passing 'e' (the current event with root/delta)
    \pattern, Pfunc { |e| Ppar([
      ~b1.value(e),  
      ~i1.value(e),  
    ]) },  
  )
));
)

Pdef(\b_root_01).play(~link);
Pdef(\b_root_01).stopQ(8);

Pdef(\a000_m).play(~link);
Pdef(\a000_m).stopQ(4);

~mOut.control(15, 20, 127);
(
Pdef(\cc_mod_1, Pbind(
  \type,  \midi,  \midiout, ~mOut,  \chan,  15,  \midicmd, \control, 
  \ctlNum, 20,            // Mod Wheel
  \dur, 1/16,            // High resolution (32 messages per beat)
  \control, Pseg([0, 127, 127,  0], [4, 4,  4], \sin, inf)
));

Pdef(\cc_mod_2, Pbind(
  \type,  \midi,  \midiout, ~mOut,  \chan,  15,  \midicmd, \control, 
  \ctlNum, 21,            // Mod Wheel
  \dur, 1/4,            // High resolution (32 messages per beat)
  \control, Pseg([0, 127, 0], [1, 4,], \sin, inf)
));
)
Pdef(\cc_mod_1).play(~link);
Pdef(\cc_mod_1).stopQ(4);
Pdef(\cc_mod_2).play(~link);
Pdef(\cc_mod_2).stopQ(4);

(
Pdefn(\a000_deg_k0, 
  Pseq([
    [0], [\],  [\], [0], [\], [\],  [\], [\],
    [\], [\],  [\], [0], [1], [\],  [\], [\],
  ], 1));  

Pdefn(\a000_deg_k1, 
  Pseq([
    [0], [\],  [\], [0], [0], [4],  [1], [4],  
    [\], [1],  [\], [\], [0], [1],  [0], [3],  
  ], 1));  

Pdefn(\a000_deg_k2, 
  Pseq([
    [0], [\],  [\], [\], [0], [\],  [\], [\],  
    [\], [\],  [\], [\], [0], [\],  [0], [\],  
  ], 1));  
  
Pdefn(\a000_deg_hh0, 
  Pseq([
    [2], [\],  [2], [\],  
    [\], [2],  [\], [3],  
  ], 
  1));  

Pdefn(\a000_deg_hh1, 
  Pseq([
    [2], [2],  [3], [\],  
    [\], [\],  [2], [2],  
  ], 
  1));  

Pdefn(\a000_deg_hh2, 
  Pseq([
    [2], [\],  [\], [\],  
    [2], [\],  [\], [\],  
  ], 
  1));  

Pdefn(\a000_hh_degs,  
Pseq([
  Pn(Pdefn(\a000_deg_hh1),  4),  
  Pn(Pdefn(\a000_deg_hh0),  4), 
  Pn(Pdefn(\a000_deg_hh2),  4), 
],  1));

Pdef(\a000_m, Ppar([
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 0,
    \scale, Scale.chromatic, \octave, 3,
    \degree, Pn(Pdefn(\a000_degs),  inf), 
    \amp,    Pn(Pseq([0.99, 0.6, 0.8, 0.7], 1), inf),  
    // \amp,  0.8, 
    \dur,    1/2, 
  ),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 0,
    \scale, Scale.chromatic, \octave, 3,
    \degree, Pn(Pdefn(\a000_hh_degs), inf), 
    \amp,    Pn(Pseq([0.8, 0.6, 0.8, 0.7], inf), inf),  
    // \dur,    Pn(Pdefn(\a000_durm0),  inf), 
    \dur,  1/4, 
  )
]));

Pdef(\a100_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  5,  \scale,  Scale.dorian,
  \root,   0,  
  \octave,  Pn(Pstep(Pseq([3,4], inf),  Pseq([1/2,  1], inf), 1), inf),   
  \amp,     Pn(Pstep(Place([9.0, [0.7,  0.5]], inf), 2), inf),
  \degree,  Pn(Pstep(Place([0, [4,  2,  ]], inf),  4),  inf),  
  \dur,     Pn(Pstep(Pdefn(\b000_durs), Pseq([7,  4, 1/2], inf)), inf),  
));
)

