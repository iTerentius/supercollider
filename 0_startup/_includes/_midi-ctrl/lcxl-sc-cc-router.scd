/* ---------------------------------------------------------------------------
   LCXL CC Mapper: rows+faders learner + named routing + auto save/load
   Names:
     Knob rows → \t1r1 .. \t8r1, \t1r2 .. \t8r2, \t1r3 .. \t8r3
     Faders    → \f1 .. \f8

   Workflow:
     1) Map hardware → names:
          ~learnRow1.(); ~learnRow2.(); ~learnRow3.(); ~learnFaders.();
        (turn each control once in the prompted order; autosaves)
     2) Bind names → synth params:
          ~ccBind.(\t1r1, \myNdef, \cutoff, ControlSpec(100,12000,\exp));
     3) Install router (translates incoming CCs into Ndef.set):
          ~installCCByNameRouter.();   // (auto-runs on load if map file exists)

   Notes:
     • Autosaves to lcxl-cc-map.archive next to this file; auto-loads on include.
     • Optional device filter: set ~lcxlCC[\srcUid] to your LCXL source uid.
--------------------------------------------------------------------------- */

// ---------- tiny utils ----------
if(~pp.isNil) {
    ~pp = { |tag, data|
        var s;
        s = "[" ++ Date.getDate.stamp ++ "] " ++ tag ++ "  " ++ data.asString;
        s.postln; s;
    };
};

if(~pathForFile.isNil) {
    ~pathForFile = { |fname|
        var base, p;
        base = if(thisProcess.nowExecutingPath.notNil) {
            PathName(thisProcess.nowExecutingPath).pathOnly
        }{
            Platform.userHomeDir
        };
        p = (base +/+ fname.asString).asString;
        p;
    };
};

// ---------- global-ish state ----------
if(~lcxlCC.isNil) { ~lcxlCC = (); };
if(~lcxlCC[\map].isNil)     { ~lcxlCC[\map]     = IdentityDictionary.new; };
if(~lcxlCC[\rev].isNil)     { ~lcxlCC[\rev]     = IdentityDictionary.new; };
if(~lcxlCC[\srcUid].isNil)  { ~lcxlCC[\srcUid]  = nil; };  // set uid to filter device (optional)
if(~lcxlCC[\mapPath].isNil) { ~lcxlCC[\mapPath] = ~pathForFile.("lcxl-cc-map.archive"); };

if(~ccTargets.isNil)     { ~ccTargets     = IdentityDictionary.new; };
if(~ccDefaultSpec.isNil) { ~ccDefaultSpec = ControlSpec(0, 1, \lin, 0, 0); };
if(~ccAutosave.isNil)    { ~ccAutosave    = true; };
if(~ccAutoBoot.isNil)    { ~ccAutoBoot    = true; };

// ---------- helpers ----------
if(~edgeKey.isNil) {
    ~edgeKey = { |chan, num|
        var k;
        k = chan.asInteger * 128 + num.asInteger;
        k;
    };
};

if(~rowNames.isNil) {
    ~rowNames = { |row|
        var names;
        names = (1..8).collect { |i| ("t" ++ i ++ "r" ++ row).asSymbol };
        names;
    };
};

if(~faderNames.isNil) {
    ~faderNames = {
        var names;
        names = (1..8).collect { |i| ("f" ++ i).asSymbol };
        names;
    };
};

// ---------- persistence ----------
~ccSaveCCMap = {
    var path, data;
    path = ~lcxlCC[\mapPath];
    data = (map: ~lcxlCC[\map], rev: ~lcxlCC[\rev], srcUid: ~lcxlCC[\srcUid]);
    data.writeArchive(path);
    ~pp.("ccSave", (path: path, names: ~lcxlCC[\map].keys.asArray.sort));
};

