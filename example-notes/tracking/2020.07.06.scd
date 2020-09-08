(
o = Server.default.options;
b = NetAddr.new("192.168.1.66", 7772);

o.numOutputBusChannels = 16; // The next time it boots, this will take effect
s.boot;
s.reboot;
)

(
v = SynthDef(\fx, {
	~kb1 = Bus.control(s, 1);
	~ab1 = Bus.audio(s, 2);
	~ab2 = Bus.audio(s, 2);
	~freq = {Out.kr(~kb1, LFNoise2.kr(Rand(1,10), mul: 0.2))}.play;
	~delay = {Out.ar([~ab1,~ab2], Delay1.ar(In.ar(~ab1) / 2, In.kr(~kb1) / 4))}.play;
	~fverb = {Out.ar(3,
		Splay.ar(
			[
				FreeVerb.ar(In.ar(~ab1), MouseX.kr(-0.5,0.5)),
				FreeVerb.ar(In.ar(~ab2), MouseX.kr(0.5,-0.5)),
	], center: MouseX.kr(-0.5, 0.5) ))}.play;
}).add;

y = SynthDef(\hpulse, { | freqs=10, out=0, control=0 |
	var ampOsc;
	ampOsc = LFPulse.kr(MouseY.kr(0, 1), 0, MouseX.kr(0, 1), mul: 0.2);
	Out.ar([out, out], (Pulse.ar(freqs, mul:0.3) * SinOscFB.ar(In.kr(control).range(20, 1), 1.5, ampOsc/4)));
}).add;

b.sendMsg("/tempo/raw", 60);
b.sendMsg("/track/1/recarm", 1);
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/3/recarm", 1);
b.sendMsg("/time", 0);
b.sendMsg("/restart", 1);
b.sendMsg("/record", 1);
//
~x = Pbind(
	\instrument, \hpulse,
	\out, [~ab1, ~ab2],
	\control, ~kb1,
	\freqs, Pseq([1, 50, 10, 50, (Rest(3)), 100], inf)

).play(~t);

)

v.free; y.free; ~x.free; ~ab1.free; ~ab2.free; ~fverb.free; ~freq.free; ~kb1.free; b.sendMsg("/stop", 1);


// Fucked Up Samples
(

StageLimiter.activate;
~sRoot = "/home/hypostatic/music/supercollider/";

~h1 = Buffer.read(s, ~sRoot +/+ "/_samples/Hoarder/hoarder/01-rats.wav");
~h2 = Buffer.read(s, ~sRoot +/+ "/_samples/Hoarder/hoarder/20-I-dont-like.wav");

~kbus1 = Bus.control(s, 1);
~kbus2 = Bus.control(s, 1);

SynthDef(\fsamp, { arg out = 0, in = nil, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=3, loop = 1;
	var speed, direction, input;
	speed = In.kr(~kbus1, 1) * rate * 0.2 + 1;
	direction = In.kr(~kbus2);
	Out.ar(out,
		Pan2.ar(
		PlayBuf.ar(2, buf, (speed * direction), startPos: pos, loop: loop, doneAction:2)
			* SinOsc.ar(LFNoise0.kr(12, mul: 50)) ));
}).add;

~speed = {Out.kr(~kbus1, MouseX.kr(-0.8, 0.8))}.play;
~direction = {Out.kr(~kbus2, LFClipNoise.kr(1))}.play;
)

(
// s.record;
Pbind(
	\instrument, \fsamp,
	\out, 4,
	\buf, ~h2,
	\rate, Pseq([1, -0.8, 2, 0.5, 1], inf),
	\pos , Pn(Pseries(0,10, ~h2.numFrames)),
	\loop, 0
).play(~t);

Pbind(
	\instrument, \fsamp,
	\out, 5,
	\buf, ~h1,
	\rate, Prand([1, -0.8, 2, 0.5, 1], inf),
	\pos, Pn(Pseries(0, 10, ~h1.numFrames)),
	\loop, 0
).play(~t);
)