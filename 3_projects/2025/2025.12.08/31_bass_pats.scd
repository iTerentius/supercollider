
/////////////////////////////////////////////////////////////
// BASS1
/////////////////////////////////////////////////////////////
// words
(
// Pdefn(\b1_deg0, Pseq([
//   \E.asDegrees(Scale.dorian), \,   
//   \B.asDegrees(Scale.dorian), \,  
//   \C.asDegrees(Scale.dorian), \, 
//   \A.asDegrees(Scale.dorian), \,   
//                 // Pn(Rest(),  4), 
//             ],  1).flatten);
Pdefn(\bass1_deg1,  Pseq([0, 2,  3,  2], 1).stutter(8));
Pdefn(\bbas1_deg2,  Pseq([0, 3, 4,  2], 1).stutter(4));

Pdefn(\bass1_dur0,  Pseq([1/4,  ].flat,  1));
// Pdefn(\b1_dur0,  Pseq([1/4!7, 1/8!2].flat,  1));
Pdefn(\bass1_dur1,  Pseq([1/8!7, 1/2!2].flat,  1));
)
(
// phrases

Pdefn(\bass1_degs, Pseq([
  // Pn(Pdefn(\b1_deg0), 4), 
  Pn(Pdefn(\bass1_deg1), 4), 
  Pn(Pdefn(\bass1_deg2), 4), 
],  inf));

Pdefn(\bass1_durs, Pseq([
  Pn(Pdefn(\bass1_dur0), 1), 
  // Pn(Pdefn(\b1_dur1), 1), 
],  inf));
)
Pdef(\bass1).play(~link, quant:4);
Pdef(\bass1).stop;
Pdef(\bass1).clear;
