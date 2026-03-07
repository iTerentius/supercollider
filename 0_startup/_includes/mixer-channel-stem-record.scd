(
// 2025-10-26 21:45 CDT  stemDiskStart v8  single block, Routine-based finalize, manual ~stemStopNow, robust split

~stemDiskStart = { |tracks=#[], returns=#[], fileBase="take", dirPath="", clock=nil, addAction=\addToTail, autoSplit=true, splitCodec=\pcm_s24le|
    var tIdx, rIdx, idxs, numChans, buf, defName, d, dstr, fullPath, baseName, baseDir, c, startBeat, synth;
    var names, sidecarPath, stemsDir, ffmpegPath, ffprobePath;
    var sanitize, writeSidecar, doSplit, mkDirIfNeeded, findBin, debug, makeFinalize, finalize, didFinalize;

    debug = true;         // set false to quiet logs
    didFinalize = false;  // guard against double finalize

    // sanitize keys for filenames
    sanitize = { |str|
        var s;
        s = str.asString;
        s = s.collect({ |ch| if(ch.isAlphaNum or: { [$_, $., $-, $ ].includes(ch) }) { ch } { $_ } }).join.replace(" ", "_");
        s
    };

    // key names in write order
    names = (tracks.collect({ |mc| var n; n = { mc.name }.try({ nil }); (n ?? { mc.asString }).asString }))
          ++ (returns.collect({ |mc| var n; n = { mc.name }.try({ nil }); (n ?? { mc.asString }).asString }));

    // input bus indices
    tIdx = tracks.collect({ |mc| { mc.inbus.index }.try({ nil }) }).reject(_.isNil);
    rIdx = returns.collect({ |mc| { mc.inbus.index }.try({ nil }) }).reject(_.isNil);
    idxs = tIdx ++ rIdx;

    if(idxs.isEmpty) {
        "stemDiskStart - no valid stem buses".warn;
        ^{ |beats=0| nil };
    };

    // destination folder
    if(dirPath.isNil or: { dirPath == "" }) {
        dirPath = (~stemBaseDir ? (Platform.userHomeDir +/+ "recordings"));
    };
    if(File.exists(dirPath).not) { File.mkdir(dirPath); ("created " ++ dirPath).postln; };

    // timestamped base
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
    stemsDir = baseDir +/+ (baseName ++ "-stems");

    // utils
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

    ffmpegPath  = findBin.([ "/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg", "/usr/bin/ffmpeg", "ffmpeg" ]);
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
            cmd.unixCmd; // stderr prints in post window
            (" → wrote " ++ outName ++ "  L=c" ++ lch ++ " R=c" ++ rch ++ " key=" ++ key).postln;

            i = i + 1;
        };

        ("✅ stems written to " ++ stemsDir).postln;
        nil
    };

    // builds a finalize closure captured to current buf and synth
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
                s.sync;     // makes the WAV header safe to open

                if(autoSplit) {
                    ("[finalize] splitting in 0.3s").postln;
                    0.3.wait;
                    doSplit.();
                }{
                    ("autoSplit false; stems not split. Sidecar at " ++ sidecarPath).postln;
                };

                ("[finalize] freeing buffer").postln;
                if(buf.notNil) { buf.free };
                ("[finalize] done").postln;
            }).play(AppClock);
            nil
        };
        nil
    };

    // schedule writer on next bar
    c = clock ?? { thisThread.clock ?? TempoClock.default };
    startBeat = c.beats.ceil(1.0);

    defName = \__stemDiskOut__;
    SynthDef(defName, { |bufnum=0|
        var sig, ins;
        ins = Array.fill(idxs.size, { |j| In.ar(idxs[j], 2) });
        sig = ins.flat; // interleaved stereo pairs
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
        synth = Synth.new(defName, [\bufnum, buf], s, addAction);
        makeFinalize.();  // bind finalize to current buf and synth
        ("stemDisk start " ++ startBeat ++ " → " ++ fullPath ++ "  chans " ++ numChans).postln;

        // stash a tiny context for manual helpers
        ~stemRec = (
            baseName: baseName,
            fullPath: fullPath,
            stemsDir: stemsDir,
            sidecarPath: sidecarPath,
            finalize: { finalize.() }   // safe callable
        );
        nil
    });

    // return a scheduled stopper
    ^{ |beats=1|
        var stopBeat;
        stopBeat = c.beats + beats;
        ("stemDisk stop scheduled at " ++ stopBeat ++ " on " ++ c).postln;
        c.schedAbs(stopBeat, {
            ("stemDisk stop firing at " ++ stopBeat).postln;
            finalize.();
            nil
        })
    };
};

// manual immediate stop helper, safe from the interpreter
~stemStopNow = {
    if(~stemRec.isNil) { "stemStopNow: no active stem recording".warn; ^nil };
    ("stemStopNow called").postln;
    if(~stemRec[\finalize].notNil) { ~stemRec[\finalize].value } { "stemStopNow: no finalize closure".warn };
    nil
};
)

