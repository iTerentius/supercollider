// 2025-10-05 stemDiskStart v2 - tail placement, ignore sends, warn - no close paren in comments

(
~stemDiskStart = { |tracks=#[], returns=#[], fileBase="take", dirPath="", clock=nil, addAction=\addToTail|
    var tIdx, rIdx, idxs, numChans, buf, defName, d, dstr, fullPath, c, startBeat, synth;

    // resolve dry indices using .inbus.index; warn on objects that don't have it
    tIdx = tracks.collect({ |mc|
        var idx = { mc.inbus.index }.try({ nil });
        if(idx.isNil) { ("skip track " ++ mc.asString ++ " - no inbus.index").warn };
        idx
    }).reject(_.isNil);

    rIdx = returns.collect({ |mc|
        var idx = { mc.inbus.index }.try({ nil });
        if(idx.isNil) { ("skip return " ++ mc.asString ++ " - no inbus.index").warn };
        idx
    }).reject(_.isNil);

    idxs = tIdx ++ rIdx;

    if(idxs.isEmpty) {
        "stemDiskStart - no valid stem buses".warn;
        ^{ |beats=0| nil };
    };

    // destination path
    if(dirPath.isNil or: { dirPath == "" }) { dirPath = Platform.userHomeDir +/+ "recordings" };
    if(File.exists(dirPath).not) { File.mkdir(dirPath); ("created " ++ dirPath).postln; };

    d = Date.getDate;
    dstr = d.year.asString ++ "-" ++ d.month.asString.padLeft(2,"0") ++ "-" ++ d.day.asString.padLeft(2,"0")
        ++ "_" ++ d.hour.asString ++ "-" ++ d.minute.asString ++ "-" ++ d.second.asString;
    fullPath = dirPath +/+ (fileBase ++ "_" ++ dstr ++ ".wav");

    // master stereo plus one stereo pair per stem
    numChans = 2 + (idxs.size * 2);

    // streaming buffer and open file for DiskOut
    buf = Buffer.alloc(s, 65536, numChans);
    buf.write(fullPath, "wav", "float", 0, 0, true);  // leaveOpen true

    // define the writer graph with your exact bus list
    defName = ("StemDiskOut_" ++ dstr).asSymbol;
    SynthDef(defName, {
        var chans, sig;
        chans = [ In.ar(0, 2) ];                 // master L/R first
        idxs.do({ |ix| chans = chans.add(In.ar(ix, 2)) });  // then each stem stereo
        sig = chans.flat;                         // single multichannel signal
        DiskOut.ar(\bufnum.kr(0), sig);          // silent file writer
    }).add;

    // schedule start on the next bar at the TAIL of defaultGroup
    c = clock ? TempoClock.default;
    startBeat = c.nextBar;
    c.schedAbs(startBeat, {
        ("stemDisk start " ++ startBeat ++ " chans " ++ numChans
            ++ "\nfile " ++ fullPath
            ++ "\nidxs " ++ idxs.asString).postln;

        synth = Synth(defName, [\bufnum, buf.bufnum], target: s.defaultGroup, addAction: addAction);
        nil
    });

    // return a stopper to close and free cleanly
    ^{ |beats=1|
        var stopBeat;
        stopBeat = c.beats + beats;
        c.schedAbs(stopBeat, {
            ("stemDisk stop " ++ stopBeat).postln;
            if(synth.notNil) { synth.free };
            buf.close; buf.free;
            nil
        })
    };
};
)

