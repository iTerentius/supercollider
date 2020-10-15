
p.clock.tempo = 45/60;
p.fadeTime = 3;
p.quant = 1;




b.sendMsg("/tempo/raw", 60);
b.sendMsg("/track/1/recarm", 1).postln;
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/3/recarm", 1);
b.sendMsg("/track/4/recarm", 1);
b.sendMsg("/time", 0);
r.link.sendMsg("/action/40042"); //Restart
b.sendMsg("/record", 1);
b.sendMsg("/stop", 1);

b.sendMsg("/action/40035"); //Select all
b.sendMsg("/action/40697"); //Delete all
b.sendMsg("/action/40001"); //Insert Track
b.sendMsg("/track/1/name", "test");
b.sendMsg("/track/1/select", 1);

b.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");

(
b.sendMsg("/action/40035"); //Select all
b.sendMsg("/action/40697"); //Delete all
["lead", "dust", "hh", "b"].do { | i, c |
	var name, num, cmdName, cmdArm;
	name = i;
	name.postln;
	num = c + 1;
	num.postln;
	cmdName = "/track/"++num++"/name";
	cmdArm = "/track/"++num++"/recarm";
	cmdArm.postln;
	b.sendMsg("/action/40001"); //Insert Track
	b.sendMsg(cmdName, i); //Insert Track
	b.sendMsg(cmdArm, 1);
	b.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");
};
)

(
SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1 ;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add
)

(
Ndef(\lead, { | out = 0, freq = 48, relTime = 2 |
	var sig = 0, temp, env, curv;
	out.postln;
	// curv = [\step, \sin, \wel].scramble;
	env = EnvGen.kr(Env.perc(0.5, releaseTime:relTime, curve: \step), doneAction: 2);
	8.do{ | i |
		temp = LFPulse.ar(freq + Rand(0, i), LFPulse.kr(Rand(0, i).round(rrand(0.125, i))).midicps)!2 / 8;
		sig = sig + temp * env * 0.9;
		Out.ar(out, sig * 1/16);
	}
}
)
)
(
Pdef(\leadPd,
	Pbind(
	\dur, Pseq([0.125, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(4), Rest(2), Rest(1)].scramble, inf),
	\degree, Pseq(Scale.hijaz.degrees.mirror.scramble -5, inf),
	\octave, Pwhite(2, 4, inf).round(1),
	\relTime, Pseq([1, 2, 3, 0.5], inf),
)
)
)

Ndef(\lead).play;
Ndef(\lead)[1] = \xset -> Pdef(\leadPd);


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
Ndef(\dust, { | out = 0, freq = 110 |
	var sig, env;
	env = EnvGen.kr(Env.asr(), doneAction: 2);
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(1, 0.2, 0.5, 0.5),0.2, 1, 0.5) * freq * 3) * (LFPulse.kr(LFPulse.kr(1, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(out, Pan2.ar(sig) * 0.09 * env);
};
)
)

Ndef(\dust).xset(\freq, Pseq(Scale.hijaz.degrees, inf).asStream);
Ndef(\dust).xset(\freq, 110);
Ndef(\dust).set(\gate, Ndef(\lead));


Ndef(\dust).stop(fadeTime:10);
Ndef(\dust).end(fadeTime:10);
Ndef(\dust).release(fadeTime:10);

(
Pdef(\hh,
	Pbind(
/*	\type, \midi,
	\midiout, m,
	\midicmd, \noteOn,
	\chan, 0,*/
	\instrument, \bplay,
	\out, 6,
	\buf, d["Hats"][1],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
	// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
	\amp, 0.025,
);
)
)
(
Pdef(\b,
	Pbind(
	\instrument, \bplay,
	\out, 8,
	\buf, d["Bass Drums"][5],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
	\amp, 0.2
);
)
)


Ndef(\hh,).play;
~hh.get(\out);
~hh.stop(fadeTime:4);
~hh.release(fadeTime:4);


~b.play;
~b.get(\out);
~b.stop(fadeTime:4);
~b.release(fadeTime:4);