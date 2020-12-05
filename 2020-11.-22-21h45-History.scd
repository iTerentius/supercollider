///////////////////////////////////////////////////
// History, as it was on Sun Nov 22 21:45:07 2020.
///////////////////////////////////////////////////

// - 0:0:0.0 -
4

// - 0:0:12.93 -
(
Ndef(\a4,
	{ | freq = 220, ffreq=10, fmul = 0.2, amp=0.5, gate=1, dur=1 |
		var sig;
		var env;
		env = EnvGen.kr(Env.asr, gate, 0.5, 0.5, 0.25, 2);
		sig = SinOsc.ar([freq/dur - fmul, ffreq/dur + fmul - dur], 0, fmul) * LFSaw.kr(ffreq) * amp * 0.3 * env}).play(fadeTime: 10);
)

// - 0:0:30.43 -
Ndef(\lfo2, { LFPulse.kr(1, LFNoise0.kr(10, 1) ) });

// - 0:0:31.97 -
Ndef(\a4).set(\freq, Ndef(\lfo2));

// - 0:0:36.22 -
(
Pdef(\a4,
	Pbind(
		\ctranspose, 0,
		\degree, Pseq([0,2,4,5,-7], inf),
		\dur, Prand([0.125, 0.25, 0.5, Rest(4)], inf),
		\amp, 0.6,
		\legato, Pseq([0.2, 0.5, 0.125], inf),
		\recordTarget, ~hr,
		\chan, 6
	)
);
)

// - 0:0:38.06 -
Ndef(\a4)[1] = \xset -> Pdef(\a4);

// - 0:0:47.36 -
Ndef(\a4)[1] = \xset -> nil;

// - 0:0:53.66 -
Ndef(\lfo3, { LFPulse.kr(2, 0, width: Line.kr(0, 1, 10, 10, 0, 0).asStream, mul: 1, add: 0).range(0, 1) });

// - 0:0:54.76 -
Ndef(\a4).set(\fmul, Ndef(\lfo3));

// - 0:0:58.56 -
Ndef(\i1).set(\gate, Ndef(\lfo3));

// - 0:1:34.27 -
Ndef(\pitch).play;

// - 0:1:35.45 -
(
Ndef(\pitch)[1] = \mix -> {Ndef(\a1)};
Ndef(\pitch)[2] = \mix -> {Ndef(\b)};
Ndef(\pitch)[3] = \mix -> {Ndef(\a4)};
Ndef(\pitch).set(\mix1, 0.5, \mix2, 0.5, \mix3, 0.5);
Ndef(\pitch)[999] = \filter -> { | in, pd=0.3, td=0.5 | PitchShift.ar(in, pitchDispersion: pd, timeDispersion: td) };
)

// - 0:1:50.54 -
(
Ndef(\pitch)[1] = \mix -> {Ndef(\i1)};
Ndef(\pitch)[2] = \mix -> {Ndef(\b)};
Ndef(\pitch)[3] = \mix -> {Ndef(\a4)};
Ndef(\pitch).set(\mix1, 0.5, \mix2, 0.5, \mix3, 0.5);
Ndef(\pitch)[999] = \filter -> { | in, pd=0.3, td=0.5 | PitchShift.ar(in, pitchDispersion: pd, timeDispersion: td) };
)

// - 0:2:4.89 -
Ndef(\pan, { SinOsc.kr(1) });

// - 0:2:11.61 -
Ndef(\a4).set(\pan, Ndef(\a1));

// - 0:2:19.95 -
Ndef(\i1).set(\pan, Ndef(\a1));

// - 0:2:31.13 -
(
Ndef(\delay, { |in| DelayC.ar(LocalIn.ar, 0.2, 5, 0.3) * 0.3 }).play;
Ndef(\delay).stop(fadeTime: 4);
Ndef(\delay)[1] = \mix -> {Ndef(\hh).ar};
Ndef(\delay)[2] = \mix -> {Ndef(\b).ar};
Ndef(\delay)[3] = \mix -> {Ndef(\pitch).ar};
)

