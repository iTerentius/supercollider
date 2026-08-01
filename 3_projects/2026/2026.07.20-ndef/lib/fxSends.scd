(
~fxAddSend.(\s3);
~fxAddSend.(\s4);
~fxAddSend.(\s5);
~fxAddSend.(\s6);
// Ndef(\fxsDistortion)[0] = {
//   var chain = Mix([
//     Ndef.ar(\)
//   ])
// };
// ~fxRouteReg instead of a plain [0]= — makes \fxsBitcrush a valid ~fxRoute
// TARGET (also restores the "fxs" prefix — was accidentally renamed to plain
// \bitcrush, which meant ~fxAddFX's name-prefix scan could never find it at
// all, regardless of what argument was passed to ~fxAddFX). Note core only
// ever gets called with `sig` (~fxRouteRebuild calls core.value(sig),
// nothing else) — so brate/bits/mix/mute/amp are exposed as inline
// \name.kr(default) NamedControls, NOT plain declared function args, or
// .set() on them would silently do nothing (same bug class as the
// ~fxg[\biscuit] positional-arg mixup). ~fxRouteReg already calls ~fxAddFX
// internally, no separate call needed.
~fxRouteReg.(\fxsBitcrush, \s2_sum, { |sig|
    ~fxg[\bitcrush].(sig, \brate.kr(44100), \bits.kr(8), \mix.kr(1), \mute.kr(0), \amp.kr(1))
});
Ndef(\fxsGreyhole)[0] = {|delayTime=0.25, size=0.2, damp=0.1,  diff=0.5,  feedback=0.9, modDepth=0.5, modFreq=2.0 | 
  var sig = Ndef.ar(\s1_sum, 2);
  Greyhole.ar(sig, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
~fxAddFX.(\fxsGreyhole);
// Biscuit
// in=0, out=0,
// drive=1.0,
// clock=30000, bits=8,
// b1=1, b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1,
// fxMode=0,
// shape=0,
// delTime=0.25, delFB=0.3,
// pitchShift=5,
// stepRate=4.0, sf0=200, sf1=400, sf2=800, sf3=1600,
// filterType=0, filterFreq=15000, filterQ=0.1,
// naked=1.0, dressed=1.0 |

Ndef(\fxsBiscuit)[0] = { |
    drive=1.0,
    clock=30000, bits=8,
    b1=1, b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1,
    fxMode=0,
    shape=0,
    delTime=0.25, delFB=0.3,
    pitchShift=5,
    stepRate=4.0, sf0=200, sf1=400, sf2=800, sf3=1600,
    filterType=0, filterFreq=15000, filterQ=0.1,
    naked=1.0, dressed=1.0 |
    var sig = Ndef.ar(\s3_sum, 2);   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
    ~fxg[\biscuit].(
      sig,
      drive,
      clock,  bits,
      b1, b2, b3, b4, b5, b6, b7, b8, 
      fxMode, 
      shape,  
      delTime,   delFB, 
      pitchShift, 
      stepRate, sf0,  sf1,  sf2,  sf3,  
      filterType, filterFreq,  filterQ, 
      naked,   dressed
    );
};
~fxAddFX.(\fxsBiscuit);

);
