(
SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add;
)

Ndef(\hh).play;
Ndef(\hh)[1] = \xset -> Pdef(\hh);
Ndef(\hh).get(\out);

(
Ndef(\hh).play;
Pdef(\hhmidi,
	Pbind(
		\type, \midi,
		\midiout, m,
		\midicmd, \noteOn,
		\chan, 1,
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
		\dur, Pbjorklund2(Pseq([3, 5, 7, 9, 11], inf), Pseq([12, 4, 6, 7], inf)),
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

(
Ndef(\b).play;
Pdef(\bmidi,
	Pbind(
		\type, \midi,
		\midiout, m,
		\midicmd, \noteOn,
		\chan, 2,
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
		// \dur, 0.125,
		\dur, Pbjorklund2(3, 7),
		\amp, 0.2
));
)
(

Pdef(\b,
	Ppar([
		Pdef(\bmidi),
		Pdef(\bsynth),
	])
	<> PtimeClutch(Pdef(\bseq))
)
)

Pdef(\hh).play(quant: -1);
Pdef(\hh).stop;

Ndef(\hh)[10] = \filter -> { | in | DelayC.ar(in, 3, 5) };
Ndef(\hh).set(\wet10, 0.5);

Pdef(\b).play(quant: -1);
Pdef(\b).stop;

Ndef(\b)[10] = \filter -> { | in | DelayC.ar(in, 6, 5) };
Ndef(\b).set(\wet10, 0.5);

TempoClock.default.tempo = 1;

(
~ndefr = NdefRecorder.new('test');
~ndefr.add([\hh, \b]);
)
~ndefr.record;
~ndefr.stop;