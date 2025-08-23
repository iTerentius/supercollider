/* Ndef Order of Ops:
1. Play Ndef (not needed with the Reaper code as it plays what is sent)
2. Set Ndef
3. Set Pdef
4. /set Pdef to Ndef
*/


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
}
)
)

(
Pdef(\leadmidi, Pbind(
	\type, \midi,
	\midiout, m,
	\midicmd, \noteOn,
	\chan, 0,
)<> PtimeClutch(Pdef(\leadseq)));
)

(
Pdef(\leadseq,
	Pbind(
		\dur, Pseq([0.125, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(4), Rest(2), Rest(1)].scramble, inf),
		\degree, Pseq(Scale.hijaz.degrees.mirror.scramble -5, inf),
		\octave, Pwhite(2, 4, inf).round(1),
		\relTime, Pseq([1, 2, 3, 0.5], inf),
	))
)

Pdef(\leadseq).play;

Ndef(\lead).play;
Ndef(\lead)[1] = \xset -> Pdef(\leadseq);
Ndef(\lead).set(\out, 0);
Ndef(\lead).get(\out);
Ndef(\lead).stop(fadeTime:10);

(
TempoClock.default.tempo = 2;
r.link.sendMsg("/tempo/raw", 120);
r.add([\lead, \dust, \hh, \b, \leadmidi, \hhmidi, \bmidi]);
)
r.record;
r.stop;


Ndef(\lead).set(\out, 0);
Ndef(\lead).get(\out);

Ndef(\lead).stop(fadeTime: 4);
Ndef(\lead).end(fadeTime:5);
Ndef(\lead).free;

Ndef(\dust).play;

(
Ndef(\dust, { | out = 0, freq = 110 |
	var sig, env;
	env = EnvGen.kr(Env.asr(), doneAction: 2);
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(1, 0.2, 0.5, 0.5),0.2, 1, 0.5) * freq * 3) * (LFPulse.kr(LFPulse.kr(1, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(out, Pan2.ar(sig) * 0.09 * env);
}
)
)

Ndef(\dust)[1] = \xset -> Pbind(\freq, Pseq(Scale.hijaz.degrees, inf));
Ndef(\dust)[1] = nil;
Ndef(\dust).xset(\freq, 110);
Ndef(\dust).set(\gate, Ndef(\lead));
Ndef(\dust).set(\out, 2);
Ndef(\dust).get(\out);


Ndef(\dust).stop(fadeTime:10);
Ndef(\dust).end(fadeTime:10);
Ndef(\dust).clear(fadeTime:10);
Ndef(\dust).release(fadeTime:10);

Pdef.defaultQuant = -1;

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
		// \recordTarget, ~mr,
));

Pdef(\hhsynth,
	Pbind(
		\instrument, \bplay,
		\out, Pfunc(Ndef(\hh).bus.index),
		\group, Pfunc(Ndef(\hh).group),
		\buf, d["Hats"][6],
));

Pdef(\hhseq,
	Pbind(

		// \dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25].scramble, inf),
		// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
		// \dur, 0.125,
		\midinote, 60,
		\dur, Pbjorklund2(Pseq([3, 5, 7, 9, 11], inf), Pseq([12, 4, 6, 7], inf))/4,
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
		// \callback, ~midif,
));

Pdef(\bsynth,
	Pbind(
		\out, Pfunc(Ndef(\hh).bus.index),
		\group, Pfunc(Ndef(\hh).group),
		\instrument, \bplay,
		\buf, d["Bass Drums"][5],
));

Pdef(\bseq,
	Pbind(
		\dur, Pbjorklund2(Prand([3, 5, 7, 9, 11], inf), Prand([12, 4, 6, 7], inf)),
		\amp, Pbjorklund2(Prand([0.5, 0.75], inf), Prand([12, 4, 6, 7], inf)),
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

TempoClock.default.tempo = 0.75;

Pdef(\b).play(quant: -1);

Pdef(\b).clear;

~ndefr = NdefRecorder.new('test');
~ndefr.add([\hh, \b]);

~ndefr.record;
~ndefr.stop;

s.waitForBoot
s.prepareForRecord(numChannels:8);
s.record(numChannels:8);

(
fork {
	t = TempoClock.default;
	s.sync;
	thisThread.clock.timeToNextBeat(-1).wait;
	s.record(numChannels:8);
};
)


s.stopRecording;

r.record;
r.stop;

Ndef(\b).play;
Ndef(\b)[0] = Pdef(\b);
Ndef(\b).set(\out, 8);
Ndef(\b).get(\out);
Ndef(\b).stop(fadeTime: 4);

Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.2"); thisProcess.recompile()})