// LCXL CC Router — full include with bind save load — 2025-09-07 America/Chicago
(
////////////////////////////////////////////////////////////////////////////////
// CONFIG
////////////////////////////////////////////////////////////////////////////////
~lcxl_config = (
    deviceName: "Launch Control XL",
    midiChan: 9,
    mapPath: Platform.userHomeDir +/+ "Music/supercollider/_lcxl_cc_map.txt"
);

////////////////////////////////////////////////////////////////////////////////
// INSTALLER
////////////////////////////////////////////////////////////////////////////////
~installCCByNameRouter = {
    var r, dev, makeMatcher, tryFind, mk;
    r = IdentityDictionary.new;
    dev = nil;

    makeMatcher = { |want|
        var v;
        v = want.asString;
        { |src|
            var n;
            n = src.name ? "";
            (n == v) or: { n.find(v).notNil }
        }
    };

    tryFind = {
        var matcher, srcs, choice;
        matcher = makeMatcher.(~lcxl_config[\deviceName]);
        srcs = MIDIClient.sources.select(matcher);
        choice = srcs.first;
        choice
    };

    mk = {
        var defs;
        defs = IdentityDictionary.new;
        r[\device] = tryFind.();
        r[\chan]   = ~lcxl_config[\midiChan];
        r[\bank]   = 0;
        r[\ccMap]  = IdentityDictionary.new;
        r[\defs]   = defs;
        r
    };

    ~ccRouter = mk.();
    "[ lcxl  ready ]".postln;
    ~ccRouter
};

////////////////////////////////////////////////////////////////////////////////
// BANK HELPERS
////////////////////////////////////////////////////////////////////////////////
~setBank = { |n=0|
    var r, nn;
    r  = ~ccRouter ?? { ~installCCByNameRouter.() };
    nn = n.clip(0, 3);
    r[\bank] = nn;
    ("[ bank  b" ++ nn ++ " ]").postln;
    nn
};

~getBank = {
    var r, b;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    b = r[\bank] ? 0;
    b
};

////////////////////////////////////////////////////////////////////////////////
// NAMING
////////////////////////////////////////////////////////////////////////////////
~withBankNames = { |baseNames|
    var bank, out;
    bank = ~getBank.();
    out  = baseNames.collect { |sym| ("b" ++ bank ++ "_" ++ sym.asString).asSymbol };
    out
};

////////////////////////////////////////////////////////////////////////////////
// PRINTER
////////////////////////////////////////////////////////////////////////////////
~printMapAll = {
    var r, map, keys;
    r   = ~ccRouter ?? { ~installCCByNameRouter.() };
    map = r[\ccMap] ? IdentityDictionary.new;
    keys = map.keys.asArray.sort { |a, b| a.asString < b.asString };

    "---- CC Map ALL KEYS ----".postln;
    keys.do { |k|
        var d, cc, ch, uid;
        d = map[k];
        cc = d[\cc]; ch = d[\chan]; uid = d[\uid];
        ("% -> cc:% chan:% uid:%".format(k, cc, ch, uid)).postln;
    };
    "---------------------------".postln;
};

////////////////////////////////////////////////////////////////////////////////
// LEARNER RESET
////////////////////////////////////////////////////////////////////////////////
~ccLearnerReset = {
    var r, keys;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    keys = r[\defs].keys.asArray;
    keys.do { |k| r[\defs][k].tryPerform(\free) };
    MIDIdef(\lcxl_learn_any).free;
    r[\defs].clear;
    "[ learners cleared ]".postln;
};

////////////////////////////////////////////////////////////////////////////////
// GENERIC LEARNER relaxed and duplicate safe
////////////////////////////////////////////////////////////////////////////////
~ccMakeRowLearner = { |label="Row", ccList=nil, baseNames|
    var r, names, idx, def, wantChan, devUid, defaults;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    defaults = (13..20).asArray;
    ccList = ccList ?? { defaults };
    names = ~withBankNames.(baseNames);
    idx = 0;
    wantChan = r[\chan];
    devUid = if(r[\device].notNil) { r[\device].uid } { nil };

    if (r[\defs][\learnAny].notNil) { r[\defs][\learnAny].free };
    MIDIdef.cc(\lcxl_learn_any).free;

    ("LEARN " ++ label ++ " b" ++ ~getBank.() ++ " — move " ++ names[idx]).postln;

    def = MIDIdef.cc(\lcxl_learn_any, { |val, cc, chan, src|
        var okChan, okDev, name, entry, prev;
        okChan = ((wantChan == (chan+1)) or: { wantChan.isNil });
        okDev  = (devUid.isNil) or: { src == devUid };

        if (okChan and: { okDev }) {
            prev = if(idx > 0) { r[\ccMap][names[idx-1]] } { nil };
            if(prev.notNil and: { prev[\cc] == cc }) {
                ("[ skip duplicate cc:" ++ cc ++ " for " ++ names[idx] ++ " ]").postln;
            } {
                name  = names[idx];
                entry = ( 'cc': cc, 'chan': chan+1, 'uid': src );
                r[\ccMap][name] = entry;

                ("[ learned  " ++ name ++ " -> cc:" ++ cc
                    ++ " chan:" ++ (chan+1) ++ " uid:" ++ src ++ " ]").postln;

                idx = idx + 1;

                if (idx >= names.size) {
                    MIDIdef.cc(\lcxl_learn_any).free;
                    def.free;
                    r[\defs][\learnAny] = nil;
                    ("[ learn  ok " ++ label ++ " names:" ++ names ++ " ]").postln;
                } {
                    ("Move " ++ names[idx]).postln;
                };
            };
        };
    });

    def.permanent_(true);
    r[\defs][\learnAny] = def;
    r
};

////////////////////////////////////////////////////////////////////////////////
// WRAPPER AND LEARNERS
////////////////////////////////////////////////////////////////////////////////
~wrapLearn = { |fn|
    var r;
    r = fn.value;
    "[ learning active — move the requested control now ]".postln;
    "ok"
};

~learnFaders = { ~wrapLearn.({
    var base, want;
    base = [\f1,\f2,\f3,\f4,\f5,\f6,\f7,\f8];
    want = (77..84).asArray;
    ~ccMakeRowLearner.( "Faders", want, base )
}) };

~learnRow1 = { ~wrapLearn.({
    var base, want;
    base = [\t1_r1,\t2_r1,\t3_r1,\t4_r1,\t5_r1,\t6_r1,\t7_r1,\t8_r1];
    want = [13,14,15,16,17,18,19,20];
    ~ccMakeRowLearner.( "Row1", want, base )
}) };

~learnRow2 = { ~wrapLearn.({
    var base, want;
    base = [\t1_r2,\t2_r2,\t3_r2,\t4_r2,\t5_r2,\t6_r2,\t7_r2,\t8_r2];
    want = [21,22,23,24,25,26,27,28];
    ~ccMakeRowLearner.( "Row2", want, base )
}) };

~learnRow3 = { ~wrapLearn.({
    var base, want;
    base = [\t1_r3,\t2_r3,\t3_r3,\t4_r3,\t5_r3,\t6_r3,\t7_r3,\t8_r3];
    want = [29,30,31,32,33,34,35,36];
    ~ccMakeRowLearner.( "Row3", want, base )
}) };

////////////////////////////////////////////////////////////////////////////////
// SANITY CHECK
////////////////////////////////////////////////////////////////////////////////
~ccSanity = {
    var r, missing, expect;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    expect = [
        ~withBankNames.([\f1,\f2,\f3,\f4,\f5,\f6,\f7,\f8]),
        ~withBankNames.([\t1_r1,\t2_r1,\t3_r1,\t4_r1,\t5_r1,\t6_r1,\t7_r1,\t8_r1]),
        ~withBankNames.([\t1_r2,\t2_r2,\t3_r2,\t4_r2,\t5_r2,\t6_r2,\t7_r2,\t8_r2]),
        ~withBankNames.([\t1_r3,\t2_r3,\t3_r3,\t4_r3,\t5_r3,\t6_r3,\t7_r3,\t8_r3])
    ].flatten;
    missing = expect.select { |k| r[\ccMap][k].isNil };
    if (missing.isEmpty) { "[ ccSanity  ok ]".postln } {
        ("[ ccSanity  missing: " ++ missing ++ " ]").postln
    };
};

////////////////////////////////////////////////////////////////////////////////
// SAVE AND LOAD
////////////////////////////////////////////////////////////////////////////////
~ccSave = {
    var r, map, path, dir, file, keys;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    map = r[\ccMap] ? IdentityDictionary.new;
    path = ~lcxl_config[\mapPath];
    dir = PathName(path).pathOnly;
    if(dir.notNil and: { File.exists(dir).not }) {
        File.mkdir(dir);
    };

    file = File(path, "w");
    file.write("# lcxl map saved " ++ Date.getDate.stamp ++ "\n");
    keys = map.keys.asArray.sort { |a, b| a.asString < b.asString };
    keys.do { |k|
        var d;
        d = map[k];
        file.write("% % % %\n".format(k.asString, d[\cc], d[\chan], d[\uid]));
    };
    file.close;

    ("[ save  " ++ path ++ " entries:" ++ keys.size ++ " ]").postln;
    path
};

~ccLoad = {
    var r, path, file, lines;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    path = ~lcxl_config[\mapPath];

    if(File.exists(path).not) {
        ("[ load  not found " ++ path ++ " ]").postln;
        ^nil
    };

    file = File(path, "r");
    lines = file.readAllString.split($\n);
    file.close;

    lines.do { |line|
        var t, k, cc, ch, uid;
        if(line.size == 0 or: { line.first == $# }) { } {
            t = line.split($ );
            if(t.size >= 4) {
                k = t[0].asSymbol;
                cc = t[1].asInteger;
                ch = t[2].asInteger;
                uid = t[3].asInteger;
                r[\ccMap][k] = ( 'cc': cc, 'chan': ch, 'uid': uid );
            };
        };
    };

    "[ load  ok ]".postln;
    r[\ccMap]
};

// lcxl autoload helper 2025-09-07 America/Chicago

~lcxl_autoload = {
    var r, path;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    path = ~lcxl_config[\mapPath];
    if(File.exists(path)) { ~ccLoad.() } { "[ lcxl autoload  no map found ]".postln };
    "[ lcxl autoload  done ]".postln;
};

// arm autoload on language boot or recompile
AppClock.sched(0.2, { ~lcxl_autoload.(); nil });

////////////////////////////////////////////////////////////////////////////////
// BIND HELPERS
////////////////////////////////////////////////////////////////////////////////
~ccBind = { |key, action, spec=nil|
    var r, entry, ccnum, chan, srcUid, defKey, mapper, mididef;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    entry = r[\ccMap][key];

    if(entry.isNil) {
        ("[ ccBind  missing map for " ++ key ++ " ]").postln;
        ^nil
    };

    // set default spec inside to avoid parse issues
    spec = spec ?? { ControlSpec(0, 1, \lin, 0, 0) };

    ccnum  = entry[\cc];
    chan   = entry[\chan];
    srcUid = entry[\uid];

    mapper = { |val| spec.map(val / 127) };

    defKey = ("lcxl_bind_" ++ key.asString).asSymbol;
    if(r[\defs][defKey].notNil) { r[\defs][defKey].free };

    mididef = MIDIdef.cc(defKey, { |val, cc, ch, src|
        var ok, x;
        ok = (cc == ccnum) and: { (ch + 1) == chan } and: { src == srcUid };
        if(ok) {
            x = mapper.(val);
            action.(x);
        }
    }, ccnum, chan - 1).permanent_(true);

    r[\defs][defKey] = mididef;
    ("[ ccBind  " ++ key ++ " -> " ++ defKey ++ " cc:" ++ ccnum
        ++ " chan:" ++ chan ++ " uid:" ++ srcUid ++ " ]").postln;
    defKey
};

~ccBindParam = { |key, ndefName, param=\amp, spec=nil|
    var f;
    // set default spec inside to avoid parse issues
    spec = spec ?? { ControlSpec(0, 1, \lin, 0, 0) };
    f = { |x| Ndef(ndefName).set(param, x) };
    ~ccBind.(key, f, spec)
};

~ccUnbind = { |key|
    var r, defKey;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    defKey = ("lcxl_bind_" ++ key.asString).asSymbol;
    if(r[\defs][defKey].notNil) {
        r[\defs][defKey].free;
        r[\defs].removeAt(defKey);
        ("[ ccUnbind  " ++ key ++ " ]").postln;
    };
};
)

