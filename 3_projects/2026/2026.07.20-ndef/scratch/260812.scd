(
SynthDef(\scratch,  {
| out=0,  freq=110, amp=0.4,  gate=1 |
var sig,   e1,  e2,  p1;
e1 = EnvGen.kr(Env.circle([0.02,  1.0,  0.02],  [1, 1,  1], \exp), gate);

e1 = e1 * PinkNoise.ar(1!2).range( 0.3, 1 ).lag(0.01);
e2 = EnvGen.kr(Env.adsr(0.03,  0.5, 0.3,  1), gate, doneAction:2);
e2 = e2 * PinkNoise.ar(1!2).range( 0.1, 1.5 ).lag(0.01);
p1 = EnvGen.kr(Env.new([1.2,  1],  [0.25],  \exp),  gate);
freq = freq * p1;
sig = SinOsc.ar([freq, freq*1.01]) * e1
* LFPulse.ar(freq 
  * LFNoise1.ar(1) 
   )  
+ LFTri.ar(freq * 0.25)
* e2 * amp;
sig = [sig, sig * 1.03] * 0.4;
// sig = RHPF.ar(sig,  100, 0.3);
// sig = RLPF.ar(sig,  SinOsc.ar(0.125).range(500, 4500),  0.5);
// Splay.ar(sig);
Out.ar(out,  Splay.ar(sig) * amp);
}).add;
)
~midiInMap.(1, \scratch,   out: Ndef(\ins5).index);

(
~midiInMap.(7,  \pBs, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree[\bass_drums].values[0..1],   
]);
)
(
~midiInMap.(8,  \pBs, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree[\hats].values[0],   
]);
)
