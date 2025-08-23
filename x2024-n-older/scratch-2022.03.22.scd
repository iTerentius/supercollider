(
SynthDef(\exp, { | freq = 110, out = 0, amp = 0.5, gate = 1, pulse = 0.5 |
	var s, e;
	s = SinOsc.ar(freq + LFPulse.kr(pulse));
	e = EnvGen.kr(Env([0, 0.5, 0.9, 0], [0.1, 0.5, 1], inf) , gate, doneAction: 2);
	Out.ar(0, s!2 * amp * 0.5);
}).add;
)

Synth(\exp).play;

(
Pdef(\0,
	Pbind(
		\instrument, \exp,
		// \note, Pbrown(0, 6, 0.1, inf),
		\freq, Pbrown(52, 440, 10, inf),
		\dur, 0.25,
		\amp, 0.1,
		\pulse, 0.25,
	).play(quant: 1);
)
)


