(
Ndef(\hh).play;
Pdef(\hhmidi,
	Pbind(
		\type, \midi,
		\midiout, m,
		\midicmd, \noteOn,
		\chan, 1,
		\recordTarget, ~mr,
));

Pdef(\hhsynth,
	Pbind(
		\instrument, \bplay,
		\out, Pfunc(Ndef(\hh).bus.index),
		\group, Pfunc(Ndef(\hh).group),
		\buf, d["Hats"][1],
));

Pdef(\hhseq,
	Pbind(

		// \dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25].scramble, inf),
		// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
		// \dur, 0.125,
		\midinote, 60,
		\dur, Pbjorklund2(3, 5, inf)),
	));
)
(

Pdef(\hh,
	Ppar([
		Pdef(\hhmidi),
		Pdef(\hhsynth),
	])
	<> PtimeClutch(Pdef(\hhseq))
);
)




Pdef(\hh).play(quant: -1);
Pdef(\hh).stop;

(
Pdef(\bmidi,
	Pbind(
		\type, \midi,
		\midiout, m,
		\midicmd, \noteOn,
		\chan, 2,
		\callback, ~midif,
));

Pdef(\bsynth,
	Pbind(
		\out, Pfunc(Ndef(\b).bus.index),
		\group, Pfunc(Ndef(\b).group),
		\instrument, \bplay,
		\buf, d["Bass Drums"][5],
));

Pdef(\bseq,
	Pbind(
		\dur, Pn(Pshuf([0.125, 0.25, 0.5, 1], 16), inf),
		// \dur, Pshuf([0.5, 0.25, 1], inf),
		// \dur, 1,
		\amp, 0.5
));
)

(

Pdef(\b,
	Ppar([
		Pdef(\bmidi),
		Pdef(\bsynth),
	])
	<> Pdef(\bseq)
)
)

Pdef(\b).play(quant: -1);
Pdef(\b).stop(fadeTime: 10);