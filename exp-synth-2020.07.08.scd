/*
What did I learn today? Things play right here with some amp issues. Also that stop actually works and free doesn't. look into that.
*/
s.reboot;
p = ProxySpace.push(s);
StageLimiter.activate;
s.prepareForRecord;
s.record;

(
~cbus1 = Bus.control(s, 1);
~synth1 = SynthDef(\sp0, { | out = 0, freqs = 30, cbus=nil |
	var sig, env;
	env = EnvGen.kr(Env.asr(0.3, 0.6, 1), gate:In.kr(cbus), levelScale: 0.5, doneAction: 2 );
	sig = Blip.ar(freqs.midicps - 12 !2, mul: In.kr(cbus)/2 * env);

	Out.ar(out, sig * env);
}).add;

~synth2 = SynthDef(\sp1, { | out=0, freqs=100, cbus1 = nil, cmod1 = nil |
var sig, env;

	env = EnvGen.kr(Env([0.1, 0.5, 0.1, 0.5, 0.1], [0, 0.25, 0.5, 0.75, 1], \sine), levelScale:0.5, doneAction: 2);
	// env = EnvGen.kr(Env.linen(0.01, 0.5, 2, 0.5, \welch));
	sig = LFPulse.ar(freqs.midicps / 2 ! 2, Rand(0, 5), mul: In.kr(cbus1)/2 * env);
	Out.ar([out, cbus1], sig * env);

}).add;

~mod1 = SynthDef(\mod1, {
	var env;
	env = EnvGen.kr(Env.asr(0.05, 1, 1), gate: SinOsc.kr(rrand(1, 10)), doneAction: 2);
	Out.kr(~cbus1, LFPulse.kr(Rand(1,4), 0.5, mul: env));
}).add;
)

(
~synth3 = SynthDef(\puls, { | out=0 |
	var sig;
	sig = {Blip.ar([40, 200], mul: In.kr(~cbus1) * 0.2)};
	Out.ar(out!2, sig);
}).add;
)

(
~y = Pbind(
	\instrument, Pseq([\sp0, \sp1], inf),
	\freqs, Pseq([Rand(30, 60), 60, 66, Rest(10), 68, 70], inf),
	\dur, Pseq([0.25, 0.125, 0.5, 0.125], inf),
	\delta, (1..5).choose,
	\cbus, ~cbus1,
	\amp, 0.5
)
)

~y.play(fadeTime: 3);
~y.free(fadeTime: 20);
~y.stop(fadeTime: 5);
~s1 = Synth(\puls);
~s1.stop(fadeTime: 20);
~cmod1.stop(fadeTime: 5);
~cbus1.stop(fadeTime: 5);
~cbus1.free;
~cmod1.play(fadeTime: 5);
~cbus1.play(fadeTime: 5);

s.stopRecording;
/////// Testing

{LFSaw.kr(1) * 0.2}.plot(5);

{EnvGen(Env([0.1, 0.7, 0, 0.7, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \lin), 1)}.scope;

Env([0.1, 0.7, 0, 0.7, 0.1], [0.25, 0.5, 0.75, 0.85, 1], \sine).plot;

Env.asr(0.3, 0.6, 0.3).plot;

Env.asr(0.3, 0.6, 1).plot;

ProxySpace.free;