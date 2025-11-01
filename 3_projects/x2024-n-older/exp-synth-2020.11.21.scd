
~hr = HypoRecorder();
~hr.add([\r1, \il, \hh, \b], 3);
~hr.record;
~hr.stop;


~roll = Array.new;
// ~folder = PathName.new("/home/hypostatic/Music/samples/_MM - Field Recordings/roll_door_2");
~folder = PathName.new("/home/hypostatic/Music/supercollider/_samples/Hoarder/hoarder");

(
~folder.entries.do({ | path |
	~roll = ~roll.add(Buffer.read(s, path.fullPath));
});
)

(
Ndef(\r1, { | amp=1, out=0, buf, rate=1, start=0, da=2, chan=1 |
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: start, loop: 1, doneAction: da);
	sig = [sig.abs, sig] * amp;
	Out.ar(out, sig);
})
)

Ndef(\r1).set(\buf, ~roll[3], \rate, Ndef(\rlfo), \start);

Ndef(\rlfo, { SinOsc.kr(LFNoise2.kr(Impulse.kr(0.5, 0, 2 ,10))).range(-1, 1); });

Ndef(\r1).clear(fadeTime: 5);

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
		\chan, 3
	)
);
)

Ndef(\il).play;

Pdef(\i1).play(quant: -1);
Pdef(\i1).clear;


(
Ndef(\hh).play;

Pdef(\hh,
	Pbind(
		\type, \composite,
		\types, [\midi, \note],
		\midiout, m,
		\instrument, \bplay,
		\out, Pfunc(Ndef(\hh).bus.index),
		\group, Pfunc(Ndef(\hh).group),
		\buf, d["Hats"][3],
		\midirec, ~hr,
		// \dur, Place(Pseq([0.125, 0.125, 0.5, 0.75, 0.25], inf), Pwhite(0, 1.0, inf)),
		// \dur, 0.125,
		\midinote, 60,
		\dur, Pbjorklund2(3, Pshuf([3,5,7], inf), inf)/4,
		\chan, 0,
		\amp, Prand([0.1, 0.2, 0.05, Rest(2)], inf),
		\amp, 0.1
));
)

Pdef(\hh).play(quant: -1);
Pdef(\hh).stop;

(
Ndef(\b).play;
Pdef(\b,
	Pbind(
		\type, \composite,
		\types, [\midi, \note],
		\midiout, m,
		\out, Pfunc(Ndef(\b).bus.index),
		\group, Pfunc(Ndef(\b).group),
		\instrument, \bplay,
		\buf, d["Bass Drums"][5],
		\dur, Pn(Pshuf([0.125, 0.25, 0.5, 1], 4), inf),
		\dur, Pshuf([0.5, 0.25, 1], inf),
		// \dur, 0.0625,
		\midirec, ~hr,
		\midinote, 30,
		\amp, Pseq([0.1, 0.2, 0.07, Rest(4)], inf),
		\chan, 1,
		// \amp, 0.1,
));
)
Pdef(\b).play(quant: -1);
Pdef(\b).stop(fadeTime: 10);

Task.


~hr = HypoRecorder();
~hr.add([\hh, \b], 2);

~hr.record;
~hr.stop;
