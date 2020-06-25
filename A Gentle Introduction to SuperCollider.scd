~myFreqs = [415, 220, 440, 880, 220, 990];
~myDurs = [0.1, 0.2, 0.2, 0.5, 0.2, 0.1];

Pbind(\freq, Pseq(~myFreqs), \dur, Pseq(~myDurs)).play;

/// Patterns

Pbind(\degree, Pseries(0, 1, 30), \dur, 0.05).play;

Pbind(\degree, Pseq([0,1,2,3,4,5,6,7], inf),\dur, 0.2, \amp, 0.8).play;

(
SynthDef(\test, {
	|freq=440, phase=0, amp=1, add=0|
	var sinewave, env, envgen;
	env = Env([0.1, 1, 0.1], [0.1, 0.25, 0.8], \exp);
	envgen = EnvGen.ar(env, 0);
	sinewave = SinOsc.ar(freq, phase, amp, add, mul: envgen/2);

	Out.ar([0,1], sinewave);
}).add;
)


(
Pbind(
	\instrument, \test,
	\degree, Prand([0, -1, 2, -3, 4, -3, 7, 11, 4, 2, 0, -3], inf),
	\dur, Pseq([0.2, 0.1, 0.1], inf),
	\amp, Pseq([0.7, 0.5, 0.3, 0.2], inf)/8,
	\legato, 0.2
).play
)

(
Pbind(
	\instrument, \test,
	\degree, Pwhite(-12, 12),
	\dur, Prand([0.2, 0.1, 0.1], inf),
	\amp, 0.2,
	\legato, 0.2
).play
)


(
Pbind(
	\note, Pser([0,2,3,5,7,8,11,12], 11),
	\dur, 0.15
).play;
)

(
Pbind(
	\note, Pshuf([0,2,3,5,7,8,11,12], inf),
	\dur, 0.15,
	\amp, Pseq([0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.01], inf);
).play;
)

(
Pbind(
	\note, Pslide([0,2,3,5,7,8,11,12], inf, 3, 1, wrapAtEnd: true),
	\dur, 0.15,
	\amp, 0.707;
).play;
)

(
Pbind(
	\instrument, \test,
	\note, Pseries(0, 2, 24),
	\dur, 0.15,
	\amp, 0.707;
).play;
)