// Fucked Up Samples
(

StageLimiter.activate;
~sRoot = "/home/hypostatic/music/supercollider/";

~h1 = Buffer.read(s, ~sRoot +/+ "/_samples/Hoarder/hoarder/01-rats.wav");
~h2 = Buffer.read(s, ~sRoot +/+ "/_samples/Hoarder/hoarder/20-I-dont-like.wav");

~kbus1 = Bus.control(s, 1);
~kbus2 = Bus.control(s, 1);
)

(
SynthDef(\fsamp, { arg out = 0, in = nil, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=3, loop = 1;
	var speed, direction, input;
	speed = In.kr(~kbus1, 1) * rate * 0.2 + 1;
	direction = In.kr(~kbus2);
	Out.ar(out, Pan2.ar(PlayBuf.ar(2, buf, (speed * direction), startPos: pos, loop: loop, doneAction:2) * SinOsc.ar(LFNoise0.kr(12, mul: 100)) ));
}).add;
)

(
~speed = {Out.kr(~kbus1, MouseX.kr(-0.8, 0.8))}.play;
~direction = {Out.kr(~kbus2, LFClipNoise.kr(1))}.play;
)


s.prepareForRecord;

(
~t = TempoClock(40/60);
// s.record;
Pbind(
	\instrument, \fsamp,
	\out, 0,
	\buf, ~h2,
	\rate, Pseq([1, -0.8, 2, 0.5, 1], inf),
	\pos, Pn(Pseries(0,10, ~h2.numFrames)),
	\loop, 0
).play(~t);

Pbind(
	\instrument, \fsamp,
	\out, 55,
	\buf, ~h1,
	\rate, Prand([1, -0.8, 2, 0.5, 1], inf),
	\pos, Pn(Pseries(0, 10, ~h1.numFrames)),
	\loop, 0
).play(~t);
)

~h1.numFrames;
s.stopRecording;


Array.fill(20, {arg cnt; cnt + 1*110});

(
{
	Pan2.ar(Mix.ar(
		Array.fill(12,
			{arg count;
				var harm;
				count.postln;
				harm = count * 110;
				SinOsc.ar(harm,
					mul: max([0,0], SinOsc.kr(count+1/4))
				)*1/(count+1)
		})
)*0.7 , pos: LFNoise0.kr(10))}.play(~t);
)
