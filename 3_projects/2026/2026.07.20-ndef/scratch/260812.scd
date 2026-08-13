(
SynthDef(\scratch,  {
| out=0,  freq=110, amp=0.4,  gate=1 |
var sig,   e1,  e2;
e1 = EnvGen.kr(Env.circle([0.0,  1.0,  0.3],  [1, 1,  1]), gate);
e2 = EnvGen.kr(Env.adsr(0.01,  0.2, 0.3,  1), gate, doneAction:2);
sig = SinOsc.ar([freq, freq*1.01]) * e1 + LFPulse.ar(freq,  2,  4) * e2;
Out.ar(out,  sig);
}).add;
)
~midiInMap.(1, \scratch,   out: Ndef(\ins1).index);
