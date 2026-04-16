
(
Pdef(\v5_pitchGate,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v5_pitchGate].nodeID }),
  \args,  #[\speed,  \len,  \pStart,  \pEnd,  \width, \mix, \amp, \rate,  \bits,  \crush],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  // \mix, Pseg([0.01,  1.0], [2],  \lin, inf),  
  // \mix,   Pseg([0.3,  1.0], [4],  \sin, inf),    // \mix, Pwhite(0.5, 1.0,  inf), 
  \mix, 0.8,  
  \amp, 1.8,  
  \speed,  Pseg([10,  1], [4], \sin,   inf), 
  \len,  2,  
  \pStart,  0,  
  \pEnd,  -12,  
  // \width, Pseg([0.5, 0.01], [4],  \sin, inf), 
  \width, 0.5,  
  \dur, 1/32,  
  \rate,  Pseg([4400,  44],  [4],  \sin,  inf), 
  \bits,  4, 
  \crush, 1,  
  // \stretch, Pn(Pdefn(\v5_smp1_strs),  inf)*4,   
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
