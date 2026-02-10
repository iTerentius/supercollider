// 2025-11-08 DynKlank playable instrument
(
SynthDef(\dynklangPluck, { |out=0, freq=440, amp=0.2, gate=1, pan=0|
	var sig, env, exc, baseFreqs, amps, rings, ratios;

	// base resonant structure
	baseFreqs = [1, 2.1, 3.4, 5.8]; // relative harmonic-ish
	amps      = [1.0, 0.5, 0.3, 0.2];
	rings     = [2, 3, 4, 5]; // decay times in seconds

	// excitation (a short noise burst or impulse)
	exc = PinkNoise.ar(0.3) * EnvGen.kr(Env.perc(0.01, 0.05), doneAction: 2);

	// scale resonant frequencies to note frequency
	sig = DynKlank.ar(
		`[ baseFreqs * freq, amps, rings ],
		exc
	);

	// simple amplitude envelope
	env = EnvGen.kr(Env.adsr(0.1, 2, 1.5), gate, doneAction: 2);
  sig = LeakDC.ar(sig);
	// pan and output
	sig = Pan2.ar(sig, pan, amp) * env;
	Out.ar(out, sig);
}).add;
)
(
Pdef(\dpat,
Pbind(
	\instrument, \dynklangPluck,
	\scale, Scale.minor,
	\degree, Prand([0,2,4,5,7,9,11,12], inf),
	\dur, 0.125,
	\amp, 0.15,
  \out, ~t2.inbus.index
)).play;
)
Pdef(\dpat).stop;
(
Ndef(\dkPluck, { |freq=220, amp=0.2, pan=0, excAmp=0.3, excAtk=0.001, excDec=0.05, trigRate=4, trig=0|
	var sig, exc, baseFreqs, amps, rings, periodicPing, manualPing;

	baseFreqs = [1, 2.1, 3.4, 5.8];
	amps      = [1.0, 0.5, 0.3, 0.2];
	rings     = [2, 3, 4, 5];

	// periodic ping: audio-rate all the way
	periodicPing = Decay2.ar(Impulse.ar(trigRate.max(0)), excAtk, excDec);

	// manual ping: convert control-rate trig to audio-rate, then Decay2.ar
	manualPing   = Decay2.ar(K2A.ar(Trig1.kr(trig, 0.001)), excAtk, excDec);

	exc = PinkNoise.ar(excAmp) * (periodicPing + manualPing);

	sig = DynKlank.ar(
		`[ baseFreqs * freq, amps, rings ],
		exc
	);

	Pan2.ar(sig, pan) * amp  // return only; Ndef handles out/gate internally
});
// Ndef(\dkPluck)[2] = \filter -> {|in, mod=8| LFPulse.ar(mod).tanh * in.distort };
Ndef(\dkPluck)[1] = \pset -> Pbind(
  \scale, Scale.mixolydian,
  \degree, Prand([0, -4, 2, -6], inf),
  \octave, Pseq([3,4], inf),
	// \freq, Prand([220, 330, 440, 550, 660]/2, inf),  // sequence of frequencies
	\amp, 0.2,
	\trig, 1,              // fires the manual ping each event
	\dur, Pbjorklund2(3,8,inf),            // event rate
	\pan, Pwhite(-0.8, 0.8, inf),
	\excAmp, 0.2,          // drive strength
	\excAtk, 0.01,
	\excDec, 0.25,
  \mod, Pseq([2,4,8,\rest], inf)
);
)
~dkp = ~t2.play(Ndef(\dkPluck));
~dkp.tryPerform(\free);
~dkp_delay = ~t2.newPostSend(~r2, 2);
~dkp_delay.tryPerform(\free); 
Ndef(\dkPluck)[2].set(\wet, 1);
Ndef(\dkPluck)[2] = nil;
Ndef(\dkPluck).clear;

