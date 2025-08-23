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
SynthDef(\iter, { | freq = 40, amp=0.5, gate = 1 |
	var temp;
	var env = 1;
	var sum = 0;
	env = EnvGen.kr(Env.linen([0, 1, 0, 1, 0.5], [0.1, 0.25, 0.5, 0.75, 1]), doneAction:2);

		temp = VarSaw.ar(
			freq * env * {Rand(0.99, 1.02)  * 1}!2,
			Impulse.kr(freq * 10) * {Rand(0.99, 1.02)}!2,
			LFPulse.kr(CombC.kr(Dust2.kr(freq), freq.midicps))!2
			);
			sum = sum + temp * 0.3;

	Out.ar(0, Pan2.ar(sum * amp));
}).add;
)

(
SynthDef(\t1, { |out = 0, freq = 110, ffreq=1, dur = 1, gate = 1, amp = 0.5 |
	var temp= 0, sum = 0, e1, l  = [5, 6, 5, 5, 6, 5, 5, 6, 5, 6, 5, 5, 6, 5, 6, 5, 6, 5, 5, 6, 5, 7];
	e1 = EnvGen.kr(Env.perc(releaseTime: dur * 2), doneAction:2);
	sum = VarSaw.ar(freq, SinOsc.kr(20)) + SinOsc.kr(Pseq(l * 0.1, inf).asStream);
	sum = sum + LFPulse.kr(Pseq(l, inf).asStream, width: 1);
	Out.ar(out, Splay.ar(sum) * e1 * amp);
}).add;
)

(
SynthDef(\a1, { |out = 0, freq = 110, ffreq=1, dur = 1, gate = 1, amp = 1 |
	var temp= 0, sum = 0, e1, l  = [5, 6, 5, 5, 6, 5, 5, 6, 5, 6, 5, 5, 6, 5, 6, 5, 6, 5, 5, 6, 5, 7];
	e1 = EnvGen.kr(Env.perc(releaseTime: dur * 2), doneAction:2);
	sum = SinOsc.ar(freq) * LFNoise2.kr(Pseq(l, inf).asStream) * 2;
	sum = sum + LFPulse.kr(freq + Pseq(l, inf).asStream, mul:SinOsc.kr(Rand(40,80)));
	Out.ar(out, Splay.ar(sum) * e1 * amp);
}).add;
)

// START FIRST!!!
~bplay.play;
l  = [5, 6, 5, 5, 6, 5, 5, 6, 5, 6, 5, 5, 6, 5, 6, 5, 6, 5, 5, 6, 5, 7];
~bplay.release;

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
~pa.play;
~pt1.play;
~verb.play;


r.add([~ip, ~hh, ~b, ~pt1, ~pa, ~dust, ~delay, ~ps, ~verb]);

)

(
~dust.stop;
~iterstop;
~iterlfok1.stop;
~itergate.stop;
~ip.stop;
~hh.stop;
~b.stop;
~delay.stop;
~ps.stop;
~pt1.stop;
~pa.stop;
~verb.stop;
)

r.record;
r.stop;

(
~pa = Pbind(
	\instrument, \a1,
	\dur, Pseq([0.25, 0.5, 0.25, Rest(0.5)], inf),
	\scale, Scale.phrygian,
	\degree, Pseq(l, inf),
	\octave, Pwhite(3,5).round(),
	\amp, 0.3,
);
)

~pa.play(faceTime:5);
~pa.stop(fadeTime:3);

(
~pt1 = Pbind(
	\instrument, \t1,
	\degree, Pseq(l, inf),
	\octave, Pseq([2, Rest(2)],inf),
	\scale, Scale.phrygian,
	\ffreq, Pseq(l, inf),
	\dur, Pseq(l, inf)/Pseq(l, inf) * 4,
	\legato, Pseq(l, inf) * 0.1,
	// \out, Pfunc(~bplay.bus.index),
	// \group, Pfunc(~bplay.group),
	\amp, 0.3,
);
)
~pt1.play;
~pt1.stop;

~dust.play;

(
~dust = { | freq = 110 |
	var sig, evn;
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(Pseq(l**2, inf).asStream, 0.2, 0.5, 0.5),0.2, 1, 0.5)) * (LFPulse.kr(LFPulse.kr(0.2, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(0, Pan2.ar(sig) * 0.2);
};
)

~dust.set(\freq, Pseq(l, inf).asStream * 100);

~dust.stop(fadeTime:10);
~dust.release(fadeTime:10);

~iter.play;
~iter.stop;
~iter.release;

~iterlfok1.play;
~iterlfok1 = {SinOsc.kr(~bplay.kr)};
~iterlfok1.stop;

~itergate.play(fadeTime:10);
~itergate = { LFPulse.ar(LFNoise0.kr(1).range(11, 110))!2 /* + Pbjorklund2(Pseq(l, inf).asStream, 22,inf).asStream/8 + Pseq(l * 100, inf).asStream **/ * 0.5 };
~itergate.release(fadeTime: 10);
~itergate.stop(fadeTime:4);

~rec.play;

(
~rec = {
	var sig = 0, temp;
	sig = LFPulse.ar(EnvGen.ar(Env([45, 60, 55, 63, 0],0.125!5,curve:\step),LFPulse.kr(Rand(0, 1).round(0.25)).midicps))!2 * 0.1;
};
)
~rec.free;

/*~ip.play;
(
~ip = Pbind(
	\instrument, \iter,
	\degree, Pseq(l, inf),
	\scale, Scale.phrygian,
	\dur, Pseq(l, inf)/Pseq(l, inf) * 4,
	\amp, Pseq(l, inf) * 0.01,
	\gate, ~itergate.kr,
);
)
~ip.stop;
~ip.release(fadeTime:5);*/
~iter.free;

// monitor - output to speakers



(
~hh = Pbind(
	\instrument, \bplay,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group ),
	\buf, d["Hats"][1],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25], inf),
	// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
	\amp, Pseq(l * 0.025, inf)
);

~b = Pbind(
	\instrument, \bplay,
	\out, Pfunc(~bplay.bus.index),
	\group, Pfunc(~bplay.group),
	\buf, d["Bass Drums"][6],
	\dur, Pbjorklund2(Pseq(l, inf), l.size, inf)/ Pseq(l, inf) + Pseq(l, inf),
	\amp, Pseq(l * 0.1, inf)
);
)


~hh.play;
~hh.stop;
~hh.release(fadeTime:4);

~bfunc = {r.collect({ | item | item }).do { | item | item.postln};};


~b.play;
~b.stop(fadeTime:4);
~b.release(fadeTime:4);


p.release(fadeTime:10);


// route the ndef through a delay - output to speakers
~delay.play;
~delay[1] = \mix -> {~hh.ar};
~delay[2] = \mix -> {~b.ar};
~delay[3] = \mix -> {~ip.ar};
~delay[4] = \mix -> {~dust.ar};
~delay[5] = \mix -> {~pt1.ar};
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
	PitchShift.ar(in * LFNoise2(~bplay.kr.reverse), 2, 2, 0.01, 0.01)
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
~verb.set(\mix0, 0.3, \mix1, 0.2, \mix2, 0.3, \mix3, 0.3);
);
// adjust wet/dry
~verb.set(\wet10, 1.0)
~verb.free;
~verb.stop(fadeTime:10);


