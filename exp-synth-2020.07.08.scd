
s.reboot;
s.prepareForRecord;
s.record;

(
SynthDef(\sp0, { | out = 0, freqs = 30, cbus=nil |
	var sig, env;
	env = EnvGen.kr(Env.asr(0.3, 0.6, 1), gate:In.kr(cbus), levelScale: 0.5 );
	sig = LFPar.ar(freqs.midicps - 12 !2, mul: In.kr(cbus)/2 * env);

	Out.ar(out, sig * env);
}).add;

SynthDef(\sp1, { | out=0, freqs=100, cbus1 = nil, cmod1 = nil |
var sig, env;

	env = EnvGen.kr(Env([0.1, 0.5, 0.1, 0.5, 0.1], [0, 0.25, 0.5, 0.75, 1], \sine), levelScale:0.5);
	// env = EnvGen.kr(Env.linen(0.01, 0.5, 2, 0.5, \welch));
	sig = SinOscFB.ar(freqs.midicps -24 ! 2, Rand(0, 5), mul: In.kr(cbus1)/2 * env);
	Out.ar([out, cbus1], sig * env);

}).add;

~cbus1 = Bus.control(s, 1);
~cmod1 = {
	var env;
	env = EnvGen.kr(Env.asr(0.05, 1, 1), gate: SinOsc.kr(rrand(1, 10)));
	Out.kr(~cbus1, LFPulse.kr(Rand(1,4), 0.5, mul: env))
}.play;

~s1 = {SinOsc.ar([100, 200], mul: In.kr(~cbus1)/2)};
)
~s1.play;


(
y = Pbind(
	\instrument, Pseq([\sp0, \sp1], inf),
	\freqs, Pseq([30, 65, 66, Rest(10), 68, 70], inf),
	\dur, Pseq([0.25, 0.125, 0.5, 0.125], inf),
	\delta, (1..5).choose,
	\cbus, ~cbus1,
	\amp, 0.25
)
)

y.play;
y.free;
~s1.free;
~cmod1.free;
~cbus1.free;

s.stopRecording;
/////// Testing

{LFSaw.kr(1) * 0.2}.plot(5);

{EnvGen(Env([0.1, 0.7, 0, 0.7, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \lin), 1)}.scope;

Env([0.1, 0.7, 0, 0.7, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \sine).plot;

Env.asr(0.3, 0.6, 0.3).plot;

Env.asr(0.3, 0.6, 1).plot;