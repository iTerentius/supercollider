(
Ndef(\synth, { | out=0, freq=440, dur=1, gate=1 |
	var sig, ef1, ef2;
	ef1 = EnvGen.kr(Env([220, 120, 0.01], [0.5,3], \sine), gate: gate, doneAction: 2);
	ef2 = EnvGen.kr(Env.adsr(Rand(0.01, 1)), gate, doneAction:2);
	sig = SinOsc.ar(SinOsc.kr(freq));
	sig = LFSaw.ar(freq) + sig * ef1;
	Out.ar(out, sig!2 * ef2 * 0.3);
}).play;
)
Ndef(\synth).play;
Ndef(\synth).clear;

(
Ndef(\synth1, { | freq=440, dur=1 |
	var sig, env;
	sig = SinOsc.ar(LFSaw.kr(freq));
	Out.ar(0, sig!2 * 0.5);
}).play;
)

Ndef(\synth1).stop;

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
		\octave, Prand([3, 5, 6], inf),
		\degree, Ppatlace([Pseq([0, -7, 2.8, 2], inf), Pseq([5, -7, 3]), inf], inf),
		// \dur, Pbjorklund2(Prand([1, 2, 3], inf),Prand([5,7,9], inf),inf)/16;
		\dur, Pseq([0.25, 0.5, Rest(1)], inf)
	)
);
)



Ndef(\synth)[10] = \filter -> { |in| DelayL.ar(in, Rand(110, 440))};
Ndef(\synth).set(\wet10, 0.5);


Env([220, 120, 10], [0.5, 7], \sine).plot;