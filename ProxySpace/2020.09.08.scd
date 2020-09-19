s.options.memSize_(2 pow: 20);
p = ProxySpace.push(s.reboot);

(
~iter = { | freq = 40, amp=0.5 |
	var temp;
	var env = 1;
	var sum = 0;
	// env = EnvGen.kr(Env([0, 1, 0, 1, 0], [0.1, 0.25, 0.5, 0.75, 1], loopNode: 10, releaseNode: 10));
	10.do{
		temp = VarSaw.ar(
			freq * MouseY.kr(1, 2.0) * {Rand(0.99, 1.02)  * 1}!2,
			~iterlfok1.kr * Impulse.kr(30) * {Rand(0.99, 1.02)}!2,
			VarSaw.kr(CombC.kr(~iterlfok1.kr, 2))!2
			);
			sum = sum + temp * 0.3 * env;
	};
	Pan2.ar([sum * amp * ~itergate.kr * 0.4, sum * amp]);
};
)

(
~dust = { | freq = 110 |
	var sig, evn;
	sig = {LFPulse.ar(MouseX.kr(10, freq)) * LFNoise0.kr(~itergate.kr) * ~iter.ar}.dup;
}
)

~dust.play;


~iter.play;
~iter.stop;
~iter.release;

~iterlfok1.play;
~iterlfok1 = {SinOsc.kr(MouseY.kr(30, 1000 ))};
~iterlfok1.stop;

~itergate = {LFPulse.kr(MouseX.kr(0.5, {Rand(20, 100)}))};

// route the ndef through a delay - output to speakers
~delay.play;
~delay[0] = \mix -> {~iter.ar};
~delay[1] = \mix -> {~dust.ar};
~delay.set(\mix0, 1, \mix1, 0.25);
(
~delay.filter(10, {|in|
	var sig;
	var fb = LocalIn.ar(2);
	fb = DelayC.ar(fb.reverse * LFNoise2.kr(~itergate.kr * 10), 1, [3/8, 5/8]);
	sig = fb * 0.7 + in;
	LocalOut.ar(sig);
	sig;
})
)

~delay.stop(fadeTime:5);


// route the delay through a pitchshift - output to speakers
~ps.play;
~ps[0] = \mix -> {~delay.ar};
~ps[1] = \mix -> {~dust.ar};
~ps.set(\mix0, 0.2);
(
~ps.filter(10, {|in|
	PitchShift.ar(in * LFNoise2(~itergate.kr), 2, 2, 0.01, 0.01)
})
)
~ps.free(fadeTime:3);

// route the dry signal, delay, and pitchshift through reverb - output to speakers
~verb.play;
~verb[0] = \mix -> {~iter.ar};
~verb[1] = \mix -> {~delay.ar};
~verb[2] = \mix -> {~ps.ar};
~verb[3] = \mix -> {~dust.ar};
~verb[3] = \mix -> nil;
~verb.filter(10, {|in| GVerb.ar(in, 10, 5, 1, 1) } );
// adjust mix
~verb.set(\mix0, 0.5, \mix1, 1, \mix2, 1);
// adjust wet/dry
~verb.set(\wet10, 0.5)
~verb.free;
~verb.stop(fadeTime:10);

s.prepareForRecord(numChannels:6);
s.record;
s.stopRecording;

(
r = ProxyRecorder(p);

r.add([~iter, ~delay, ~ps, ~verb]);
)

r.record;
r.stop;
