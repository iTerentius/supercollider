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
)

(
~a = { | freq=440, width=0.5, amp=0.2 |
	var sig, env=1;
	env = EnvGen.kr(Env.perc(), doneAction: 0);
	sig = SinOsc.ar(freq, 0, width, amp).dup;
	sig = sig * env;
};
)

~out.play;
~out.xmap(
(
~out = SynthDef(\a, { | out = 0, gate=1, freq=440, width=0.5, amp=0.2 |
	var sig, env=1;
	env = EnvGen.kr(Env.perc(), gate, doneAction: 0);
	sig = SinOsc.ar(freq, 0, width, amp).dup;
	Out.ar(out, sig * env);
});
)
~out.set(\out, ~delay);
~out.stop;

~delay.play;
(
~delay = SynthDef(\delay, { | in, out=0 |
	Out.ar(out,  LFPulse.ar(In.ar(in)));
});
)
~delay.set(\in, ~dbus);
~delay.free;
~delay.stop;

// ~out = { LFPulse.ar(\freq.kr(440), 0, \width.kr(0.5), \amp.kr(0.2)).dup };

~freq = { MouseY.kr(40, 5120, 1) };

~width = { MouseX.kr(0, 0.5) };

~out.play(fadeTimie: 3);
~out.stop(0.1);

~freq <>>.freq ~out; ~wdith <>>.width ~out;

~out.end(1);
