
(
SynthDef(\pm1, {
    | out=0, freq = 220, ratio = 2, index = 3, atk=0.1, rel=2, amp = 0.3, mix = 1,  gate=1 |
    var mod, phase, carrier, env, sig;

    // modulator: oscillates at freq*ratio, scaled by index (the brightness amount)
    env = EnvGen.kr(Env.asr(atk, 1,  rel),  gate,  doneAction: 2);
    mod = SinOsc.ar(freq * ratio) * freq/8 * index * env * 1/amp;
    index = index * (freq.sqrt + env.pow(0.5)) * LFTri.ar(0.1, Rand(-0.1, 0.1), mul: env.pow(0.1)).range(0.01,  0.2);
    // mod = SinOsc.ar(freq * ratio)* index;
    env = env * PinkNoise.ar(1!2).range( 0.1, 1 ).lag(0.01);

    // manual phase ramp for the carrier: 0 -> 2pi, incrementing by
    // (freq * SampleDur) each sample = correct radians-per-sample step
    phase = Phasor.ar(0, freq * env.pow(0.3) * SampleDur.ir, 0, 2pi);

    // carrier reads phase + mod directly as its phase input
    carrier = SinOsc.ar(
      freq + LFSaw.ar(freq + LFNoise1.kr(0.8).range(1, 3), phase + mod, mul: env.pow(0.8)) +
      LFTri.ar(env.pow(0.5) * LFNoise1.kr(0.3).range(1,5), Rand(0.0,2pi), mul: env.pow(0.2) * freq * 0.005) + 
      WhiteNoise.ar(freq/8!2).lag(0.001), phase + mod);

    sig = carrier * env * amp;
    // sig = LPF.ar(sig, 1400);
    sig = HPF.ar(sig, freq);
    // sig = HPF.ar(sig, 200);
    Out.ar(out, Pan2.ar(sig, 0, mix));
}).add;
);
(
Ndef(\pm1)[0] = Pbind(
  \instrument, \pm1,
  \scale,  Scale.egyptian,  
  \octave,  4,  
  \dur, 1,  
  \rel, 4, 
  \atk, Prand((0.1..0.5),  inf), 
  \index, 3,  
  // \shift,  Pseq([12,  5], inf), 
  \shift,  12,  
  \ratio, Pxrand([0,  1,  2,  4], inf), 
  \degree,   Pseq([[0, 2],  [1,  4], -2].scramble, inf), 
  \stretch, Pseq([1/8!3, 3].flat, inf),
);
Ndef(\pm1)[1] = \filter -> { |in, shift | ~fxg[\shimmer].(in, shift:shift,   mix: 1 );  };
Ndef(\pm1)[4] = \filter -> { |in | ~fxg[\duck].(in, Ndef.ar(\kitA), 0.3, ratio:4, release:0.3,  makeup:1.3 );  };
Ndef(\pm1)[6] = \pset -> Pbind(\dur, 2,  \shift,  Pseq([12,5], inf));
Ndef(\ratio,   { SinOsc.kr(0.5) * 2pi });
);
// (
// SynthDef(\pmBell, {| out, vel=0.8 |
//
// 	var f,ff0,ff1,ff2,a,b,c,d,e, modInd,aa;
// 	var osc,signal;
// 	f = \freq.kr(100).lag(0.01);
//
// 	e = EnvGen.kr(Env.perc(
// 		\att.kr(0.015) * Rand(0.9,1.1),
// 		\rel.kr(1.02), 
// 		curve: \curve.kr(-4)
// 	),
// 		gate: Impulse.kr(0.5),
// 	) * vel;
//
// 	ff0= f * \f0ratio.kr(2 * e.pow(0.8));
// 	ff1= f * \f1ratio.kr(2 * e.pow(1.2));
// 	c = SinOsc.ar(ff0) * f * \modInd0.kr(1) * e;
// 	a = SinOsc.ar(f + [b,c].sum 
// 	);
//
// 	a = HPF.ar(a*e, f * 0.5);
//
// 	osc = a * \pgain.kr(1);
// };
// );
// (
// Ndef(\pmBell)[1] = \filter -> { |in, trigRate = 40, grainDur = 0.08, pan = 0.0, amp = 0.3, envbufnum = 0|
//     var mono, wet;
//     mono = (in[0] + in[1]) * 0.5;
//     wet = GrainIn.ar(
//         numChannels: 2, trigger: Dust.kr(trigRate), dur: grainDur,
//         in: mono, pan: pan, envbufnum: envbufnum
//     ) * amp;
//     wet   // just return it — no In.ar/Out.ar/ReplaceOut.ar needed, NodeProxy handles both
// };
// Ndef(\pmBell)[5] = \pset -> Pbind(
//   \octave,  4,  
//   \degree,  Pseq((0..7).scramble,  inf),  
//   \dur, 1/4,  
//   \stretch, Pseq([1/3!3,  1].flat,  inf), 
//   \f0ratio,  Pwhite(1,  4,  inf), 
//   \f1ratio,  Pwhite(2,  5,  inf), 
// );
// );
( 
Ndef(\fm1)[0] = Pbind(
	\instrument, Pseq([
    // \fmSaw, 
    \fm3
  ], inf), 
  \scale,  Scale.egyptian,  
	\dur, Pseq( 2.pow((-4..2).scramble), inf ),
  // \dur, 4,  
	\legato, Pfunc({rrand(0.01,1)}),
	\degree, Pseq([0,2,5,6,8,11].scramble, inf),
	\octave, Pstutter(3, Pseq([3,4,5], inf) ),
	\vel, Pstutter(6, Pseq([ 0.2, 1, 1.2 ].scramble, inf)),
	\f0ratio, Pseq( (3..5).scramble, inf ),
	\f1ratio, Pseq( (1..3).scramble, inf ),
	\f2ratio, Pseq( (3..5) / (1..3).scramble, inf ),
	\modInd0, Pfunc{rrand(0,2.0)},
	\modInd1, Pfunc{rrand(0,1.0)},
	\modInd2, Pfunc{rrand(0,0.5)},
); 
);

