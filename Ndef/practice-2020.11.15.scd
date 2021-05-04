(
Ndef(\synth, { | out=0, freq=440, dur=1, gate=1, amp=0.6 |
	var sig, ef1;
	ef1 = EnvGen.kr(Env([220, 120, 60, 0], [0.5, 0.5, 0.75, 0.78, 1], \sine), gate: gate, doneAction: 2);
	sig = LFTri.ar(SinOsc.kr(freq) *LFPulse.kr(50 * freq) * ef1);
	Out.ar(\out.ar(0), sig!2 * ef1 * 0.002 * amp);
});
)
Ndef(\synth).play;
Ndef(\synth).clear;

(
Ndef(\synth1, { | freq=440, dur=1 |
	var sig, env;
	sig = SinOsc.ar(Pulse.kr(freq));
	Out.ar(\out.ar(0), sig!2 * 0.2);
}).play;
)


Ndef(\synth1)[1] = \xset -> Pdef(\s1).quant_(-1);
Ndef(\synth)[1] = \xset -> Pdef(\s1).quant_(1);


Ndef(\synthlfo, { LFPulse.kr(1, width:5) });

Ndef(\synth).xmap(\amp, Ndef(\synthlfo));

(
Pdef(\s1,
	Pbind(
		\out, (Ndef(\synth).bus.index);
		\group, (Ndef(\synth).group);
		\freq, Ppatlace([Pseq([60, 110, 20, 30], inf), Pseq([150, 60, 110, Rest(16)]), inf], inf),
		\octave, Prand([2, 3, 4, 5], inf),
		\degree, Ppatlace([Pseq([0, -7, 2-8, 2], inf), Pseq([5, -7, 3, Rest(16)]), inf], inf),
		\dur, Pwhite(0.15, 1.0, inf),
	)
);
)



Ndef(\synth)[10] = \filter -> { |in| DelayC.ar(in * Dust.ar(100 + in), 1, 1) };
Ndef(\synth).set(\wet10, 0.5);




