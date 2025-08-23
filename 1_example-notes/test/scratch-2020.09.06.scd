s.reboot;
(
SynthDef(\iter, { | freq = 40 |
	var temp;
	var env;
	var sum = 0;
	// env = EnvGen.kr(
	// 	Env.perc(0.1, 1, 1, -2),
	// 	doneAction:2
	// 	);
	10.do{
		temp = VarSaw.ar(
			freq.midicps * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005, 0.05)}!2
			);
			sum = sum + temp;
	};
	sum = sum * 0.5;
	Out.ar(0, sum);

}).add;
)
x = Synth.new(\iter, [\freq, 20]);
x.free;

(
Pbind(
	\instrument, \iter,
	\freq, Pseq([40, 60, 50, 40], inf),
	\dur, Prand([1, 0.25, 0.5, 0.75], inf),
	\amp, 0.05
	).play;
)
