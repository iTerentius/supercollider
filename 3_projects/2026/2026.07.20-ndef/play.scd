
Ndef(\impact).pause;
Ndef(\impact).resume;
Ndef(\impact).clear;

Ndef(\hh1).pause;
Ndef(\hh1).resume;
Ndef(\hh1).clear;

Ndef(\kk1).pause;
Ndef(\kk1).resume;
Ndef(\kk1).clear;

Ndef(\kitA).pause;
Ndef(\kitA).resume;
Ndef(\kitA).clear;

Ndef(\ins1)[0] = { | amp=1 | Ndef.ar(\kitA, 2) * amp };

Ndef(\lfo1, {LFPulse.ar(1.5) + SinOsc.ar(1)});

// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
(
Ndef(\kitA).set(
  \delayTime,  0.25, 
  \size,  0.8, 
  \damp,  0.1,  
  \diff,  0.5,  
  \feedback, 0.5,  
  \modDepth,  0.5,  
  \modFreq, 2.0
);
)

~apcBindParam.(\b0_ds1_k1, { |x| Ndef(\fxsBitcrush).set(\wet4,  x)});
Ndef(\kitA).map(\modFreq,  { 1/ Ndef(\lfo1,  1).max(0.1) });
Ndef(\kitA).map(\size,  Ndef(\lfo1));
Ndef(\kitA).map(\diff,  Ndef(\lfo1));

Ndef(\impact).set(\rate, -1); 
Ndef(\hh1).set(\rate, 1); 
Ndef(\kk1).set(\rate, 2); 
Ndef(\kk1).unmap(\rate, { Ndef.ar(\brate,  1) });
(
Ndef(\kk1)[1] = \pset -> Pbind(
  \dur,  1/2, 
  \rate,  Pseq((-2..2),  inf), 
  \stretch, Pseq([1/4!3,   3.25].flat,   inf),  
);
)
Ndef(\kk1)[1] = nil;

Ndef(\kitA).set(\wet7, 0.0);

Ndef(\fxsBitcrush).set(\brate, 14000, \bits, 8, \mix, 1);
~fxSetSend.(\ins1,  \s1,  0.0);
~fxSetSend.(\ins2,  \s1,  1.0);
~fxSetSend.(\ins3,  \s1,  0.9);
Ndef(\brate,   { SinOsc.ar(0.5) });
Ndef(\fxsBitcrush).unmap(\brate, { Ndef.kr(\brate, 1).range(10, 100) });
