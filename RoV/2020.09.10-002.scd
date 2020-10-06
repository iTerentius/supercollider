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
	// d.add(\foldernames -> PathName("/home/hypostatic/Music/samples/808s_by_SHD/Classic").entries); // Linux
	d.add(\foldernames -> PathName("/Users/isaactlinder/Music/supercollider/_samples/808s_by_SHD/").entries); //Mac
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
p.clock.tempo = 120/60;
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
}).add;q
)
(
SynthDef(\iter, { | freq = 40, amp=0.5, gate = 1 |
	var temp;
	var env = 1;
	var sum = 0;
	env = EnvGen.kr(Env.linen([0, 1, 0, 1, 0.5], [0.1, 0.25, 0.5, 0.75, 1]), gate: gate, doneAction:2);
	10.do{
		temp = VarSaw.ar(
			freq * 1-env * {Rand(0.99, 1.02)  * 1}!2,
			Impulse.kr(freq * 10) * {Rand(0.99, 1.02)}!2,
			LFPulse.kr(CombC.kr(Dust2.kr(freq), freq.midicps))!2
			);
			sum = sum + temp * 0.3;
	};
	Out.ar(0, Pan2.ar(sum * amp));
}).add;
)

(
SynthDef(\t1, { |freq = 110, ffreq=1, dur = 1 |
	var temp= 0, sum = 0, e1;
	e1 = EnvGen.kr(Env.perc(releaseTime: dur, doneAction:2));
	sum = Blip.ar(freq/12, ffreq) + SinOsc.kr(ffreq) * e1 * 0.5;
	Out.ar(0, sum!2);
}).add;
)


~bplay.play;
l  = [5, 6, 5, 5, 6, 5, 5, 6, 5, 6, 5, 5, 6, 5, 6, 5, 6, 5, 5, 6, 5, 7];


(
r = ProxyRecorder(p);

~bplay.play;
~dust.play;
~iter.play;
~iterlfok1.play;
~itergate.play;
~ip.play;
~hh.play;
~b.play;
~delay.play;
~ps.play;
~verb.play;


r.add([~ip, ~hh, ~b, ~dust, ~delay, ~ps, ~verb]);
)

r.record;
r.stop;

(
~pt1 = Pbind(
	\instrument, \t1,
	\degree, Pseq(l, inf),
	\scale, Scale.minor,
	\ffreq, Pseq(l, inf),
	\dur, Pseq(l, inf)/Pseq(l, inf) * 4,
	\amp, Pseq(l, inf) * 0.01,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group),
)
)

~dust.play;

(
~dust = { | freq = 110 |
	var sig, evn;
	sig = Pan2.ar(SinOsc.ar(freq / Pseq(l, inf).asStream * ~itergate.kr * 0.1));
};
)

~dust.stop(fadeTime:10);
~dust.release(fadeTime:10);

~iter.play;
~iter.stop;
~iter.release;

~iterlfok1.play;
~iterlfok1 = {SinOsc.kr(Line.kr(30, ~bplay.kr ))};
~iterlfok1.stop;

~itergate.play;
~itergate = { LFPulse.ar(LFNoise0.kr(1).range(11, 110))!2 /* + Pbjorklund2(Pseq(l, inf).asStream, 22,inf).asStream/8 + Pseq(l * 100, inf).asStream **/ * 0.5 };
~itergate.release(fadeTime: 10);
~itergate.stop;

~ip.play;
(
~ip = Pbind(
	\instrument, \iter,
	\freq, Pseq(l, inf).pow(2),
	\dur, Pseq(l, inf)/Pseq(l, inf) * 4,
	\amp, Pseq(l, inf) * 0.01,
	\gate, ~itergate.kr,
);
)
~ip.stop;
~ip.release(fadeTime:5);
~iter.free;

// monitor - output to speakers



(
~hh = Pbind(
	\instrument, \bplay,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group ),
	\buf, d["Hats"][3],
	// \dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25], inf),
	\dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/16,
	\amp, Pseq(l * 0.025, inf)
);

~b = Pbind(
	\instrument, \bplay,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group),
	\buf, d["Bass Drums"][1],
	\dur, Pbjorklund2(Pseq(l, inf), l.size, inf)/ Pseq(l, inf) + Pseq(l, inf)/4,
	\amp, Pseq(l * 0.05, inf)
);
)


~hh.play;
~hh.stop;
~hh.release(fadeTime:4);

~bfunc = {r.collect({ | item | item }).do { | item | item.postln};};


~b.play;
~b.stop(fadeTime:4);
~b.release;


p.release(fadeTime:10);


// route the ndef through a delay - output to speakers
~delay.play;
~delay[1] = \mix -> {~hh.ar};
~delay[2] = \mix -> {~b.ar};
~delay[3] = \mix -> {~ip.ar};
~delay[4] = \mix -> {~dust.ar};
~delay[5] = \mix -> {~bplay.ar};
~delay.set(\mix1, 0.25, \mix2, 0.5);
(
~delay.filter(10, {|in|
	var sig;
	var fb = LocalIn.ar(2);
	fb = DelayC.ar(fb.reverse * LFNoise2.kr(10), 1, [1/8, 5/8]);
	sig = fb * 0.5 + in;
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
	PitchShift.ar(in * LFNoise2(~hh.kr.reverse), 2, 2, 0.01, 0.01)
})
)
~ps.stop(fadeTime:3);

// route the dry signal, delay, and pitchshift through reverb - output to speakers
~verb.play;
~verb[1] = \mix -> {~delay.ar};
~verb[2] = \mix -> {~ps.ar};
~verb[3] = \mix -> {~pt1.ar};
~verb.filter(10, {|in| GVerb.ar(in.reverse, 10, 5, 1, 1) } );
// adjust mix
~verb.set(\mix0, 0.5, \mix1, 0.5, \mix2, 0.5);
);
// adjust wet/dry
~verb.set(\wet10, 0.9)
~verb.free;
~verb.stop(fadeTime:10);


