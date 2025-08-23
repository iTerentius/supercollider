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

p.fadeTime = 3;

s.prepareForRecord;
s.record;
s.stopRecord;

(
SynthDef(\a, { | out=0, freq=100, time=5, dur=1 |
	var sig, env = 1;
	// env = EnvGen.kr(Env.perc(), doneAction: 2);
	sig = SinOsc.ar(freq * LFNoise0.kr(time));
	sig = sig * env;
	Out.ar(out, Splay.ar(sig *  0.2));
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


SynthDef(\delay, { | in, out=0 |
	Out.ar(out,  DelayC.ar(In.ar(in)));
}).add;

SynthDef(\fuck, { | freq=110 | Out.ar(0, LFSaw.ar(freq: Line.kr(50, 110) * freq, amp: 0.2).dup * 0.02) }).add;
)

/* Notes: OoE here that sort of works is ~out (Bus) then Source (with play or doesn't work), then FX (~delay).
Pbind play when defined puts them in the default group at the head so fx keep workiing (but I'm getting both)
NEXT: Try Pbind out to another Proxy set in correct group order to see if that allows for muting of source (or mixing)*/

~out = Bus.audio(s, 2);

~fxgroup.play;

~a = { | t_trig | SinOsc.ar(TRand.kr(100, 200, t_trig), 0, 0.5) };
~a.play;
~a = \a;
~a.stop;
~a.free;

~fuck.play;
~fuck.stop;
~fuck.free;

~fuck = \fuck;
~fuck.xmap(\freq, ~fctl);
~fctl = { LFTri.kr(~a * Line.kr(0, 1) * 30) };
~fctl.stop;
(
~delay = { | in, out=0 |
	DelayC.ar(In.ar(~out));
};
)
~delay.set(\group, ~fxgroup);
~delay.set(\in, ~out);
~delay.play;
~delay.stop;
~delay.free;

(
~h = Pbind(
	\instrument, \bplay,
	\out, ~out,
	\addAction, \addToHead,
	\buf, d["Hats"][2],
	\dur, 0.25);
)

~h.play;
~h.stop;
~h.free;
~delay[0].map(\in, ~h);
(
~b = Pbind(
	\instrument, \bplay,
	\out, ~out,
	\buf, d["Bass Drums"][1],
	\dur, Pseq([0.5, 1, 0.5, 1], inf),
	\amp, 0.4
);
)

~b.play;
~b.stop;
~b.free;
~a = \a;
~a.play;






















// ~out = { LFPulse.ar(\freq.kr(440), 0, \width.kr(0.5), \amp.kr(0.2)).dup };

~freq = { MouseY.kr(40, 5120, 1) };

~width = { MouseX.kr(0, 0.5) };

~out.play(fadeTimie: 3);
~out.stop(0.1);

~freq <>>.freq ~out; ~wdith <>>.width ~out;

~out.end(1);