(
Ndef(\impact)[0] =  Pbind(
  \instrument,  Pseq([
    \slice_s, 
    // \pBs
  ],  inf),  
  \bufnum,  Pseq(~sTree[\impacts].values[0..8], inf),   
  \amp,  0.4, 
  \nSlices,  Pseq((8..16),  inf),  
  \spread,  Pseq([0.2, -0.2], inf),   
  \dur,   2,
  \stretch, Pseq([1/4!3,   2.25].flat,   inf), 
);
);
(
Ndef(\hh1)[0] = Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\hats].values(1,  3), inf),   
  \degree,  Pseq([0], inf),
  \amp,  0.4, 
  \dur,   Pseq([1/2].flat, inf), 
  // \stretch, Pseg([1,   1/5],[8],  \sin,   inf), 
);
);
(
Ndef(\kk1)[0] =  Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\bass_drums].values[0..4], inf),   
  \amp,  0.9, 
  \dur,   Pseq([1, 1/2],  inf), 
  \stretch, Pseq([1/4!3,   3.25].flat,   inf), 
);
);
(
Ndef(\kitA)[0] = {
    var kit = Mix([
      Ndef.ar(\impact, 2), 
      Ndef.ar(\hh1, 2),
      Ndef.ar(\kk1, 2),
    ]);
    Compander.ar(kit, kit, thresh: 0.5, slopeAbove: 0.4)   // group glue comp, EQ, etc.
};
);
Ndef(\kitA)[4] = \filter -> {|in, delayTime=0.25, size=0.2, damp=0.1,  diff=0.5,  feedback=0.9, modDepth=0.5, modFreq=2.0 | Greyhole.ar(in, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
~apcBindParam.(\b0_ds1_k1, { |x| Ndef(\kitA).set(\wet4,  x)});


// Ndef(\impact).pause;
// Ndef(\impact).resume;
// Ndef(\impact).clear;
//
// Ndef(\hh1).pause;
// Ndef(\hh1).resume;
// Ndef(\hh1).clear;
//
// Ndef(\kk1).pause;
// Ndef(\kk1).resume;
// Ndef(\kk1).clear;
//
// Ndef(\kitA).pause;
// Ndef(\kitA).resume;
// Ndef(\kitA).clear;