//////////////////////////////////////////////////////////////////////////////////////
(
Ndef(\dynklanks).fadeTime_(3.0);
Ndef(\dynklanks, { | freqs = #[200, 671, 1153, 1723], mod=8, amp=0.2, dur=1, freq=100 |
  var sig;
	//DynKlank.ar(`[freqs, nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007]))
  sig = DynKlank.ar(`[freqs, nil, [0.9, 0.9, 0.5, 0.5]], LFPulse.ar(freq: 0.05, phase: 0.5, width: 0.5, mul:0.1 )); 
  sig!2 * amp;
});
// Ndef(\dynklanks)[1] = \pset -> Pbind(\amp, 0.2, \dur, Pseq([1, 2, 4, 8, 16, 1], inf), \mod, Pseq((10..1), inf));
// Ndef(\dynklanks)[1] = \pset -> Pbind(\amp, 0.3, \dur, .25, \mod, Pseq((10..1), inf));
)
Ndef(\dynklanks)[1] = nil;
~rez = ~t3.play(Ndef(\dynklanks));
~rez.tryPerform(\free);

~rez_verb = ~t3.newPostSend(~r1, 2);
~rez_verb.tryPerform(\free);

~rez_delay = ~t3.newPostSend(~r2, 2);
~rez_delay.tryPerform(\free);

~apcBindParam.(\b0_s1_r2, {|x| Ndef(\dynklanks).set(\mod, x.linlin(0, 127, 1, 50))});
~lcxlParam[\b1_s1_r2] = {|x| Ndef(\dynklanks).set(\mod, x.linlin(0, 127, 1, 10))};
// Ndef(\dynklanks).play;
// Ndef(\dynklanks).stop(3);
Ndef(\dynklanks).clear(3);

Ndef(\dynklanks).set(\freqs, [333, 444, 555, 666].rand);

/////////////////////////////////////////////////////////////////////////////////////
(
var env = Env.new([0, 1, 0], [0.01, 1], [0, -4]);
~grainenv = Buffer.loadCollection(s, env.discretize(8192));
)
~loadSamps.("~/Music/supercollider/_samples/_mono/");
~samp1 = ~sTree.at(\hoarder_mono).asArray[4];
~samp1 = ~sTree.at(\hoarder_mono).asArray;
~samp1 = ~sTree.at(\jttcot).asArray;
~samp1 = ~sTree.at(\_mono).asArray;
~samp1 = ~getSample.(\_mono, \Ya_Ya_125bpm_Vox);
~samp1 = ~getSample.(\hoarder_mono, \n);
~samp1 = ~sTree[\jttcot][\00];
(
Pdef(\gpat, 
  Pbind(
    \instrument, \gb1, 
    \dur, Pseq([4, Rest()],inf), 
    \amp, 1, 
    \trig_rate, 32, 
    \buf, Pseq(~samp1,  inf).stutter(1), 
    \env, ~grainenv, 
    \grain_dur, Prand([0.05, 0.125, 0.25, 0.5],inf), 
    \rate, Prand([-3, 2, -1, 2],inf), 
    \out, 2,  
  )
);
)
s.plotTree;
Pdef(\gpat).play(~link,  quant:4, out: 2);
Pdef(\gpat).stop;
~t2_src = ~t2.play(\gb1, [\buf, ~samp1, \env, ~grainenv] );
~t2_src.tryPerform(\free);
~t2_src.set(\trig_enabled, 1, \pos, 0.5);
~t2_src.set(\buf, ~samp1);
~t2_src.free;

~grain_rev = ~t2.newPostSend(~r1, 0.5);
~grain_rev.free;

~samp1 = Buffer.readChannel(s, "/Users/isaaclinder/Music/supercollider/_samples/Field/Bambu/bambu-1.wav", channels: [0]);
~loadSamps.("~/Music/supercollider/_samples/_mono/");
~loadSamps.("~/Music/supercollider/_samples/_mono/hoarder_mono/");
~samp2 = ~sTree[\hoarder_mono][\n04_6_rats];

ServerMeter(s);
~printTree.();
//////////////////////////////////////////////////////////////////////////////////////
(
Ndef(\gb1).fadeTime_(2);
Ndef(\gb1, { | amp=1, freq=220, trig_rate=8, grain_dur=0.05, buf, env, rate=1, pan_rate=10, trig_enabled=1 | 
  var sig;
	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: Impulse.kr(trig_rate) * trig_enabled,
		dur: grain_dur,
		sndbuf: buf,
		rate: rate.midiratio,
		pos: Line.kr(0, 1, BufDur.ir(buf)),
		interp: 2,
		pan: LFNoise1.kr(pan_rate),
		envbufnum: env
	);
 sig * 1.2  
});
Ndef(\gb1)[1] = \pset -> Pbind(\dur, Pseq([3, Rest()],inf), \amp, 1, \trig_rate, 32, \buf, Pfunc({~samp1.choose;}), \env, ~grainenv, \grain_dur, Prand([0.05, 0.125, 0.25, 0.5],inf), \rate, Prand([-4, 2, -1, 2],inf));
Ndef(\gb1)[2] = \filter -> {|in, trig_rate, rate| Gate.ar(in, LFPulse.ar(SinOsc.kr(trig_rate))/2)};
Ndef(\gb1)[3] = \filter -> {|in, mod=10| in + SinOsc.ar(mod)};
// Ndef(\gb1)[2] = nil;
)
Ndef(\gb1).play;
Ndef(\gb1).stop(3);
Ndef(\gb1).clear;

Ndef(\gb1).set(\wet2, 1.0);
~gb1 = ~t2.play(Ndef(\gb1));
~gb1.tryPerform(\free);
(
~gb1_fx = ~t5.playfx(\duck, [
  \side, ~pbd1.inbus.index,
  \thresh, 0.12,
  \ratio, 10,
  \attack, 0.01,
  \release, 0.1
]);
)

~gb1_rev = ~t2.newPostSend(~r1, 1);
~gb1_rev.free;
~gb1_delay = ~t2.newPostSend(~r2, 1);
~gb1_delay.free;

~r1.level_(1);
~r2.level_(1);
