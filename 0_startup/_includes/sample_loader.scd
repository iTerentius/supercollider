
// sample_loader.scd
// version 2025-09-01 auto mono or stereo audition recursive loader no right parens in comments

// state
if(~samplesTree.isNil) { ~samplesTree = IdentityDictionary.new };
if(~auditionOut.isNil) { ~auditionOut = 0 };
if(~bufMeta.isNil) { ~bufMeta = IdentityDictionary.new };

// helpers
~canon = { |x|
    var s;
    s = x.asString;
    s = s.toLower;
    s = s.replace($ , $_);
    s = s.replace($-, $_);
    s = s.replace($., $_);
    s = s.replace($[, $_);
    s = s.replace($], $_);
    s.asSymbol
};

~postRoot = { |root|
    var msg;
    msg = "[sample_loader] root, " ++ root ++ " ";
    msg.postln;
};

// ensure audition synthdefs mono and stereo
~ensureAuditionDefs = {
    var haveM, haveS;

    haveM = SynthDescLib.global.at(\audPBmono).notNil;
    haveS = SynthDescLib.global.at(\audPBstereo).notNil;

    if(haveM.not) {
        SynthDef(\audPBmono, { |out=0, buf=0, rate=1, amp=0.8, startPos=0, loop=0, pan=0|
            var sig;
            sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, startPos: startPos, loop: loop);
            sig = Pan2.ar(sig, pan);
            OffsetOut.ar(out, sig * amp);
        }).add;
    };

    if(haveS.not) {
        SynthDef(\audPBstereo, { |out=0, buf=0, rate=1, amp=0.8, startPos=0, loop=0, pan=0|
            var pair, left, right, outPair;
            pair = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startPos, loop: loop);
            left = pair[0];
            right = pair[1];
            outPair = Balance2.ar(left, right, pan);
            OffsetOut.ar(out, outPair * amp);
        }).add;
    };
};

// public api
~setDefaultOut = { |pair=0|
    var msg;
    ~auditionOut = pair;
    msg = "[auditionOut set to " ++ pair ++ "]";
    msg.postln;
};

~printTree = {
    var rec;
    rec = { |d, indent=0|
        d.keysValuesDo { |k, v|
            (((" " ! indent).join) ++ k.asString).postln;
            if(v.isKindOf(Dictionary) or: { v.isKindOf(IdentityDictionary) }) { rec.(v, indent+2) };
        };
    };
    rec.(~samplesTree, 0);
};

~getSample = { |folderSym, fileSym|
    var sub, buf;
    sub = ~samplesTree[folderSym];
    if(sub.isNil) { buf = nil } { buf = sub[fileSym] };
    buf
};

// audition player auto mono or stereo
~playBuf = { |buf, out, amp=0.8, rate=1, loop=0, start=0.0, pan=0|
    var outBus, bnum, chs, frames, startPos, instr;

    if(buf.isNil) { "[playBuf] nil buffer".postln; ^nil };

    // choose default output here, not in the arg list
    outBus = out;
    if(outBus.isNil) { outBus = ~auditionOut };

    // make sure audition defs exist
    ~ensureAuditionDefs.();

    bnum    = buf.bufnum;
    chs     = if(buf.numChannels.isNil) { 2 } { buf.numChannels };
    frames  = if(buf.numFrames.isNil)   { 0 } { buf.numFrames };
    startPos = (start.clip(0, 1) * frames).round(1);

    instr = if(chs == 1) { \audPBmono } { \audPBstereo };

    ^Synth(instr, [
        \out, outBus,
        \buf, bnum,
        \amp, amp,
        \rate, rate,
        \loop, loop,
        \startPos, startPos,
        \pan, pan
    ]);
};

