Ndef(\a4, { | freq = 110, ffreq=10, fmul = 0.2| LFSaw.ar([freq, freq*2], 0, fmul) * SinOsc.kr(ffreq) * 0.2}).play;

Ndef(\lfo2, { SinOsc.kr(2, LFNoise0.kr(200, 0, 10, Ndef(\b).kr), 10, 0.3, 1) });

Ndef(\a4).set(\ffreq, Ndef(\lfo2));
Ndef(\a4).unset(\fmul, Ndef(\lfo2));

Ndef(\a4)[10] = \filter -> { | in | Decay.ar(in, Ndef(\a4).get(\ffreq), 0.2) };
Ndef(\a4).set(\wet10, 0.04);
Ndef(\a4)[20] = \filter -> { | in | Delay1.ar(in) };
Ndef(\a4).set(\wet20, 0.2);

Tempo.bpm = 130;
	