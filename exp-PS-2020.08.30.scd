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
p.clock.tempo = 80/60;
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

(
p.clock.tempo = 80/60;
p.fadeTime = 3;
p.quant = 1;
)

(
SynthDef(\a, { | out=0, freq=100, time=5, dur=1 |
	var sig, env = 1;
	env = EnvGen.kr(Env.perc(), doneAction: 2);
	sig = LFPulse.ar(freq/2 * LFNoise0.kr(time), width: Rand(0, 1));
	sig = sig * env;
	Out.ar(out, Splay.ar(sig *  0.2));
}).add;


SynthDef(\s1, {
	var freq = \freq.kr(220);
	var cutoff = \cutoff.kr(100);
	var fvel = \fvel.kr(8);
	var res = \res.kr(0.5).linlin(0, 1, 1, 0.001);
	var aeg = Env.asr.ar(doneAction:Done.freeSelf, gate:\gate.kr(1));
	var sig = RLPF.ar(LFSaw.ar(freq), aeg.linlin(0, 1, cutoff * LFPulse.kr(fvel, width: 1), cutoff * fvel), res);
	sig = (sig * aeg) * \amp.kr(0.3);
	sig = Splay.ar(sig * 2);
	Out.ar(\out.kr(0), sig);
}).add;


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

// monitor - output to speakers
~s1.play(vol: 1);
~bplay.play(vol: 1);
~a.play;

// play the synthdef routed through the ndef
(
~s1p = Pbind(
		\instrument, \s1,
		\out, Pfunc(~s1.bus.index ),
		\group, Pfunc(~s1.group ),
		\degree, Ppatlace([Pseq([0, -1, -7, -1], inf), Pseq([-1, 1, -2, 2], inf)], inf),
		\legato, 0.1,
	\cutoff, Pwhite(30, 100, inf),
	// \fvel, Rand(1, 8);
		\dur, Pseq([0.25, 0.5, Rest(1)], inf);
	)
)

~s1p.play;
~s1p.stop(fadeTime:3);

(
~hh = Pbind(
	\instrument, \bplay,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group ),
	\buf, d["Hats"][2],
		\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25], inf),
		// \dur, 0.5,
		\amp, 0.2);
)

~hh.play;
~hh.stop;
~hh.release;

(
~b = Pbind(
	\instrument, \bplay,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group),
	\buf, d["Bass Drums"][10],
	\dur, Pseq([1, 0.5, 0.5, 0.25], inf),
	\amp, 0.5);
)


~b.play;
~b.stop(fadeTime:4);
~b.release;

~a = { |freq=110, amp=0.5| Out.ar(0, SinOsc.ar(freq * Line.kr(freq, 1) * Saw.kr(freq), mul: 0.08).dup, gate: 0) };
~a = \a;

(
~ap = Pbind(
	\instrument, \a,
	\out, Pfunc(~a.bus.index),
	\group, Pfunc(~a.group),
	\degree, Pseq([0, 3], inf),
	\dur, Pwhite(0.25, 1, inf).round);
)

~ap.play;
~ap.stop(fadeTime: 4);
~a.play;

~a.release;
~a.stop(fadeTime: 3);


p.release;


// route the ndef through a delay - output to speakers
~delay.play;
~delay[0] = \mix -> {~s1.ar};
~delay[1] = \mix -> {~hh.ar};
~delay[2] = \mix -> {~b.ar};
~delay[3] = \mix -> {~a.ar};
~delay[4] = \mix -> {~ap.ar);
~delay[3] = \mix -> nil;
~delay.set(\mix0, 0.25, \mix2, 0.25);
(
~delay.filter(10, {|in|
	var sig;
	var fb = LocalIn.ar(2);
	fb = DelayC.ar(fb.reverse * LFNoise2.kr(~s1p.kr * 10), 1, [3/8, 5/8]);
	sig = fb * 0.7 + in;
	LocalOut.ar(sig);
	sig;
})
)

~delay.stop(fadeTime:5);

// route the delay through a pitchshift - output to speakers
~ps.play;
~ps[0] = \mix -> {~delay.ar};
~ps.set(\mix0, 0.8);
(
~ps.filter(10, {|in|
	PitchShift.ar(in * LFNoise2(3), 2, 2, 0.01, 0.01)
})
)
~ps.stop(fadeTime:3);

// route the dry signal, delay, and pitchshift through reverb - output to speakers
~verb.play(vol:0.5);
~verb[0] = \mix -> {~s1.ar};
~verb[1] = \mix -> {~delay.ar};
~verb[2] = \mix -> {~ps.ar};
~verb[3] = \mix -> {~ap.ar};
~verb.filter(10, {|in| GVerb.ar(in, 10, 5, 1, 1) } );
// adjust mix
~verb.set(\mix0, 0.5, \mix1, 1, \mix2, 1);
// adjust wet/dry
~verb.set(\wet10, 0.5)
~verb.free;
~verb.stop(fadeTime:10);

(
r = ProxyRecorder(p);

r.add([~s1p, ~hh, ~b, ~a, ~delay, ~ps, ~verb]);
)

r.record;
r.stop;