~ccLoadCCMap = {
    var path, data;
    path = ~lcxlCC[\mapPath];
    if(path.notNil and: { File.exists(path) }) {
        data = Object.readArchive(path);
        if(data.respondsTo(\at)) {
            ~lcxlCC[\map]    = data[\map] ? IdentityDictionary.new;
            ~lcxlCC[\rev]    = data[\rev] ? IdentityDictionary.new;
            ~lcxlCC[\srcUid] = data[\srcUid] ?? { ~lcxlCC[\srcUid] };
            ~pp.("ccLoad", (ok: true, names: ~lcxlCC[\map].keys.asArray.sort));
        }{
            ~pp.("ccLoad", (warn: "bad archive", path: path));
        };
    }{
        ~pp.("ccLoad", (info: "no file", path: path));
    };
};

// ---------- fast learner for a given ordered name list ----------
~ccQuickLearn = { |names, lockChan = true|
    var seen, got, locked, lockedChan;
    names = names.collect(_.asSymbol);
    seen = IdentitySet.new;
    got = 0;
    locked = (lockChan == true);
    lockedChan = nil;

    MIDIdef.free(\lcxl_cc_quick);
    ~pp.("ccQuick", (expect: names.size, names: names));

    MIDIdef.cc(\lcxl_cc_quick, { |val, num, chan, src|
        var key, name, rkey;
        if(~lcxlCC[\srcUid].notNil and: { src.asInteger != ~lcxlCC[\srcUid] }) { ^nil };

        if(locked and: { lockedChan.isNil }) {
            lockedChan = chan;
            ~pp.("ccQuick", (lockChan: chan));
        };
        if(locked and: { chan != lockedChan }) { ^nil };

        key = locked.if({ chan.asInteger * 128 + num.asInteger }, { num.asInteger });
        if(seen.includes(key)) { ^nil };
        seen.add(key);

        name = names.at(got);
        rkey = chan.asInteger * 128 + num.asInteger;
        ~lcxlCC[\map][name] = (chan: chan, num: num);
        ~lcxlCC[\rev][rkey] = name;

        got = got + 1;
        ~pp.("ccQuick", (index: got, name: name, chan: chan, cc: num));
        if(~ccAutosave) { ~ccSaveCCMap.() };

        if(got >= names.size) {
            MIDIdef.free(\lcxl_cc_quick);
            ~pp.("ccQuick ✅", (done: true, captured: got));
        };
    }, nil, nil, nil);
};

// convenience wrappers (8 controls each)
~learnRow1   = { var names; names = ~rowNames.(1); ~ccQuickLearn.(names, true); };
~learnRow2   = { var names; names = ~rowNames.(2); ~ccQuickLearn.(names, true); };
~learnRow3   = { var names; names = ~rowNames.(3); ~ccQuickLearn.(names, true); };
~learnFaders = { var names; names = ~faderNames.();  ~ccQuickLearn.(names, true); };

// ---------- binding & routing ----------
// --- Flexible binder --------------------------------------------------------
~ccBind = { |name, target, param=nil, spec=nil|
    var nm, theSpec, rec;
    nm = name.asSymbol;
    theSpec = spec ?? { ~ccDefaultSpec };

    // Two forms:
    // 1) target is a Function => call with mapped value
    // 2) target is a Symbol (Ndef name) + param => set Ndef(param)
    if(target.isKindOf(Function)) {
        rec = (fn: target, spec: theSpec);
        ~pp.("ccBind+", (name: nm, kind: "fn"));
    }{
        rec = (ndef: target.asSymbol, param: param.asSymbol, spec: theSpec);
        ~pp.("ccBind+", (name: nm, kind: "ndef", ndef: target, param: param));
    };
    ~ccTargets[nm] = rec;
};

