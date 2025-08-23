TempoClock.default.tempo = 130/2/60;

Tempo.bpm = 130;
Tempo.bpm

(
~hr = HypoRecorder('take4');
~hr.add([\a1, \a2, \a4, \b1, \delay, \pitch, \hh, \b], 2);
)

~hr.record;
~hr.stop;

s.prepareForRecord;
s.record;

(
Ndef(\a1, { |freq=220, pan=0, gate=1, dur=1, octave=0, amp=0.5|
	var env = EnvGen.kr(Env.asr(0.05, releaseTime: Rand(1, 2.0), curve: \sin), gate: gate, doneAction: 2);
	var sig = Mix.fill(8, { | i |
		SinOscFB.ar((freq/2 *gate) * Pulse.kr(dur * gate) * LFPulse.kr(i**2, 0, Pulse.kr(1+i), dur, i.abs, i.cubed), dur/gate);
	});
	// sig = RLPF.ar(sig, 600, 0.75);
	Pan2.ar(sig * env * 0.07);
}).play(out: 0);
)

(
Ndef(\a2, { |freq=110, pan=0, gate=1, dur=1, octave=0, root=0, amp=0.5|
	var env = EnvGen.kr(Env.asr(0.05, releaseTime: dur, curve: \sin), gate: gate, doneAction: 2);
	var gate2 = gate * Pulse.kr(2);
	var sig = LFPulse.ar(freq* dur) + LFTri.kr(SinOsc.kr(dur), gate, LFPulse.kr(freq, 0, 2));
	// sig = RLPF.ar(sig, 600, 0.75);
	Pan2.ar(sig * env * 0.2);
}).play(out: 0);
)
Ndef(\a2).stop(fadeTime:3);

Ndef(\a2)[1] = \xset -> Pdef(\a1play);

Ndef(\a1).xset(\freq, 150);

Ndef(\a1).fadeTime = 0;
Ndef(\a1)[2] = \xset -> Pdef(\a1play).quant_(-1);
Ndef(\a2)[2] = \xset -> Pdef(\a1src).quant_(-1);
Ndef(\a2)[2] = \xset -> nil;

Ndef(\a2)[1] = \xset -> Pdef(\a1src);

Ndef(\a1).stop(fadeTime: 10);
Ndef(\a1).free;

Ndef(\pan, { SinOsc.kr(1) });
Ndef(\pan).stop;
Ndef(\a1).set(\pan, Ndef(\a1));

Ndef(\pitch).play;
(
Ndef(\pitch)[1] = \mix -> {Ndef(\a1)};
Ndef(\pitch)[2] = \mix -> {Ndef(\b)};
Ndef(\pitch)[3] = \mix -> {Ndef(\a4)};
Ndef(\pitch).set(\mix1, 0.5, \mix2, 0.5, \mix3, 0.5);
Ndef(\pitch)[999] = \filter -> { | in, pd=0.3, td=0.5 | PitchShift.ar(in, pitchDispersion: pd, timeDispersion: td) };
)
Ndef(\pitch).stop(fadeTime:2);

Ndef(\lfo, { SinOsc.kr(1, add: LFSaw.kr(1, Ndef(\a1).get(\dur), 0, 1, 300)) });
Ndef(\lfo).release;
Ndef(\a1).xmap(\gate, Ndef(\lfo));
Ndef(\b1).xmap(\octave, Ndef(\lfo));
Ndef(\b1).xmap(\carfreq, Ndef(\lfo));
Ndef(\a1).unmap(\gate, Ndef(\lfo));



Ndef(\lfo).clear;


Ndef(\b1, { |carfreq=1, freq=10| SinOsc.ar(carfreq + freq!2, 2, LFSaw.kr(SinOsc.kr(10000, 0, 200, 10), 0, 0.3, 0),0) * 0.9}).play;
Ndef(\b1).stop(fadeTime: 3);

(
Ndef(\delay, { |in| DelayC.ar(LocalIn.ar, 0.2, 5, 0.3) * 0.3 }).play;
Ndef(\delay).stop(fadeTime: 4);
Ndef(\delay)[1] = \mix -> {Ndef(\hh).ar};
Ndef(\delay)[2] = \mix -> {Ndef(\b).ar};
Ndef(\delay)[3] = \mix -> {Ndef(\pitch).ar};
)
Ndef(\delay)[99] = \filter -> {DelayC.ar(LocalIn.ar,1, 5, 0.1)};
Ndef(\delay).release(fadeTime: 4);



(
Pdef(\ax, Pbind(\dur, Pgeom(0.125, 2, 5), \root, Pseries(0, 1, 6)));
Pdef(\ay, Pchain(Pbind(\degree, Prand([0, 5, 5], inf), \legato, Pseq([0.3, 2.2], inf)), Pdef(\ax)));
Pdef(\az, Pchain(Pbind(\degree, Pseq([0, -2, 5, -7, 8, 9], 1)), Pn(Pdef(\ay))));
Pdef(\a1play, Psym(Pseq([\ax, \ay, Prand([\ax, \ay]), \az, \ay], inf)));
)


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

