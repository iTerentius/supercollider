Tempo.bpm = 60;
(
SynthDef(\a4,
	{ | out=0, freq = 220, ffreq=10, fmul = 0.2, amp=0.5, gate=1, dur=1 |
		var sig;
		var env;
		env = EnvGen.kr(Env.asr, gate, 0.5, 0.5, 0.25, 2);
		sig = LFSaw.ar([freq/dur - fmul, ffreq/dur + fmul - dur], 0, fmul) * LFSaw.kr(ffreq) * amp * env;
		OffsetOut.ar(out, sig);
}).add;
)
Ndef(\lfo2, { LFPulse.kr(1, LFNoise0.kr(10, 1) ) });

Ndef(\a4).set(\gate, Ndef(\lfo2));
Ndef(\a4).unset(\freq, Ndef(\lfo2));

Ndef(\a4)[10] = \filter -> { | in | Decay.ar(in, 4, 0.05) };
Ndef(\a4).set(\wet10, 0.01);
Ndef(\a4)[20] = nil;
Ndef(\a4)[20] = \filter -> { | in | Ringz.ar(in, mul: 0.01) };
Ndef(\a4).map(\wet20, 0.6);
Ndef(\a4).release(fadeTime: 10);
Tempo.bpm = 130;


Ndef(\lfo3, { LFPulse.kr(1, 0, width: Line.kr(0, 1, 10, 10, 0, 0).asStream, mul: 1, add: 0).range(0, 1) });

Ndef(\a4).set(\fmul, Ndef(\lfo3));
Ndef(\i1).unset(\gate, Ndef(\lfo3));

(
Ndef(\a4).play;
Pdef(\a4,
	Pbind(
		\instrument, \a4,
		\ctranspose, 0,
		\out, Pfunc(Ndef(\a4).bus.index),
		\group, Pfunc(Ndef(\a4).group),
		\degree, Pseq([0,2,4,5,-7], inf),
		\dur, Prand([0.125, 0.25, 0.5, 1, Rest(4)], inf),
		\legato, Pseq([0.2, 0.5, 0.125, Rest(5)], inf),
		// \recordTarget, ~hr,
		// \chan, 6,
		\amp, 0.2,
	)
);
)

Pdef(\a4).play(quant: -1);
Ndef(\a4)[1] = \xset -> Pdef(\a4);
Ndef(\a4)[1] = \xset -> nil;