

(
~t = TempoClock(30/60);
~kb1 = Bus.control(s, 1);
~ab1 = Bus.audio(s, 2);
~ab2 = Bus.audio(s, 2);
~freq = {Out.kr(~kb1, LFNoise2.kr(Rand(1,10)))}.play;
~delay = {Out.ar([~ab1,~ab2], Delay1.ar(In.ar(~ab1), In.kr(~kb1)) * 0.5)}.play;
~fverb = {Out.ar([0,1], FreeVerb.ar(In.ar(~ab1)))}.play;
)

(
SynthDef(\hpulse, { | freqs=10, out=0, control=0 |
	var ampOsc;
	ampOsc = LFPulse.kr(MouseY.kr(0, 2)!2, 0, MouseX.kr(0, 3), 1);
	Out.ar(out, Pan2.ar(Pulse.ar(freqs) * SinOscFB.ar(In.kr(control).range(1, 3), 1.5, ampOsc)));
}).add;
)


(
~x = Pbind(
	\instrument, \hpulse,
	\out, ~ab1,
	\control, ~kb1,
	\freqs, Pseq([1, 5, 10, 50, (Rest(3)), 2], inf)

).play(~t);

)

~x.free; ~ab1.free; ~ab2.free;
