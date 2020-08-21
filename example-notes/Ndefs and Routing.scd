(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 64;
s.options.numOutputBusChannels = 2;
//boot the server
s.reboot;

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

/* NOTES:
Order of Execution here. https://doc.sccode.org/Guides/Order-of-execution.html
This works, but lacks proxy control. Also .play on Pbinds need to be done on the def.
Also, TempoClock does seem to keep things in sync if not using ProxySpace. Still
Need to find out how this all works with Ndefs and in ProxySpace. */

(
~t = TempoClock(60/60);

)

Ndef(\a, { SinOsc.ar(\freq.kr(500)!2 * LFNoise0.kr(\time.kr(5)) * \amp.kr(0.2)).dup }).play;

Ndef(\a).play;
Ndef(\a).set(\freq, 140, \time, 5);

(
SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1, channels = 2;
		// channels = BufChannels.kr(buf);
		sig = Mix.ar(PlayBuf.ar(channels,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add;
)

(
Ndef(\delay, { | in, out=0 |
	Out.ar(out,  DelayC.ar(In.ar(~out)));
});
)

(
~out = Bus.audio(s, 2);

~synthgroup = Group.tail(s);
~fxgroup = Group.tail(s);

~delay = Synth.tail(~fxgroup, \delay, [\out, ~out]);

// ~xfer = {Out.ar(0, In.ar(~out, 2) * 0.25) }.play(s, addAction: \addToTail);
)

// ~a = Synth.tail

// Beats using SynthDef
(
~h = Pbind(
	\instrument, \bplay,
	\group, ~fxgroup,
	\addAction, \addToHead,
	\buf, d["Hats"][2],
	\dur, 0.25
).play(~t);  // seems like stop doesn't work here without playing from here
)
// ~h.play(~t);
~h.set(\group, nil);

~h.stop;

(
~b = Pbind(
	\instrument, \bplay,
	// \group, ~fxgroup,
	// \addAction, \addToHead,
	\out, ~out,
	\buf, d["Bass Drums"][2],
	\dur, Pseq([0.5, 1, 0.5, 0.25], inf),
	\amp, 0.6
).play(~t);
)

// ~h.play(out:6);
// ~b.play(~t);
// ~b.set(\out, ~fxb);
~b.stop;

// ~out = { LFPulse.ar(\freq.kr(440), 0, \width.kr(0.5), \amp.kr(0.2)).dup };

~freq = { MouseY.kr(40, 5120, 1) };

~width = { MouseX.kr(0, 0.5) };

~out.play(fadeTimie: 3);
~out.stop(0.1);

~freq <>>.freq ~out; ~wdith <>>.width ~out;

~out.end(1);