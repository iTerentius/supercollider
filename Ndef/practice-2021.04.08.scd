(
Ndef(\synth, { | out=0, freq=440, dur=1, gate=1 |
	var sig, ef1;
	ef1 = EnvGen.kr(Env([220, 120, 0.01], [0.5, 3, 7], \sine), gate: gate, doneAction: 2);
	sig = LFTri.ar(SinOsc.kr(freq) * ef1);
	Out.ar(out, sig!2 * ef1 * 0.002);
}).play(out: 0);
)
Ndef(\synth).play;
Ndef(\synth).clear;

(
Ndef(\synth1, { | freq=440, dur=1 |
	var sig, env;
	sig = SinOsc.ar(LFSaw.kr(freq));
	Out.ar(0, sig!2 * 0.2);
}).play;
)

(
Ndef(\synth1)[1] = \xset -> Pdef(\s1).quant_(-1);
Ndef(\synth)[1] = \xset -> Pdef(\s1).quant_(-1);
)

Ndef(\synthlfo, { LFPulse.kr(1) });

Ndef(\synth).xmap(\gate, Ndef(\synthlfo));

(
Pdef(\s1,
	Pbind(
		\out, {Ndef(\synth).bus.index};
		\group, {Ndef(\synth).group};
		// \freq, Ppatlace([Pseq([60, 110, 20, 30], inf), Pseq([150, 60, 110, Rest(16)]), inf], inf),
		\octave, Prand([7, 5, 6], inf),
		\degree, Ppatlace([Pseq([0, -7, 2.8, 2], inf), Pseq([5, -7, 3]), inf], inf),
		\dur, Pbjorklund2(Prand([1, 2, 3], inf),Prand([5,7,9], inf),inf)/4;
	)
).stop;
)



Ndef(\synth)[10] = \filter -> { |in| LPF.ar(in, Rand(110, 440))};
Ndef(\synth).set(\wet10, 1);
