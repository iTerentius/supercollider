
~l = LinkClock.newFromTempoClock(TempoClock.default);
~l.latency = Server.default.latency;
~l.tempo = 1;


/*(
// ~hr = HypoRecorder();
~bw = Bitwig("localhost", 7772, ~l);
~bw.add([\i1]);
)

~bw.record;
~bw.stop;*/

(
SynthDef(\i1, { | out=0, freq=220, gate=1 |
	var sig, env, freq2;
	freq2 = freq +5;
	env = EnvGen.kr(Env.asr(), gate: gate, doneAction:2);
	sig = SinOsc.ar(freq + LFPulse.kr([freq, freq2], 0, 2)) * SinOsc.ar(Dust2.kr(220, add:freq), 0.5, 2) * LFPulse.kr(10, width:Line.kr(0, 1));
	OffsetOut.ar(out, sig * env * 0.1);
}).add;

)

(
Ndef(\i1).play;
Pdef(\i1,
	Pbind(
		\type, \composite,
		\types, [\note, \midi],
		\midiout, m,
		\instrument, \i1,
		\out, Pfunc(Ndef(\i1).bus.index),
		\group, Pfunc(Ndef(\i1).group),
		\octave, Pseq([3,4,5], inf),
		\scale, Scale.minor,
		\degree, Prand([1,2,4,-5,7], inf),
		// \dur, Pseq([0.15, 0.25, 0.35, Rest(1)], inf),
		\dur, 0.25,
		\midirec, ~hr,
		\chan, 0
	)
);
)

Pdef(\i1).play(~l, quant: -1);
Pdef(\i1).clear;


