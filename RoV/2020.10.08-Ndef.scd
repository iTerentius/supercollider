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
Pdef(\lead,
	Pbind(
	/*\out, Pfunc({ Ndef(\lead).bus.index }),*/

	\dur, Pseq([0.125, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(4), Rest(2), Rest(1)].scramble, inf),
	\degree, Pseq(Scale.hijaz.degrees.mirror.scramble -5, inf),
	\octave, Pwhite(2, 4, inf).round(1),
	\relTime, Pseq([1, 2, 3, 0.5], inf),
)
)
)

Pdef(\lead).play;

Ndef(\lead).play;
Ndef(\lead)[1] = \xset -> Pdef(\lead);
Ndef(\lead).set(\out, 2);
Ndef(\lead).get(\out);

m = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
m = MIDIOut(0);
m.latency(0);
m.noteOn(0, 60, 30);
m.noteOff(0, 60);

r.link.sendMsg("/tempo/raw", 80);
r.add([\lead, \dust, \hh, \b]);
r.record;
r.stop;


Ndef(\lead).set(\out, 0);
Ndef(\lead).get(\out);

Ndef(\lead).stop(fadeTime: 4);
Ndef(\lead).end(fadeTime:5);
Ndef(\lead).free;

Ndef(\dust).play;

(
Ndef(\dust, { | out, freq = 110 |
	var sig, env;
	env = EnvGen.kr(Env.asr(), doneAction: 2);
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(1, 0.2, 0.5, 0.5),0.2, 1, 0.5) * freq * 3) * (LFPulse.kr(LFPulse.kr(1, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(out, Pan2.ar(sig) * 0.09 * env);
}
)
)

Ndef(\dust)[1] = \xset -> Pbind(\freq, Pseq(Scale.hijaz.degrees, inf));
Ndef(\dust).xset(\freq, 110);
Ndef(\dust).set(\gate, Ndef(\lead));
Ndef(\dust).set(\out, 4);
Ndef(\dust).get(\out);


Ndef(\dust).stop(fadeTime:10);
Ndef(\dust).end(fadeTime:10);
Ndef(\dust).clear(fadeTime:10);
Ndef(\dust).release(fadeTime:10);


(
SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1 ;
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
Pdef(\hh,
	Pbind(
		\instrument, \bplay,
		\out,6,
		\buf, d["Hats"][1],
		\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
		// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
		\amp, 0.025,
	))
)
Pdef(\hh).play;
Pdef(\hh).stop;

(
Pdef(\b,
	Pbind(
		\instrument, \bplay,
		\out, 8,
		\buf, d["Bass Drums"][5],
		\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
		\amp, 0.2
))
)

Pdef(\b).play;
Pdef(\b).stop;

Ndef(\b).play;
Ndef(\b)[0] = Pdef(\b);
Ndef(\b).set(\out, 8);
Ndef(\b).get(\out);
Ndef(\b).stop(fadeTime: 4);