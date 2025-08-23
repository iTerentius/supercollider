TempoClock.default.tempo = 130/60;

Tempo.bpm = 60;

(TempoClock.default.tempo * 60).postln;

~t1 = Bus.audio(s, 2);
~t2 = Bus.audio(s, 2);
~t3 = Bus.audio(s, 2);

(
Ndef(\a1, { |freq=110, pan=0, gate=1, dur=1 |
	var env = EnvGen.kr(Env.asr(0.01, releaseTime: Rand(1, 2.0), curve: \sin), gate: gate, doneAction: 2);
	var sig = Mix.fill(8, { | i |
		LFPulse.ar(freq/dur + 1 * gate + Impulse.kr(1, Pulse.kr(1), dur, i, i.squared), dur);
	});
	// sig = RHPF.ar(sig, 300, 0.75);
	Pan2.ar(sig * env * 0.05, pos: pan);
}).play(out: 0);
)
Ndef(\a1)[1] = \xset -> Pdef(\a1);

Ndef(\a1).gui;
Ndef(\a1).stop(fadeTime: 3);
Ndef(\a1).free;

Ndef(\pan, { SinOsc.kr(1) });
Ndef(\pan).stop;
Ndef(\a1).set(\pan, Ndef(\a1));

Ndef(\pitch).play;
Ndef(\pitch)[1] = \mix -> {Ndef(\a1)};
Ndef(\pitch).set(\mix, 0.5);
Ndef(\a1)[999] = \filter -> { | in, pd=0.3, td=0.5 | PitchShift.ar(in, pitchDispersion: pd, timeDispersion: td) };
Ndef(\a1).set(\wet999, 0.5);
Ndef(\pitch).free;

Ndef(\lfo, { SinOsc.kr(1) });
Ndef(\a1).xset(\pan, Ndef(\lfo));
Ndef(\b1).map(\freq, Ndef(\lfo));
Ndef(\b1).map(\carfreq, Ndef(\lfo) * 10);

Ndef(\a1).play;

Ndef(\b1, { |carfreq=100, freq=200| SinOsc.ar(carfreq + freq!2, 2, LFSaw.kr(SinOsc.kr(10000, 0, 200, 10), 0, 0.3, 0),0) * 0.7}).play;
Ndef(\b1).stop(fadeTime: 3);


Ndef(\delay, { DelayN.ar(Ndef(\b1),0.2, 1, 0.3) * 0.2 }).play;
Ndef(\delay).stop(fadeTime: 4);
Ndef(\delay)[1] = \filter -> {DelayC.ar(Ndef(\a1),2)};
Ndef(\delay).release;



(
Pdef(\a1midi, Pbind(\type, \midi, \midiout, m, \midicmd, \noteOn, \chan, 0,));
Pdef(\a1synth, Pbind(\out, Pfunc(Ndef(\a1).bus.index), \group, Pfunc(Ndef(\a1).group)));
Pdef(\a1src,
	Pbind(
		\degree, Prand([ Pseq([0,2,3,5,7],4), Pseq([-2, -5, 5, 0], 8) ], inf),
		\octave, Pshuf([-1,1,2],inf),
		\pan, Pwhite(-0.75, 0.75),
		// \dur, Pseq([Pbjorklund2(Pseq([0.125, 0.25, 0.125], inf), 5, 7), Rest(2)], inf),
		// \dur, Pseq([Pseq([0.125, 0.25, 0.5, 0.75, 1], 3), Pseq([Rest(2), Rest(4)], 8)], inf),
		\dur, Pseq([0.125, 0.25, Rest(0.5), 0.5, 0.25], inf),
		\amp, Pwhite(0.2, 0.3, inf)
));
)

(
Pdef(\a1, 	Ppar([
		Pdef(\a1midi),
		Pdef(\a1synth),
	])
	<> PtimeClutch(Pdef(\a1src))
);
)

(
~ndefrec = NdefRecorder();
~ndefrec.add([\a1, \b1, \delay, \pitch]);
)

~ndefrec.record;
~ndefrec.stop;