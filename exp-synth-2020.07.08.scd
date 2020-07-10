(
~cbus1 = Bus.control(s, 1);
~cmod1 = {Out.kr(~cbus1, LFSaw.kr(1)/2)}.play;
~s1 = {SinOsc.ar([100, 200], mul: In.kr(~cbus1))};
)
~s1.play;

s.prepareForRecord;
s.record;

(
SynthDef(\sp1, { | out=0, freqs=100 |
var cbus1, cmod1, sig, env;
	cbus1 = Bus.control(s, 1);
	env = EnvGen.kr(Env([0.1, 0.5, 0, 0.5, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \lin));
	cmod1 = Out.kr(cbus1, (SinOsc.kr(env)));

	sig = SinOsc.ar([freqs.midicps, freqs.midicps], 0, In.kr(cbus1).range(-0.2, 0.2));
	Out.ar(out, sig);

}).add;
)

(
y = Pbind(
	\instrument, \sp1,
	\freqs, Pseq([30, 65, 66, Rest(10), 68, 70], inf),
	\dur, Pseq([0.25, 0.125, 0.5, 0.125], inf),
	\delta, Pwhite(1, 5)
)
)

y.play;

s.stopRecording;
/////// Testing

{LFSaw.kr(1) * 0.2}.plot(5);

{EnvGen(Env([0.1, 0.7, 0, 0.7, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \lin), 1)}.scope;

Env([0.1, 0.7, 0, 0.7, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \sine).plot;