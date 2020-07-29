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

~env = { Pulse.kr(5 * Line.kr(0, 1, 3), SinOsc.kr(1.5)).range(120, 550) };
~env = { LFNoise0.kr(4).range(120, 550); };
(
SynthDef(\s1, { | freq = 440, gate = 1, atk = 0.01, sus = 0, rel = 1, fb = 0, amp = 0.3, out = 0, pan=0 |
	var env, sig;
	env = EnvGen.kr(Env.asr(0.1, 0.7, 0.5,\sine), gate: gate, doneAction: 2);
	sig = SinOsc.ar(freq * PMOsc.ar(freq * ~env, width: ~env), mul: env).dup;
	Out.ar(0, sig * ~env.abs * env);
}).add;
)

(
~out = Pbind(
	\instrument, \s1,
	\scale, Scale.at(\minor),
	// \freq, Pseq([200, 110, 440, 110], inf, 2),
	\degree, Pseq((0..7), inf),
	\octave, 4,
	\dur, Pseq([0.25, Rest(1), 2, Rest(2), 3], inf),
	// \gate, Pseq([0,1,0,1],inf);
);
)

p.stop;
