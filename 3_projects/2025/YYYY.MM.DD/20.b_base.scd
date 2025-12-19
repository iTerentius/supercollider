/////////////////////////////////////////////////////////////
// b000
/////////////////////////////////////////////////////////////
// voices
(
Pdef(\b000_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.dorian, 
  \root,  5,  
  \octave,  Pn(Pdefn(\b000_octs),  inf), 
  \amp,     Pn(Pdefn(\b000_amps),  inf), 
  \degree,  Pn(Pdefn(\b000_degs), inf),
  // \degree,  Pseq([0,  2,  4,  7], inf), 
  // \legato,  Pn(Pdefn(\bd1_durs),  inf),
  // \sustain, 1,  
  \dur,     Pn(Pdefn(\b000_durs), inf),
));

Pdef(\b000, Pdef(\b000_m));
~apcAssignPad.(35, \b0);
~lcxlBindPdef.(\b1_s5_p, \b0);
)
