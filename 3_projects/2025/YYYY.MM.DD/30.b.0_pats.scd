
/////////////////////////////////////////////////////////////
// b000
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
Pdefn(\b000_deg1,  Pseq([2, 4,  2,  0], 1).stutter(8));
Pdefn(\b000_deg2,  Pseq([2, 3, 5,  8], 1).stutter(4));

Pdefn(\b000_dur0,  Pseq([1/2, 1/4!2 ].flat,  1));
// Pdefn(\b1_dur0,  Pseq([1/4!7, 1/8!2].flat,  1));
Pdefn(\b000_dur1,  Pseq([1/8!7, 1/2!2].flat,  1));

Pdefn(\b000_oct0, Prand([3].flat,  1));   
Pdefn(\b000_oct1, Prand([3!2, 4].flat,  1));   

Pdefn(\b000_amp1, Pseq([0.8, 0.7,   0.6],  1)); 
);
(
// phrases

Pdefn(\b000_degs, Pseq([
  // Pn(Pdefn(\b1_deg0), 4), 
  Pn(Pdefn(\b000_deg1), 4), 
  Pn(Pdefn(\b000_deg2), 4), 
],  1));

Pdefn(\b000_durs, Pseq([
  // Ppatlace([
    Pn(Pdefn(\a000_phr), 1), 
    // Pn(Pdefn(\b000_dur2), 1), 
  // ],  4)
],  1));

Pdefn(\b000_octs, Pseq([
  Pn(Pdefn(\b000_oct0), 4), 
  Pn(Pdefn(\b000_oct1), 2), 
],  1));

Pdefn(\b000_amps, Pseq([
  Pn(Pdefn(\b000_amp1), 2), 
],  1));
)
