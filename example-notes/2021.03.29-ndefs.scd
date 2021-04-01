(
SynthDef(\as1, { | out = 0, freq = 110, t_gate=1 |
	var sig, e;
	e = EnvGen.kr(Env.perc, t_gate, doneAction: 2);
	sig = LFSaw.ar(freq, LFNoise0.kr(1))!2 * e;
	Out.ar(out, sig);
}).add;
)

Ndef(\a1).play;
(
Ndef(\a1, {| freq=1110, gate = 1 |
	var sig, e;
	e = EnvGen.kr(Env.perc, gate, doneAction: 2);
	sig = LFSaw.ar(freq, LFNoise0.kr(1))!2 * e;
});
)

(
Pdef(\ap1, {
	Pbind(
		\instrument, \as1,
		\octave, 2,
		\note, Pseq((0..7), inf),
		\degree, Scale.minor,
		\dur, Pwhite(0.25, 1, inf),
	)
});
)

Pdef(\ap1).play;
Pdef(\ap1).play;
Ndef(\a1)[0] = \xset -> Pdef(\ap1);

Ndef(\a1).stop;