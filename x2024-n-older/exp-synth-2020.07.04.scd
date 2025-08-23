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
				FreeVerb.ar(In.ar(~ab1), MouseX.kr(-1,1)),
				FreeVerb.ar(In.ar(~ab2), MouseX.kr(0.5,-0.5)),
	], center: MouseX.kr(-0.5, 0.5) ))}.play;
}).add;

/*b.sendMsg("/tempo/raw", 60);
b.sendMsg("/track/1/recarm", 1);
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/3/recarm", 1);
b.sendMsg("/time", 0);
b.sendMsg("/restart", 1);
b.sendMsg("/record", 1);*/


y = SynthDef(\hpulse, { | freqs=10, out=0, control=0 |
	var ampOsc;
	ampOsc = LFPulse.kr(MouseY.kr(0, 1), 0, MouseX.kr(0, 1), mul: 0.2);
	Out.ar([out, out], (Pulse.ar(freqs, mul:0.3) * SinOscFB.ar(In.kr(control).range(20, 1), 1.5, ampOsc/2)));
}).add;

~x = Pbind(
	\instrument, \hpulse,
	\out, [~ab1, ~ab2],
	\control, ~kb1,
	\freqs, Pseq([1, 50, 10, 50, (Rest(3)), 100], inf)

).play();

)

v.free; y.free; ~x.free; ~ab1.free; ~ab2.free; ~fverb.free; ~freq.free; ~kb1.free;

s.stopRecording;

