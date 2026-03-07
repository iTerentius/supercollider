(
// -----------------------------------------------------------------------------
// record-on-start.scd  —  16‑ch stems recorder (Tidal-controlled, no polling)
// -----------------------------------------------------------------------------
// Stems layout (server output channel pairs):
//   orbit 0 → ch 0/1   (alias: \master, \drums)
//   orbit 1 → ch 2/3   (alias: \bass)
//   orbit 2 → ch 4/5   (alias: \melody)
//   orbit 3 → ch 6/7   (alias: \pads)
//   orbit 4 → ch 8/9
//   orbit 5 → ch 10/11
//   orbit 6 → ch 12/13
//   orbit 7 → ch 14/15
//
// Start/stop/split from Tidal with:  once $ s "recstart"  /  "recstop"  /  "recsplit"
// Route SC synths to a stem pair with:  Synth(\yourDef, [\out, ~stem.(\pads)]);
// -----------------------------------------------------------------------------

s.notify(true);

// ----------- recording folder -----------
~recDir = Platform.userHomeDir +/+ "Music/recordings";
File.mkdir(~recDir);

// ----------- stem helpers -----------
~stemFirstChan = IdentityDictionary[
    \stem0 -> 0,  \stem1 -> 2,  \stem2 -> 4,  \stem3 -> 6,
    \stem4 -> 8,  \stem5 -> 10, \stem6 -> 12, \stem7 -> 14
];
// friendly aliases
~stemFirstChan[\master] = 0;
~stemFirstChan[\drums]  = 0;
~stemFirstChan[\bass]   = 2;
~stemFirstChan[\melody] = 4;
~stemFirstChan[\pads]   = 6;

// get first channel for a stem Symbol or numeric index (0..7)
~stem = { |key|
    if(key.isNumber) { (key.clip(0,7) * 2) } {
        ~stemFirstChan[key] ? { "Unknown stem %, defaulting to 0".format(key).postln; 0 }.value
    }
};

// ----------- map SuperDirt orbits to stems (runs when ~dirt is ready) -----------
~routeOrbitsToStems = {
    if(~dirt.notNil) {
        ~dirt.orbits.size.do { |i|
            // each orbit writes its monitor to the matching output pair
            ~dirt.orbits[i].outBus = i * 2;
        };
        "[rec] Routed SuperDirt orbits → output pairs (0/1,2/3,...).".postln;
    } {
        // retry until SuperDirt is booted
        AppClock.sched(0.5, { ~routeOrbitsToStems.value; nil });
    }
};
~routeOrbitsToStems.value;

// ----------- the recorder -----------
~rec = (
    channels: 16,
    header: 'wav',
    sampleFmt: 'int24',
    filePath: nil,
    started: false,

    newFilePath: {
        var stamp = Date.getDate.stamp.replace($:, $_);
        ~recDir +/+ ("sc_rec_" ++ stamp ++ ".wav")
    },

    start: {
        if(~rec.started.not) {
            ~rec.filePath = ~rec.newFilePath;
            "Preparing recording on 'localhost'".postln;
            ("Recording channels [" ++ (0..(~rec.channels-1)).join(", ") ++ "] ... ").postln;
            ("path: '" ++ ~rec.filePath ++ "'").postln;

            s.prepareForRecord(~rec.filePath, ~rec.channels, ~rec.header, ~rec.sampleFmt);
            s.record;
            ~rec.started = true;
            ("[rec] Recording started (" ++ ~rec.channels ++ "ch) → " ++ ~rec.filePath).postln;
        }
    },

    stop: {
        if(~rec.started) {
            s.stopRecording;
            ~rec.started = false;
            "[rec] Recording stopped.".postln;
        }
    },

    split: {
        ~rec.stop;
        ~rec.start;
    }
);

// ----------- Tidal trigger SynthDefs (send once, then free) -----------
SynthDef(\recstart, {
    var t = Impulse.kr(1);              // one bang per second
    SendReply.kr(t, '/rec/start', []);  // send first bang
    FreeSelf.kr(t);                     // free immediately after first send
    OffsetOut.ar(0, Silent.ar(2));
}).add;

SynthDef(\recstop, {
    var t = Impulse.kr(1);
    SendReply.kr(t, '/rec/stop', []);
    FreeSelf.kr(t);
    OffsetOut.ar(0, Silent.ar(2));
}).add;

SynthDef(\recsplit, {
    var t = Impulse.kr(1);
    SendReply.kr(t, '/rec/split', []);
    FreeSelf.kr(t);
    OffsetOut.ar(0, Silent.ar(2));
}).add;

// Make sure the server has installed these defs before we attach responders
s.sync;

OSCdef(\recStartReply, { ~rec.start }, '/rec/start');
OSCdef(\recStopReply,  { ~rec.stop  }, '/rec/stop');
OSCdef(\recSplitReply, { ~rec.split }, '/rec/split');

// ----------- manual helpers -----------
~recStart  = { ~rec.start };
~recStop   = { ~rec.stop  };
~recSplit  = { ~rec.split };

// ----------- SC self-test (hits 4 stems; waits for defs to install) -----------
~recSelfTest = {
    SynthDef(\_testRec, { |out=0, freq=440|
        var sig = SinOsc.ar(freq) * 0.2 * Env.perc(0.005, 0.25).ar(doneAction:2);
        OffsetOut.ar(out, sig!2);
    }).add;
    s.sync;

    ~rec.start;

    fork {
        Synth(\_testRec, [\out, ~stem.(\master), \freq, 330]); 0.25.wait;
        Synth(\_testRec, [\out, ~stem.(\bass),   \freq, 110]); 0.25.wait;
        Synth(\_testRec, [\out, ~stem.(\melody), \freq, 660]); 0.25.wait;
        Synth(\_testRec, [\out, ~stem.(\pads),   \freq, 220]); 0.50.wait;
        ~rec.stop;
    };
    "[rec] self-test fired (check pairs 0/1,2/3,4/5,6/7)".postln;
};
)

