(
Pdefn(\k1_deg0, Pseq([0!4, Pn(Rest(), 1)].flat,  1));
Pdefn(\k1_deg1, Pseq([0!4, Prand((0..7),  8),  \,  3].flat,  1));
Pdefn(\k1_deg2, Pseq([0!4, Pxrand((0..7),  2),  Pn(Rest(), 4)].flat,  1));

Pdefn(\k1_dur0, Pseq([1/4!4].flat,  1));
Pdefn(\k1_dur1, Pseq([1/4!4,   1/8!8,  Pn(Rest(), 2)].flat,  1));
)
(
Pdefn(\k1_degs, Pseq([
  Pn(Pdefn(\k1_deg0), 4), 
  Pn(Pdefn(\k1_deg1), 1), 
  Pn(Pdefn(\k1_deg2), 1), 
],  inf));

Pdefn(\k1_durs, Pseq([
  Pn(Pdefn(\k0_dur1), 2), 
  Pn(Pdefn(\k1_dur1), 1), 
],  inf));
)
(
Pbindef(\k1,
  \type,  \midi,  \midiout,  ~mOut, \chan,  0,  \scale,  Scale.dorian, 
  \octave,  Pseq(#[3, 4,  2], inf),  
  \degree,  Pdefn(\k1_degs),
  \dur,     Pdefn(\k1_durs),
);
)
Pbindef(\k1).play;
Pbindef(\k1).stop;
Pbindef(\k1).clear;
