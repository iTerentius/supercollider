// ~sTree[\bass_drums].values[0..4];
(
// Pdefn(\slow,  Pseq([1,  2,  4], inf));
Ndef(\impact)[0] =  Pbindef(\impact,  
  \instrument,  Pseq([
    \slice_s, 
    // \pBs
  ],  inf),  
  \bufnum,  Pseq(~sTree[\impacts].values[0..8], inf),   
  \amp,  0.4, 
  \nSlices,  Pseq((1..16),  inf),  
  // \nSlices, 8,  
  \sliceDur,   0.5,  
  \spread,  Pseq([0.2, -0.2], inf),   
  \dur,  2 * Pn(Pdefn(\slow)),
  // \stretch, Pseq([1/4!3,   2.25].flat,   inf), 
);
Ndef(\hh1)[0] = Pbindef(\hh1, 
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\hats].values(1,  3), inf),   
  \degree,  Pseq([0], inf),
  \amp,  0.4, 
  \rate,  1,  
  \pan,  Pseq((-0.5..0.5),  inf),   
  \dur,   Pseq([1/4].flat, inf) * Pn(Pdefn(\slow)), 
  // \stretch, Pseg([1,   1/8],[16],  \lin,   inf), 
);
Ndef(\kk1)[0] =  Pbindef(\kk1,  
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\bass_drums].values[0..0], inf),   
  \amp,  0.9, 
  \rate,  1,  
  \dur,   Pseq([1, 1/2],  inf) * Pn(Pdefn(\slow)), 
  // \stretch, Pseq([1/4!3,   3.25].flat,   inf), 
);
Ndef(\kitA)[0] = {
    var kit = Mix([
      Ndef.ar(\impact, 2), 
      Ndef.ar(\hh1, 2),
      Ndef.ar(\kk1, 2),
    ]);
    kit = HPF.ar(kit, 98);
    Compander.ar(kit, kit, thresh: 0.5, slopeAbove: 0.4)   // group glue comp, EQ, etc.
};
);
// Ndef(\kitA)[4] = \filter -> {|in, delayTime=0.25, size=0.2, damp=0.1,  diff=0.5,  feedback=0.9, modDepth=0.5, modFreq=2.0 | Greyhole.ar(in, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
~apcBindParam.(\b0_ds1_k1, { |x| Ndef(\fxsGreyhole).set(\mix,  x)});
~apcBindToggleFn.(32, { Ndef(\impact).resume }, { Ndef(\impact).pause }, \green, \blue);
~apcBindToggleFn.(33, { Ndef(\hh1).resume }, { Ndef(\hh1).pause }, \green, \blue);
~apcBindToggleFn.(34, { Ndef(\kk1).resume }, { Ndef(\kk1).pause }, \green, \blue);
Pdefn(\slow,  2);

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
