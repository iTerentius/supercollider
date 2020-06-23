//Envelope Custom
(
var envtri, dur=2;
envtri = Env([0.1, 0.707, 0.01], [dur/2, dur/2], \exp);
envtri.test.plot;
)

(
var envadsr, dur=2;
var rel = Line.kr(0.01, 1);
envadsr = Env([0, 0.707, 0.65, 0.4, 0], [1/64, 3/32, 14/16/ 1/64] * dur, -4);
envadsr.test.plot;
)

(
{
	var dur=2, envtri, trig, envgen, output;
	trig = Impulse.kr(1/dur);
	envtri = Env([0.01, 0.707, 0.01], [dur/2, dur/2], \exp);
	envgen = EnvGen.ar(envtri, trig);
	output = SinOsc.ar(mul: envgen);
}.scope
)

(
{
	var dur=2, envadsr, gate, envgen, output;
	envadsr = Env.adsr(sustainLevel: 0.707);
	gate = LFNoise1.ar([1/dur, dur], mul: 1/2);
	envgen = EnvGen.ar(envadsr, gate);
	output = SawDPW.ar(mul: envgen/2, freq: rrand(20, 100));
}.play
)

(
{
	var dur=1, env16seg, trig, envgen, output, freq;
	freq = LFNoise2.ar(6).range(20, 500);
	env16seg = Env([0.01, 1, 0.01, 7/8, 0.01, 6/8, 0.01, 5/8, 0.01, 4/8, 1, 3/8, 0.01, 2/8, 0.01, 1/8, 0.01]*0.707, dur/16!16, \exp);
	trig = SinOsc.ar([1/dur, 1/dur], mul:1/2);
	envgen = EnvGen.ar(env16seg, trig);
	output = SinOsc.ar(freq: freq, mul:envgen);
}.play;
)

(
SynthDef(\sinenv, {
	|freq=440, amp=1, dur=1|
	var env, trig, envgen, output;
	env = Env([0, 0.707, 0.65, 0.4, 0]*amp, [1/64, 3/32, 14/16/ 1/64]*dur, -4).plot;
	trig= SinOsc.ar(1/dur, mul: 1/2);
	envgen = EnvGen.ar(env, trig);
	Out.ar(0, SinOsc.ar(freq, mul:envgen))
}).add;
)

(
a = Synth(\sinenv, [\amp, 1/3]);

b = Synth(\sinenv, [\freq, 550, \amp, 1/3, \dur, 2]);

c = Synth(\sinenv, [\freq, 660, \amp, 1/3, \dur, 3]);
)

a.free; b.free; c.free;

{SinOsc.ar(440)}.play;

{SinOsc.ar(midicps(69))}.play;

{SinOsc.ar(octcps(4.75))}.play;

(
var amaj, amp;

amaj = [60, 64, 67, 72].midicps;

amp = 0.707/amaj.size;
{SinOsc.ar(amaj[0], mul:amp)}.play;

{SinOsc.ar(amaj[1], mul:amp)}.play;

{SinOsc.ar(amaj[2], mul:amp)}.play;

{SinOsc.ar(amaj[3], mul:amp)}.play;
)


{SinOsc.ar.(XLine.ar(440, 330, 1), mul: -3.dbamp)}.play;

{SinOsc.ar(EnvGen.ar(Env([220, 440, 330], [1,1]*0.707, \exp)))}.play;