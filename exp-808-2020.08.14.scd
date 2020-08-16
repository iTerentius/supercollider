
//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 64;
s.options.numOutputBusChannels = 16;
//boot the server
s.reboot;
//display the oscilloscope
s.scope;
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;
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
SynthDef(\iter, { | out = 0, amp = 0.5, pan = 0, freq=40, w=1 |
	var temp, sum, env, aug;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 1, 1, -2),
		doneAction: 2
	);
	w = w * Rand(0, 1);
	10.do{
		temp = LFPulse.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005,0.05)}!2
		);
		sum = sum + temp;
	};
	aug = VarSaw.ar(freq, width: w);
	sum = sum * 0.01 * env + aug;
	Out.ar(out, Splay.ar(sum * amp));
}).add;

SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env ;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out!2,Pan2.ar(sig.dup,pan));
}).add;
)

(
~z= Pbind(
	\instrument, \iter,
	\scale, Scale.minor,
	\octave, Pseq([-1,1,3,4], inf),
	\degree, Pseq([-7, -7, -4, 0, -4, -3, 0], inf),
	\dur, Pseq([0.25, Rest(3), 0.5, 0.25, 1], inf),
	\w, Pwhite(0.3, 1, inf),
	\amp, 0.1);
)
~z.play;
~z.free;

(
~x= Pbind(
	\instrument, \iter,
	\scale, Scale.minor,
	\octave, Pseq([-1,2,3,5], inf),
	\degree, Pseq([7, -3, 4, 0, 5, 7, 0], inf),
	\dur, Prand([0.25, 0.5, 0.25, 1, Rest(2)], inf),
	\w, Pwhite(0.3, 1, inf),
	\amp, 0.08);
)
~x.play;
~x.stop;





(
~b = Pbind(
	\instrument, \bplay,
	// \out, 3,
	\buf, d["Bass Drums"][1],
	// \dur, Pbjorklund2(Pseq([2,4,2,Pwhite(1, 4)], inf), 16)/4,
	\dur, 1,
	\amp, Pwhite(0.3, 0.6, inf));
)

~b.play;
~b.free;
~b.stop;

(
r = ProxyRecorder(p);


r.add([~b, ~x, ~z]);
)

r.record;
r.stop;