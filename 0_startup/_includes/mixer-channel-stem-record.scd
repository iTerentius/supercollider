(
// stemDiskStart v9  — adds captureHistory + captureMidi kwargs
//
// NOT loaded by default. Load manually before use:
//   "_includes/mixer-channel-stem-record.scd".loadRelative;
//
// New kwargs (both default false):
//   captureHistory: saves a .history.scd alongside stems (History.start/end/write)
//   captureMidi:    captures all note events during recording → .mid file
//                   Patches Event.eventTypes[\note] while recording; restores on stop.
//                   ~stemMidiUnpatch.() is an emergency restore if something goes wrong.
//
// ~stemMidiWrite is also a standalone helper — call it manually to snapshot patterns.

// =============================================================================
// MIDI FILE WRITER — standalone helper
// =============================================================================
// ~stemMidiWrite.(path, tracksEvents, bpm, ppq)
//   tracksEvents : Array of Arrays.
//                  Each inner Array is one MIDI track (one voice).
//                  Each event is an Event with keys:
//                    \tick  (integer ticks from recording start)
//                    \pitch (0–127)
//                    \dur   (ticks, note-on to note-off)
//                    \vel   (1–127)
//                  Events must be pre-sorted by \tick within each inner array.
//   bpm          : tempo to embed in MIDI tempo track
//   ppq          : ticks per quarter note (default 96)
//
// Returns true on success, false on failure (logs error to post window).

~stemMidiWrite = { |path, tracksEvents, bpm=120, ppq=96|
    var microspb, mkTrackBytes, tempoBytes, allTrackBytes, numTracks, f, ok;

    microspb = (60000000.0 / bpm).asInteger;

    // Build one track's bytes as Array.
    // Note on immediately, note off after dur ticks (running events aren't sorted back here —
    // for pattern-based capture events per voice rarely overlap, so this is fine).
    mkTrackBytes = { |events|
        var b = List.new;
        var lastTick = 0;

        // Append variable-length encoded integer
        var vl = { |n|
            var v = n.max(0).asInteger;
            var chunks = [];
            chunks = chunks.add(v.bitAnd(0x7F));
            v = v >> 7;
            while { v > 0 } {
                chunks = [(v.bitAnd(0x7F)) | 0x80] ++ chunks;
                v = v >> 7;
            };
            chunks.do { |byte| b.add(byte.bitAnd(0xFF)) };
        };

        events.do { |ev|
            var delta = (ev[\tick] - lastTick).max(0);
            lastTick = ev[\tick];
            vl.(delta);
            b.add(0x90);                           // note on, channel 0
            b.add(ev[\pitch].clip(0, 127));
            b.add(ev[\vel].clip(1, 127));
            vl.(ev[\dur].max(1));
            b.add(0x80);                           // note off, channel 0
            b.add(ev[\pitch].clip(0, 127));
            b.add(0);
        };
        // end-of-track meta event
        b.add(0); b.add(0xFF); b.add(0x2F); b.add(0x00);
        b.asArray
    };

    // Tempo track (track 0): just a tempo event + end-of-track
    tempoBytes = [
        0,                                      // delta 0
        0xFF, 0x51, 0x03,                       // set tempo meta
        (microspb >> 16).bitAnd(0xFF),
        (microspb >> 8).bitAnd(0xFF),
        microspb.bitAnd(0xFF),
        0, 0xFF, 0x2F, 0x00                     // end-of-track
    ];

    allTrackBytes = [tempoBytes] ++ tracksEvents.collect { |evs| mkTrackBytes.(evs) };
    numTracks = allTrackBytes.size;

    ok = try {
        f = File.new(path, "wb");
        if(f.isNil) { Error("Cannot open for write: " ++ path).throw };

        // MIDI header chunk
        "MThd".do { |c| f.putInt8(c.ascii) };
        f.putInt32(6, 'big');            // always 6
        f.putInt16(1, 'big');            // format 1 (multi-track)
        f.putInt16(numTracks, 'big');
        f.putInt16(ppq, 'big');

        // Track chunks
        allTrackBytes.do { |tb|
            "MTrk".do { |c| f.putInt8(c.ascii) };
            f.putInt32(tb.size, 'big');
            tb.do { |byte| f.putInt8(byte.bitAnd(0xFF)) };
        };

        f.close;
        ("[stemMidiWrite] written: " ++ path).postln;
        true
    } { |err|
        ("[stemMidiWrite] failed: " ++ err.errorString).warn;
        f.tryPerform(\close);
        false
    };
    ok
};

// Emergency restore if recording stops unexpectedly while MIDI spy is active.
// Safe to call even if no spy is active.
~stemMidiUnpatch = {
    if(~stemMidiOrigNoteHandler.notNil) {
        Event.eventTypes[\note] = ~stemMidiOrigNoteHandler;
        ~stemMidiOrigNoteHandler = nil;
        "[stemRec] Event.eventTypes[\\note] restored.".postln;
    } {
        "[stemRec] no MIDI spy active.".postln;
    };
};

// =============================================================================
// MAIN RECORDING FUNCTION
// =============================================================================
~stemDiskStart = { |tracks=#[], returns=#[], fileBase="take", dirPath="",
                    clock=nil, addAction=\addToTail, autoSplit=true, splitCodec=\pcm_s24le,
                    captureHistory=false, captureMidi=false|

    var tIdx, rIdx, idxs, numChans, buf, defName, d, dstr, fullPath, baseName, baseDir, c, startBeat, synth;
    var names, sidecarPath, stemsDir, ffmpegPath, ffprobePath;
    var sanitize, writeSidecar, doSplit, mkDirIfNeeded, findBin, debug, makeFinalize, finalize, didFinalize;
    // MIDI capture state
    var midiLog, busTrackMap, midiStartBeat, bpmAtStart, ppqn, midiActive;
    var midiPath, origNoteType;

    debug = true;
    didFinalize = false;
    ppqn = 96;

    sanitize = { |str|
        var s;
        s = str.asString;
        s = s.collect({ |ch| if(ch.isAlphaNum or: { [$_, $., $-, $ ].includes(ch) }) { ch } { $_ } }).join.replace(" ", "_");
        s
    };

    names = (tracks.collect({ |mc| var n; n = { mc.name }.try({ nil }); (n ?? { mc.asString }).asString }))
          ++ (returns.collect({ |mc| var n; n = { mc.name }.try({ nil }); (n ?? { mc.asString }).asString }));

    tIdx = tracks.collect({ |mc| { mc.inbus.index }.try({ nil }) }).reject(_.isNil);
    rIdx = returns.collect({ |mc| { mc.inbus.index }.try({ nil }) }).reject(_.isNil);
    idxs = tIdx ++ rIdx;

    if(idxs.isEmpty) {
        "stemDiskStart - no valid stem buses".warn;
        { |beats=0| nil }
    } {

    if(dirPath.isNil or: { dirPath == "" }) {
        dirPath = (~stemBaseDir ? (Platform.userHomeDir +/+ "recordings"));
    };
    dirPath = dirPath.asString.standardizePath;
    if(File.exists(dirPath).not) { File.mkdir(dirPath); ("created " ++ dirPath).postln; };

    d = Date.getDate;
    dstr = d.year.asString
        ++ "-" ++ d.month.asString.padLeft(2, "0")
        ++ "-" ++ d.day.asString.padLeft(2, "0")
        ++ "_" ++ d.hour.asString.padLeft(2, "0")
        ++ "-" ++ d.minute.asString.padLeft(2, "0")
        ++ "-" ++ d.second.asString.padLeft(2, "0");

    baseName = fileBase ++ "_" ++ dstr;
    fullPath = dirPath +/+ (baseName ++ ".wav");
    baseDir  = dirPath;

    sidecarPath = baseDir +/+ (baseName ++ ".stemnames.txt");
    stemsDir    = baseDir +/+ (baseName ++ "-stems");
    midiPath    = baseDir +/+ (baseName ++ ".mid");

    mkDirIfNeeded = { |path| if(File.exists(path).not) { File.mkdir(path) } };

    writeSidecar = {
        var f;
        f = File(sidecarPath, "w");
        names.do { |nm| f.write(nm.asString ++ "\n") };
        f.close;
        ("wrote stem name sidecar: " ++ sidecarPath).postln;
    };

    findBin = { |cands|
        var p, whichPath;
        p = cands.detect { |p0| File.exists(p0) };
        if(p.isNil) {
            whichPath = ("which " ++ cands.last).unixCmdGetStdOut.tryPerform(\trim);
            if(whichPath.notNil and: { whichPath.size > 0 } and: { File.exists(whichPath) }) { p = whichPath };
        };
        p
    };

    ffmpegPath  = findBin.([ "/opt/homebrew/bin/ffmpeg",  "/usr/local/bin/ffmpeg",  "/usr/bin/ffmpeg",  "ffmpeg" ]);
    ffprobePath = findBin.([ "/opt/homebrew/bin/ffprobe", "/usr/local/bin/ffprobe", "/usr/bin/ffprobe", "ffprobe" ]);

    doSplit = {
        var probeCmd, chCountStr, chCount, pairs, i, key, keySafe, lch, rch, outName, codec, cmd;
        if(ffmpegPath.isNil or: { ffprobePath.isNil }) {
            "autoSplit: ffmpeg or ffprobe not found on PATH; skipped".warn;
            ("ffmpeg: " ++ ffmpegPath.asString ++ "  ffprobe: " ++ ffprobePath.asString).postln;
            ^nil
        };

        probeCmd = ffprobePath ++ " -v error -select_streams a:0 -show_entries stream=channels -of default=nw=1:nk=1 " ++ fullPath.escapeChar($ );
        if(debug) { ("[split] probeCmd: " ++ probeCmd).postln; };
        chCountStr = probeCmd.unixCmdGetStdOut.tryPerform(\trim) ?? { "" };
        if(chCountStr.isEmpty) { "[split] could not read channel count; skipped".warn; ^nil };
        chCount = chCountStr.asInteger;
        if(chCount.odd) { ("[split] odd channel count " ++ chCount ++ " last channel ignored").warn };
        pairs = chCount div: 2;

        mkDirIfNeeded.(stemsDir);
        codec = splitCodec.asString;

        i = 0;
        pairs.do {
            lch = i * 2;
            rch = i * 2 + 1;
            key = (i < names.size).if({ names[i] }, { "t" ++ (i+1).asString });
            keySafe = sanitize.(key);
            outName = stemsDir +/+ (baseName ++ "_t" ++ (i+1).asString ++ "__" ++ keySafe ++ ".wav");

            cmd = ffmpegPath
                ++ " -y -i " ++ fullPath.escapeChar($ )
                ++ " -filter_complex 'pan=stereo|FL=c" ++ lch ++ "|FR=c" ++ rch ++ "'"
                ++ " -c:a " ++ codec
                ++ " -metadata title=" ++ key.asString.escapeChar($ )
                ++ " " ++ outName.escapeChar($ );

            if(debug) { ("[split] cmd: " ++ cmd).postln; };
            cmd.unixCmd;
            (" → wrote " ++ outName ++ "  L=c" ++ lch ++ " R=c" ++ rch ++ " key=" ++ key).postln;

            i = i + 1;
        };

        ("stems written to " ++ stemsDir).postln;
        nil
    };

    makeFinalize = {
        finalize = {
            if(didFinalize) { "[finalize] already ran, skipping".postln; ^nil };
            didFinalize = true;
            Routine({
                ("[finalize] stopping writer").postln;
                if(synth.notNil) { synth.free };
                s.sync;

                ("[finalize] closing buffer").postln;
                if(buf.notNil) { buf.close };
                s.sync;

                // --- History save ---
                if(captureHistory) {
                    try {
                        var srcPath;
                        History.end;
                        // History always writes to this platform path; no path accessor exists
                        srcPath = Platform.userAppSupportDir +/+ "sclang-history";
                        if(File.exists(srcPath)) {
                            ("cp " ++ srcPath.escapeChar($ ) ++ " " ++ ~stemHistoryPath.escapeChar($ )).unixCmd;
                            ("[stemRec] History saved: " ++ ~stemHistoryPath).postln;
                        } {
                            ("[stemRec] History: log not found at " ++ srcPath).warn;
                        };
                    } { |e| ("[stemRec] History save failed: " ++ e.errorString).warn };
                };

                // --- MIDI write --- (disabled: see captureMidi note above)
                // if(captureMidi) { ... };

                if(autoSplit) {
                    ("[finalize] splitting in 0.3s").postln;
                    0.3.wait;
                    doSplit.();
                }{
                    ("autoSplit false; sidecar at " ++ sidecarPath).postln;
                };

                ("[finalize] freeing buffer").postln;
                if(buf.notNil) { buf.free };
                ("[finalize] done").postln;
            }).play(AppClock);
            nil
        };
        nil
    };

    c = clock ?? { thisThread.clock ?? TempoClock.default };
    startBeat = c.beats.ceil(1.0);
    bpmAtStart = (c.tempo * 60).round(0.01);

    defName = \__stemDiskOut__;
    SynthDef(defName, { |bufnum=0|
        var sig, ins;
        ins = Array.fill(idxs.size, { |j| In.ar(idxs[j], 2) });
        sig = ins.flat;
        DiskOut.ar(bufnum, sig);
    }).add;

    numChans = idxs.size * 2;

    c.schedAbs(startBeat, {
        buf = Buffer.alloc(s, 65536, numChans);
        buf.write(
            path: fullPath,
            headerFormat: "WAV",
            sampleFormat: "int24",
            numFrames: 0,
            startFrame: 0,
            leaveOpen: true
        );
        mkDirIfNeeded.(baseDir);
        writeSidecar.();
        // Place DiskOut at the root node tail — AFTER the default group and all
        // MixerChannel fadergroups (including post-send synths), so In.ar reads
        // current-block values written by sends/FX rather than zeroed bus state.
        synth = Synth.new(defName, [\bufnum, buf], RootNode(s), \addToTail);
        makeFinalize.();

        // --- History start ---
        if(captureHistory) {
            ~stemHistoryPath = baseDir +/+ (baseName ++ ".history.scd");
            try { History.start } { |e| ("[stemRec] History.start failed: " ++ e.errorString).warn };
            "[stemRec] History recording started.".postln;
        };

        // --- MIDI spy setup ---
        // NOTE: captureMidi is currently disabled. SC's built-in \note event type handler
        // uses non-local return (^) internally, which unwinds past any try{} wrapper and
        // causes OutOfContextReturnError in PauseStream:awake, crashing EventStreamPlayers.
        // Infrastructure (~stemMidiWrite, ~stemMidiUnpatch, midiLog, etc.) is preserved
        // for future implementation once a safe patching strategy is found.
        if(captureMidi) {
            "[stemRec] captureMidi: not yet supported — skipping MIDI capture.".warn;
        };

        ("stemDisk start " ++ startBeat ++ " → " ++ fullPath ++ "  chans " ++ numChans).postln;

        ~stemRec = (
            baseName:    baseName,
            fullPath:    fullPath,
            stemsDir:    stemsDir,
            sidecarPath: sidecarPath,
            midiPath:    midiPath,
            finalize:    { finalize.() }
        );
        nil
    });

    { |beats=1|
        var stopBeat;
        stopBeat = c.beats + beats;
        ("stemDisk stop scheduled at " ++ stopBeat ++ " on " ++ c).postln;
        c.schedAbs(stopBeat, {
            ("stemDisk stop firing at " ++ stopBeat).postln;
            finalize.();
            nil
        })
    }

    } // end if(idxs.isEmpty) else
};

~stemStopNow = {
    if(~stemRec.isNil) {
        "stemStopNow: no active stem recording".warn;
    } {
        ("stemStopNow called").postln;
        if(~stemRec[\finalize].notNil) { ~stemRec[\finalize].value } { "stemStopNow: no finalize closure".warn };
    };
    nil
};
)
