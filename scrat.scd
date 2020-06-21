Platform.systemAppSupportDir
(
play({
	var sines = 5, speed = 6;
	Mix.fill(sines,
		{arg x;
			Pan2.ar(
				SinOsc.ar(x+1* {exprand(1.0, 100.0)},
					mul: max(0,
						LFNoise1.kr(speed) +
						Line.kr(1, -1, 30)
					)
), rand2(1.0))}) / sines });
)
thisThread.randSeed = 555; {rand(10.0)} ! 10;

dup("echo", 20);
sort([23, 54, 678, 1, 21, 91, 34, 78]);

exprand(1.0, 100.0);

(
play(
	{
		CombN.ar(
			SinOsc.ar(
				midicps(
					LFNoise1.ar([3, 24],
						LFSaw.ar([5, 5.123], 0, 3, 80)
					)
				),
				0, 0.4),
			1, 0.3, 2)
	}
)
)


(
play(
	{
		SinOsc.ar(
			LFNoise2.kr(10, Line.kr(1, 10, 24))
		)
	}
)
)

SuperDirt.start


{LFNoise0.ar(10000)}.scope

exprand(1, 1000.0)

{exprand(1, 1000.0)}.play

{100.rand}.dup(10)

{100.rand} ! 10

{Blip.ar(50, LFNoise0.kr([55,10], 12, 14), 0.3)}.play

{PMOsc.ar( carfreq: 440, modfreq: MouseY.kr(1, 550), pmindex: MouseX.kr(1,15) )}.play

{SinOsc.ar(mul: Line.kr(0, 1.0, 24))}.scope

(
{
	Blip.ar(
		TRand.kr(
			40, 500,
			Impulse.kr(Line.kr(1, 20, 60), Line.ar(50, 1000))),
		TRand.kr(
			1, 10,
			Impulse.kr(Line.kr(1, 40, 60))),
		Linen.kr(
			Impulse.kr(Line.kr(1, 20, 60)),
			0,
			0.5,
			1/Line.kr(1, 20, 60))
	)
}.play
)

{Impulse.ar([500,50], phase: 10, mul: 0, add: 0)}.play

(
{
	r = MouseX.kr(1/3, 10);
	SinOsc.ar(mul: Linen.kr(Impulse.kr([r, r]), 0, 1, 1/r))
}.play
)

(
p = {
	r = Line.kr(1, 20, 60);
	q = LFNoise1.kr(r);
	r = LFTri.kr(1/10) * 3 +7;
	t = Impulse.kr(q);
	t = Dust.kr(r);
	e = Linen.kr(t, 0, 0.5, 1/r);
	f = TRand.kr(1, 10, t);
	// f = e + 1 * 4;
	Blip.ar(f*100, f, e)
}.play
)

p.free

(
{
	r = Impulse.kr(10);
	c = TRand.kr([100, 100], 5000, r);
	m = TRand.kr(100, 5000, r);
	PMOsc.ar(c, m, 12) * 0.3
}.play
)

(
{
	var rate = 4, carrier, modRatio, line, env;
	rate = Line.kr(start: 1, end: 20);
	// carrier = LFNoise0.kr(freq: rate) * 300 + 100;
	modRatio = MouseX.kr(minval: 1, maxval: 2.0);
	line = Line.kr(start: 1, end: 20);
	env = Linen.kr(attackTime: 1/rate, decay: 0);
	PMOsc.ar(carfreq: [carrier, carrier], modfreq: carrier*modRatio, pmindex: line, mul: env) * 0.3
}.play
)

(
SynthDef("different_tones", {
	arg freq = 440;
	var out;
	out = SinOsc.ar(freq)*0.3;
	Out.ar(0, out)
}).add
)

Synth("different_tones", ["freq", 550]);
Synth("different_tones", [\freq, 660]);
Synth("different_tones", ["freq", 880]);

a = Synth("different_tones", ["freq", 64.midicps]);
b = Synth("different_tones", [\freq, 67.midicps]);
c = Synth("different_tones", ["freq", 72.midicps]);
a.set("freq", 65.midicps);
c.set("freq", 71.midicps);
a.set("freq", 64.midicps); c.set("freq", 72.midicps);
a.free;
b.free;
c.free;



(
SynthDef("PMCrotale", {
	arg midi = 60, tone = 3, art = 1, amp = 0.8, pan = 0;
	var env, out, mod, freq;

	freq = midi.midicps;
	env = Env.perc(0, art);
	mod = 5 + (1/IRand(2, 6));

	out = PMOsc.ar(freq, mod*freq,
		pmindex: EnvGen.kr(env, timeScale: art, levelScale: tone),
		mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3));

	out = Pan2.ar(out, pan);

	out = out * EnvGen.kr(env, timeScale: 1.3*art,
		levelScale: Rand(0.1, 0.5), doneAction: 2);
	Out.ar(0, out);

}).add;
)

Synth("PMCrotale", ["midi", rrand(48, 72), "tone", rrand(1, 6)]);

~houston = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");
~chooston = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

{PlayBuf.ar(1, ~houston)}.play;
{PlayBuf.ar(1, ~chooston)}.play;

//C1 section 1.10

[~houston.bufnum, ~houston.numChannels, ~houston.path, ~houston.numFrames];
[~chooston.bufnum, ~chooston.numChannels, ~chooston.path, ~chooston.numFrames];

(
{
	var rate, trigger, frames;
	frames = ~houston.numFrames;

	rate = [1, 1.01];

	trigger = Impulse.kr(rate);
	PlayBuf.ar(1, ~houston, 1, trigger, frames * Line.kr(0, 1, 60)) * EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;
}.play;
)


(
{
	var speed, direction;
	speed = LFNoise0.kr([1,11]) * 0.2 + 1;
	direction = LFClipNoise.kr(2/3);
	PlayBuf.ar(1, ~houston, (speed * direction), loop: 1);
}.play;
)

(
~kbus1 = Bus.control;
~kbus2 = Bus.control;
{
	var speed, direction;
	speed = In.kr(~kbus1, 1) * 0.2 + 1;
	direction = In.kr(~kbus2);
	PlayBuf.ar(1, ~chooston, (speed * direction), loop: 1);
}.play;
)

(
{Out.kr(~kbus1, LFNoise0.kr(12))}.play;
{Out.kr(~kbus2, LFClipNoise.kr(1/4))}.play;
)

(
{
	var speed, direction;
	speed = In.kr(~kbus1, 1) * 0.2 + 1;
	direction = In.kr(~kbus2);
	Out.ar(1, PlayBuf.ar(1, ~houston, (speed * direction), loop: 1));
}.play;
)

~kbus3 = Bus.control;
~kbus4 = Bus.control;

{Out.kr(~kbus3, LFNoise2.kr(3).scope("out3") * 100)}.play;
{Out.kr(~kbus4, LFPulse.kr(1/3).scope("out4") * 200)}.play;
{Out.ar(0, SinOsc.kr(In.kr(~kbus3) + In.kr(~kbus4) + 440).scope("left"))}.play;
{Out.ar(1, SinOsc.ar(In.kr(~kbus3) + In.kr(~kbus4) + 880).scope("right"))}.play;

~kbus3 = Bus.control;
~kbus4 = Bus.control;
{Out.kr(~kbus3, SinOsc.kr(3).range(340, 540)) }.play;
{Out.kr(~kbus4, LFPulse.kr(6).range(240, 640))}.play;
SynthDef("another", { arg freq = 440; Out.ar(0, SinOsc.ar(freq, 0, 0.3)) }).add

x = Synth("another");
x.map(\freq, ~kbus3)
x.map(\freq, ~kbus4)

