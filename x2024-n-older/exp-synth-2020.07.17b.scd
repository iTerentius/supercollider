(
s.reboot;
p = ProxySpace.push(s);

p.fadeTime = 3;
)


StageLimiter.activate;
(
s.prepareForRecord;
)

s.record;

~out.play;
(
SynthDef(\bass, { |freqs = 100, freqmod = 1 |
	var sig, env;
	env = EnvGen.kr(
		Env.new(
			levels: [0.5, 0.7, 0.5, 0.01, 2, 0.01],
			times: [0.5, 0.5, 0.6, 0.8, 1],
			curve: \step
		),
		doneAction: 2,
		timeScale: 2
	);
	sig = Pan2.ar(PMOsc.ar(
		LFPulse.ar(LFSaw.ar(freqs) * LFNoise2.kr(freqmod)),
		modfreq: freqmod.midicps / 4,
		pmindex: env * 2,
		mul: env),
	Rand(-0.75, 0.75));
	Out.ar(0, sig * 0.2);
}).add;
)

~out = ~out * Dust2.kr(500, 0, 1) / 2;

(
~score = Pbind(
	\instrument, \bass,
	\freqs, Pseq([85, 110, [Pwhite(150, 55), 30], Rest(2)], inf),
	\dur, Pseq([0.25, 0.5, 3,Rest(3), 0.25], inf),
	\freqmod, Pwhite(50, 110, inf),
	\amp, 0.2
);
)

~score.play;
~score.stop;
~out.stop;

p.releaseAll;

s.stopRecording;
(
Env.new(
			levels: [0.5, 0.7, 0.5, 0.01, 3, 0.01],
			times: [0.5, 0.5, 0.6, 0.8, 1],
			curve: [\step, \sine].choose
		).plot;
)