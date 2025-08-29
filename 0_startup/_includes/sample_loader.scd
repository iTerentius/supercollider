(
// ===== RECURSIVE SAMPLE LOADER (robust + verbose, SC-legal) =====

// ---------- Config ----------
~sampleRoot = Platform.userHomeDir +/+ "Music/supercollider/_samples"; // <- change if needed
~allowedExts = ["wav","aiff","aif","flac","ogg"];  // keep lowercase
~sampleLoaderVerbose = true;                      // set false to reduce logs

// ---------- State ----------
~sampleTree = IdentityDictionary.new;

// ---------- Free previous buffers ----------
~freeSamples = {
    var freeDict;
    freeDict = { |dict|
        dict.keysValuesDo { |k, v|
            if(v.isKindOf(Buffer)) { v.free };
            if(v.isKindOf(Dictionary) or: { v.isKindOf(IdentityDictionary) }) { freeDict.(v) };
        };
    };
    freeDict.(~sampleTree);
    ~sampleTree = IdentityDictionary.new;
    if(~sampleLoaderVerbose) { "Freed old buffers".postln };
};

// ---------- Safe basename helper ----------
~basenameSym = { |pn|
    var n = pn.fileName;
    if(n.isNil or: { n.size == 0 }) {
        n = pn.fullPath.split($/).reject(_.isEmpty).last;
    };
    n.asSymbol;
};

// ---------- Recursive loader ----------
~loadSamplesRecursive = { |root|
    var loadFolder, rootPN, addedFolders=0, addedFiles=0;

    loadFolder = { |path, dict, depth=0|
        var isAllowed;  // declare once here

        // FOLDERS
        path.folders.do { |fd|
            var key = ~basenameSym.(fd);
            var sub = IdentityDictionary.new;
            dict[key] = sub;
            addedFolders = addedFolders + 1;
            if(~sampleLoaderVerbose) { (" " ! depth).join.post; ("+ folder: " ++ key).postln };
            loadFolder.(fd, sub, depth+2);
        };

        // FILES
        path.files.do { |fn|
            var ext, name;
            ext = fn.extension;
            ext = ext.isNil.if({ "" }, { ext.toLower });
            if(~sampleLoaderVerbose) { (" " ! depth).join.post; ("  ext=" ++ ext).postln };

            isAllowed = ~allowedExts.any { |e| e == ext };

            if(isAllowed) {
                name = fn.fileNameWithoutExtension;
                name = (name.isNil or: { name.size == 0 }).if({ ~basenameSym.(fn).asString }, { name });
                dict[name.asSymbol] = Buffer.read(s, fn.fullPath);  // preserve native channel count
                addedFiles = addedFiles + 1;
                if(~sampleLoaderVerbose) { (" " ! depth).join.post; ("  file: " ++ name ++ "." ++ ext).postln };
            } {
                if(~sampleLoaderVerbose) { (" " ! depth).join.post; ("  skip: " ++ fn.fileName).postln };
            };
        };
    };

    // Normalize root to PathName and check it
    rootPN = (root.isKindOf(PathName)).if({ root }, { PathName(root) });
    if(rootPN.isFolder.not) {
        ("⚠️ Root folder does not exist:\n" ++ rootPN.fullPath).warn;
        ^nil;
    };

    ~freeSamples.();
    if(~sampleLoaderVerbose) { ("Scanning: " ++ rootPN.fullPath).postln };
    loadFolder.(rootPN, ~sampleTree, 0);

    ("✅ Loaded samples from " ++ rootPN.fullPath).postln;
    ("> Folders added: " ++ addedFolders).postln;
    ("> Files loaded:  " ++ addedFiles).postln;
    ("> Top-level keys: " ++ ~sampleTree.keys).postln;
};

// ---------- Fetch helpers ----------
~getSample = { |...keys|
    var dict = ~sampleTree;
    keys.do { |k| dict = dict[k]; if(dict.isNil) { ^nil } };
    dict.isKindOf(Buffer).if({ dict }, { nil });
};

~printTree = {
    var rec;
    rec = { |d, indent=0|
        d.keysValuesDo { |k, v|
            (((" " ! indent).join) ++ k.asString).postln;
            if(v.isKindOf(Dictionary) or: { v.isKindOf(IdentityDictionary) }) { rec.(v, indent+2) };
        };
    };
    rec.(~sampleTree, 0);
};

~listKeys = { |...keys|
    var dict = ~sampleTree;
    keys.do { |k| dict = dict[k] };
    if(dict.isNil) { "⚠️ Path not found".warn } { dict.keys.do(_.postln) };
};

// ---------- Run once ----------
// ~loadSamplesRecursive.(~sampleRoot);

// // Quick test (adjust to a real path you see in ~printTree):
// { PlayBuf.ar(1, ~getSample.(\AKWF, \SomeSubFolder, \someFile), doneAction:2) * 0.4 }.play;
)

