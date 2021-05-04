/*
FM Synth from Eli F - https://youtu.be/5vltzRNQnbo

Also trying to modify/gate continuous signal with an LFO driven by PDef

Notes:
You can add the keys in for args instead of in the args section
*/


(
Ndef(\t425, {
	var car, mod, sig, env = 1, amp;
	env = EnvGen.kr(Env.perc(\atk.kr, \rel.kr));
	// Controls the amplitude
	amp = LFPulse.kr(\ampl.kr(1), LFSaw.kr(\phase.kr(1))).range(0, 0.7);
	// FM Synth technique from Eli F
	mod = LFSaw.ar(
		\freq.kr(110) * \ratio.kr(2),
		mul:\freq.kr(110) * \ratio.kr(2) * \index.kr(1) /2
	);
	sig = SinOsc.ar(\freq.kr(110) + mod * TRand.kr(1, 4));
	sig = sig + (VarSaw.ar(\index.kr * Rand(0.1, 3), \phase.kr(1)*Rand(0.001,1)) * Impulse.kr(\index.kr));
	sig = sig * amp;
	sig = Splay.ar([sig, sig**2], center: \pan.kr(-1));
	// Why does this only work?
	Out.ar(\out.ar(0), sig * 0.1);
});
)
// Keep at least the Role Pdef nearby as every change to the Ndef means it needs to be executed again.
// FIND OUT HOW TO CAUSE CHANGES WIHTOUT DOING THIS!

Ndef(\t425).play;
Ndef(\t425)[0].stop;
Ndef(\425).fadeTime = 3;
Ndef(\t425).release; // This doesn't seem to work - because of the Out on the Ndef?
Ndef(\t425)[1] = \xset -> Pdef(\p425).quant_(-1);
Ndef(\t425)[1] = \xset -> nil;

(
Pdef(\p425, {
	Pseq([
		Pbind(
			\out, Pfunc(Ndef(\t425).bus.index),
			\group, Pfunc(Ndef(\t425).group),
			\atk, Pseries(0.01, 1, 3),
			\octave, Pseq([2,5,3], 12),
			\scale, Scale.minor,
			\degree, Prand((0..14), 5),
			\phase, Prand([0.25, 0.5, 0.75, 1], 10),
			// \freq, Pwhite(55, 440, inf),
			\atk, Pwhite(0.0, 1.0, 7),
			\ampl, Pseries(1, 2, 15),
			\dur, Pbjorklund2(5, 12, 12)/32,
			\pan, Pseq([0.5, -0.5], 6)/2,
			\phase, Pwhite(0,0.5, 3),
		),
		Pbind(
			\out, Pfunc(Ndef(\t425).bus.index),
			\group, Pfunc(Ndef(\t425).group),
			\octave, Pseq([4,3], 5),
			\scale, Scale.minor,
			\ratio, Pseq([1,2,4], 3),
			\degree, Prand((0..7), 6),
			\index, Pseq([2, 3, 1], 10),
			\atk, Pseq((0.01..1), 10),
			// \freq, Pwhite(55, 440, inf),
			\ampl, Pxrand([3, 8], 7),
			\dur, Pseq([2, Rest(4)], 15)/Pwhite(2,64, 16),
		),
	], inf)
});
)

Pdef(\p425).stop;


Ndef(\index, { SinOsc.kr(1).range(1,4) });
Ndef(\t425).xmap(\index, Ndef(\index));

Ndef(\delay).play;
Ndef(\delay).stop;
Ndef(\t425)[999] = \filter -> { |in| DelayC.ar(in * Dust.ar(10 + in), 3, 1) };
Ndef(\t425).set(\wet999, 0.5);
Ndef(\delay) <<>.in Ndef(\t425);

Ndef(\rev).play;
Ndef(\425)[1000] = \filter -> {|in| GVerb.ar(in, 10) };
Ndef(\rev) <<>.in Ndef(\425);
