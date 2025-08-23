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
	amp = SinOsc.kr(\ampl.kr(1), SinOsc.kr(\phase.kr(1))).range(0, 0.7);
	// FM Synth technique from Eli F
	mod = LFSaw.ar(
		\freq.kr(110) * \ratio.kr(2),
		mul:\freq.kr(110) * \ratio.kr(2) * \index.kr(1)
	);
	sig = LFPulse.ar(\freq.kr(110) + mod);
	sig = sig + (VarSaw.ar(\index.kr * Rand(0.1, 3), \phase.kr(1)*Rand(0.001,1)) * Impulse.kr(\index.kr));
	sig = sig * amp;
	sig = Splay.ar([sig, sig**2]);
	// Why does this only work?
	Out.ar(0, sig * 0.5);
});
)
// Keep at least the Role Pdef nearby as every change to the Ndef means it needs to be executed again.
// FIND OUT HOW TO CAUSE CHANGES WIHTOUT DOING THIS!



Ndef(\t425).stop; // This doesn't seem to work - because of the Out on the Ndef?
Ndef(\t425)[1] = \xset -> Pdef(\p425);
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
			\degree, Prand((0..7), 5),
			\phase, Prand([0.25, 0.5, 0.75, 1], 10),
			// \freq, Pwhite(55, 440, inf),
			\atk, Pwhite(0.0, 1.0, inf),
			\ampl, Pseries(1, 2, 15),
			\dur, 1,
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
			\dur, Pseq([2, Rest(1)], 15),
		),
	], inf)
});
)




Ndef(\index, { SinOsc.kr(1).range(1,4) });
Ndef(\t425).xmap(\index, Ndef(\index));

Ndef(\delay).play;
Ndef(\delay).stop;
Ndef(\delay, { | in | CombC.ar(in, 5, 2) });
Ndef(\delay) <<>.in Ndef(\t425);
