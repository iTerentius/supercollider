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
s.stopRecording;

(
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

Ndef(\fx).play;
Ndef(\fx)[0] = \mix -> { Ndef(\synth1).ar };
Ndef(\fx)[1] = \mix -> { Ndef(\synth2).ar };
Ndef(\fx)[3] = \mix -> { Ndef(\fuck).ar};
Ndef(\fx)[1] = \mix -> { Ndef(\bplay).ar };
Ndef(\fx).filter(10, {|in| DelayC.ar(in) });

Ndef(\fuck).play;
Ndef(\fuck, { LFSaw.ar(freq: Line.kr(50, 110), amp: 0.2).dup * 0.02 }).play;

// you can control the wet and dry levels like this
Ndef(\fx).set(\mix0, 0.5, \mix1, 0.9, \wet10, 0.5);

Ndef(\synth1, { SinOsc.ar(110, 0, 1, 0.5).dup * 0.02}).play;
Ndef(\synth2, { LFSaw.ar(Rand(1,10)).dup * 0.2}).play;

Ndef(\synth2).stop;
Ndef(\synth1).stop;
Ndef(\fx).stop(fadeTime: 3);
Ndef(\fuck).stop(fadeTime: 3);
Ndef(\bplay).stop(fadeTime: 2);

(
Ndef(\bplay,
	{ | buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15 |
		var sig,env=1 ;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
});
)

Ndef(\bplay).play;

(
Ndef(\bplay)[1] = \set -> Pbind(
    \buf, d["Bass Drums"][1],
    \dur, Pseq([0.5, 1, 0.5, 1], inf),
    \amp, 0.3
);
)

(
~bb = Pbind(
	\instrument, \bplay,
	\buf, d["Bass Drums"][3],
	\dur, Pseq([0.25, 1, 0.5, 1], inf),
	\amp, 0.5
).play;
)

~bb.stop;
