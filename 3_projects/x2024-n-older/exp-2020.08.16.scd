
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
// s.scope;
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

~dBus = Bus.audio(s, 2);
~delay.spawn;
~delay = \delay;
~delay.set(\in, ~dBus);
~delay.set(\gate, ~ap);
~delay.free;


(
SynthDef(\a, { | out=0, freq=100, time=5, dur=1 |
	var sig, env;
	env = EnvGen.kr(Env.perc(), doneAction: 2);
	sig = LFPulse.ar(freq * LFNoise0.kr(time));
	sig = sig * env;
	Out.ar(out, Splay.ar(sig *  0.2));
}).add;

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
}).add;
)
(
SynthDef(\delay, { | in, out=0 |
	var sig, env = 1, trig;
	trig = Dust.kr(2);
	env = EnvGen.kr(Env.perc(0.1, 3), trig);
	sig = DelayC.ar(In.ar(in));
	Out.ar(out,  Splay.ar(sig * env));
}).add;
)

~a.play;
(
~a = 20.do{ arg i;
	var s1, freq;
	s1 = Synth(\a, [\freq, 100 * i]);
};
)
~a.set(\freq, 60.midicps, \time, 8);
~a.stop;

(
~ap = Pbind(
	\out, ~dBus,
	\instrument, \a,
	\freq, Pwhite(40, 100, inf).round,
	\dur, 0.25,
	\time, 4,
);
)

~ap.play;
~ap.set(\out, ~dBus);
~ap.stop;
~ap.free;

(
~h = Pbind(
	\instrument, \bplay,
	\out, ~dBus,
	\buf, d["Hats"][2],
	\dur, 0.25);
)

// ~h.play(out:6);
~h.play;
~h.stop;

(
~b = Pbind(
	\instrument, \bplay,
	\out, ~dBus,
	\buf, d["Bass Drums"][2],
	\dur, Pseq([0.5, 1, 0.5, 1], inf),
	\amp, 0.6
);
)

// ~h.play(out:6);
~b.play;
~b.set(\out, ~dBus);
~b.stop;