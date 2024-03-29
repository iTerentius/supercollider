(
s.reboot;
p = ProxySpace.push(s);
)

StageLimiter.activate;
(
s.prepareForRecord;
)

s.record;

~bass.play;
(
SynthDef(\bass, { |freqs = 100 |
	var sig, env;
	env = EnvGen.kr(Env.pairs([[0.5, 1, 0.25, 1, 0.5], [0, 0.5, 0.6, 0.8]], \sine), doneAction: Rand(0,2));
	sig = PMOsc.ar(freqs * 0.5 * (MouseY.kr(0, 1) * LFPulse.kr(Rand(1,4)))!2, modfreq: MouseX.kr(0, 400), pmindex: Line.kr(0, 150), mul: env);
	Out.ar(0, sig);
}).add;
)
(
~score = Pbind(
	\instrument, \bass,
	\freqs, Pseq([110, 200, [Pwhite(0, 300), 500]], inf),
	\dur, Pseq([1, 0.5, 3, 0.25], inf)
);
)

~score.play;

s.stopRecording;