/////////////////////////////////////////////////////////////
// BASS1
/////////////////////////////////////////////////////////////
// voices
(
Pdef(\bass1_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.dorian, 
  \root,  5,  
  \octave,  Prand([3!3, 4].flat,  inf),   
  \amp,  Pseq([0.8, 0.7,   0.6],  inf), 
  \degree,  Pn(Pdefn(\bass1_degs), inf),
  // \degree,  Pseq([0,  2,  4,  7], inf), 
  // \legato,  Pn(Pdefn(\bd1_durs),  inf),
  // \sustain, 1,  
  \dur,     Pn(Pdefn(\bass1_durs), inf),
));

Pdef(\bass1, Pdef(\bass1_m));
~apcAssignPad.(35, \hh1);
~lcxlBindPdef.(\b1_s4_p, \hh1);
)
