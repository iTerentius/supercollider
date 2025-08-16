(
SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		out.postln;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add;
)

~rec = Reaper("192.168.1.132", 7772);
~rec.add([\hh, \b, \lead]);
~rec.record;
~rec.stop;


(
Ndef(\lead, { | out, freq = 48, relTime = 2 |
	var sig = 0, temp, env, curv;
	out.postln;
	// curv = [\step, \sin, \wel].scramble;
	env = EnvGen.kr(Env.perc(0.5, releaseTime:relTime, curve: \step), doneAction: 2);
	8.do{ | i |
		temp = LFPulse.ar(freq + Rand(0, i), LFPulse.kr(Rand(0, i).round(rrand(0.125, i))).midicps)!2 / 8;
		sig = sig + temp * env * 0.9;
		Out.ar(out, sig * 0.05);
	}
})
)


(
Ndef(\lead).play(\out, 6);
Pdef(\leadmidi, Pbind(
	\type, \midi,
	\midiout, m,
	\midicmd, \noteOn,
	\chan, 0,
	\recordTarget, ~rec,
));

Pdef(\leadsynth,
	Pbind(
		\out, Pfunc(Ndef(\lead).bus.index),
		\group, Pfunc(Ndef(\lead).group),
		\buf, d["Hats"][1],
));

Pdef(\leadseq,
	Pbind(
		\dur, Pseq([0.125, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(4), Rest(2), Rest(1)].scramble, inf),
		\degree, Pseq(Scale.hijaz.degrees.mirror.scramble -5, inf),
		\octave, Pwhite(2, 4, inf).round(1),
		\relTime, Pseq([1, 2, 3, 0.5], inf),
		\out, Pfunc(Ndef(\lead).bus.index),
		\group, Pfunc(Ndef(\lead).group),
	))
)

(
Pdef(\lead,
	Ppar([
		Pdef(\leadmidi),
		Pdef(\leadsynth),
	])
	<> PtimeClutch(Pdef(\leadseq))
);
)

Ndef(\lead);
Ndef(\lead)[1] = \xset -> Pdef(\lead);
Pdef(\leadseq).play;
Pdef(\lead).play(quant: -1);


(
Ndef(\hh).set(\out, 2);
Ndef(\hh).play;
Pdef(\hhmidi,
	Pbind(
		\type, \midi,
		\midiout, m,
		\midicmd, \noteOn,
		\chan, 2,
		\recordTarget, ~rec,
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
Ndef(\b).set(\out, 4);
Ndef(\b).play;
Pdef(\bmidi,
	Pbind(
		\type, \midi,
		\midiout, m,
		\midicmd, \noteOn,
		\chan, 3,
		\recordTarget, ~rec,
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
		\dur, 1,
		\amp, 0.4
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

Pdef(\leadmidi).play;

Ndef(\b)[10] = \filter -> { | in | DelayC.ar(in, 6, 5) };
Ndef(\b).set(\wet10, 0.5);


