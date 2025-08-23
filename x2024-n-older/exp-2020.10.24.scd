Ndef(\a2, {LFSaw.ar(110, 0, SinOsc.kr(LFPulse.kr(550, 0.5, 1)), 0, 0.5).dup * 0.1});
Ndef(\a2).stop;

Ndef(\b2, {SinOsc.ar(110!2 * LFSaw.kr(SinOsc.kr(100, 0.5, 300))) * 0.5}).play;
Ndef(\b2).stop;


Ndef(\delay2, { DelayN.ar(Ndef(\b1),0.2, 1).dup }).play;
Ndef(\delay2)[1] = \mix -> {Pan2.ar(Ndef(\a1).ar)};
Ndef(\delay2).stop;