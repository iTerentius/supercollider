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


{SinOsc.ar(XLine.ar(440, 330, 1), mul: -3.dbamp)}.play;

{SinOsc.ar(EnvGen.ar(Env([220, 440, 330], [1,1]*0.707, \exp)))}.play;

(
var freq = {XLine.kr(400, 440, 10)};

{SinOsc.ar([440, freq], mul:-3.dbamp)}.play;
)

// Wavetable

~buffer = Buffer.alloc(s, 2**16);
~fund = 100;
~harmN = ((s.sampleRate/2)/~fund).floor;
~norm = -3.dbamp;

(
var sine;
sine = ~buffer.sine1([1]);
{Osc.ar(sine, ~fund, mul: ~norm)}.play;
)


(
var harm, saw;
harm = Harmonics(~harmN);
saw = ~buffer.sine1(harm.decay);
{Osc.ar(saw, ~fund)}.play;
)

(
var freqs, amps, square;
freqs = (1, 3..~harmN);
amps = 1/freqs;
square = ~buffer.sine2(freqs, amps);
{Osc.ar(square, ~fund, mul: ~norm)}.play;
)

(
var freqs, amps, triangle;
freqs = (1/3..~harmN);
amps = 1/freqs.pow(2);
triangle = ~buffer.sine2(freqs, amps);
{Osc.ar(triangle, ~fund, mul: ~norm)}.play;
)

(
var freqs, amps, pulse;
amps = 1/(1!~harmN);
pulse = ~buffer.sine1(amps, asWavetable:false);
{OscN.ar(pulse, ~fund, mul: ~norm)}.play;
)

~buffer.free;

f = { arg a; a.value + 3 };    // call 'value' on the arg; polymorphism awaits!
f.value(3);            // 3.value = 3, so this returns 3 + 3 = 6
g = { 3.0.rand; };
f.value(g);            // here the arg is a Function. Cool, huh?
f.value(g);            // try it again, different result

///////////


(
~score = {
	var freqs, size=32, selector, output;
	freqs = Array.fill(128, {rrand(36, 84).midicps/2});
	selector = LFSaw.ar(1.0, mul:size/2, add:size/2);
	output = Select.kr(selector, freqs);
}
)

~synths = [SinOsc, Saw, Pulse, LFTri, Blip];

(
var choice, amp, output;
choice = Array.fill(4, {rrand(0, 4)});
amp = 0.707/(choice.size);
output = Array.newClear(choice.size);
choice.size.do{|i|
	choice[i] = if(choice[i]>0, choice[i], 0);
	choice[i] = if(choice[i] < (~synths.size), choice[i], (~synths.size-1));
	output[i] = {~synths[choice[i]].ar(~score, mul: [amp, amp])}.play;
}
)

///////////////

b = Buffer.alloc(s, 2**16);
b.sine2((1,3..23), 1/(1,3..23).pow(2));

(
SynthDef(\tri, {
	|buff=0, freq=440, amp=0.707, dur=1, t_trig=0|
	var env, envgen, output;
	env = Env([0, 1, 9/10, 1/2, 0]*amp, [1/50, 1/25, 23/25, 1/50]*dur);
	envgen = EnvGen.ar(env, t_trig);
	output = Osc.ar(buff, freq, mul:envgen);
	Out.ar(0, output);
}).add;
)

(
var clock, synth, freq, dur;
clock = [TempoClock, TempoClock(2)];
synth = [Synth(\tri, [\buff, b, \amp, 0.707/2]), Synth(\tri, [\buff, b, \amp, 0.707/2])];
freq = [[60,64,67,72], Array.fill(7, {60+12.rand})].midicps;
dur = [2!4, 1!6++2];
freq.do{
	|i,j|
	i.size.do{
		|x|
		clock[j].sched(x, {synth[j].set(\freq, i[x], \dur, dur[j][x], \t_trig, 1)});
	};
	clock[j].sched(dur[j].sum+2, {synth[j].set(\amp, 0); synth[j].free});
};
)
