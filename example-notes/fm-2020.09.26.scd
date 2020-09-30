s.reboot;
(
SynthDef(\t1, { | ffreq=1 |
	var temp= 0, sum = 0;
	8.do{ | c, i |
		temp = LFPulse.ar(Line.kr(10, c*  2 * 4) * MouseX.kr(0, 10) + LFPulse.kr(LFNoise0.kr(5, 20)));
		sum = sum + temp * 0.2;
	};
	Out.ar(0, sum!2);
}).add;
)

a = Synth(\t1);
a.free;


pb = Pbind


)
{Pan2.ar(SinOsc.ar(300) + SinOsc.kr(MouseX.kr(0, 2000))) * 0.2 }.play;