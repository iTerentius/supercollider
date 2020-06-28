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
	env = Env.perc([0,1,0]*amp/2, [1, 1]);
	envgen = EnvGen.ar(env, 0);
	sinewave = SinOsc.ar(freq, phase, amp, add);

	Out.ar([0,1], sinewave + envgen);
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

(
Pbind(
	\note, Pseq([0, 2, 3, 5, 7, 8, 11, 12], inf),
	\dur, Pgeom(0.1, 1.1, inf);,
	\amp, 0.707;
).play;
)

(
Pbind(
	\note, Pseq([0, Pn(2,3), 3, Pn(5,3), 7, Pn(8,3), 11, 12], 1),
	\dur, 0.15;
).play;
)

// More Pattern Tricks

// Chords

(
Pbind(
	\note, Pseq([[0,3,7], [2,5,8], [3,7,10], [5,8,12]], 3),
	\dur, 0.15
).play;
)

// Strum
(
p = Pbind(
	\instrument, \test,
	\note, Pseq([[-7, 3, 7, 10], [0,3,5,8]], 2),
	\dur, 1,
	\legato, 0.4,
	\strum, 0.4
);
)

~player = p.play;

~player.stop;


// Nesting and proper indentation
(
SynthDef(\test2, {
	|freq=440, phase=0, amp=1, add=0|
	CombC.ar(
		SinOsc.ar(
			(
				LFNoise1.ar(3, 24,
					LFSaw.ar([5, 5.123], 0, 3, 80)
				) -12
			)*freq,
			0, LFPulse.kr(0.5)
		),
		1, 0.3, 2)
}).add;
)

(
~scale = Scale.harmonicMinor;
~degree = Pseq([0,1,2,3,4,5,6,7], 1);
Pbind(
	\instrument, \test,
	\scale, ~scale,
	\degree, rand(~degree),
).play;

)


// Transpose & Tempo Clock
(
Pbind(
	\note, Pser([0, 2, 3, 5, 7, 8, 11, 12], inf),
	\ctranspose, -12, // transpose an octave above (= 12 semitones)
	\dur, 0.8;
).play(TempoClock(120/60));
)

