
(
Pdef(\crush,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v2_crush].nodeID }), 
  \args,  #[\rate,  \bits,  \mix, \amp],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  // \mix, Pseg([0.01,  1.0], [2],  \lin, inf),  
  \mix,  Pbjorklund(3, 8,  inf)/2, 
  // \mix, Pwhite(0.5, 1.0,  inf), 
  \amp, 0.8,  
  \rate,  Pseg([2500, 80000], [2],  \sin, inf),  
  \bits,  4,  
  \dur, Pseq([1/4!2, 1/2,   1,  1/8!4].flat, inf), 
  \stretch, Pn(Pdefn(\v1_808k_strs),  inf),  
));
)
