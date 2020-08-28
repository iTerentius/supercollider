(
s.reboot;
Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName("/home/hypostatic/music/samples/808s_by_SHD/Classic").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	// ("SynthDefs.scd").loadRelative;
	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	3.wait;
	//activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;
	"Setup done!".postln;
}).start;
)

s.prepareForRecord;
s.record;
s.stopRecord;

(
SynthDef(\a, { | out=0, freq=100, time=5, dur=1 |
	var sig, env = 1;
	// env = EnvGen.kr(Env.perc(), doneAction: 2);
	sig = SinOsc.ar(freq * LFNoise0.kr(time));
	sig = sig * env;
	Out.ar(out, Splay.ar(sig *  0.2));
}).add;

SynthDef(\s1, {
	var freq = \freq.kr(220);
	var cutoff = \cutoff.kr(100);
	var fvel = \fvel.kr(8);
	var res = \res.kr(0.5).linlin(0, 1, 1, 0.001);
	var aeg = Env.asr.ar(doneAction:Done.freeSelf, gate:\gate.kr(1));
	var sig = RLPF.ar(Saw.ar(freq), aeg.linlin(0, 1, cutoff, cutoff * fvel), res);
	sig = sig * aeg * \amp.kr(0.3);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1 ;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add;

)

// monitor - output to speakers
Ndef(\s1).play(vol:1);
Ndef(\bplay).play(vol: 1);

// play the synthdef routed through the ndef
(
Pdef(\s1,
	Pbind(
		\instrument, \s1,
		\out, Pfunc({ Ndef(\s1).bus.index }),
		\group, Pfunc({ Ndef(\s1).group }),
		\degree, Ppatlace([Pseq([0, -5], inf), Pseq([-1, 1, -2, 2], inf)], inf),
		\legato, 0.1,
		\dur, 0.25
	)
)
)
Pdef(\s1).play;
Pdef(\s1).stop;

(
Pdef(\hh,
	Pbind(
	\instrument, \bplay,
	\out, Pfunc({ Ndef(\bplay).bus.index }),
	\group, Pfunc({ Ndef(\bplay).group }),
	\buf, d["Hats"][2],
	\dur, 0.25);
)
)

Pdef(\hh).play;
Pdef(\hh).stop;

(
Pdef(\b,
	Pbind(
	\instrument, \bplay,
	\out, Pfunc({ Ndef(\bplay).bus.index }),
	\group, Pfunc({ Ndef(\bplay).group }),
	\buf, d["Bass Drums"][2],
		\dur, Pseq([0.25, 0.5, 1, 0.5], inf));
)
)

Pdef(\b).play;
Pdef(\b).stop;

Ndef(\a, { |freq=110| SinOsc.ar(freq!2 * LFPulse.kr(4), mul: 0.4) });

Ndef(\a).play;
Ndef(\a).free;


// route the ndef through a delay - output to speakers
Ndef(\delay).play;
Ndef(\delay)[0] = \mix -> {Ndef(\s1).ar};f
Ndef(\delay)[1] = \mix -> {Ndef(\hh).ar};
Ndef(\delay)[2] = \mix -> {Ndef(\b).ar};
Ndef(\delay)[3] = \mix -> {Ndef(\a).ar};
Ndef(\delay).set(\mix0, 0.5);
(
Ndef(\delay).filter(10, {|in|
	var sig;
	var fb = LocalIn.ar(2);
	fb = DelayC.ar(fb.reverse, 1, [3/8, 5/8]);
	sig = fb * 0.7 + in;
	LocalOut.ar(sig);
	sig;
})
)

// route the delay through a pitchshift - output to speakers
Ndef(\ps).play;
Ndef(\ps)[0] = \mix -> {Ndef(\delay).ar};
Ndef(\ps).set(\mix0, 1);
(
Ndef(\ps).filter(10, {|in|
	PitchShift.ar(in, 2, 2, 0.01, 0.01)
})
)
Ndef(\ps).stop(fadeTime:3);
// route the dry signal, delay, and pitchshift through reverb - output to speakers
Ndef(\verb).play(vol:0.5);
Ndef(\verb)[0] = \mix -> {Ndef(\s1).ar};
Ndef(\verb)[1] = \mix -> {Ndef(\delay).ar};
Ndef(\verb)[2] = \mix -> {Ndef(\ps).ar};
Ndef(\verb).filter(10, {|in| GVerb.ar(in, 10, 5, 1, 1) } );
// adjust mix
Ndef(\verb).set(\mix0, 0.5, \mix1, 1, \mix2, 1);
// adjust wet/dry
Ndef(\verb).set(\wet10, 0.5)
Ndef(\verb).free;
