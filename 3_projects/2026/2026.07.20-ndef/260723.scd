(
SynthDef(\v1, { |out=0,  amp=0.2, gate=1 | 
  var sig, f, ff0,  ff1, a, b, e;
  f = \freq.kr(220);
  ff0 = f * \ff0r.kr(2);
  ff1 = f * \ff1r.kr(2);

  e = EnvGen.kr(
    Env.perc(
      \att.kr(0.015), 
      \rel.kr(1.2), 
      curve: \curve.kr(-4), 
    ),  
    gate: gate, 
    doneAction: 2
  );
	e = e * PinkNoise.ar(1!2).range( 0.1, 1 ).lag(0.01);
  
  a = SinOsc.ar(ff0) * f * \mi0.kr(1) * e.pow(0.8);
  b = SinOsc.ar(ff1) * f * \mi1.kr(0.6) * e.pow(1.4);
  
  sig = LFTri.ar([f, f + rrand(-2, 2)]) * SinOsc.ar([f, f + rrand(-1, 1)]) * LFPulse.ar(f!2) * amp * e; 
  // sig = f + SinOsc.ar(e.pow(0.5) * LFNoise1.kr(0.3).range(1,  5), Rand(0.0, 2pi), mul: e.pow(0.2) * f * 0.005); 
  sig = HPF.ar(sig * e.pow(0.5),  f);
  Out.ar(out,  sig);

}).add;
)
(
Ndef(\v1)[0] = 
  Pbind(
    \type,  \grain, 
    \instrument,  \v1,  
    \scale, Scale.egyptian,  
    \dur, Pseq([1/4!3, Rest(0.25) ].flat, inf),  
    \att, Pseg([0.015,  0.5,  0.015], [4],  \wel, inf),  
    \degree,  Pseq((-7..7).scramble,   inf),  
    \rel, Pkey(\stretch) * Pseq((0.2..1.4), inf), 
    // \stretch, Pseq([1/2!2,  1], inf), 
  );
Ndef(\v1)[3] = \filter -> {|in| ~ilfxCores[\shimmer].(in)};
Ndef(\ins1)[0] = {|amp=0.75| Ndef(\v1) * amp };
~apcBindParam.(\b0_ds1_k2, { |x| Ndef(\v1).set(\wet3,  x)});
)
)
Ndef(\v1).set(\wet3,  0.5);
Ndef(\v1).free;
Scale.directory
