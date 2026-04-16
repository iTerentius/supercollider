
(
Pdef(\v5_pitchGate,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v5_pitchGate].nodeID }),
  \args,  #[\speed,  \len,  \pStart,  \pEnd,  \width, \mix, \amp],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  // \mix, Pseg([0.01,  1.0], [2],  \lin, inf),  
  \mix,   1,   // \mix, Pwhite(0.5, 1.0,  inf), 
  \amp, 0.8,  
  \speed,  Pseg([100,  1], [4], \lin,   inf), 
  \len,  1,  
  \pStart,  0,  
  \pEnd,  -12,  
  // \width, Pseg([2, 0.2], [1],  \sin, inf), 
  \width, 0.5,  
  \dur, 1/16,  
  \stretch, 1,  

));

// OSCdef(\v1_crush, { |msg| 
//     var bits, rate;
//     bits = msg[1].linlin(0, 1,  4,  12);
//     rate = msg[2].linlin(0, 1,  100, 10000);
//     // var val = msg[1].linlin(0, 1, 4, 12);
//     ~ilfx[\v2_crush].set(\bits, bits, \rate,  rate);
// }, '/2/xy3', srcID: ~toscAddr);
// OSCdef(\v1_crush_mix, { |msg| 
//     var mix = msg[1].linlin(0, 1,  0, 1);
//     ~ilfx[\v2_crush].set(\mix, mix);
// }, '/2/fader2', srcID: ~toscAddr);

)
