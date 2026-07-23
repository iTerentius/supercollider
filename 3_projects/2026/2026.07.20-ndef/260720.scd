
(
Ndef.dictFor(s).clock = ~link;
Ndef.dictFor(s).quant = 1;
Ndef.dictFor(s).fadeTime = 3;
)
// Example:
Ndef(\pad, { SinOsc.ar([100, 441]) * 0.2 });
Ndef(\pad).fadeTime = 2;

Ndef(\pad).play;
Ndef(\pad).stop;
Ndef(\pad).clear;

Ndef(\pad).source = ~ufn[\dk];
Ndef(\pad).map(\freq,  Ndef(\lfo));

Ndef(\lfo, {SinOsc.ar(0.5) + 3 * 2});

(
Ndef(\v1).fadeTime = 0;
Ndef(\v1, ~ufn[\thickPad]);
Ndef(\v1)[1] = \pset -> Pbind(
  \octave,  3,  
  \degree,   Pslide([0, 0,  2,  4,  \], inf,  3,  4),  
  \dur,  Pseq((1..4), inf), 
  \freeze,  Pseq([0, 1], inf), 
  \amp,  0.3, 
  \bits,   Pseg([6,  24],[16], \sin,   inf), 
  \rate,   Pslide([500, 3000, 12000], inf,  2,  3), 
  \stretch, Pseg([2,  1/4], [16],  \sin,  inf),  
);
Ndef(\v1)[2] = \filter -> { |in|
        var sig = in;
        var wet = Decimator.ar(sig, \rate.kr(44100), \bits.kr(8));
        XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
    };
Ndef(\v1)[3] = \mix ->  ~ufn[\dk];
Ndef(\v1)[4] = \filter -> { |in|
    var sig, chains, wetFreeze, wetSmear, wet, mix, amp, freeze, smear, freezeSmear, chunk;
    sig = in;
    mix = \mix.kr(1);
    amp = \amp.kr(1);
    chunk = \chunk.kr(2048);
    freeze = \freeze.kr(0);
    smear = \smear.kr(0);
    freezeSmear = \freezeSmear.kr(0);

    chains = sig.collect({ |chan| FFT(LocalBuf(chunk), chan) });
    wetFreeze = IFFT(chains.collect({ |chain| PV_Freeze(chain, freeze) }));
    wetSmear  = IFFT(chains.collect({ |chain| PV_MagSmear(chain, smear) }));

    wet = XFade2.ar(wetFreeze, wetSmear, freezeSmear * 2 - 1);
    XFade2.ar(sig, wet, mix * 2 - 1) * amp;
};

Ndef(\ins3)[0] = {|amp = 1| Ndef.ar(\v1) * amp};
)
Ndef(\v1).map(\bits, { Ndef.kr(\lfo).range(4,  12) });
Ndef(\v1).unmap(\freeze, Ndef(\freezeLFO));
Ndef(\v1).set(\smear, 0);
Ndef(\v1).set(\freezeSmear, 0);
Ndef(\v1).map(\wet4,  Ndef(\freezeLFO));
Ndef(\v1)[2] = nil;
Ndef(\v1).free;
Ndef(\v1).clear;

Ndef(\freezeLFO, { LFPulse.kr(0.5) }).play;
~sTree[\bd];

