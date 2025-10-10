// 2025-09-29 Pdef into MixerChannel

// make a master and one track
~m1 = MixerChannel(\master, s, 2, 2, outbus: 0);
~t1 = MixerChannel(\t1, s, 2, 2, outbus: ~m1);

(
// define a simple synth
SynthDef(\beep, { |out=0, freq=440, amp=0.1, sustain=0.2|
    var env = EnvGen.kr(Env.perc(0.01, sustain), doneAction:2);
    var sig = SinOsc.ar(freq) * env * amp;
    Out.ar(out, sig ! 2);
}).add;
)

// Pdef sending into the mixer channel
(
Pdef(\melody,
    Pbind(
        \instrument, \syn1,
        \dur, Pseq([0.5,Rest(0.5)], inf),
        \degree, Prand([0,2,4,5,7], inf),
        \amp, 0.35,
        \out, ~t1.inbus.index   // <--- key part
    )
).play;
)

// reverb send
// // we know in advance what fx insert is needed!
// // so we can write it at init time, save a step
// (
// ~r1 = MixerChannel(\rvb, s, 2, 2, level: 1,
// 	completionFunc: { |chan|
// 		~rvb = chan.playfx { |outbus|
// 			var sig = In.ar(outbus, 2);
// 			FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.2);
// 		}
// 	}, outbus: ~m1
// );
// )
(
~r1.playfx( { |outbus|
			var sig = In.ar(outbus, 2);
			FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.2);
		}
);
)
~t2s1 = ~t2.newPostSend(~r1, 0.1);
~t2s1.level_(1);
~t3s1.free;
~t3s1 = ~t3.newPostSend(~r1, 1);
~t4s1 = ~t4.newPostSend(~r1, 1);
~r1.level_(0.9);
Pdef.clear;
Pdef(\melody).clear;

ServerMeter(s);


// start stems to one multichannel WAV on the next bar
~stopStems = ~stemDiskStart.([~m1, ~t2, ~perc, ~phh1], [~r1], "songB");

// later, stop one bar after you call it
~stopStems.(1);
