~link.tempo = 120/60;

(
Pdefn(\b_mel_0, Pseq([0, 4, 2, 3, 4, 2, 0, -1], 1));
Pdefn(\b_mel_1, Prand((-1..7), 8));
Pdefn(\b_mels,  Pseq([
  Pn(Pdefn(\b_mel_0), 1), 
  Pn(Pdefn(\b_mel_1), 1), 
],  inf));
// 1. Define your melody/voice pattern generator
~melodyPattern = { |parentEvent|
  var div = parentEvent[\div];
  var delta = parentEvent.delta;
  Pbind(
    \type,   \midi, \midiout, ~mOut,  \chan,  2,  
    \octave,  Pstep(Pseq([4,  5], 1), 4, 1),    
    \root, parentEvent[\root],
    \scale, parentEvent[\scale],
    // \degree, Pn(Pdefn(\b_mels), 1),  
    // \degree, Pn(Place([Pkey(\root), Pdefn(\b_mels)], 1)),  
    \degree, Pn(Place([Pdefn(\a000_root_degs), Pdefn(\b_mels)], 1)),  
    \amp, 0.1,
    \dur, delta / (8 * div), 
    // IMPORTANT: Ensure the child pattern stops exactly when the parent switches chords.
    // We use Pfindur to limit this pattern's total length to the parent's delta.
    // (parentEvent[\delta] is the duration until the next spawn)
  // )
  ).finDur(parentEvent[\delta]);
};

Pdefn(\a000_deg_0, Pseq([0, 5,  7,  0], 1));
Pdefn(\a000_deg_1, Pseq([2!2, 5,  7].flat, 1));

Pdefn(\a000_root_degs,  Pseq([
  Pn(Pdefn(\a000_deg_0),  1), 
  Pn(Pdefn(\a000_deg_1),  1), 
],  inf));
~bassPattern = { |parentEvent|
  var delta = parentEvent.delta;
  var div = parentEvent[\div];
  var root = parentEvent[\root];
  Pbind(
    \type,   \midi, \midiout, ~mOut,  \chan,  1,  
    \octave,  Pstep(Pseq([4,  3], 1), 1,  4/div),  
    \root, parentEvent[\root],
    \scale, parentEvent[\scale],
    \legato,  Pkey(\dur), 
    \degree, root + 0, 
    \amp, 0.1,
    \dur, 1/div,      
    // \dur, 1/2/div,      
  ).finDur(parentEvent[\delta]);
};
)
(
// 2. The Master Spawner
Pdef(\b_root_01, Pspawn(
  Pbindef(\b_root_pbd,  
    \root, Pn(Pdefn(\a000_root_degs), inf), 
    \scale, Scale.minor, 
    \div, Pseq([1,  2,  ].flat.reverse, inf),  
    \delta, Pseq([8], inf),  
    \dur, 1/4,  
    \method, \par, 
    
    // Generate the child pattern, passing 'e' (the current event with root/delta)
    \pattern, Pfunc { |e| Ppar([
      ~melodyPattern.value(e),  
      ~bassPattern.value(e),  
    ]) },  
  )
));
)

Pdef(\b_root_01).play(~link);
Pdef(\b_root_01).stopQ(8);
(
Pdefn(\a000_deg_k0, 
  Pseq([
    [0], [\],  [\], [0], [\], [\],  [\], [\],
    [\], [\],  [\], [0], [1], [\],  [\], [\],
  ], 1));  

Pdefn(\a000_deg_k1, 
  Pseq([
    [0], [\],  [\], [0], [0], [4],  [1], [10],  
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
    [\], [2],  [2], [3],  
  ], 
  1));  

Pdefn(\a000_deg_hh1, 
  Pseq([
    [2], [\],  [\], [\],  
    [2], [\],  [2], [3],  
  ], 
  1));  

Pdefn(\a000_deg_hh2, 
  Pseq([
    [2], [\],  [\], [\],  
    [\], [\],  [\], [\],  
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
    \dur,  1/2, 
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
Pdef(\a000, Pdef(\a000_m));
(

Pdefn(\a000_deg_0, Pseq([0, 5,  7,  0], 1));
Pdefn(\a000_deg_1, Pseq([2!2, 5,  7].flat, 1));

Pdefn(\a000_root_degs,  Pseq([
  Pn(Pdefn(\a000_deg_0),  1), 
  Pn(Pdefn(\a000_deg_1),  1), 
],  inf));

Pdef(\a000_m, Pbind( 
  \type,  \midi,  \midiout, ~mOut,  \chan,  0, 
  \scale, Scale.minor, \root, 0,
  \octmod,  Pseq([0,  1, ], inf),
  \octave,  Pseq([3!4,  4!2,  5!2, ].flat + 1,  inf), 
  // \legato, Pkey(\dur), 
  \amp,  Pwhite(0.7,  0.9,  inf), 
  // \legato, Pkey(\dur) * Pseq([0.8,  1.0], inf), 
  \degree,  Pseq([
    Pn(Pseq(\Cm7.asDegrees(Scale.minor),  1),  4),  
    Pn(Pseq(\Gm7.asDegrees(Scale.minor), 1),  4),  
    Pn(Pseq(\Fm.asDegrees(Scale.minor), 1),  4),  
    Pn(Pseq(\EbM7.asDegrees(Scale.minor), 1),  4),  
  ],  inf), 
  \dur, Pbjorklund(7,  8,  inf)/2, 
));
)
Pdef(\a000_m).play(~link);
Pdef(\a000_m).stopQ(4);
Pdef(\a000_m).clear;

(
Pdef(\b000_m, Pbind(
  \type,   \midi, \midiout, ~mOut,  \chan,  1,  
  \scale, Scale.minor,  
  \octave,  4,  
  \sustain, Pkey(\dur)*2,  
  \degree,  Pseq([
    \C.asDegrees[0],  
    \G.asDegrees[0],  
    \F.asDegrees[0],  
    \Eb.asDegrees[0],  
  ], inf),
  \dur, Pbjorklund2(5,  8,  inf), 
))
)
Pdef(\b000_m).play(~link);
Pdef(\b000_m).stopQ(4);
Pdef(\b000_m).clear;

Pdef(\b000_m).play(~link); Pdef(\a000_m).play(~link);
Pdef(\b000_m).stopQ(4); Pdef(\a000_m).stopQ(4);