(
Ndef(\pedestrian).fadeTime = 8;
Ndef(\pedestrian)[0] = { | freq=220,   amp=0.2 |
	var sig;
  sig = SinOsc.ar([freq, freq * 1.1], 0, 0.2) * LFPulse.ar([5,  5.2], 0.5).lag(0.01);
  sig * amp; 
};
Ndef(\pedestrian)[1] = \pset -> Pbind(
  \amp, 0.8,  
  // \octave,  Pseq([4,  5,  6], inf), 
  \degree,  Pslide((0..7).scramble, inf,  3,  4),  
  \dur, 1
);
);
// (
// SynthDef(\scr2, {
//   | out=0,  freq=100, amp=0.4,  gate=1 |
//   var sig, f, e1;
//   e1 
//
// });
// );
(
SynthDef(\scratch,  {
| out=0,  freq=110, amp=0.4,  gate=1 |
var sig,   e1,  e2,  p1;
e1 = EnvGen.kr(Env.circle([0.02,  1.0,  0.02],  [1, 1,  1], \exp), gate);

e1 = e1 * PinkNoise.ar(1!2).range( 0.3, 1 ).lag(0.01);
e2 = EnvGen.kr(Env.adsr(0.03,  0.5, 0.3,  1), gate, doneAction:2);
e2 = e2 * PinkNoise.ar(1!2).range( 0.1, 1.5 ).lag(0.01);
p1 = EnvGen.kr(Env.new([1.2,  1],  [0.25],  \exp),  gate);
freq = freq * p1;
sig = SinOsc.ar([freq, freq*1.01]) * e1
* LFPulse.ar(freq 
  * LFNoise1.ar(1) 
   )  
+ LFTri.ar(freq * 0.25)
* e2 * amp;
sig = [sig, sig * 1.03] * 0.4;
// sig = RHPF.ar(sig,  100, 0.3);
// sig = RLPF.ar(sig,  SinOsc.ar(0.125).range(500, 4500),  0.5);
// Splay.ar(sig);
Out.ar(out,  Splay.ar(sig) * amp);
}).add;
);

