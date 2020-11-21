Ndef(\hh).play;
(
Pdef(\hh,
	Pbind(
		\instrument, \bplay,
		\out, Pfunc(Ndef(\hh).bus.index),
		\group, Pfunc(Ndef(\hh).group),
		\buf, d["Hats"][rrand(1,10)],
		\dur, Pseq([0.125, 0.125, 0.5, 0.75, 0.25], inf),
		// \dur,Pbjorklund2(Pseq([0.25, 1], inf),12,inf)/8,
		// \dur, 0.125,
		\midinote, 60,
		\dur, Pbjorklund2(3, 5, inf),
		/*\recordTarget, ~hr,
		\chan, 0,*/
));
)

Pdef(\hh).play(quant: -1);
Pdef(\hh).stop;

(
Ndef(\sn).play;
Pdef(\sn,
	Pbind(
		\instrument, \bplay,
		\out, Pfunc(Ndef(\sn).bus.index),
		\group, Pfunc(Ndef(\sn).group),
		\buf, d["Snare Drums"][4],
		// \dur, Pseq([0.125, 0.125, 0.5, 0.75, 0.25], inf),
		// \dur,Pbjorklund2(Pseq([0.25, 1], inf),12,inf)/8,
		// \dur, 0.125,
		\midinote, 60,
		\dur, Pbjorklund2(3, 7, inf)/2,
		/*\recordTarget, ~hr,
		\chan, 0,*/
));
)


Pdef(\sn).play(quant: -1);
Pdef(\sn).stop;



Ndef(\b).release;
(
Ndef(\b).play;
Pdef(\b,
	Pbind(
		\out, Pfunc(Ndef(\b).bus.index),
		\group, Pfunc(Ndef(\b).group),
		\instrument, \bplay,
		\buf, d["Bass Drums"][10],
		\dur, Pn(Pshuf([0.125, 0.25, 0.5, 1], 4), inf),
		\dur, Pshuf([0.5, 0.25, 1], inf),
		// \dur, 0.5,
		\amp, 0.3,
		// \recordTarget, ~hr,
		// \chan, 1,
));
)

Pdef(\b).play(quant: -1);
Pdef(\b).stop(fadeTime: 10);

~hr = HypoRecorder('test1');
~hr.add([\hh, \b], 2);

~hr.record;
~hr.stop;

~hr.smf