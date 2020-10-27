Ndef(\a1, {LFSaw.ar(210 * SinOsc.kr(10, 0, LFSaw.kr(1000, 0, 1000)))!2});
Ndef(\a1).stop;

Ndef(\b1, {SinOsc.ar(110 * LFSaw.kr(SinOsc.kr(10, 0.5, 300)))!2}).play;
Ndef(\b1).stop;

Ndef(\delay, { DelayN.ar(Ndef(\b1),0.2, 1) }).play;
Ndef(\delay)[10] = \mix -> Ndef(\a1);
Ndef(\delay).stop;


(
~ndefrec = NdefRecorder();
~ndefrec.add([\a1, \b1, \delay]);
)

~ndefrec.record;