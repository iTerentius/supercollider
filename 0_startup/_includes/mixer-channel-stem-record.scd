(
// stemDiskStart v10  — captureMidi re-implemented via Event.parentEvents[\default][\callback]
//
// NOT loaded by default. Load manually before use:
//   "_includes/mixer-channel-stem-record.scd".loadRelative;
//
// New kwargs (both default false):
//   captureHistory: saves a .history.scd alongside stems (History.start/end/write)
//   captureMidi:    captures all note events during recording → .mid file
//                   Hooks Event.parentEvents[\default][\callback] (called by play: AFTER each note event
//                   type fires). Does NOT wrap Event.eventTypes[\note], so no
//                   OutOfContextReturnError. ~stemMidiUnpatch.() is an emergency restore.
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
    // ~stemMidiOrigCallback is set to a Function or nil (nil = no spy active)
    // We use the midiActive-via-global flag: check if callback was patched
    Event.parentEvents[\default][\callback] = ~stemMidiOrigCallback;  // nil is fine (clears it)
    ~stemMidiOrigCallback = nil;
    "[stemRec] Event.default[\\callback] restored (or cleared).".postln;
};

// =============================================================================
// MAIN RECORDING FUNCTION
// =============================================================================
~stemDiskStart = { |tracks=#[], returns=#[], fileBase="take", dirPath="",
                    clock=nil, addAction=\addToTail, autoSplit=true, splitCodec=\pcm_s24le,
                    captureHistory=false, captureMidi=false, captureCC=false,
                    encodeMp3=true, deleteMixWav=true|

    var tIdx, rIdx, idxs, numChans, buf, defName, d, dstr, fullPath, baseName, sessionDir, baseDir, c, startBeat, synth;
    var names, sidecarPath, stemsDir, midiDir, ffmpegPath, ffprobePath, ccLogPath;
    var sanitize, writeSidecar, doSplit, mkDirIfNeeded, findBin, debug, makeFinalize, finalize, didFinalize;
    // MIDI capture state
    var midiLog, midiStartBeat, bpmAtStart, ppqn, midiActive, midiCbOrig, midiCbCount;
    var midiPath;

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

    tIdx = tracks.collect({ |mc, i|
        { mc.inbus.index }.try({ |err|
            ("[stemRec] track '" ++ names[i] ++ "' failed to resolve inbus.index — DROPPED from recording: " ++ err.errorString).warn;
            nil
        })
    }).reject(_.isNil);
    rIdx = returns.collect({ |mc, i|
        { mc.inbus.index }.try({ |err|
            ("[stemRec] return '" ++ names[tracks.size + i] ++ "' failed to resolve inbus.index — DROPPED from recording: " ++ err.errorString).warn;
            nil
        })
    }).reject(_.isNil);
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

    baseName   = fileBase ++ "_" ++ dstr;
    sessionDir = dirPath +/+ baseName;           // master session folder
    baseDir    = sessionDir;
    fullPath   = sessionDir +/+ (baseName ++ ".wav");

    sidecarPath = sessionDir +/+ (baseName ++ ".stemnames.txt");
    stemsDir    = sessionDir +/+ "stems";
    midiDir     = sessionDir +/+ "midi";
    midiPath    = midiDir +/+ (baseName ++ ".mid");
    ccLogPath   = sessionDir +/+ (baseName ++ ".cc.scd");

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
        var probeCmd, chCountStr, chCount, pairs, key, keySafe, lch, rch, outName, mp3Name, gainStr, evenChans, oddChans, mixFilter, codec, scriptLines, scriptPath, scriptStr, i;
        if(ffmpegPath.isNil or: { ffprobePath.isNil }) {
            "autoSplit: ffmpeg or ffprobe not found on PATH; skipped".warn;
            ("ffmpeg: " ++ ffmpegPath.asString ++ "  ffprobe: " ++ ffprobePath.asString).postln;
            ^nil
        };

        probeCmd = ffprobePath ++ " -v error -select_streams a:0 -show_entries stream=channels -of default=nw=1:nk=1 " ++ fullPath.escapeChar($ );
        if(debug) { ("[split] probeCmd: " ++ probeCmd).postln; };
        // Large recordings can still be settling (disk/OS contention right after
        // b_close on a multi-GB file) — a single immediate probe can race that.
        // Retry with backoff before giving up.
        block { |break|
            var tries = 0, delay = 0.3;
            while { tries < 6 } {
                chCountStr = probeCmd.unixCmdGetStdOut.tryPerform(\trim) ?? { "" };
                if(chCountStr.notEmpty) { break.value(nil) };
                tries = tries + 1;
                if(tries < 6) {
                    ("[split] probe attempt " ++ tries ++ " empty, retrying in " ++ delay ++ "s").postln;
                    delay.wait;
                    delay = delay * 2;
                };
            };
        };
        if(chCountStr.isEmpty) {
            "[split] could not read channel count after retries; skipped".warn;
            ("[split] check manually: " ++ probeCmd).postln;
            ^nil
        };
        chCount = chCountStr.asInteger;
        if(chCount.odd) { ("[split] odd channel count " ++ chCount ++ " last channel ignored").warn };
        pairs = chCount div: 2;

        mkDirIfNeeded.(stemsDir);
        codec = splitCodec.asString;

        // Build a shell script so all ffmpeg commands run sequentially and
        // deleteMixWav fires only after all encoding is complete.
        scriptLines = List.with("#!/bin/sh");

        i = 0;
        pairs.do {
            lch = i * 2;
            rch = i * 2 + 1;
            key     = (i < names.size).if({ names[i] }, { "t" ++ (i + 1).asString });
            keySafe = sanitize.(key);
            outName = stemsDir +/+ (baseName ++ "_t" ++ (i + 1).asString ++ "__" ++ keySafe ++ ".wav");
            scriptLines.add(
                ffmpegPath
                ++ " -y -i " ++ fullPath.escapeChar($ )
                ++ " -filter_complex 'pan=stereo|FL=c" ++ lch ++ "|FR=c" ++ rch ++ "'"
                ++ " -c:a " ++ codec
                ++ " -metadata title=" ++ key.asString.escapeChar($ )
                ++ " " ++ outName.escapeChar($ )
            );
            (" -> " ++ outName ++ "  L=c" ++ lch ++ " R=c" ++ rch ++ " key=" ++ key).postln;
            i = i + 1;
        };

        // Mix-down MP3: sum all channel pairs to stereo with auto-normalisation (<)
        if(encodeMp3) {
            gainStr   = (1.0 / pairs).round(0.001).asString;
            evenChans = Array.series(pairs, 0, 2).collect { |ch| gainStr ++ "*c" ++ ch }.join("+");
            oddChans  = Array.series(pairs, 1, 2).collect { |ch| gainStr ++ "*c" ++ ch }.join("+");
            mixFilter = "[0:a]pan=stereo|FL=" ++ evenChans ++ "|FR=" ++ oddChans ++ ",loudnorm=I=-14:TP=-1[mix]";
            mp3Name = sessionDir +/+ (baseName ++ "_mix.mp3");
            scriptLines.add(
                ffmpegPath
                ++ " -y -i " ++ fullPath.escapeChar($ )
                ++ " -filter_complex '" ++ mixFilter ++ "'"
                ++ " -map '[mix]' -codec:a libmp3lame -b:a 320k"
                ++ " " ++ mp3Name.escapeChar($ )
            );
            (" -> mix-down MP3: " ++ mp3Name).postln;
        };

        if(deleteMixWav) { scriptLines.add("rm -- " ++ fullPath.escapeChar($ )) };

        scriptStr  = scriptLines.join("\n");
        scriptPath = "/tmp/stemrec_" ++ Date.getDate.rawSeconds.asInteger.asString ++ ".sh";
        if(debug) { ("[split] script:\n" ++ scriptStr).postln };
        File.new(scriptPath, "w").write(scriptStr).close;
        ("chmod +x " ++ scriptPath).unixCmdGetStdOut;
        scriptPath.unixCmd({ |exitCode|
            if(exitCode == 0) {
                ("stems written to " ++ stemsDir
                    ++ if(encodeMp3) { "\nmix MP3: " ++ mp3Name } { "" }).postln;
            } {
                ("[split] script exited with code " ++ exitCode ++ " — check post window").warn;
            };
            File.delete(scriptPath);
        });
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
                        var histPath = baseDir +/+ (baseName ++ ".history.scd");
                        History.end;
                        // saveStory writes directly to a supplied path (logFolder is read-only)
                        History.saveStory(histPath);
                        ("[stemRec] History saved: " ++ histPath).postln;
                    } { |e| ("[stemRec] History save failed: " ++ e.errorString).warn };
                };

                // --- CC logger close ---
                if(captureCC) { ~ccLogClose !? { ~ccLogClose.() } };

                // --- MIDI write ---
                if(captureMidi) {
                    // Stop capture first so no new events sneak in
                    midiActive = false;
                    // Restore Event.parentEvents[\default][\callback]
                    Event.parentEvents[\default][\callback] = ~stemMidiOrigCallback;  // nil is fine
                    ~stemMidiOrigCallback = nil;
                    ("[stemRec] MIDI spy fired " ++ midiCbCount ++ " times, tracks=" ++ midiLog.size).postln;
                    if(midiLog.notNil and: { midiLog.size > 0 }) {
                        // One .mid file per voice, named after the mixer channel.
                        var busToName = Dictionary.new;
                        idxs.do { |idx, i| busToName[idx] = names[i] };
                        "[stemRec] Writing " ++ midiLog.size ++ " MIDI files.".postln;
                        midiLog.keys.asArray.sort.do { |busIdx|
                            var vName = busToName[busIdx] ?? { "track_" ++ busIdx };
                            var vPath = midiDir +/+ (baseName ++ "_" ++ sanitize.(vName) ++ ".mid");
                            ~stemMidiWrite.(vPath, [midiLog[busIdx].asArray], bpmAtStart, ppqn);
                        };
                    } {
                        "[stemRec] MIDI capture: no events recorded.".postln;
                    };
                };

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
        mkDirIfNeeded.(sessionDir);
        mkDirIfNeeded.(midiDir);
        buf = Buffer.alloc(s, 65536, numChans);
        buf.write(
            path: fullPath,
            headerFormat: "WAV",
            sampleFormat: "int24",
            numFrames: 0,
            startFrame: 0,
            leaveOpen: true
        );
        writeSidecar.();
        // Place DiskOut at the root node tail — AFTER the default group and all
        // MixerChannel fadergroups (including post-send synths), so In.ar reads
        // current-block values written by sends/FX rather than zeroed bus state.
        synth = Synth.new(defName, [\bufnum, buf], RootNode(s), \addToTail);
        makeFinalize.();

        // --- History start ---
        if(captureHistory) {
            try { History.start } { |e| ("[stemRec] History.start failed: " ++ e.errorString).warn };
            "[stemRec] History recording started.".postln;
        };

        // --- CC logger open ---
        if(captureCC) {
            if(~ccLogOpen.isNil) {
                "[stemRec] captureCC: cc-logger.scd not loaded — load _includes/cc-logger.scd first".warn;
            } {
                ~ccLogOpen.(ccLogPath);
                "[stemRec] CC logger active: ".post; ccLogPath.postln;
            };
        };

        // --- MIDI spy setup ---
        // Hook Event.parentEvents[\default][\callback] — called by play: AFTER the note event type fires,
        // so we never call the #{...} note handler via .value (no OutOfContextReturnError).
        if(captureMidi) {
            // midiLog: Dictionary busIndex -> List of events (one entry per active voice/channel)
            midiLog = Dictionary.new;
            midiStartBeat = c.beats;
            midiActive = true;
            midiCbCount = 0;
            midiCbOrig = Event.parentEvents[\default][\callback];
            ~stemMidiOrigCallback = midiCbOrig;
            Event.parentEvents[\default][\callback] = { |ev|
                midiCbOrig !? { midiCbOrig.value(ev) };
                midiCbCount = midiCbCount + 1;
                if(midiCbCount <= 3) {
                    ("[MIDI spy] cb #" ++ midiCbCount
                        ++ " midiActive=" ++ midiActive
                        ++ " isRest=" ++ ev.isRest
                        ++ " type=" ++ ev[\type]
                        ++ " out=" ++ ev[\out]
                        ++ " freqClass=" ++ ev[\freq].class).postln;
                };
                // Only capture note-type events (skip \set, \rest, etc.)
                if(midiActive and: { ev.isRest.not } and: {
                    var t = ev[\type]; t.isNil or: { t == \note }
                }) {
                    var freq = ev[\freq];
                    if(freq.isKindOf(Number) or: { freq.isKindOf(SequenceableCollection) and: { freq.size > 0 } and: { freq.first.isKindOf(Number) } }) {
                        var outIdxRaw, outIdx, track, startBeats, durBeats, freqs, amps;
                        outIdxRaw = ev[\out];
                        outIdx = if(outIdxRaw.isKindOf(Number)) { outIdxRaw.asInteger } { -1 };
                        track = midiLog[outIdx];
                        if(track.isNil) { track = List.new; midiLog[outIdx] = track };
                        startBeats = c.beats - midiStartBeat;
                        durBeats = (ev[\dur] ? 1).asFloat;
                        freqs = freq.asArray;
                        amps = ev[\amp].asArray;
                        freqs.do { |f, i|
                            if(f.isKindOf(Number)) {
                                var mn = f.cpsmidi.round.asInteger.clip(0, 127);
                                var vel = (amps.wrapAt(i).asFloat * 127).clip(1, 127).round.asInteger;
                                var tick = (startBeats * ppqn).round.asInteger;
                                var durTick = (durBeats * ppqn).round.asInteger.max(1);
                                track.add((tick: tick, pitch: mn, vel: vel, dur: durTick));
                            };
                        };
                    };
                };
            };
            "[stemRec] MIDI capture active.".postln;
        };

        ("stemDisk start " ++ startBeat ++ " -> " ++ fullPath ++ "  chans " ++ numChans).postln;

        ~stemRec = (
            baseName:    baseName,
            sessionDir:  sessionDir,
            fullPath:    fullPath,
            stemsDir:    stemsDir,
            midiDir:     midiDir,
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
