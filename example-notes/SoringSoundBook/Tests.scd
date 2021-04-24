// using only one Dust UGen to trigger all the filters:
(
{
	var trigger, freq;
	trigger = Dust.ar(3, 0.3);
	freq = 440;
	Ringz.ar(trigger, 440, 2, 0.3) +
	Ringz.ar(trigger, freq*2, 2, 0.3)
	+
	Ringz.ar(trigger, freq*3, 2, 0.3) !2
}.play
)
// but there is a better way:
// Klank is a bank of resonators like Ringz, but the frequency is fixed. (there is DynKlank)
{ Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], Impulse.ar(MouseX.kr(0, 10), 0, 0.1)) }.play;
// whitenoise input
{ Klank.ar(`[[440, 980, 1220, 1560], nil, [2, 2, 2, 2]], WhiteNoise.ar(0.005)) }.play;
// AudioIn input
{ Klank.ar(`[[220, 440, 980, 1220], nil, [1, 1, 1, 1]], Meta_AudioIn.ar([1])*0.001) }.play;
Let’s explore the DynKlank UGen. It does the same as Klank, but it allows us to change the values after
the synth has been instantiated.
{ DynKlank.ar(`[[800, 1071, 1353, 1723], nil, [1, 1, 1, 1]], Dust.ar(8, 0.1)) }.play;
{ DynKlank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007])) }.play;
{ DynKlank.ar(`[[200, 671, 1153, 1723]*XLine.ar(1, [1.2, 1.1, 1.3, 1.43], 5), nil, [1, 1, 1\
	, 1]], PinkNoise.ar([0.007,0.007])) }.play;
SynthDef(\dynklanks, {arg freqs = #[200, 671, 1153, 1723];
	Out.ar(0,
		DynKlank.ar(`[freqs, nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007]))
	)
}).add
a = Synth(\dynklanks)
a.set(\freqs, [333, 444, 555, 666])
a.set(\freqs, [333, 444, 555, 666].rand)

(
SynthDef(\warble, { | out=0, freq = 110, gate=1, amp=0.3 |
	var e;
	e = EnvGen.ar(Env.perc, gate, doneAction: 2);
	Out.ar(0, Splay.ar(SinOsc.ar([freq * PinkNoise.kr(1), freq + PinkNoise.kr(1.5)])) * e * amp);
}).add;
)
(
Pdef(\w, {
	Pbind(
		\instrument, \warble,
		\scale, Scale.major,
		\degree, Pseq([0,1,2,3,4,5,6,7],inf),
		\dur, Pbjorklund2(3, 7, inf)/8,
		\amp, 0.3,
)};
)
)

Pdef(\w).play;

Ndef(\warble)[1] = \set -> Pdef(\w).play;

{ Crackle.ar(XLine.kr(0.99, 2, 10), 0.4) }.freqscope.scope;

{ LFDNoise0.ar(XLine.kr(1000, 20000, 10), 0.1) }.freqscope.scope;
{ LFClipNoise.ar(XLine.kr(1000, 20000, 10), 0.1) }.freqscope.scope;
// Impulse
{ Impulse.ar(80, 0.7) }.play

{ Impulse.ar(4, 0.7) }.play
// Dust (random impulses)
{ Dust.ar(80) }.play
{ Dust.ar(4) }.play

(
{
var signal;
var delaytime = MouseX.kr(0.000022675, 0.001); // from a sample
signal = Saw.ar(220, 0.5);
d = DelayC.ar(signal, 0.6, delaytime);
(signal + d).dup
}.play
)

// low pass filter
{LPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1)!2) }.play;
// low pass filter with XLine
{LPF.ar(WhiteNoise.ar(0.4), XLine.kr(40,20000, 3, doneAction:2)!2) }.play;
// high pass filter
{HPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1)!2) }.play;
// band pass filter (the Q is controlled by the MouseY)
{BPF.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1), MouseY.kr(0.01,1)!2) }.play;
// Mid EQ filter attenuates or boosts a frequency band
{MidEQ.ar(WhiteNoise.ar(0.024), MouseX.kr(40,20000,1), MouseY.kr(0.01,1), 24)!2 }.play;
// what's happening here?
(
{
var signal = MidEQ.ar(WhiteNoise.ar(0.4), MouseX.kr(40,20000,1), MouseY.kr(0.01,1), 24);
BPF.ar(signal, MouseX.kr(40,20000,1), MouseY.kr(0.01,1)) !2
}.play;
)


// resonant filter
{ Resonz.ar(WhiteNoise.ar(0.5), MouseX.kr(40,20000,1), 0.1)!2 }.play
// a short impulse won't resonate
{ Resonz.ar(Dust.ar(0.5), 2000, 0.1) }.play
// for that we use Ringz
{ Ringz.ar(Dust.ar(2, 0.6), MouseX.kr(200,6000,1), 2) }.play
// X is frequency and Y is ring time
{ Ringz.ar(Impulse.ar(4, 0, 0.3), MouseX.kr(200,6000,1), MouseY.kr(0.04,6,1)) }.play
{ Ringz.ar(Impulse.ar(LFNoise2.ar(2).range(0.5, 4), 0, 0.3), LFNoise2.ar(2).range(0.04,6,1)) }.play
LFNoise2.ar(0.1).range(200,30\
{ Mix.fill(10, {Ringz.ar(Impulse.ar(LFNoise2.ar(rrand(0.1, 1)).range(0.5, 1), 0, 0.1),
oise2.ar(0.1).range(200,12000), LFNoise2.ar(2).range(0.04,6,1)) })}.play
LFN\
{ Formlet.ar(Impulse.ar(4, 0.9), MouseX.kr(300,2000), 0.006, 0.1) }.play;
{ Formlet.ar(LFNoise0.ar(4, 0.2), MouseX.kr(300,2000), 0.006, 0.1) }.play;