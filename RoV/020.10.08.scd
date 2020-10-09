//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 2;
//boot the server
s.reboot;
//display the oscilloscope
// s.scope;
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 80/60;
Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName("/home/hypostatic/Music/samples/808s_by_SHD/Classic").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	// ("SynthDefs.scd").loadRelative;
	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	3.wait;
	//activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;
	"Setup done!".postln;
}).start;
)


p.clock.tempo = 45/60;
p.fadeTime = 3;
p.quant = 1;


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
~dust.play;
// ~recOut.play;
~rec.play;
~hh.play;
~b.play;
)

(
r = ProxyRecorder(p);

r.add([~hh, ~b, ~rec, ~dust]);

)


~dust.stop;
~rec.stop;
~recOut.stop;
~hh.stop;
~b.stop;


r.record;
r.stop;

p.prepareForRecord;

~recOut.play;
~dustOut.play;


(
~rec = { | out = 0, freq = 48, relTime = 2 |
	var sig = 0, temp, env, curv;
	// curv = [\step, \sin, \wel].scramble;
	env = EnvGen.kr(Env.perc(0.5, releaseTime:relTime, curve: \sqr), doneAction: 2);
	8.do{ | i |
		temp = LFPulse.ar(freq + Rand(0, i), LFPulse.kr(Rand(0, i).round(rrand(0.125, i))).midicps)!2 / 8;
		sig = sig + temp * env * 0.9;
		Out.ar(out, sig * 1/16);
	};
};

~rec[1] = \xset -> Pbind(
	\dur, Pseq([0.125, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(4), Rest(2), Rest(1)].scramble, inf),
	\degree, Pseq(Scale.hijaz.degrees.mirror.scramble -5, inf),
	\octave, Pwhite(2, 5, inf).round(1),
	\relTime, Pseq([1, 2, 3, 0.5], inf),
	\out, 0,
)
)
~rec.play;
~rec.stop(fadeTime: 4);
~rec.end(fadeTime:5);
~rec.free;

~dust.play;

(
~dust = { | out = 0, freq = 110 |
	var sig, env;
	env = EnvGen.kr(Env.asr(), doneAction: 2);
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(1, 0.2, 0.5, 0.5),0.2, 1, 0.5) * freq * 3) * (LFPulse.kr(LFPulse.kr(1, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(out, Pan2.ar(sig) * 0.09 * env);
};
)

~dust.set(\freq, Pseq(Scale.hijaz.degrees, inf).asStream);
~dust.xset(\freq, 110);
~dust.set(\gate, ~rec);


~dust.stop(fadeTime:10);
~dust.end(fadeTime:10);
~dust.release(fadeTime:10);

(
~hh = Pbind(
	\instrument, \bplay,
	\buf, d["Hats"][1],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
	// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
	\amp, 0.025,
);

~b = Pbind(
	\instrument, \bplay,
	\buf, d["Bass Drums"][5],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
	\amp, 0.2
);
)


~hh.play;
~hh.stop(fadeTime:4);
~hh.release(fadeTime:4);


~b.play;
~b.stop(fadeTime:4);
~b.release(fadeTime:4);