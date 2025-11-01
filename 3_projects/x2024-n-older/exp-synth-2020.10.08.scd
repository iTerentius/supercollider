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

(
p.clock.tempo = 45/60;
p.fadeTime = 3;
p.quant = 1;
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
~rec[0] = { | freq = 48, relTime = 2 |
	var sig = 0, temp, env;
	env = EnvGen.kr(Env.perc(releaseTime:relTime), doneAction: 2);
	8.do{ | i |
		temp = LFPulse.ar(freq + i, LFPulse.kr(Rand(0, i).round(rrand(0.125, i))).midicps)!2 / 8;
		sig = sig + temp * env;
		Out.ar(0, sig * 1/8);
	};
};
)

(
~rec[1] = \xset -> Pbind(
	\dur, Pseq([0.5, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(2)].scramble, inf),
	\degree, Pseq(Scale.minor.degrees.mirror.scramble, inf),
	\octave, 2,
	\relTime, Pseq([1, 2, 3, 0.5], inf),
)
)
~rec.play;
~rec.stop;
~rec.free;

~dust.play;

(
~dust = { | freq = 110 |
	var sig, evn;
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(10, 0.2, 0.5, 0.5),0.2, 1, 0.5) * freq) * (LFPulse.kr(LFPulse.kr(0.2, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(0, Pan2.ar(sig) * 0.1);
};
)

~dust.set(\freq, 220);

~dust.stop(fadeTime:10);
~dust.end(fadeTime:10);
~dust.release(fadeTime:10);

(
~hh = Pbind(
	\instrument, \bplay,
	\buf, d["Hats"][10],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25], inf),
	// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
	\amp, 0.025,
);

~b = Pbind(
	\instrument, \bplay,
	\buf, d["Bass Drums"][6],
	\dur, 1,
	\amp, 0.1
);
)


~hh.play;
~hh.stop;
~hh.release(fadeTime:4);


~b.play;
~b.stop(fadeTime:4);
~b.release(fadeTime:4);