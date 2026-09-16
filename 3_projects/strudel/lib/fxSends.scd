(
~fxAddSend.(\s3);
~fxAddSend.(\s4);
~fxAddSend.(\s5);
~fxAddSend.(\s6);
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
// ~fxRouteReg.(\fxsDistort, \s3_sum, { |sig|
//     ~fxg[\bitcrush].(sig, \brate.kr(44100), \bits.kr(8), \mix.kr(1), \mute.kr(0), \amp.kr(1))
// });
Ndef(\fxsGreyhole)[0] = {|delayTime=0.25, size=0.2, damp=0.1,  diff=0.5,  feedback=0.9, modDepth=0.5, modFreq=2.0 | 
  var sig = Ndef.ar(\s1_sum, 2);
  Greyhole.ar(sig, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
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

Ndef(\fxsMod,  {  var sig = Ndef.ar(\s2_sum, 2); sig });   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
Ndef(\fxsMod)[1] = \filter -> {|in| ~fxg[\chorus].(in,  \rate,  0.25,  \depth, 0.004)}; Ndef(\lfo2, { LFPulse.ar(0.025)});

Ndef(\fxsMod).set(\rate,  0.25,  \depth, 0.005);
Ndef(\fxsGlitch).set(\rate, 8,  \mix, 1,   \amp,  2);
Ndef(\fxsGlitch).map(\freeze, Ndef(\lfo2));

Ndef(\fxsDistort,  {  var sig = Ndef.ar(\s3_sum, 2); sig });   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
Ndef(\fxsDistort)[1] = \filter -> { | in,  
    drive=1.0,
    clock=30000, bits=8,
    b1=1, b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1,
    fxMode=1,
    shape=0,
    delTime=0.25, delFB=0.3,
    pitchShift=5,
    stepRate=4.0, sf0=200, sf1=400, sf2=800, sf3=1600,
    filterType=0, filterFreq=15000, filterQ=0.1,
    naked=1.0, dressed=1.0 |
    ~fxg[\biscuit].(
      in,
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
Ndef(\fxsDistort)[2] = \filter -> {|in| ~fxg[\bitcrush].(in, \brate.kr(44100), \bbits.kr(8), \bmix.kr(0), \mute.kr(0), \amp.kr(1)) };
Ndef(\fxsDistort)[3] = \filter -> {|in| ~fxg[\fold].(in,  \gain.kr(2),   \wfmix.kr(0),  \amp.kr(0.5)) };

Ndef(\fxsGlitch,  {  var sig = Ndef.ar(\s4_sum, 2); sig });   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
Ndef(\fxsGlitch)[3] = \filter -> {|in| ~fxg[\stutter].(in, \rate.kr(2),  \mix.kr(0.5),  \amp.kr(1))};
Ndef(\fxsGlitch)[4] = \filter -> {|in| ~fxg[\spectral].(in, \chunk.kr(2048),  \freeze.kr(0),  \smear.kr(0), \freezeSmear.kr(0), \mix.kr(1))};
);
~fxAddFX.(\fxsGreyhole);
~fxAddFX.(\fxsDistort);
~fxAddFX.(\fxsMod);
~fxAddFX.(\fxsGlitch);

(
Ndef(\fxsGreyhole).set(
  \delayTime,  0.25, 
  \size,  0.8, 
  \damp,  0.5,  
  \diff,  0.8,  
  \feedback, 0.5,  
  \modDepth,  0.5,  
  \modFreq, 1.0,  
  \mix, 0.8,  
);
);
Ndef(\lfo1, {LFSaw.ar(0.25)});

Ndef(\fxsGreyhole).map(\modFreq,  { Ndef.kr(\lfo1).range(0.01,  2.0)});
Ndef(\fxsGreyhole).map(\size,  Ndef(\lfo1));
Ndef(\fxsGreyhold).map(\diff,  1/Ndef(\lfo1));
~apcBindParam.(\b3_s1_f, { |x| ~fxSetSend.(\ins1,  \s1,  x)});
~apcBindParam.(\b3_s2_f, { |x| ~fxSetSend.(\ins2,  \s1,  x)});
~apcBindParam.(\b3_s3_f, { |x| ~fxSetSend.(\ins3,  \s1,  x)});
~apcBindParam.(\b3_s4_f, { |x| ~fxSetSend.(\ins4,  \s1,  x)});
~apcBindParam.(\b3_s5_f, { |x| ~fxSetSend.(\ins1,  \s2,  x)});
~apcBindParam.(\b3_s6_f, { |x| ~fxSetSend.(\ins2,  \s2,  x)});
~apcBindParam.(\b3_s7_f, { |x| ~fxSetSend.(\ins3,  \s2,  x)});
~apcBindParam.(\b3_s8_f, { |x| ~fxSetSend.(\ins4,  \s2,  x)});
~apcBindParam.(\b4_s1_f, { |x| ~fxSetSend.(\ins1,  \s3,  x)});
~apcBindParam.(\b4_s2_f, { |x| ~fxSetSend.(\ins2,  \s3,  x)});
~apcBindParam.(\b4_s3_f, { |x| ~fxSetSend.(\ins3,  \s3,  x)});
~apcBindParam.(\b4_s4_f, { |x| ~fxSetSend.(\ins4,  \s3,  x)});
~apcBindParam.(\b4_s5_f, { |x| ~fxSetSend.(\ins1,  \s4,  x)});
~apcBindParam.(\b4_s6_f, { |x| ~fxSetSend.(\ins2,  \s4,  x)});
~apcBindParam.(\b4_s7_f, { |x| ~fxSetSend.(\ins3,  \s4,  x)});
~apcBindParam.(\b4_s8_f, { |x| ~fxSetSend.(\ins4,  \s4,  x)});
