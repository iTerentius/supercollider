
(
// ~ilfx[\v6_crush].free; ~ilfx[\v6_crush] = nil;
// ~ilfx[\v6_crush] = ~fxLib[\bitcrush].(~t6);
Pdef(\bass_crush,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v6_crush].nodeID }), 
  \args,  #[\rate,  \bits,  \mix, \amp],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  // \mix, Pseg([0.01,  1.0, 0.01], [4,  4],  \exp, inf),  
  // \mix,  Pbjorklund2(3, 8,  inf), 
  // \mix, Pstep(Pseg([0.0, 1.0, 1.0],  [1,  8], \step, inf), 4), 
  \amp, 0.8,  
  \rate,  Pseg([2500, 80000,  20000], [8, 8],  \step, inf),  
  \bits,  Pseg([4,  8,  6], [8, 8], \step,  inf),  
  \dur, Pseq([1/4!2, 1/2,   1,  1/8!4].flat, inf), 
  // \dur, Pseg([1/10,  1/5], [4],  \step, inf), 
  \stretch, Pn(Pdefn(\all_div),  inf),  
));

// OSCdef(\bass_crush, { |msg| 
//     var bits, rate;
//     bits = msg[1].linlin(0, 1,  4,  12);
//     rate = msg[2].linlin(0, 1,  100, 10000);
//     // var val = msg[1].linlin(0, 1, 4, 12);
//     ~ilfx[\v6_crush].set(\bits, bits, \rate,  rate);
// }, '/2/xy3', srcID: ~toscAddr);
// OSCdef(\bass_crush_mix, { |msg| 
//     var mix = msg[1].linlin(0, 1,  0, 1);
//     ~ilfx[\v6_crush].set(\mix, mix);
// }, '/2/fader2', srcID: ~toscAddr);
//
);
