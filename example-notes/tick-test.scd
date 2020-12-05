(
~hr = HypoRecorder();
~hr.add([\tick], 1);
)

~hr.record;
~hr.stop;

(
SynthDef(\tick, { | out=0, freq=520, gate=1, dur=1 |
	var sig, env;
	env = EnvGen.kr(Env.perc(0.0001,releaseTime: dur), doneAction: 2);
	sig = LFPulse.ar(freq * env);
	OffsetOut.ar(out, sig!2 * 0.05);
}).add;
)

(
Ndef(\tick).play;
Pdef(\tick,
	Pbind(
		\instrument, \tick,
		\degree, Prand((0..7), inf),
		\scale, Scale.major,
		\out, Pfunc(Ndef(\tick).bus.index),
		\group, Pfunc(Ndef(\tick).group),
		// \dur, Pseq([0.125, 0.325, 0.625, 0.825], inf),
		\dur, 0.25,
		\recordTarget, ~hr,
		\chan, 0,
	)
)
)

Pdef(\tick).play(quant: -1);