(
p = ProxySpace.push(s.reboot);
p.makeTempoClock;
p.clock.tempo(1);
)

StageLimiter.activate;
s.prepareForRecord;
s.record;
s.stopRecording;

p.fadeTime = 3;

~out.play;

~env = { Pulse.kr(5 * Line.kr(0, 1, 3), SinOsc.kr(1.5)) };
~env = { LFNoise0.kr(20); };
(
SynthDef(\s1, { | freq = 440, atk = 0.01, sus = 0, rel = 1, fb = 0, amp = 0.3, out = 0, pan=0 |
	var env, sig;
	env = EnvGen.kr(Env.asr(0.1, 0.7, 0.1,\sine), gate: ~env, timeScale: 2, doneAction: 2);
	sig = SinOsc.ar(freq * PMOsc.ar(freq * env, width: ~env), mul: env).dup;
	Out.ar(0, sig * env);
}).add;
)

(
~out = Pbind(
	\instrument, \s1,
	\freq, Pseq([50, 110, 440, 110], inf, 2),
	\dur, Pseq([2, Rest(1), 1, Rest(2)], inf)
);
)

p.stop;
