// version 2025-09-02 21:05 America/Chicago sample loader and stereo helpers in one block

(
/* =========================================================
   1 load samples and build a tree
   prints [add] when queuing and [ready] when a Buffer finishes
   returns the tree and stores to ~samplesTree and ~sampleTree
   ========================================================= */

// 2025-09-02 21:20 America/Chicago — loader with robust root key and guaranteed tree set


~loadSamplesRecursive = { |rootPath|
    var server, expanded, rootPN, tree, exts;
    var deriveKey, toSampleKey;
    var entries, rootFiles, subfolders;
    var ensureFolder, registerFile, loadFile;
    var registered, start, elapsed, total;

    server   = s;
    expanded = rootPath.standardizePath;

    if(File.exists(expanded).not) {
        "[sample_loader] ERROR root missing → %".format(expanded).postln;
        ^nil
    };

    rootPN = PathName.new(expanded);

    exts = ["wav", "aif", "aiff", "flac"];

    // folder key from last non-empty path segment
    deriveKey = { |pn|
        var segs, last, norm;
        segs = pn.fullPath.split($/).reject({ |s| s.isEmpty });
        last = segs.isEmpty.if({ "" }, { segs.last });
        norm = last.asString.toLower;
        if(norm.size == 0) { ^\root };
        ^norm.asSymbol
    };

    // sample key from filename, dots and spaces to underscores
    toSampleKey = { |name|
        var base;
        base = name.asString;
        base = base.replace($., $_);
        base = base.replace($ , $_);
        base = base.replace($-, $_);
        ^base.asSymbol
    };

    tree = IdentityDictionary.new;
    ~samplesTree = tree;
    ~sampleTree  = tree;   // mirror for older code

    "[sample_loader] REGISTER start → %".format(rootPN.fullPath).postln;

    start = SystemClock.seconds;
    registered = List.new;
    total = 0;

    // helper to ensure a folder dict exists
    ensureFolder = { |folderKey|
        if(tree.includesKey(folderKey).not) {
            "[ensure] make folder key → %".format(folderKey).postln;
            tree.put(folderKey, IdentityDictionary.new);
        }{
            "[ensure] folder key already present → %".format(folderKey).postln;
        };
        ^tree.at(folderKey)
    };

    // first pass: register the file path as a placeholder so keys appear immediately
    registerFile = { |folderKey, filePN|
        var ext, base, sampleKey, subdict, info;
        ext = filePN.extension.asString.toLower;

        "[try] register % ext % → folder %"
        .format(filePN.fileName, ext, folderKey).postln;

        if(exts.detect({ |e| e == ext }).isNil) {
            "[skip] unsupported ext for %".format(filePN.fileName).postln;
            ^nil
        };

        base      = filePN.fileNameWithoutExtension;
        sampleKey = toSampleKey.(base);
        subdict   = ensureFolder.(folderKey);

        // store a small info dict for now; replaced by Buffer on load
        info = (path: filePN.fullPath, ext: ext, status: \queued);
        subdict.put(sampleKey, info);

        "[[add], % , %]".format(folderKey.asString, sampleKey.asString).postln;

        registered.add([folderKey, sampleKey, filePN.fullPath]);
        total = total + 1;
    };

    // second pass: actually load buffers and replace placeholders
    loadFile = { |folderKey, sampleKey, fullPath|
        Buffer.read(server, fullPath, action: { |b|
            tree[folderKey][sampleKey] = b;
            "[[ready], % , %]".format(folderKey.asString, sampleKey.asString).postln;
        });
    };

    // enumerate root entries
    entries    = rootPN.entries ? [];
    rootFiles  = entries.select(_.isFile) ? [];
    subfolders = entries.select(_.isFolder) ? [];

    "[debug] entries %  rootFiles %  subfolders %"
    .format(entries.size, rootFiles.size, subfolders.size).postln;

    // register loose files at root
    if(rootFiles.size > 0) {
        var rootKey;
        rootKey = deriveKey.(rootPN);
        "[root] register % files under → %".format(rootFiles.size, rootKey).postln;
        rootFiles.do { |fp| registerFile.(rootKey, fp) };
    }{
        "[root] no loose files".postln;
    };

    // register files in each immediate subfolder
    if(subfolders.size > 0) {
        "[folders] iterating % subfolders".format(subfolders.size).postln;
        subfolders.do { |folderPN|
            var folderKey, files;
            folderKey = deriveKey.(folderPN);
            files = folderPN.entries.select(_.isFile) ? [];
            "[folder] % has % files".format(folderKey, files.size).postln;
            files.do { |fp| registerFile.(folderKey, fp) };
        };
    }{
        "[folders] none".postln;
    };

    // keys should be visible now
    "[registered] keys → %".format((tree.keys ? []).asArray).postln;

    elapsed = (SystemClock.seconds - start).round(0.001);
    "[registered] queued % files in % s".format(total, elapsed).postln;

    // kick off buffer loads
    registered.do { |triple|
        loadFile.(triple[0], triple[1], triple[2])
    };

    ^tree
};
/* =========================================================

   2 tiny stereo safe players
   no comments with closing parens and vars at top of functions
   ========================================================= */

s.waitForBoot {
    SynthDef(\st_play_mono, { |out=0, buf=0, amp=0.5, rate=1, startPos=0, pan=0|
        var rs, sig, l, r;
        rs  = BufRateScale.kr(buf) * rate;
        sig = PlayBuf.ar(1, buf, rs, startPos: startPos, doneAction: 2);
        l   = sig; r = sig;
        OffsetOut.ar(out, Balance2.ar(l, r, pan, amp));
    }).add;

    SynthDef(\st_play_stereo, { |out=0, buf=0, amp=0.5, rate=1, startPos=0, pan=0|
        var rs, sig, l, r;
        rs  = BufRateScale.kr(buf) * rate;
        sig = PlayBuf.ar(2, buf, rs, startPos: startPos, doneAction: 2);
        l   = sig[0]; r = sig[1];
        OffsetOut.ar(out, Balance2.ar(l, r, pan, amp));
    }).add;
};

/* =========================================================
   3 helpers to inspect the tree, resolve buffers, and play
   ========================================================= */

~listTopKeys = {
    var root, keys;
    root = ~samplesTree; if(root.isNil and: { ~sampleTree.notNil }) { root = ~sampleTree };
    if(root.isNil) { "[listTopKeys] no sample tree".postln; ^nil };
    keys = root.tryPerform(\keys) ? [];
    "[listTopKeys] top keys → %".format(keys).postln;
    ^keys
};

~asBuf = { |a, b=nil, c=nil|
    var t, path, v1, v2, v3, buf;
    if(a.isKindOf(Buffer)) {
        buf = a;
        ^buf
    };
    t = ~samplesTree; if(t.isNil and: { ~sampleTree.notNil }) { t = ~sampleTree };
    if(t.isNil) { "[asBuf] no sample tree available".postln; ^nil };
    path = [a, b, c].reject(_.isNil);

    v1 = t.at(path[0]);
    if(path.size == 1) { ^(v1.isKindOf(Buffer).if({ v1 }, { nil })) };

    v2 = v1.tryPerform(\at, path[1]);
    if(path.size == 2) { ^(v2.isKindOf(Buffer).if({ v2 }, { nil })) };

    v3 = v2.tryPerform(\at, path[2]);
    ^(v3.isKindOf(Buffer).if({ v3 }, { nil }))
};

~playBuf = { |a, b=nil, c=nil, out=0, amp=0.6, rate=1, startPos=0, pan=0|
    var buf, ch, defName;
    buf = ~asBuf.(a, b, c);
    if(buf.isNil) { "[playBuf] buf is nil".postln; ^nil };
    ch = buf.numChannels ? 2;
    defName = (ch == 1).if({ \st_play_mono }, { \st_play_stereo });
    "[playBuf] bufnum:% channels:% def:% out:%"
    .format(buf.bufnum, ch, defName, out).postln;
    Synth(defName, [\out, out, \buf, buf, \amp, amp, \rate, rate,
                    \startPos, startPos, \pan, pan])
};

~chopInstrForBuf = { |buf|
    var ch;
    ch = buf.numChannels ? 2;
    if(ch == 1) { \chop_pb_m } { \chop_pb_s }
};

~chopSample = { |a, b=nil, c=nil, out=0, amp=0.5, rate=1|
    var buf, instr;
    buf = ~asBuf.(a, b, c);
    if(buf.isNil) { "[chopSample] could not resolve to a Buffer".postln; ^nil };
    instr = ~chopInstrForBuf.(buf);
    Synth(instr, [\buf, buf, \out, out, \amp, amp, \rate, rate])
};

)  // end single outer block

