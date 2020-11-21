(
Ndef(\a4,
	{ | freq = 220, ffreq=10, fmul = 0.2, amp=0.5, gate=1, dur=1 |
		var sig;
		var env;
		env = EnvGen.kr(Env.asr, gate, 0.5, 0.5, 0.25, 2);
		sig = SinOsc.ar([freq/dur - fmul, ffreq/dur + fmul - dur], 0, fmul) * LFSaw.kr(ffreq) * amp * 0.3 * env}).play(fadeTime: 10);
)
Ndef(\lfo2, { LFPulse.kr(1, LFNoise0.kr(10, 1), 100, 40) });

Ndef(\a4).set(\ffreq, Ndef(\lfo2));
Ndef(\a4).unset(\fmul, Ndef(\lfo2));

Ndef(\a4)[10] = \filter -> { | in | Decay.ar(in, 12, 0.1) };
Ndef(\a4).set(\wet10, 0.05);
Ndef(\a4)[20] = \filter -> { | in | Delay1.ar(in) };
Ndef(\a4).set(\wet10, 0.2);
Ndef(\a4).stop(fadeTime: 10);
Tempo.bpm = 130;


Ndef(\lfo3, { LFPulse.kr(20, 0, width: Line.kr(0, 1, 10, 10, 0, 0).asStream, mul: 1, add: 0) });

Ndef(\a4).set(\fmul, Ndef(\lfo3));

(
Pdef(\a4,
	Pbind(
		\ctranspose, 0,
		\degree, Pseq([0,2,4,5,-7], inf),
		\dur, Prand([0.125, 0.25, 0.5, Rest(4)], inf),
		\amp, 0.6,
		\legato, Pseq([0.2, 0.5, 0.125], inf),
		// \recordTarget, ~hr,
		// \chan, 6
	)
);
)
Ndef(\a4)[1] = \xset -> Pdef(\a4);