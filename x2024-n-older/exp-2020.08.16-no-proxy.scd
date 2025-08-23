
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
// p=ProxySpace.push(s);
//start tempo clock
// p.makeTempoClock;
//give proxyspace a tempo
// p.clock.tempo = 1;
Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName("/home/hypostatic/music/supercollider/_samples/808s_by_SHD/Classic").entries);
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

~t = TempoClock(60/60);

(
SynthDef(\a, { | out=0,  freq=100, time=5 |
	var sig, env;
	env = EnvGen.kr(Env.asr(), doneAction: 2);
	sig = SinOsc.ar(freq * LFNoise0.kr(Rand(time, time*2).range(0.5, 1)));
	// sig = sig * env;
	Out.ar(out, Splay.ar(sig *  0.2));
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

SynthDef(\delay, {
	| in, out=0 |
	var sig;
	sig = In.ar(in, 2);
	sig = Impulse.kr() * sig;
	Out.ar(out, sig);
}).add;
)

p.fadeTime = 4;

~delayBus = Bus.audio(s, 2);
~delayOut = \delay;
~delayOut.set(\in, ~delayBus);
~delayOut.play;

~a.play;
~a = Synth(\a).play(~t);

~a.set([\out, 0, \freq, 60.midicps, \time, 8]);
~a.free;

(
~ap = Pbind(
	\instrument, \a,
	\freq, 100,
	\dur, Pseq([1, 2], inf),
	\time, 4);
)

~ap.play;
~ap.set(\freq, 500);
~ap.stop(fadeTime: 1);
~ap.free;

(
~h = Pbind(
	\out, 0,
	\instrument, \bplay,
	// \out, 3,
	\buf, d["Hats"][2],
	\dur, 0.25);
)

// ~h.play(out:6);
~h.play;
~h.record(clock: ~t);
~h.stop;
~t.stop;


(
~b = Pbind(
	\instrument, \bplay,
	// \out, ~dBus,
	\buf, d["Bass Drums"][2],
	// \dur, Pseq([0.5, 1, 0.5, 1], inf),
	\dur, 1,
	\amp, 0.6
);
)

// ~h.play(out:6);
~b.play;
~b.record(clock: ~t);
~b.set(\out, ~dBus);
~b.stop;