(
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
)
(
Ndef(\kit)[0] =  Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\bass_drums].values[0..3], inf),   
  \amp,  0.4, 
  \dur,   1,
  \stretch, Pseg([1,   3],[8],  \lin,   inf), 
);
Ndef(\kit)[1] = Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\hats].values[1..3], inf),   
  \amp,  0.4, 
  \dur,   1/3,
  // \stretch, Pseg([1,   1/5],[8],  \sin,   inf), 
);
Ndef(\kit)[2] = \filter -> {|in, delayTime=2.0, size=0.2, damp=0.1,  diff=0.5,  feedback=0.9, modDepth=0.5, modFreq=2.0 | Greyhole.ar(in, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
// Ndef(\kit)[1] = nil;
Ndef(\ins2)[0] = { |amp=1| Ndef.ar(\kit, 2) * amp };
~apcBindParam.(\b0_ds1_k1, { |x| Ndef(\kit).set(\wet2,  x)});
)

// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
Ndef(\lfo, {LFPulse.ar(1.5) + SinOsc.ar(1)});

Ndef(\kit).set(\size,  0.8, \damp,  0.1,  \diff,  0.5,  \modDepth,  0.5);
Ndef(\kit).map(\modFreq,  { 1/ Ndef(\lfo,  1).max(0.1) });
Ndef(\kit).map(\size,  Ndef(\lfo));
Ndef(\kit).map(\diff,  { Ndef.kr(\lfo)});
Ndef(\kit)[2] = nil
Ndef(\kit).set(\wet2, 0.5);

Ndef(\kit).free;
Ndef(\kit).clear;
Ndef.clear;

Ndef(\kit,  { SinOsc.ar([110,  111]) * 0.2 });
Ndef(\test).free;
(
Ndef(\as, { | freq=410 ,  index=0.42, distance=1.00,  amp=0.2 |
	var theta, beta, num, denom, son, env;
	
	// Two phasors which will ramp from zero to 2pi
	theta = Phasor.ar(0, freq, 0, 2pi);
	beta  = Phasor.ar(0, freq * distance, 0, 2pi);
	
	num = sin(theta) - (index * sin(theta - beta));
	denom = 1 + index.squared - (2 * index * cos(beta));
	
	son = num / denom;
	
	Pan2.ar(son * amp);
	
});
Ndef(\as)[1] = \pset -> Pbind(
  \dur,  8, 
  // \index,  Pwhite(0.42, 0.9,  inf), 
  \distance,  Pseq((5..10), inf),  
  \octave, Pstep(Pseq((-2..1), inf),4),   
  \degree,  Pseq([0, 4,  2,  1], inf),  
  \stretch,  Pseg([1/2, 2,   1/2], [4,  2],  \sin, inf), 
);
)
Ndef(\ins1,  {|amp=0.75| Ndef(\as) * amp});
Ndef(\as).free;
Ndef(\as).map(\index, {Ndef.kr(\lfo).range(0.3, 0.9)});
Ndef.all.free;

(
Ndef(\pmManual, {
    |  freq = 220, ratio = 2, index = 3, amp = 0.3, mix = 1,  t_gate=1 |
    var mod, phase, carrier, env, sig;

    // modulator: oscillates at freq*ratio, scaled by index (the brightness amount)
    mod = SinOsc.ar(freq * ratio) * index;

    // manual phase ramp for the carrier: 0 -> 2pi, incrementing by
    // (freq * SampleDur) each sample = correct radians-per-sample step
    phase = Phasor.ar(0, freq * SampleDur.ir, 0, 2pi);

    // carrier reads phase + mod directly as its phase input
    carrier = SinOsc.ar(0, phase + mod);

    env = EnvGen.kr(Env.perc(0.01, 2),  t_gate);
    sig = carrier * env * amp;

    Pan2.ar(sig, 0, mix);
});
// Ndef(\pmManual)[1] = \pset -> Pbind(
//   \octave,  3,  
//   \dur, 1/2,  
//   \t_gate,   1, 
//   \index, Pseq((3..5),  inf), 
//   \ratio, Pwhite(1, 10,  inf), 
//   \degree,   Pseq([0, 2,  0,  \,  4], inf), 
// );
)
Ndef(\pmManual).play;
Ndef(\pmManual).clear;
Ndef(\pmManual).stop;

(
Ndef(\pmBell, {
    |freq = 220, ratio = 1.4, indexMax = 8, amp = 0.3, t_trig = 1|
    var trig, indexEnv, ampEnv, carrier;

    trig = Trig1.kr(t_trig, 0); // or just use t_trig directly, both work with EnvGen

    indexEnv = EnvGen.kr(Env.perc(0.001, 2, indexMax, -4), t_trig);
    ampEnv   = EnvGen.kr(Env.perc(0.001, 3), t_trig); // no doneAction, no gate collision

    carrier  = PMOsc.ar(freq, freq * ratio, indexEnv);
    carrier * ampEnv * amp;
    Pan2.ar(carrier,  0,  1);
});
)

Ndef(\pmBell).play;
Ndef(\pmBell).clear;
Ndef(\pmBell).stop;
Ndef(\pmBell).set(\t_trig, 0); // retriggers the perc envelope every time

