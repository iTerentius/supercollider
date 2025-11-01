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

// Pdef test
Pdef(\kick, Pbind(\instrument, \default, \dur, 0.25, \freq, 110));
~lcxlBindPdef.(\b0_s1_p, \kick);

// Ndef test (simple drone)
Ndef(\padbus, { SinOsc.ar(220) * EnvGen.kr(Env.asr, gate:1, doneAction:0) * -12.dbamp });
~lcxlBindNdef.(\b0_s2_n, \padbus);

// press s1 -> Pdef plays green; press again -> amber
// press s2 -> Ndef plays green; press again -> amber

// bank switch (as before), then:
~lcxlPdefRefresh.(); // recompute p-row LEDs for current bank
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

(
// TEMP one shot  lcxl midi spy  2025-10-20 America Chicago

MIDIdef(\spy_cc).free;
MIDIdef(\spy_note).free;

MIDIdef.cc(\spy_cc, { |val, num, chan, src|
    var ep, dev, name;
    ep = MIDIClient.sources.detect { |e| e.uid == src };
    dev = (ep.notNil).if({ ep.device }, { "?" });
    name = (ep.notNil).if({ ep.name }, { "?" });
    ["CC", "src", src, "dev", dev, "name", name, "chan", chan, "num", num, "val", val].postln;
}, nil);

MIDIdef.noteOn(\spy_note, { |vel, num, chan, src|
    var ep, dev, name;
    ep = MIDIClient.sources.detect { |e| e.uid == src };
    dev = (ep.notNil).if({ ep.device }, { "?" });
    name = (ep.notNil).if({ ep.name }, { "?" });
    ["NOTE", "src", src, "dev", dev, "name", name, "chan", chan, "num", num, "vel", vel].postln;
}, nil);
)

(
// 2025-10-21 CDT — wavetable bank + Pdef control (no resize calls)

// ---------- VARS ----------
var wtSize, numTables, mkCos, wtSignals;
wtSize = 8192;         // source Signal length (power of two)
numTables = 4;

// ---------- SOURCE SIGNALS (exact sizes) ----------
// Helper: single-cycle cosine table of exact length
mkCos = { |n|
    Signal.fill(n, { |i| cos(2pi * (i / n)) })
};

// Build a set of different spectra/shapes, all exactly wtSize long
wtSignals = [
    Signal.chebyFill(wtSize, Array.rand(7, 0, 7)), // random partial weighting
    Signal.hanningWindow(wtSize),                  // exact-length window
    Signal.rectWindow(wtSize, wtSize/8),          // exact-length rect window
    mkCos.(wtSize)                                 // exact-length cosine
];
// ---------- SERVER BUFFERS ----------
~wtBufs = Buffer.allocConsecutive(numTables, s, wtSize * 2, 1);


// Load wavetables (each source Signal size is power-of-two)
~wtBufs.do { |buf, i|
    var wt = wtSignals[i].asWavetable; // OK: source is power-of-two length
    buf.loadCollection(wt);
};

// s.sync;
)
(
// ---------- SYNTHDEF ----------
SynthDef(\wavtab, { |out=0, freq=110, baseBuf=0, tableCount=4, sel=0, amp=0.2|
    var sig, tableSel;
    tableSel = sel.clip(0, tableCount - 0.001);   // fractional index 0..N-ε
    sig = VOsc.ar(baseBuf + tableSel, freq, 0);
    Out.ar(out, (sig * amp) ! 2);
}).add;

// s.sync;
)
(
// ---------- PATTERNS ----------

// Continuous scanner: sweeps across all tables with Pseg
Pdef(\wtScan,
    Pbind(
        \type, \note,
        \instrument, \wavtab,
        \dur, 0.25,
        \degree, Pwhite(0, 7),
        \octave, 4,
        \baseBuf, ~wtBufs[0].bufnum,
        \tableCount, numTables,
        \sel, Pseg(
            levels: Pseq([0, numTables - 0.001], inf),
            durs:  Pseq([8], inf),   // seconds per full sweep
            curve: \lin
        ),
        \amp, 0.15
    )
);
)
(
// Stepped selector: hops tables per bar
Pdef(\wtStep,
    Pbind(
        \type, \note,
        \instrument, \wavtab,
        \dur, 0.5,
        \degree, Pseq([0,2,4,5,7,9,11,12], inf),
        \octave, 3,
        \baseBuf, ~wtBufs[0].bufnum,
        \tableCount, numTables,
        \sel, Pstutter(8, Pseries(0, 1, numTables)).wrap(0, numTables - 0.001),
        \amp, 0.18
    )
);
)
// ---------- HELPERS ----------
~wtPlayScan = { Pdef(\wtScan).play };
~wtPlayStep = { Pdef(\wtStep).play };
~wtStop = { Pdef(\wtScan).stop; Pdef(\wtStep).stop };
~wtFree = { ~wtStop.(); ~wtBufs.do(_.free) };
)

// 1. Boot the server and install quark if necessary
s.boot;

// If not already installed:
// Quarks.install("ddwMixerChannel");
// Server.quit;
// Server.local.reboot;

// 2. Define a new ddwMixerChannel for the Ndef
MixerChannel.new(\mySine, s, 2, 2);
(
// 3. Define the Ndef with your synth logic
Ndef(\mySine, {
    var freq = MouseX.kr(100, 1000, 1);
    var pan = MouseY.kr(-1, 1, 1);
    Pan2.ar(LFPulse.ar(freq, 0, 0.2), pan);
});
)
// 4. Play the Ndef through the ddwMixerChannel
~t1.play(Ndef(\mySine));

// 5. Control the mixer channel (adjust volume, pan, etc.)
~t1.level = 0.5;
~t1.pan = -0.8;
(
// 6. Stop and free everything when finished
CmdPeriod.doOnce({
    // ~t1.free;
    Ndef(\mySine).clear;
});
)
(
// 2025-10-06

Pdef(\midiNotes,
    Pbind(
        \type, \midi,
        \midiout, Pfunc { ~mOut },
        \chan, 0,                 // MIDI channel 0..15
        \octave, 3,
        \degree, Prand([0, 1, 4, 7], inf),
        \dur, 0.25,               // pattern step duration
        \sustain, 1.22,           // note length
        \amp, 0.9                 // 0..1 mapped to velocity 1..127
    )
).play;
)
Ndef(\mySine).clear;
