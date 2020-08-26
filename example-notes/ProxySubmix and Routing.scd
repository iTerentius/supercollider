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

m = ProxySubmix(\del);
m.ar(2);

p.envir.put(\del, m);

~del = { DelayC.ar(m.ar) };
~del.play;

m.addMix(~h, postVol: true);
m.addMix(~b, postVol: true);

NdefGui(m, 8); // gets these params automagically:

(
~h = Pbind(
	\instrument, \bplay,
	// \out, ~out,
	// \addAction, \addToHead,
	\buf, d["Hats"][2],
	\dur, Pseq([0.25, 0.5], inf),
)
)

// ~h.play;
// ~h.stop;
// ~h.free;
(
~b = Pbind(
	\instrument, \bplay,
	// \out, ~out,
	\buf, d["Bass Drums"][2],
	\dur, Pseq([0.5, 1, 0.5, 1], inf),
	\amp, 0.6
).play;
)

// ~b.play;
// ~b.stop;
// ~b.free;





















// ~out = { LFPulse.ar(\freq.kr(440), 0, \width.kr(0.5), \amp.kr(0.2)).dup };

~freq = { MouseY.kr(40, 5120, 1) };

~width = { MouseX.kr(0, 0.5) };

~out.play(fadeTimie: 3);
~out.stop(0.1);

~freq <>>.freq ~out; ~wdith <>>.width ~out;

~out.end(1);