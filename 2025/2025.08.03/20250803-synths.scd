(
SynthDef.new(\sineTest, {
	arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, offset, noise=0, ph=1, noiseHz=2;
	var sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) *amp;
	Out.ar(0, Pan2.ar(sig, pan, amp));
}).add
)

(
SynthDef.new(\simpSine, {
  arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, attack = 0.01, release = 1.0, offset = 0;
  var env, sig;
  env = EnvGen.kr(Env.circle([0.1, 0.25, 0.5], [0.15, 0.75]), 1);
  sig = Pulse.ar(freq + LFPulse.kr(16).exprange(200, 1000)) * env * amp;
  Out.ar(out, Pan2.ar(sig, pan, amp));
}).add
)


// Route orbit 0 through myCustomFX
~dirt.orbits[0].effect = \myCustomFX;
