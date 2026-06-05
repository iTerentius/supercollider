
(
~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;
~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t6);
Pdef(\v1_crush,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v1_crush].nodeID }), 
  \args,  #[\rate,  \bits,  \mix, \amp],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  // \mix, Pseg([0.01,  1.0], [2],  \lin, inf),  
  // \mix,  Pbjorklund(3, 8,  inf), 
  \mix, Pwhite(0.5, 1.0,  inf), 
  \amp, 0.8,  
  \rate,  Pseg([2500, 20000], [3],  \step, inf),  
  \bits,  Pseg([4,  6], [3], \step,  inf),  
  // \dur, Pseq([1/4!2, 1/2,   1,  1/8!4].flat, inf), 
  \dur, Pseg([1,  1/8], [3],  \step, inf), 
  \stretch, Pn(Pdefn(\v1_808k_strs),  inf),  
));

OSCdef(\v1_crush, { |msg| 
    var bits, rate;
    bits = msg[1].linlin(0, 1,  4,  12);
    rate = msg[2].linlin(0, 1,  100, 10000);
    // var val = msg[1].linlin(0, 1, 4, 12);
    ~ilfx[\v1_crush].set(\bits, bits, \rate,  rate);
}, '/2/xy3', srcID: ~toscAddr);
OSCdef(\v1_crush_mix, { |msg| 
    var mix = msg[1].linlin(0, 1,  0, 1);
    ~ilfx[\v1_crush].set(\mix, mix);
}, '/2/fader2', srcID: ~toscAddr);

);
