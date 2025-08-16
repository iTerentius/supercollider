(
SynthDef.new(\sineosc, {
	arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, offset, noise=0, ph=1, noiseHz=8;
	var sig;
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, Pan2.ar(sig, pan));
}).add
)