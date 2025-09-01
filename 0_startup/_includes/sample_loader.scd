// sample_loader.scd
// version 2025-09-01 15:36:09 CDT
// sample loader and audition helpers
// no Ndefs created here
// no right parens in comments

(
var exts, count, startTime, auditionOut,
    symFromPath, folderKeyFrom, isAudioName, addBuf, loadDir,
    postTree, listKeys, keysIn, firstIn, getSample, findSample,
    playBufFallbackMono, playBufFallbackStereo,
    probeOutputsOneShot, setDefaultOut,
    f_getSampleSmart;

// exported state
~samplesRoot = nil;
~samplesTree = IdentityDictionary.new;

// config
exts = [ "wav", "aif", "aiff", "flac" ];
auditionOut = 0;

// global normalizer returns Symbol
// treats space dot dash as underscore and collapses doubles
~canon = { |x|
    var s;
    s = x.asString.toLower;
    s = s.replace($ , $_).replace($., $_).replace($-, $_);
    while({ s.contains("__") }, { s = s.replace("__", "_") });
    s.asSymbol
};

// filename to symbol with underscores
symFromPath = { |str|
    var base;
    base = PathName(str).fileNameWithoutExtension;
    base = base.replace($ , $_);
    base = base.replace($., $_);
    base = base.replace($-, $_);
    base.asSymbol
};

// derive folder symbol from directory path
folderKeyFrom = { |dirPath|
    var std, parts, nonEmpty, lastStr, sym;
    std = dirPath.standardizePath;
    parts = std.split($/);
    nonEmpty = parts.select({ |s| s.notNil and: { s.size > 0 } });
    lastStr = nonEmpty.isEmpty.if({ "root" }, { nonEmpty.last });
    lastStr = lastStr.replace($ , $_).replace($-, $_);
    sym = lastStr.asSymbol;
    sym
};

isAudioName = { |fileName|
    var low;
    low = fileName.asString.toLower;
    exts.any({ |x| low.endsWith("." ++ x) })
};

addBuf = { |folderSym, filePath|
    var key, buf;
    key = symFromPath.(filePath);
    if(~samplesTree[folderSym].isNil) { ~samplesTree[folderSym] = IdentityDictionary.new };
    buf = Buffer.read(s, filePath, action: { |b|
        ["[[ready],", folderSym, ",", key].join(" ").postln;
    });
    ~samplesTree[folderSym][key] = buf;
    count = count + 1;
    ["[[add],", folderSym, ",", key].join(" ").postln;
};

loadDir = { |dirPath|
    var pathStd, pn, ents, fkey;
    pathStd = dirPath.standardizePath;
    pn = PathName(pathStd);
    if(pn.isNil) { ["[sample_loader] bad path", dirPath].postln; ^nil };
    if(pn.isFolder.not) { ["[sample_loader] not a folder", pathStd].postln; ^nil };
    fkey = folderKeyFrom.(pathStd);
    ents = pn.entries;
    ents.do({ |e|
        var name;
        name = e.fileName.asString;
        if(e.isFile and: { isAudioName.(name) }) {
            addBuf.(fkey, e.fullPath);
        }{
            if(e.isFolder) { loadDir.(e.fullPath) };
        };
    });
};

postTree = {
    var keys;
    keys = ~samplesTree.keys.asArray.sort;
    keys.do({ |k|
        k.postln;
        ~samplesTree[k].keys.asArray.sort.do({ |kk| "  ".post; kk.postln });
    });
};

listKeys = {
    var keys;
    keys = ~samplesTree.keys.asArray.sort;
    ^keys
};

keysIn = { |folderSym|
    var d, keys;
    d = ~samplesTree[folderSym];
    if(d.isNil) { ^[] };
    keys = d.keys.asArray.sort;
    ^keys
};

firstIn = { |folderSym|
    var d;
    d = ~samplesTree[folderSym];
    if(d.isNil) { ^nil };
    ^d.values.asArray.detect({ |b| b.notNil })
};

getSample = { |a, b=nil|
    var d, out;
    if(b.isNil) { ^~samplesTree[a] }{
        d = ~samplesTree[a];
        if(d.notNil) {
            out = d[b];
            if(out.notNil) { ^out };
        };
        ~samplesTree.keysValuesDo({ |k, dd|
            if(out.isNil and: { dd.notNil }) {
                var hit;
                hit = dd[b];
                if(hit.notNil) { out = hit };
            };
        });
        if(out.isNil) { ["[getSample] not found", a, b].join(" ").postln };
        ^out
    };
};

findSample = { |fileSym|
    var out;
    out = nil;
    ~samplesTree.valuesDo({ |d|
        if(out.isNil and: { d.notNil }) {
            var h;
            h = d[fileSym];
            if(h.notNil) { out = h };
        };
    });
    if(out.isNil) { ["[findSample] not found", fileSym].join(" ").postln };
    ^out
};

// tolerant lookup exact first then canonical
f_getSampleSmart = { |folderSym, fileSym=nil|
    var tree, sub, buf, fs, ks, canon;
    canon = ~canon;
    tree  = ~samplesTree;
    if(tree.isNil) { ^nil };

    sub = tree[folderSym];
    if(sub.notNil) {
        if(fileSym.isNil) { ^sub };
        buf = sub[fileSym];
        if(buf.notNil) { ^buf };
    };

    fs = canon.(folderSym);
    sub = nil;
    tree.keysDo({ |k| if(canon.(k) == fs) { sub = tree[k] } });
    if(sub.isNil) { ^nil };
    if(fileSym.isNil) { ^sub };

    buf = sub[fileSym];
    if(buf.notNil) { ^buf };

    ks = canon.(fileSym);
    buf = nil;
    sub.keysDo({ |k| if(canon.(k) == ks) { buf = sub[k] } });
    ^buf
};

// public api  tilded names only
~loadSamplesRecursive = { |path|
    var elapsed, std;
    count = 0;
    startTime = Main.elapsedTime;
    std = path.standardizePath;
    ~samplesRoot = std;
    ["[[sample_loader] root,", std, "]"].join(" ").postln;
    loadDir.(std);
    elapsed = Main.elapsedTime - startTime;
    ["[sample_loader] Loaded", count, "files in", elapsed.round(0.01), "s"].join(" ").postln;
};

~printTree      = postTree;
~listKeys       = listKeys;
~keysIn         = keysIn;
~firstIn        = firstIn;
~getSample      = getSample;
~findSample     = findSample;
~getSampleSmart = f_getSampleSmart;

// fallback players
playBufFallbackMono = { |bnum, out=0, amp=0.8, rate=1, loop=0, start=0.0, pan=0|
    var synth;
    synth = {
        var frames, startSamp, sig;
        frames    = BufFrames.kr(bnum);
        startSamp = (start.clip(0, 1) * frames).round(1);
        sig = PlayBuf.ar(1, bnum, rate * BufRateScale.kr(bnum), startPos: startSamp, loop: loop, doneAction: 0);
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }.play;
    ^synth
};

playBufFallbackStereo = { |bnum, out=0, amp=0.8, rate=1, loop=0, start=0.0, pan=0|
    var synth;
    synth = {
        var frames, startSamp, sig, pair;
        frames    = BufFrames.kr(bnum);
        startSamp = (start.clip(0, 1) * frames).round(1);
        sig = PlayBuf.ar(2, bnum, rate * BufRateScale.kr(bnum), startPos: startSamp, loop: loop, doneAction: 0);
        pair = sig.isArray.if({ sig[0..1] }, { [sig, sig] });
        Out.ar(out, Balance2.ar(pair[0], pair[1], pan, amp));
    }.play;
    ^synth
};

// audition wrapper uses your defs if present else falls back
~playBuf = { |bufOrBufnum, out=nil, amp=0.8, rate=1, loop=0, start=0.0, pan=0, numCh=nil|
    var isBuf, bnum, chs, def, hasDef, node;
    out = out ?? { auditionOut };
    if(bufOrBufnum.isNil) { "[playBuf] nil buffer".postln; ^nil };
    isBuf = bufOrBufnum.isKindOf(Buffer);
    if(isBuf.not and: { bufOrBufnum.isNumber.not }) { "[playBuf] received non buffer and non bufnum".postln; ^nil };
    bnum = isBuf.if({ bufOrBufnum.bufnum }, { bufOrBufnum });
    chs  = numCh ?? { isBuf.if({ bufOrBufnum.numChannels }, { 2 }) };
    def  = (chs <= 1).if({ \playBuf_m }, { \playBuf_s });
    hasDef = SynthDescLib.global.at(def).notNil;
    if(hasDef) {
        node = Synth(def, [ \buf, bnum, \out, out, \amp, amp, \rate, rate, \loop, loop, \start, start, \pan, pan ]);
        ^node;
    }{
        node = (chs <= 1).if({
            playBufFallbackMono.(bnum, out, amp, rate, loop, start, pan)
        },{ 
            playBufFallbackStereo.(bnum, out, amp, rate, loop, start, pan)
        });
        ^node;
    };
};

// output probe one shot
probeOutputsOneShot = { |dur=0.25|
    var n, pairs, r;
    n = s.options.numOutputBusChannels;
    pairs = (0, 2 .. (n - 2));
    r = Routine({
        pairs.do({ |ch|
            ("[probe once] out: " ++ ch).postln;
            {
                var env, sig;
                env = EnvGen.kr(Env.perc(0.005, dur), doneAction: 2);
                sig = WhiteNoise.ar(0.05) * env;
                OffsetOut.ar(ch, sig ! 2);
            }.play;
            dur.wait;
        });
    });
    r.play;
    ^r
};

setDefaultOut = { |bus|
    auditionOut = bus;
    ("[auditionOut set to " ++ bus ++ "]").postln;
};

~probeOutputs  = probeOutputsOneShot;
~setDefaultOut = setDefaultOut;

"[[sample_loader] ready]".postln;
)