// recursive loader
~loadSamplesRecursive = { |dirPath|
    var root, count, t0, walk, addBuf, canonSym;

    // normalize to a safe symbol  lower and underscores
    canonSym = { |str|
        var s;
        s = str.asString.toLower.replace($ , $_).replace($-, $_).replace($., $_);
        s.asSymbol
    };

    count = 0;
    t0 = Main.elapsedTime;

    root = dirPath.asString.standardizePath;
    ("[sample_loader] root, " ++ root ++ " ").postln;

    addBuf = { |fpath|
        var parts, len, fname, folderName, base, nameParts, folderSym, fileSym, lower, ok;

        parts = fpath.split($/);
        len = parts.size;
        if(len < 1) { ^nil };

        fname = parts.last;
        folderName = (len >= 2).if({ parts[len-2] }, { "root" });

        lower = fpath.toLower;
        ok = lower.endsWith(".wav") or: { lower.endsWith(".aif") } or: { lower.endsWith(".aiff") } or: { lower.endsWith(".flac") };
        if(ok.not) { ^nil };

        // strip extension by splitting on dot and rejoining everything except final segment
        nameParts = fname.split($.);
        base = (nameParts.size > 1).if({
            nameParts.copyRange(0, nameParts.size - 2).join(".")
        },{
            fname
        });

        folderSym = canonSym.(folderName);
        base = base.replace($ , $_).replace($-, $_).replace($., $_);
        fileSym = base.asSymbol;

        if(~samplesTree[folderSym].isNil) {
            ~samplesTree[folderSym] = IdentityDictionary.new;
        };

        Buffer.read(s, fpath, action: { |b|
            var sub, ch;
            sub = ~samplesTree[folderSym];
            sub[fileSym] = b;
            ~samplesTree[folderSym] = sub;

            ch = if(b.numChannels.isNil) { 2 } { b.numChannels };
            ~bufMeta[b.bufnum] = ch;

            ("[[ready], " ++ folderSym ++ " , " ++ fileSym ++ "]").postln;
        });

        count = count + 1;
        ("[[add], " ++ folderSym ++ " , " ++ fileSym ++ "]").postln;
    };

    walk = { |path|
        var dir, entries;
        dir = PathName.new(path);
        if(dir.isFolder.not) {
            "[sample_loader] not a folder".warn;
            ^nil
        };
        entries = dir.entries;
        entries.do({ |child|
            if(child.isFolder) {
                walk.(child.fullPath);
            }{
                addBuf.(child.fullPath);
            };
        });
    };

    walk.(root);

    ("[sample_loader] Loaded " ++ count ++ " files in " ++ (Main.elapsedTime - t0).round(0.001) ++ " s").postln;
};

// 2025-09-02 — robust sample root resolver, tolerant key match, mono or stereo player, chop helper

