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
			Impulse.kr(Line.kr([1,1], 20, 60), Line.ar(50, 1000))),
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

{Impulse.ar([500,50], phase: 10, mul: 1, add: 0)}.play

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
	r = Impulse.kr(MouseX.kr(1,30));
	c = TRand.kr([100, 100], 5000, r);
	m = TRand.kr(100, 5000, r);
	PMOsc.ar(c, m, 12) * 0.3
}.play
)

(
{
	var rate = 4, carrier, modRatio, line, env;
	rate = Line.kr(start: 1, end: 20);
	carrier = LFNoise0.kr(freq: rate) * 100 + 100;
	modRatio = MouseX.kr(minval: 1, maxval: 2.0) * rate;
	line = Line.kr(start: 1, end: 20);
	env = Linen.kr(
		attackTime: 1/rate, decay: 0);
	PMOsc.ar(carfreq: [carrier, carrier], modfreq: modRatio, pmindex: line, mul: env) * 0.3
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

Pbind(
	\instrument, \PMCrotale,
	\midi, rrand(48, 72).round(1),
	\tone, rrand(1, 6),
)




~houston = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");
~chooston = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


{PlayBuf.ar(1, ~houston)}.play;
{PlayBuf.ar(1, ~chooston)}.play;



[~houston.bufnum, ~houston.numChannels, ~houston.path, ~houston.numFrames];
[~chooston.bufnum, ~chooston.numChannels, ~chooston.path, ~chooston.numFrames];

(
{
	var rate, trigger, frames;
	frames = ~h1.numFrames;

	rate = [1, 1.01];

	trigger = Impulse.kr(rate);
	PlayBuf.ar(1, ~h1, 1, trigger, frames * Line.kr(0, 1, 60)) * EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;
}.play;
)

(
{
	Out.ar(0,
		Pan2.ar(PlayBuf.ar(1, ~houston, loop: 1) *
			SinOsc.ar(LFNoise0.kr(12, mul: 500, add: 600)), 0.5)
	)
}.play
)

(
{
	var source, delay;
	source = PlayBuf.ar(1, ~chooston, loop: 1);
	delay = AllpassC(source, 2, [0.65, 1.15], 10);
	Out.ar(0,
		Pan2.ar(source) + delay
	)
}.play;
)

// Page 30 F1.11
~delay = Bus.audio(s, 2);
~mod = Bus.audio(s, 2);
~gate = Bus.audio(s, 2);
~k5 = Bus.control;

~controlSyn = {Out.kr(~k5, LFNoise0.kr(4))}.play;

~delaySyn = {Out.ar(0, AllpassC.ar(In.ar(~delay, 2), 2, [0.65, 1.15], 10))}.play(~controlSyn, addAction: \addAfter);

~modSyn = {Out.ar(~delay, In.ar(~mod, 2) * SinOsc.ar(In.kr(~k5) * 500 + 1100))}.play(~delaySyn, addAction: \addBefore);

~gateSyn = {Out.ar([0, ~mod], In.ar(~gate, 2) * max(0, In.kr(~k5)))}.play(~modSyn, addAction: \addBefore);

~pbGroup = Group.before(~controlSyn);

{Out.ar(~gate, Pan2.ar(PlayBuf.ar(1, ~houston, loop: 1), 0.5))}.play(~pbGroup);

{Out.ar(~gate, Pan2.ar(PlayBuf.ar(1, ~chooston, loop: 1), -0.5))}.play(~pbGroup);

s.plotTree;

//Page 35 Additive Synthesis (with my modifications for code simplification)

{LFNoise1.ar(5000).range(0, 5000)}.plot;

(
a ={
	var ampCont;
	ampCont = max(0, LFNoise1.kr(12));
};

{
	var fund = 200;
	Mix.ar(Pan2.ar(
		[
			SinOsc.ar([fund, fund], mul: a),
			SinOsc.ar(fund*2, mul: a) * 1/2,
			SinOsc.ar(fund*3, mul: a) * 1/3,
			SinOsc.ar(fund*4, mul: a) * 1/4,
			SinOsc.ar(fund*5, mul: a) * 1/5,
			SinOsc.ar(fund*6, mul: a) * 1/6
		]
		))* 0.5;
}.play;
)

// Page 37 with better code simp F1.16 **Look**

Array.fill(20, {arg cnt; cnt + 1*110});

(
{ | fund=20 |
	Pan2.ar(Mix.ar(
		Array.fill(12,
			{arg count;
				var harm;
				count.postln;
				harm = count * fund / Line.kr(-1, 2.0, 4) * 1/MouseY.kr(1, -1) * 05;
				SinOscFB.ar(harm,
					mul: max([0,0], LFNoise2.kr(count+1/MouseX.kr(1,3)))
				)*5/(count+1)
		})
)*0.7 , pos: LFNoise0.kr(10))}.play
)

// Page 38 F1.18 Bells
Array.fill(3, {Array.fill(10, {rand(1000)})});


s.prepareForRecord;
(

// s.record;

{
var scale, specs, freqs, amps, rings,
numRes = 5, bells = 20, pan;
scale = [60, 62, 64, 67, 69].midicps;
Mix.fill(bells, {
	freqs = Array.fill(numRes, {rrand(1, 15)*(scale.choose)});
	amps = Array.fill(numRes, {rrand(0.3, 0.9)});
	rings = Array.fill(numRes, {rrand(1.0, 4.0)});
	specs = [freqs, amps * 2, rings].round(0.01);
	// specs.postln;
		pan = (LFNoise1.kr(rrand(3, MouseX.kr(1, 6)))*2).softclip;
	Pan2.ar(
		Klank.ar(`specs,
			Dust.ar(1/6, 0.03)),
		pan)
});
}.play;
)

s.stopRecording;


(
Synt