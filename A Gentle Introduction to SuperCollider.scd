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

// plot not working

l = {Synth(\test)}.plot;
{\test}.plot;

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
~t = TempoClock(120/60);
Pbind(
	\note, Pser([0, 2, 3, 5, 7, 8, 11, 12], inf),
	\ctranspose, -12, // transpose an octave above (= 12 semitones)
	\dur, 0.8;
).play(TempoClock(~t);



// Rest (and be added anywhere

Pbind(
	\ctranspose, -24,
	\degree, Pwhite(0,10),
	\dur, Pseq([0.1, 0.1, 0.03, 0.6, Rest(0.3), 0.25], inf);
		).play(~t);
)
)

// Fork

(
t = TempoClock(76/60);
{
	Pbind(
		\note, Pseq([[4, 11], [6,9]], 32),
		\dur, 1/6,
		\amp, Pseq([0.05, 0.03], inf)
	).play(t);

	2.wait(t);

	Pbind(
		\note, Pseq([[-25, -13, -1], [-20, -8, 4], Rest(3)], 3),
		\dur, Pseq([1, 1, Rest(1)], inf),
		\amp, 0.1,
		\leagto, Pseq([0.4, 0.7, \rest], inf)
	).play(t);

	2.75.wait(t);

	Pbind(
		\insrument, \test,
		\note, Pseq([23, 21, 25, 23, 21, 20, 18, 16, 20, 21, 23, 21], inf),
		\dur, Pseq([0.25, 0.75, 0.25, 1.75, 0.125, 0.125, 0.80, 0.20, 0.125, 0.125, 1], 1),
		\amp, 0.1,
		\legato, 0.5
	).play(t);
}.fork(t);
)

// Functions

(
f = {
	|a, b|
	["a plus b", a+b, "a times b", a*b].postln};

f.value(3, 7);
)

~sillyRand = rrand(0, 10);
~sillyRand.value;
~sillyRand2 = {rrand(0, 10)};
~sillyRand2.value;


// Arrays
~a = [1, 11, 12, 13, 14, 15, 16, 17];

~a.reverse;
~a.scramble;
~a.choose;
~a.size;
~a.at(0);
~a[0];
~a.wrapAt(9);
["wow", 99] ++ ~a
~a ++ \hi
~a ++ "hi";
~a.add(44);
~a.insert(5, "wow");
~a;
~a.put(2, "oops");
~a;
~a.permute(3);
~a.mirror;
~a.powerset;

[1, 2, 3, 4, 5] **10;
([1, 2, 3, 4, 5,] / 7).round(0.01);


x = 11; y=12;
[x, y, 9] * 100;

[1, 2, 3, 4, "oops", 11] + 10;

Array.series(size: 6, start: 10, step: 3);

Array.geom(size: 10, start: 1, grow: 2);

Array.series(7, 100, -10);

Array.series(7, 100, 0.9);

Array.fill(10, "same");

"same".dup(10);

Array.fill(10, rrand(1, 10));
Array.fill(10, {rrand(1, 10)});
Array.fill(10,{arg wow; wow+1 * 440});

a =Array.newClear(7);
a[3] = "wow";

30!4;
"hello".dup(10);
30.dup(4);

(50..79);

series(50, 51, 79);

(50, 53 .. 79);

Array.series(10, 50, 3);

~myFreqs = Array.fill(10, {rrand(440, 880)});

~myFreqs.do({arg item, count; ("Item " ++ " is " ++ item ++ " Hz. Closest midinote is " ++ item.cpsmidi.round).postln});

~myFreqs.do({arg item; {SinOsc.ar(item, 0, 0.1)}.play});

~myFreqs.do({arg item; item.squared.postln});

// SOUND SYNTHESIS
s.prepareForRecord;
s.record;
(
x = {Decimator.ar(
	Pulse.ar(
		freq: MouseX.kr([10, 11], 200),
		mul: MouseY.kr(0, LFNoise1.ar(10))
	),
	bits: MouseY.kr(1, 24)
)
}.play;
)

s.stopRecording; x.free;

{SinOsc.ar}.plot;

{Saw.ar}.plot;

{Pulse.ar}.scope;
