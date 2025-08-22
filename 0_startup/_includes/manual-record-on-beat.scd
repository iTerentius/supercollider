// ======================================================================
// MIX + Stereo Stems Recorder for SuperDirt + Tidal (merged, clean)
// - MIX → ch 0/1
// - Stereo orbits → 2/3, 4/5, … up to ~numOrbits
// - Trigger from Tidal: once $ s "recstart" / "recstop" / "recsplit"
// - Uses silent sample sets (so Dirt never errors) + universal OSC hook
// - No Dirt modules, no extra synths → no doubling/lag
// ======================================================================

s.notify(true);

// ---------------- SETTINGS ----------------
~numOrbits = 16;  // number of stereo orbits to capture

~recConfig = (
    chans: 2 + (2 * ~numOrbits),    // 2 (mix) + 2*orbits
    header: 'wav',                  // 'wav' or 'caf'
    sampleFmt: 'int24',
    basePath: Platform.userHomeDir +/+ "Music/recordings"
);
File.mkdir(~recConfig[\basePath]);

// ---------------- ROUTE ORBITS (reserve 0/1 for the mix) ----------------
// Each orbit outputs to its own stereo pair starting at bus 2
~routeOrbitsToPairs = {
    if(~dirt.notNil) {
        ~dirt.orbits.size.do { |i|
            if(i < ~numOrbits) {
                ~dirt.orbits[i].outBus = 2 + (2 * i);  // orbit i → 2+2*i (L), 3+2*i (R)
            };
        };
        ("[rec] Orbits routed: mix 0/1, orbits start at 2/3 (count=" ++ ~numOrbits ++ ").").postln;
    } {
        AppClock.sched(0.5, { ~routeOrbitsToPairs.(); nil });
    };
};
~routeOrbitsToPairs.();

// ---------------- RECORDER CORE ----------------
~recState = ~recState ? \idle; // \idle | \recording

~recNewFilePath = {
    var stamp = Date.getDate.stamp.replace($:, $_);
    ~recConfig[\basePath] +/+ ("mix+orbits_" ++ stamp ++ ".wav")
};

~recStart = {
    var path, nCh, fmtH, fmtS;
    if(~recState == \recording) { "[rec] already recording".postln; ^nil };

    path = ~recNewFilePath.();
    nCh  = ~recConfig[\chans];
    fmtH = ~recConfig[\header];
    fmtS = ~recConfig[\sampleFmt];

    if(s.options.numOutputBusChannels < nCh) {
        ("[rec] WARN: server has % output busses; writing " ++ nCh
         ++ "ch (extra channels silent).").format(s.options.numOutputBusChannels).postln;
    };

    ("[rec] prepare " ++ nCh ++ "ch → " ++ path).postln;
    s.prepareForRecord(path, nCh, fmtH, fmtS);
    s.record(bus: 0, numChannels: nCh);  // capture from bus 0
    ~recState = \recording;
    ("[rec] RECORDING — bus 0 → " ++ nCh ++ "ch").postln;
};

~recStop = {
    if(~recState != \recording) { "WARNING: Not Recording".postln; ^nil };
    s.stopRecording;
    ~recState = \idle;
    "[rec] stopped.".postln;
};

~recSplit = { ~recStop.(); ~recStart.() };

// ---------------- SELF-TEST (optional) ----------------
SynthDef(\recBeep, { |out=0, freq=440|
    var sig = SinOsc.ar(freq) * Env.perc(0.005, 0.2).ar(doneAction:2);
    OffsetOut.ar(out, sig!2);
}).add;
s.sync;

~recSelfTest = {
    ~recStart.();
    fork {
        0.15.wait;  Synth(\recBeep, [\out, 0, \freq, 440]);           // mix 0/1
        0.35.wait;  Synth(\recBeep, [\out, 2 + (2 * 0), \freq, 220]); // orbit0 2/3
        0.60.wait;  ~recStop.();
    };
    "[rec] self-test fired (check ch 0/1 and 2/3)".postln;
};

// ---------------- SILENT CUE SETS (so Tidal never errors) ----------------
// Creates tiny silent stereo files for recstart/recstop/recsplit and loads them.
~installSilentCueSets = {
    var base = Platform.userHomeDir +/+ "Music/superdirt/cues";
    var sets = [ \recstart, \recstop, \recsplit ];
    var sr = 44100;
    var frames = (sr * 0.01).asInteger.max(8); // ~10 ms
    File.mkdir(base);

    sets.do { |nm|
        var folder = base +/+ nm.asString;
        var wav = folder +/+ "0.wav";
        File.mkdir(folder);
        if(File.exists(wav).not) {
            var sf = SoundFile.new;
            if(sf.openWrite(wav, "WAV", "int16", 2, sr)) {
                sf.writeData(FloatArray.fill(frames * 2, 0.0));  // stereo zeros
                sf.close;
                ("[rec] wrote silent cue file: " ++ wav).postln;
            }{
                ("[rec] ERROR: couldn't open " ++ wav ++ " for write").warn;
            };
        };
    };

    // IMPORTANT: point Dirt at the parent with "/*" so it registers subfolders as sets
    if(~dirt.notNil) { ~dirt.loadSoundFiles(base +/+ "/*") };
    "[rec] Silent cue *sets* installed and loaded (recstart/recstop/recsplit)".postln;
};
~installSilentCueSets.();

// ---------------- UNIVERSAL OSC HOOK (address‑agnostic) ----------------
// Watches all incoming Tidal events on sclang port and triggers recorder

// Clear any old hooks from previous attempts
[ \tidalRecHook_any, \tidalRecHook_play2d, \tidalRecHook_playd, \tidalRecHook_play2, \tidalRecHook_play ].do { |k|
    var d = OSCdef(k); if(d.notNil) { d.free };
};

// Helper: extract 'sound' name from flat key/value arg list
~recExtractSoundName = { |msg|
    var name = nil, i = 0, n = msg.size, key, val, ks;
    // msg is [key0, val0, key1, val1, ...]
    while({ i < (n - 1) }, {
        key = msg[i]; val = msg[i+1];
        if(key.notNil) {
            ks = key.asString.toLower;
            if((ks == "s") or: { ks == "sound" }) {
                name = val.asString.toLower;
                i = n; // break
            } {
                i = i + 2;
            };
        } {
            i = i + 2;
        };
    });
    name
};

// Listen on the language port so we see the same packets Dirt sees
OSCdef(
    \tidalRecHook_any,
    { |msg, time, addr, recvPort, path|
        var nm = ~recExtractSoundName.(msg);
        if(nm.notNil) {
            switch(nm,
                "recstart", { { ~recStart.() }.defer; },
                "recstop",  { { ~recStop.()  }.defer; },
                "recsplit", { { ~recSplit.() }.defer; },
                { }
            );
        };
    },
    nil,                    // match all addresses
    recvPort: NetAddr.langPort
);
"[rec] OSC hook active (listening for recstart/recstop/recsplit)".postln;

// ---------------- BOOT MESSAGE ----------------
("[rec] Loaded: mix 0/1 + " ++ ~numOrbits ++ " stereo orbits → "
 ++ ~recConfig[\chans] ++ "‑ch file").postln;

// ======================================================================

