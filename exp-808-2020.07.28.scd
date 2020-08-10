
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
	("SynthDefs.scd").loadRelative;
	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	3.wait;
	//activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;
	"Setup done!".postln;
}).start;
)

// Set up REAPER
(
b = NetAddr.new("localhost", 7772);
b.sendMsg("/tempo/raw", 60 * p.clock.tempo);
b.sendMsg("/track/1/recarm", );
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/3/recarm", 1);
b.sendMsg("/track/4/recarm", 1);
)

// Record in REAPER
(
b.sendMsg("/time", 0);
b.sendMsg("/restart", 1);
b.sendMsg("/record", 1);
)

(
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

~out.play(out:0);
~out.free;

~ob1 = Bus.audio(s, 2);
~ob1.play;
~ob3 = Bus.audio(s, 2);
~ob3.play;
~ob5 = Bus.audio(s, 2);
~ob7 = Bus.audio(s, 2);

p.fadeTime = 2;
(
~b = Pbind(
	\instrument, \bplay,
	// \out, 3,
	\buf, d["Bass Drums"][1],
	\dur, Pbjorklund2(Pseq([1,3,2,Pwhite(1, 4)], inf), 8)/4,
	\amp, Pwhite(0.3, 0.6, inf));
)

// ~b.play(out:2);
~b.play;

(
~sn = Pbind(
	// \out, 2,
	\instrument, \bplay,
	\buf, d["Snare Drums"][5],
	\dur, Pbjorklund2(Pseq([1,2,3,1], inf), 4)/4,
	\amp, Pwhite(0.1, 0.3, inf));
)

// ~sn.play(out:4);
~sn.play;

(
~h = Pbind(
	\instrument, \bplay,
	// \out, 3,
	\buf, d["Hats"][rrand(0, 10)],
	\dur, Pbjorklund2(Pseq([10,5,3,5], inf), 8)/4);
)

// ~h.play(out:6);
~h.play;

s.prepareForRecord;
s.record;

~b.free;
~sn.free;
~h.free;

s.stopRecording;


(
SynthDef(\bass, { | out = 0, freq = 110, mul = 1 |
	var sig, env;
	env = EnvGen.kr(Env.pairs([[0.5, 0.9, 0.25, 0.9, 0.5], [0.1, 0.5, 0.6, 0.8]], \step), doneAction: Done.freeSelf);
	sig = LFSaw.ar((SinOsc.ar(freq) * LFPulse.kr(Rand(1,4)).range(60, 220))!2, modfreq: freq, pmindex: Line.kr(0, 20), mul: env * 0.2).dup;
	Out.ar(out, sig * 0.3, mul: mul * ~b.ar.reciprocal);
}).add;
)

(
~score = Pbind(
	\instrument, \bass,
	// \out, 4,
	\scale, Scale.minor,
	\octave, Pseq([1,1,3,4], inf),
	\degree, Pseq([-7, -3, 0, 4, 5, 7], inf),
	\dur, Pseq([0.25, 0.5, 3, 0.25], inf),
	\add, ~b.ar);
)


// ~score.play(out:8);
~score.play;
~sccore.free;
p.free;

(
r = ProxyRecorder(p);

r.add([~b, ~sn, ~h, ~score]);
)

r.record;
r.stop;

