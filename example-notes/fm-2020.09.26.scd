s.reboot;
(
SynthDef(\t1, { |freq = 10, ffreq=1 |
	var temp= 0, sum = 0, fenv;
	8.do{ | c, i |
		temp = LFPulse.ar(Line.kr(10, c * freq) + LFPulse.kr(LFNoise0.kr(0,1)));
		sum = sum + temp * 0.2;
	};
	Out.ar(0, sum!2);
}).add;
)

{Pan2.ar(Dust2.ar(Rand(0, 1)) + SinOsc.kr(Rand(0, 111))) }.play;

a = Synth(\t1);
a.set(\freq, 20);
a.free;

{Pan2.ar(SinOsc.ar(100) + SinOsc.kr(Rand(0, 2000))) * 0.2 }.play;