// - 0:2:42.74 -
(
Ndef(\delay, { |in| DelayC.ar(LocalIn.ar, 0.2, 5, 0.3) * 0.3 }).play;
Ndef(\delay).stop(fadeTime: 4);
Ndef(\delay)[1] = \mix -> {Ndef(\i1).ar};
Ndef(\delay)[2] = \mix -> {Ndef(\b).ar};
Ndef(\delay)[3] = \mix -> {Ndef(\pitch).ar};
)

// - 0:3:9.27 -
Ndef(\b1, { |carfreq=1, freq=10| SinOsc.ar(carfreq + freq!2, 2, LFSaw.kr(SinOsc.kr(10000, 0, 200, 10), 0, 0.3, 0),0) * 1}).play(fadeTime:10);

// - 0:3:29.87 -
Ndef(\lfo, { LFPulse.kr(1, 1, 10, LFSaw.kr(2, 1, 10, 100).range(0, 1))});

// - 0:3:32.53 -
Ndef(\b1).xmap(\octave, Ndef(\lfo));

// - 0:3:35.59 -
Ndef(\b1).xmap(\carfreq, Ndef(\lfo));

// - 0:3:47.26 -
Ndef(\a4).unmap(\gate, Ndef(\lfo));

// - 0:4:0.93 -
(
Pdef(\a1src,
		Pbind(
		\ctranspose, -36,
		\degree, Prand([ Pseq([0,2,3,5,7], inf), Pseq([-2, -5, 5, 0], 8) ], inf),
		\pan, Pwhite(-0.75, 0.75),
		// \dur, Pseq([Pbjorklund2(Pseq([0.125, 0.25, 0.125], inf), 5, 7), Rest(2)], inf),
		// \dur, Pseq([Pseq([0.125, 0.25, 0.5, 0.75, 1], 3), Pseq([Rest(2), Rest(4)], 8)], inf),
		\dur, Pseq([0.125, 0.25, Rest(0.5), 0.5, 0.25, Rest(3)], inf),
		// \amp, Pwhite(0.2, 0.3, inf),
));
)

// - 0:4:50.27 -
Ndef(\b1)[1] = \xset -> Pdef(\b1);

// - 0:4:58.49 -
Ndef(\b1)[1] = \xset -> Pdef(\a1src);

// - 0:5:28.55 -
Ndef(\b1)[1] = \xset -> Pdef(\i1);

// - 0:5:36.06 -
Ndef(\b1)[1] = \xset -> Pdef(\a4);

// - 0:6:0.0 -
Ndef(\b1)[1] = \xset -> Pdef(\b);

// - 0:6:7.38 -
Ndef(\b1)[1] = \xset -> Pdef(\i1);

// - 0:6:34.1 -
Ndef(\lfo3, { LFPulse.kr(2, 0, width: Line.kr(0, 1, 10, 10, 0, 0).asStream, mul: 1, add: 0).range(0, 1) });

// - 0:6:36.5 -
Ndef(\i1).set(\gate, Ndef(\lfo3));

// - 0:6:40.7 -
Ndef(\lfo3, { LFPulse.kr(200, 0, width: Line.kr(0, 1, 10, 10, 0, 0).asStream, mul: 1, add: 0).range(0, 1) });

// - 0:7:0.22 -
Ndef(\a4).release(fadeTime: 10);

// - 0:7:17.72 -
Ndef(\delay).release(fadeTime: 4);

// - 0:7:23.46 -
Ndef(\pitch).stop(fadeTime:5);

// - 0:7:36.48 -
Ndef(\pitch).free(fadeTime:5);

// - 0:7:58.7 -
Ndef(\a4)[1] = \xset -> nil;

// - 0:8:4.87 -
Ndef(\a4).release(fadeTime: 10);

// - 0:9:12.78 -
Pdef(\i1).free;

// - 0:9:31.97 -
Ndef(\b1).stop(fadeTime: 20);

