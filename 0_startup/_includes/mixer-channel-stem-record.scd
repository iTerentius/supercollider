// 2025-10-05 19:50 CDT  stemDiskStart v3a  fixes padLeft char bug and improves ffmpeg lookup  no numbered parens in comments

(
~stemDiskStart = { |tracks=#[], returns=#[], fileBase="take", dirPath="", clock=nil, addAction=\addToTail, autoSplit=true, splitCodec=\pcm_s24le|
    var tIdx, rIdx, idxs, numChans, buf, defName, d, dstr, fullPath, baseName, baseDir, c, startBeat, synth;
    var names, sidecarPath, stemsDir, ffmpegPath, ffprobePath;
    var sanitize, writeSidecar, doSplit, mkDirIfNeeded, findBin;

    // helper to sanitize key names for filenames
    sanitize = { |str|
        var s;
        s = str.asString;
        s = s.collect({ |ch| if(ch.isAlphaNum or: { [$_, $., $-, $ ].includes(ch) }) { ch } { $_ } }).join.replace(" ", "_");
        s
    };

    // collect the printed key names in the order they will be written
    names = (tracks.collect({ |mc| var n; n = { mc.name }.try({ nil }); (n ?? { mc.asString }).asString })) ++
            (returns.collect({ |mc| var n; n = { mc.name }.try({ nil }); (n ?? { mc.asString }).asString }));

    // resolve dry indices using .inbus.index
    tIdx = tracks.collect({ |mc| { mc.inbus.index }.try({ nil }) }).reject(_.isNil);
    rIdx = returns.collect({ |mc| { mc.inbus.index }.try({ nil }) }).reject(_.isNil);
    idxs = tIdx ++ rIdx;

    if(idxs.isEmpty) {
        "stemDiskStart - no valid stem buses".warn;
        ^{ |beats=0| nil };
    };

    // destination path
    if(dirPath.isNil or: { dirPath == "" }) { dirPath = Platform.userHomeDir +/+ "recordings" };
    if(File.exists(dirPath).not) { File.mkdir(dirPath); ("created " ++ dirPath).postln; };

    d = Date.getDate;
    // use "0" string for pad
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

    mkDirIfNeeded = { |path| if(File.exists(path).not) { File.mkdir(path) } };

    writeSidecar = {
        var f;
        f = File(sidecarPath, "w");
        names.do { |nm| f.write(nm.asString ++ "\n") };
        f.close;
        ("wrote stem name sidecar: " ++ sidecarPath).postln;
    };

    // find binaries either by absolute path or via `which`
    findBin = { |cands|
        var p;
        p = cands.detect { |p0| File.exists(p0) };
        if(p.isNil) {
            var whichPath;
            whichPath = Pipe.read("which " ++ cands.last, "r", 1.0);
            if(whichPath.notNil) {
                whichPath = whichPath.trim;
                if(whichPath.size > 0 and: { File.exists(whichPath) }) { p = whichPath };
            };
        };
        p
    };

    ffmpegPath  = findBin.([ "/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg", "/usr/bin/ffmpeg", "ffmpeg" ]);
    ffprobePath = findBin.([ "/opt/homebrew/bin/ffprobe", "/usr/local/bin/ffprobe", "/usr/bin/ffprobe", "ffprobe" ]);

    doSplit = {
        var probeCmd, chCountStr, chCount, pairs, i, key, keySafe, lch, rch, outName, codec;

        if(ffmpegPath.isNil or: { ffprobePath.isNil }) {
            "autoSplit: ffmpeg or ffprobe not found on PATH; skipped".warn;
            ^nil
        };

        probeCmd = ffprobePath ++ " -v error -select_streams a:0 -show_entries stream=channels -of default=nw=1:nk=1 " ++ fullPath.escapeChar($ );
        chCountStr = Pipe.read(probeCmd, "r", 2.0).trim;
        if(chCountStr.isNil or: { chCountStr.isEmpty }) { "autoSplit: could not read channel count; skipped".warn; ^nil };
        chCount = chCountStr.asInteger;
        if(chCount.odd) { ("autoSplit: odd channel count " ++ chCount ++ " last channel will be ignored").warn };
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

            Pipe.read(
                ffmpegPath ++ " -y -i " ++ fullPath.escapeChar($ ) ++
                " -filter_complex " ++ ("\"pan=stereo|FL=c" ++ lch ++ "|FR=c" ++ rch ++ "\"") ++
                " -c:a " ++ codec ++
                " -metadata title=" ++ key.asString.escapeChar($ ) ++
                " " ++ outName.escapeChar($ ),
                "r", 120.0
            );
            (" → wrote " ++ outName ++ "  L=c" ++ lch ++ " R=c" ++ rch ++ " key=" ++ key).postln;
            i = i + 1;
        };

        ("✅ stems written to " ++ stemsDir).postln;
        nil
    };

    // choose clock and schedule start on next bar
    c = clock ?? { thisThread.clock ?? TempoClock.default };
    startBeat = (c.beats.ceil(1.0)); // next bar

    defName = \__stemDiskOut__;
    SynthDef(defName, { |bufnum=0|
        var sig, ins, i;
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

        ("stemDisk start " ++ startBeat ++ " → " ++ fullPath ++ "  chans " ++ numChans).postln;
        nil
    });

    // return a stopper
    ^{ |beats=1|
        var stopBeat;
        stopBeat = c.beats + beats;
        c.schedAbs(stopBeat, {
            ("stemDisk stop " ++ stopBeat).postln;
            if(synth.notNil) { synth.free };
            buf.close;
            buf.free;

            if(autoSplit) {
                AppClock.sched(0.2, { doSplit.(); nil });
            }{
                ("autoSplit is false; stems not split. Sidecar at " ++ sidecarPath).postln;
            };
            nil
        })
    };
};
)