// --- Router (unchanged behavior + adds fn target) ---------------------------
~installCCByNameRouter = { |srcUid = nil|
    var suid;
    suid = (srcUid.notNil).if({ srcUid }, { ~lcxlCC[\srcUid] });
    MIDIdef.free(\lcxl_cc_byname_router);

    MIDIdef.cc(\lcxl_cc_byname_router, { |val, num, chan, src|
        var k, name, tgt, spec, outVal, n, p, fn;
        if(suid.notNil and: { src.asInteger != suid }) { ^nil };

        k = chan.asInteger * 128 + num.asInteger;
        name = ~lcxlCC[\rev][k];
        if(name.isNil) { ^nil };

        tgt = ~ccTargets.at(name);
        if(tgt.isNil) { ^nil };

        spec = tgt[\spec]; if(spec.isNil) { spec = ~ccDefaultSpec };
        outVal = spec.map(val / 127.0);

        fn = tgt[\fn];
        if(fn.notNil) {
            fn.value(outVal);
            ~pp.("cc→fn", (name: name, val: outVal.round(0.001)));
        }{
            n = tgt[\ndef]; p = tgt[\param];
            Ndef(n).set(p, outVal);
            ~pp.("cc→Ndef", (name: name, ndef: n, param: p, val: outVal.round(0.001)));
        };
    }, nil, nil, nil);

    ~pp.("ccRouter (installed)", (filterByUID: suid.notNil));
};

// --- Convenience helpers -----------------------------------------------------
~ccBindFn = { |name, func, spec=nil|
    var sp;
    sp = spec ?? { ~ccDefaultSpec };
    ~ccBind.(name, func, nil, sp);
};

~ccBindSynth = { |name, synth, param, spec=nil|
    var sp, fn;
    sp = spec ?? { ~ccDefaultSpec };
    fn = { |v| synth.set(param, v) };
    ~ccBind.(name, fn, nil, sp);
};

~ccBindBus = { |name, bus, spec=nil|
    var sp, fn;
    sp = spec ?? { ~ccDefaultSpec };
    fn = { |v| bus.set(v) };
    ~ccBind.(name, fn, nil, sp);
};

~ccBindPbindef = { |name, pdefName, param, spec=nil|
    var sp, fn;
    sp = spec ?? { ~ccDefaultSpec };
    fn = { |v| Pbindef(pdefName, param, v) };  // live pattern param updates
    ~ccBind.(name, fn, nil, sp);
};

// ---------- dump & clear ----------
~ccDumpCCMap = {
    var keys;
    keys = ~lcxlCC[\map].keys.asArray.sort;
    keys.do { |nm|
        var m, line;
        m = ~lcxlCC[\map][nm];
        line = "%-6s -> chan:% 2d  cc:% 3d".format(nm.asString, m[\chan], m[\num]);
        line.postln;
    };
};

~ccClearMap = {
    ~lcxlCC[\map] = IdentityDictionary.new;
    ~lcxlCC[\rev] = IdentityDictionary.new;
    ~ccSaveCCMap.();
    ~pp.("ccClear", ());
};

// ---------- auto-load on include (scheduled; avoids top-level if pitfalls) ----------
~ccAutoloadFn = {
    var path, loaded;
    path = ~lcxlCC[\mapPath];
    loaded = false;
    if(path.notNil and: { File.exists(path) }) {
        ~ccLoadCCMap.();
        loaded = true;
    }{
        ~pp.("ccAuto", (info: "no cc map found", path: path));
    };
    if(loaded) {
        ~installCCByNameRouter.();
        ~pp.("ccAuto", (loaded: true, path: path));
    };
};

if(~ccAutoBoot) {
    AppClock.sched(0.2, { ~ccAutoloadFn.(); nil; });
};

// ---------- quick tips (scheduled) ----------
if(~postCcHintFn.isNil) {
    ~postCcHintFn = {
        var done;
        done = ~lcxlCC[\_hintDone];
        if(done.isNil) {
            ~lcxlCC[\_hintDone] = true;
            ~pp.("hint", (a: "Learn: ~learnRow1.(); ~learnRow2.(); ~learnRow3.(); ~learnFaders.()",
                          b: "Bind:  ~ccBind.(\\t1r1, \\pad, \\cutoff, ControlSpec(100,12000,\\exp))",
                          c: "Route: ~installCCByNameRouter.()",
                          d: "Dump:  ~ccDumpCCMap.();  Clear: ~ccClearMap.()"));
        };
    };
};

AppClock.sched(0.3, { ~postCcHintFn.(); nil; });

