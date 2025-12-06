// Key Thing
// words
(
Pdefn(\k1_deg0, Pseq([0!4, Pn(Rest(), 1)].flat,  1));
Pdefn(\k1_deg1, Pseq([0!4, Prand((1..7),  8),  \,  3].flat,  1));
Pdefn(\k1_deg2, Pseq([0!4, Pxrand((1..7),  2),  Pn(Rest(), 4)].flat,  1));

Pdefn(\k1_dur0, Pseq([1/2!2,   1/4!4,  1/2,  1/8!4, Pn(Rest(), 1)].flat,  1));
Pdefn(\k1_dur1, Pseq([1/4!4,   1/8!8,  Pn(Rest(), 2)].flat,  1));
)

// phrases
(
Pdefn(\k1_degs, Pseq([
  Pn(Pdefn(\k1_deg0), 4), 
  Pn(Pdefn(\k1_deg1), 1), 
  Pn(Pdefn(\k1_deg2), 1), 
],  inf));

Pdefn(\k1_durs, Pseq([
  Pn(Pdefn(\k0_dur1), 1), 
  Pn(Pdefn(\k1_dur1), 1), 
],  inf));
)

// voices
(
Pbindef(\k1,
  \type,  \midi,  \midiout,  ~mOut, \chan,  1,  \scale,  Scale.dorian, 
  // \octave,  Pseq(#[3, 4,  2], inf),  
  \octave,  3,  
  \amp,  0.8, 
  \degree,  Pdefn(\k1_degs),
  \dur,     Pdefn(\k1_durs),
);
)
Pbindef(\k1).play;
Pbindef(\k1).stop;
Pbindef(\k1).clear;

// Bass Thing
// words
(
Pdefn(\b1_deg0, Pseq([
  \E.asDegrees(Scale.dorian), \,   
  \B.asDegrees(Scale.dorian), \,  
  \C.asDegrees(Scale.dorian), \, 
  \A.asDegrees(Scale.dorian), \,   
                // Pn(Rest(),  4), 
            ],  1).flatten);
Pdefn(\b1_deg1,  Pseq([0, 3,  7,  \], 1));
Pdefn(\b1_dur0,  Pseq([1/4!7, Pn(Rest(),  1)],  1));
)
// phrases
(
Pdefn(\b1_degs, Pseq([
  Pn(Pdefn(\b1_deg0), 4), 
  Pn(Pdefn(\b1_deg1), 4), 
],  inf));

Pdefn(\b1_durs, Pseq([
  Pn(Pdefn(\b0_dur0)/4, 1), 
],  inf));
)
// voices
(
Pbindef(\b1,
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.dorian, 
  \octave,  Pseq(#[3, 4,  2], inf),  
  // \octave,  3,  
  \amp,  0.9, 
  \degree,  Pdefn(\b1_degs),
  \dur,     Pdefn(\b1_durs),
);
)
Pbindef(\b1).play;
Pbindef(\b1).stop;
Pbindef(\b1).clear;

