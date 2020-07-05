

(
~t = TempoClock(30/60);
~kb1 = Bus.control(s, 1);
~ab1 = Bus.audio(s, 2);
~freq = {Out.kr(~kb1, LFNoise2.kr(Rand(1,10)))}.play;
~delay = {Out.ar([0,1], Delay1.ar(In.ar(~ab1), In.kr(~kb1)) * 0.5)}.play;
)

(
SynthDef(\hpulse, { | freqs=100, out=0, control=0 |
	var ampOsc;
	ampOsc = LFPulse.kr(MouseY.kr(0, 4)!2 / freqs, 0, MouseX.kr(0, 3) * pi, 1);
	Out.ar(out, Pan2.ar(Pulse.ar(100) * SinOscFB.ar(In.kr(control).range(1, 3), 1.5, ampOsc)));
}).add;
)


(
Pbind(
	\instrument, \hpulse,
	\out, ~ab1,
	\conttrol, ~kb1,
	\freqs, Pseq([20, 30, 40, 50, 100], inf)

).play(~t);

)
