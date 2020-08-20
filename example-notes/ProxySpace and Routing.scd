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

SynthDef(\delay, { | in, out=0 |
	Out.ar(out,  LFPulse.ar(In.ar(in)));
}).add;
)

~dbus = Bus.audio(s, 2);


~out.play;
~out = \a;
~out.set(\out, ~delay);
~out.stop;

~delay.play;
~delay = ;
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