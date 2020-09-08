(
p = ProxySpace.push(s.reboot);
p.makeTempoClock;
p.clock.tempo(1);
p.fadeTime = 3;
)

(
SynthDef(\s1, { | out=0, freq=440, gate=1, amp=0.5, trig=1, ts=1 |
	var sig, env;
	env = EnvGen.kr(Env.perc(0.1, 0.5, 1.0, \sine), gate: gate, timeScale: ts * Rand(1, 5), doneAction: Done.freeSelf);
	env = SinOsc.kr(3, mul: env);
	sig = Pulse.ar(freq: [freq.midicps, freq] + SinOsc.ar(freq /2), mul: env * amp);
	Out.ar(out, sig!2);
}).add;
)

~s1 = Synth(\s1, [\freq, 100]);

~s1.set(\freq, 100);

p.clock.tempo(0.2);

(
~p = Pbind(
	\instrument, \s1,
	\freq, Pseq([36, 41, 48, 43, 53], inf),
	\amp, Pseq([0.1, 0.25, 0.5, 0.8], inf),
	\gate, Pseq([0, 1, 1, 0, 0], inf),
	\ts, Pseq([0, 1, 1, 0, 0], inf),
);
)

~p.play;