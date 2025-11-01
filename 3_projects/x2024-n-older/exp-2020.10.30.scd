TempoClock.default.tempo = 220/60;

TempoClock.default.tempo.postln;

~t1 = Bus.audio(s, 2);
~t2 = Bus.audio(s, 2);
~t3 = Bus.audio(s, 2);

(
Ndef(\a1, { |freq, t_trig=0, t_gate=1, pan=0 |
	var env = EnvGen.kr(Env.asr(0.01, releaseTime: Rand(1, 2.0)), doneAction: 2);
	var sig = Mix.fill(8, {LFPulse.ar(freq, Dust2.kr(0.5, 1), LFSaw.kr(Rand(1,5)), LFSaw.kr(LFPulse.kr(1, 0.5, 1)), 0) });
	Out.ar(2,Pan2.ar(sig * env * 0.125, pan));
});
)

Ndef(\a1)[1] = \xset -> Pdef(\a1);

Ndef(\a1).play(out: 4);

Ndef(\b1, {SinOsc.ar(1000 * LFSaw.kr(SinOsc.kr(1, 0, 20, 10), 0, 0.1, 0)!2) * 0.2});
Ndef(\b1).play(out: 4);
Ndef(\b1).stop(fadeTime: 3);


Ndef(\delay, { Out.ar(6, DelayN.ar(Ndef(\b1),0.2, 1, 0.3)) * 0.2 }).play;
Ndef(\delay)[1] = \mix -> {Ndef(\a1)};
Ndef(\delay).release;



(
Pdef(\a1midi, Pbind(\type, \midi, \midiout, m, \midicmd, \noteOn, \chan, 0,));
Pdef(\a1synth, Pbind(\out, Pfunc(Ndef(\a1).bus.index), \group, Pfunc(Ndef(\a1).group)));
Pdef(\a1src,
	Pbind(
		\degree, Pseq([1,4,5,7], inf),
		\octave, Pshuf([2,3,4],inf),
		\pan, Pseq([-0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75], inf),
		// \dur, Pseq([Pbjorklund2(Pseq([1, 2, 3], inf), 5, 7), Rest(2)], inf),
		\dur, Pseq([Pseq([0.125, 0.25, 0.5, 0.75, 1], 3), Pseq([Rest(4), Rest(8)], 8)], inf),
		\amp, 0.3
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

~rec = Reaper("192.168.1.132", 7772);
~rec.add([\a1, \b1, \delay]);
~rec.record;
~rec.stop;


(
~ndefrec = NdefRecorder();
~ndefrec.add([\a1, \b1, \delay]);
)

~ndefrec.record;