(
// small utility to get whichever tree exists
if(~sampleRoot.isNil) {
    ~sampleRoot = {
        var root;
        root = ~samplesTree;
        if(root.isNil) { root = ~sampleTree };
        if(root.isNil) { "[sampleRoot] no ~samplesTree or ~sampleTree is defined".postln };
        ^root
    };
};

// optional quick inspector for the current tree
if(~listTopKeys.isNil) {
    ~listTopKeys = {
        var root, keys;
        root = ~sampleRoot.();
        if(root.isNil) { ^nil };
        keys = root.tryPerform(\keys) ? [];
        "[listTopKeys] top level keys → %".format(keys).postln;
        ^keys
    };
};

// tolerant key finder that accepts Symbol or String and ignores case and basic separators
if(~matchKey.isNil) {
    ~matchKey = { |dict, key|
        var dictKeys, normChar, normalize, target, chosen;
        dictKeys = dict.tryPerform(\keys) ? [];
        normChar = { |c| var ch; ch = c; if(ch == $_ or: { ch == $- } or: { ch == $\  }) { $_ } { ch.toLower } };
        normalize = { |s| var str, arr; str = s.asString; arr = str.collect(normChar); String.newFrom(arr) };
        target = normalize.(key);
        chosen = dictKeys.detect { |k| normalize.(k) == target };
        ^chosen
    };
};

// resolve either a Buffer or exact-ish keys into a Buffer with good error messages
if(~asBuf.isNil) {
    ~asBuf = { |a, b=nil, c=nil|
        var root, path, buf, v, k, step, levels, label, found;
        if(a.isKindOf(Buffer)) {
            buf = a;
            ^buf
        };
        root = ~sampleRoot.();
        if(root.isNil) { "[asBuf] no sample tree is available".postln; ^nil };
        path = [a, b, c].reject(_.isNil);
        label = path.collect(_.asString).join("/");

        v = root;
        levels = path.size;
        step = 0;
        while { step < levels } {
            k = path[step];
            if(v.isKindOf(Buffer)) {
                "[asBuf] encountered a Buffer before finishing the path → %".format(label).postln;
                ^v
            };
            if(v.isNil) {
                "[asBuf] parent is nil at step % for %".format(step + 1, label).postln;
                ^nil
            };
            found = v.at(k);
            if(found.isNil) {
                // try tolerant match
                var mk;
                mk = ~matchKey.(v, k);
                if(mk.notNil) { found = v.at(mk) };
            };
            if(found.isNil) {
                "[asBuf] not found at level % for key % in %".format(step + 1, k, label).postln;
                ^nil
            };
            v = found;
            step = step + 1;
        };

        if(v.isKindOf(Buffer)) { ^v };
        "[asBuf] resolved % but final value is not a Buffer".format(label).postln;
        ^nil
    };
};

// mono player duplicated to stereo
SynthDef(\st_playbuf_mono, { |out=0, buf=0, amp=0.5, rate=1, startPos=0, pan=0|
    var rateScale, sig, l, r;
    rateScale = BufRateScale.kr(buf) * rate;
    sig = PlayBuf.ar(1, buf, rateScale, startPos: startPos, doneAction: 2);
    l = sig; r = sig;
    OffsetOut.ar(out, Balance2.ar(l, r, pan, amp));
}).add;

// stereo player
SynthDef(\st_playbuf_stereo, { |out=0, buf=0, amp=0.5, rate=1, startPos=0, pan=0|
    var rateScale, sig, l, r;
    rateScale = BufRateScale.kr(buf) * rate;
    sig = PlayBuf.ar(2, buf, rateScale, startPos: startPos, doneAction: 2);
    l = sig[0]; r = sig[1];
    OffsetOut.ar(out, Balance2.ar(l, r, pan, amp));
}).add;

// stereo-ensuring player that accepts Buffer or keys
if(~playBuf.isNil) {
    ~playBuf = { |a, b=nil, c=nil, out=0, amp=0.6, rate=1, startPos=0, pan=0|
        var buf, ch, defName;
        buf = ~asBuf.(a, b, c);
        if(buf.isNil) { ^nil };
        ch = buf.numChannels ? 2;
        defName = (ch == 1).if({ \st_playbuf_mono }, { \st_playbuf_stereo });
        Synth(defName, [\out, out, \buf, buf, \amp, amp, \rate, rate, \startPos, startPos, \pan, pan])
    };
};

// auto-pick your mono or stereo chop def by buffer channels
if(~chopInstrForBuf.isNil) {
    ~chopInstrForBuf = { |buf|
        var ch;
        ch = buf.numChannels ? 2;
        if(ch == 1) { \chop_pb_m } { \chop_pb_s }
    };
};

// convenience helper to trigger chop on a Buffer or keys
if(~chopSample.isNil) {
    ~chopSample = { |a, b=nil, c=nil, out=0, amp=0.5, rate=1|
        var buf, instr;
        buf = ~asBuf.(a, b, c);
        if(buf.isNil) { "[chopSample] could not resolve to a Buffer".postln; ^nil };
        instr = ~chopInstrForBuf.(buf);
        Synth(instr, [\buf, buf, \out, out, \amp, amp, \rate, rate])
    };
};
)

