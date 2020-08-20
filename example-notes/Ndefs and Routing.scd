(
s.options.memSize_(2 pow: 20);
p = ProxySpace.push(s.boot);
p.clock = TempoClock.default;
p.clock.tempo = 1;
)
(
SynthDef(\a, { | out = 0, gate=1, freq=440, width=0.5, amp=0.2 |
	var sig, env=1;
	env = EnvGen.kr(Env.perc(), gate, doneAction: 0);
	sig = SinOsc.ar(freq, 0, width, amp).dup;
	Out.ar(out, sig * env);
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

SynthDef(\delay, { | in, out=0 |
	Out.ar(out,  LFPulse.ar(In.ar(in)));
}).add;
)

(
~fxbus = Bus.audio(s, 2);

~synthgroup = Group.tail(s);


~out.play;
~out = \a;
~out.set(\in, ~delay);
~out.stop;

~delay.play;
~delay = \delay;
~delay.free;
~delay.stop;


// Beats using SynthDef
(
~h = Pbind(
	\instrument, ~bplay,
	\out, ~fxb,
	\buf, d["Hats"][2],
	\dur, 0.25);
)

// ~h.play(out:6);
~h.play;

~
~h.stop;

(
~b = Pbind(
	\instrument, \bplay,
	// \out, ~fx1,
	\buf, d["Bass Drums"][2],
	\dur, Pseq([0.5, 1, 0.5, 0.25], inf),
	\amp, 0.6
);
)

// ~h.play(out:6);
~b.play;
~b.set(\out, ~fxb);
~b.stop;

// ~out = { LFPulse.ar(\freq.kr(440), 0, \width.kr(0.5), \amp.kr(0.2)).dup };

~freq = { MouseY.kr(40, 5120, 1) };

~width = { MouseX.kr(0, 0.5) };

~out.play(fadeTimie: 3);
~out.stop(0.1);

~freq <>>.freq ~out; ~wdith <>>.width ~out;

~out.end(1);