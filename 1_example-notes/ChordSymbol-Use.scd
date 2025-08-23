p = ProxySpace.push(s.boot);
p.makeTempoClock;
p.clock.tempo = 2;
StageLimiter.activate;

(
SynthDef(\ct, { | freq=110, gate=1 |
	var sig, env;
	env = EnvGen.ar(Env.asr(0.5, 0.8, 0.25), 1, levelScale: 0.5, doneAction: 2);
	sig = SinOsc.ar(freq).dup;
	Out.ar(0, sig);
}).add;
)


(
~s1 = Pbind(
	\instrument, \ct,
	\note, \C1M.asNotes,
	\dur, Pseq([0.5, 1, 0.5], inf),
	\amp, 0.1
)
)

~s1.play;
