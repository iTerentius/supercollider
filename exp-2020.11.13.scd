(
Ndef(\a4,
	{ | freq = 110, ffreq=10, fmul = 0.2, amp=0.5, gate=1, dur=1 |
		var sig;
		var env;
		env = EnvGen.kr(Env.asr, gate, 1, 0, 1, 2);
		sig = SinOsc.ar([freq/dur, freq*2], 0, fmul) * SinOsc.kr(ffreq) * amp * 0.3 * env}).play(fadeTime: 10);
)
Ndef(\lfo2, { LFTri.kr(2, LFNoise0.kr(200, 0, 10, Ndef(\b).kr), 10, 0.3, 1) });

Ndef(\a4).set(\ffreq, Ndef(\lfo2));
Ndef(\a4).unset(\fmul, Ndef(\lfo2));

Ndef(\a4)[10] = \filter -> { | in | Decay.ar(in, 12, 0.2) };
Ndef(\a4).set(\wet10, 0.5);
Ndef(\a4)[20] = \filter -> { | in | Delay1.ar(in) };
Ndef(\a4).set(\wet20, 0.2);
Ndef(\a4).stop(fadeTime: 10);
Tempo.bpm = 130;


Ndef(\lfo3, { LFPulse.kr(10, 1, 1).range(0.0, 1.0) });

Ndef(\a4).set(\fmul, Ndef(\lfo3));

(
Pdef(\a4,
	Pbind(
		\ctranspose, 0,
		\degree, Pseq([0,2,4,5,7], inf),
		\dur, Prand([0.125, 1, 0.5, Rest(4)], inf),
		\amp, 0.2,
		\legato, Pseq([0.2, 0.5, 0.125], inf),
	)
);
)
Ndef(\a4)[1] = \xset -> Pdef(\a4);