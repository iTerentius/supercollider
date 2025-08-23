(
s.reboot;
p = ProxySpace.push(s);
)

StageLimiter.activate;

p.fadeTime = 3;
(
s.prepareForRecord;
)

s.record;

~bass.play;
(
~bass = SynthDef(\bass, { |freqs = 100, freqmod = 1 |
	var sig, env;
	env = EnvGen.kr(
		Env.pairs([
			[0.5, 1, 0.25, 1, 0.5],
			[0, 0.5, 0, 0.8]],
		\sine
		),
		doneAction: 2
	);
	sig = PMOsc.ar(
		freqs * 0.5 * (MouseY.kr(0, 1) * LFPulse.kr(Rand(1,4)))!2,
		modfreq: Line.kr(0, freqmod),
		pmindex: Line.kr(0, 150),
		mul: env);
	Out.ar(0, sig);
});
)
(
~score = Pbind(
	\instrument, \bass,
	\freqs, Pseq([110, 200, [Pwhite(0, 300), 500]], inf),
	\dur, Pseq([1, 0.5, 3, 0.25], inf),
	\freqmod, Line.kr(0, 200)
);
)

~score.play;
~score.stop;
~bass.free;
~bass.stop;
~bass.release;

p.releaseAll;

s.stopRecording;