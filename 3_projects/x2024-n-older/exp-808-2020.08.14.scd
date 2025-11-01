
//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 64;
s.options.numOutputBusChannels = 2;
//boot the server
s.reboot;
//display the oscilloscope
s.scope;
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 1;
Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName("/home/hypostatic/music/samples/808s_by_SHD/Classic").entries);
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

p.clock.tempo = 1;




(
SynthDef(\iter, { | out = 0, amp = 0.5, pan = 0, freq=40, w=1, gate=1, dur=1 |
	var temp, sum, env, aug;
	sum = 0;
	env = EnvGen.kr(
		Env.adsr(), gate, doneAction:2
	);
	20.do{ | count |
		temp = SinOsc.ar(
			freq.midicps *
			(count + 1) * LFNoise2.kr({Rand(0.05, 0.2)}!2).range(0.98, 1.02)
		);
		sum = sum + temp;
	};
	aug = VarSaw.ar(freq.midicps, width: LFNoise1.kr(1), iphase: {Rand(0.0, 1.0)});
	sum = sum * 0.01 * env + aug;
	Out.ar(out, Splay.ar(DelayC.ar(sum, dur) * amp));
}).add;

SynthDef(\iter2, { | out = 0, amp = 0.5, pan = 0, freq=40, w=1, gate=1, dur=1 |
	var temp, sum, env, aug;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(), gate, doneAction:2
	);
	20.do{ | count |
		temp = VarSaw.ar(
			freq.midicps *
			(count + 1) * Line.kr({Rand(0.05, 0.2)}!2).range(0.80, 1.02)
		);
		sum = sum + temp;
	};
	aug = LFTri.ar(freq.midicps, width: SinOsc.kr(1), iphase: {Rand(0.0, 1.0)});
	sum = sum * 0.01 * env + aug;
	Out.ar(out, Splay.ar(DelayC.ar(sum, dur) * amp));
}).add;

SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env ;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add;
)

(
~z= Pbind(
	\instrument, \iter,
	\scale, Scale.minor,
	\octave, 3,
	\degree, Pseq([0,3,-3,2,0,2], inf),
	\dur, Pseq([0.25, Rest(2.75), 0.5, 0.25, 1.25], inf),
	\w, Pwhite(0.3, 1, inf),
	\gate, 0,
	\amp, 0.1)

)
~z.play;
~z.free;

(
~x= Pbind(
	\instrument, \iter2,
	\scale, Scale.minor,
	\octave, 2.3,
	\degree, Pseq([0,-2,-3,0,-3], inf),
	\dur, Pseq([0.25, 1], inf),
	\w, Pwhite(0.3, 1, inf),
	\amp, 0.08);
)
~x.play;
~x.stop(fadeTime:3);



(
~h = Pbind(
	\instrument, \bplay,
	// \out, 3,
	\buf, d["Hats"][6],
	\dur, Pbjorklund2(Pseq([5,2,3,4,5], inf), 8)/4);
)

// ~h.play(out:6);
~h.play;
~h.stop;


(
~b = Pbind(
	\instrument, \bplay,
	// \out, 3,
	\buf, d["Bass Drums"][3],
	\dur, Pbjorklund2(Pseq([1,3,5,1,1], inf), 8)/4,
	// \dur, 1,
	\amp, Pwhite(0.5, 0.707, inf));
)

~b.play;
~b.free;
~b.stop(fadeTime: 3);

(
r = ProxyRecorder(p);


r.add([~b, ~x, ~z, ~h]);
)

r.record;
r.stop;