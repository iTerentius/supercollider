~link.tempo = 120/60;
(
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


