/* LaunchControl XL — Multi-Bank Learn & Bind Router (fixed drop-in, no AppClock)
   -----------------------------------------------------------------------------
   - Default map path (changed to avoid clashing with your Tidal map):
       "/Users/isaaclinder/_includes/_midi-ctrl/lcxl-multibank.map"
   - Auto-inits ONCE at file load (guarded), no scheduling.
   - Track Select banking: Back CC106 (val==0) dec; Next CC107 (val>0) inc.
   - Learned keys: \bN-f1…\bN-f8, \bN-t1-r1…\bN-t8-r3
   - Only current bank’s bindings fire.
   - ~printMap sorts r1→r2→r3, then faders.
   - All functions: vars at top; no "~_var" names.
*/

// -------------------- Config / Path --------------------
~ccMapDefaultPath = {
    var p;
    p = "/Users/isaaclinder/Music/supercollider/0_startup/_includes/_midi-ctrl/lcxl-router.map";
    p
};

// Optional: set before load to override default
~ccMapPendingPath = ~ccMapPendingPath ? nil;

// Guard so auto-init runs only once per session
~lcxlAutoInitDone = ~lcxlAutoInitDone ? false;

// -------------------- Helpers --------------------
~ensureDir = { |path|
    var dir, ok;
    dir = PathName(path).pathOnly;
    if(dir.notNil and: { dir.size > 0 }) {
        if(File.exists(dir).not) {
            ok = File.mkdir(dir);   // portable mkdir
            if(ok.not) { ("[ saveMap ] couldn't create dir: " ++ dir).warn; };
        };
    };
    dir
};

~setMapPath = { |path|
    var finalPath, r;
    finalPath = path ? ~ccMapDefaultPath.();
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.notNil) {
        r[\mapFile] = finalPath;
    }{
        ~ccMapPendingPath = finalPath;
    };
    ("[ mapPath set ] %").format(finalPath).postln;
    finalPath
};

// -------------------- Router Install --------------------
~installCCByNameRouter = {
    var routerExists, init, onCC, def, r;

    routerExists = ~ccRouter.notNil and: { ~ccRouter.isKindOf(IdentityDictionary) };
    if(routerExists) { ^~ccRouter };

    init = {
        var rr;
        rr = IdentityDictionary.new;
        rr[\name]        = "CCRouter";
        rr[\uid]         = nil;
        rr[\filterByUID] = true;
        rr[\chan]        = 7; // zero-based (prints as 8)
        rr[\devSubstr]   = "Launch Control XL";
        rr[\ccMap]       = IdentityDictionary.new;  // \key -> (cc, chan, uid)
        rr[\binds]       = IdentityDictionary.new;  // \key -> Array of bindings
        rr[\defs]        = IdentityDictionary.new;  // MIDIdefs
        rr[\bank]        = 0;
        rr[\mapFile]     = (~ccMapPendingPath ? ~ccMapDefaultPath.());
        rr
    };

    ~ccRouter = init.value;
    r = ~ccRouter;

    onCC = { |val, cc, chan, src|
        var uid, okDevice, okChan, bankTag, keyString;
        var recCC, recChan, recUID, ccMatch, chanMatch, uidMatch;

        uid = src.tryPerform(\uid) ? src;

        okDevice = r[\filterByUID].if({
            (r[\uid].notNil) and: { uid == r[\uid] }
        },{
            true
        });

        okChan  = (chan == (r[\chan] ? 7));
        bankTag = ("b" ++ r[\bank] ++ "-").asString;

        if(okDevice and: { okChan }) {
            r[\ccMap].keysValuesDo { |key, rec|
                recCC   = rec[\cc];
                recChan = rec[\chan];
                recUID  = rec[\uid];
                ccMatch   = (recCC == cc);
                chanMatch = (recChan == chan);
                uidMatch  = recUID.isNil or: { recUID == uid };
                keyString = key.asString;

                if(keyString.beginsWith(bankTag) and: { ccMatch } and: { chanMatch } and: { uidMatch }) {
                    ~ccApplyBinding.(key, val);
                };
            };
        };
    };

    def = MIDIdef.cc(\_ccrouter_global, onCC);
    r[\defs][\globalRouter] = def;
    r
};

// -------------------- Banking --------------------
~getBank = {
    var r;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    r[\bank] ? 0
};

~setBank = { |n|
    var r, nn;
    r  = ~ccRouter ?? { ~installCCByNameRouter.() };
    nn = n.max(0);
    if(nn != (r[\bank] ? 0)) {
        r[\bank] = nn;
        "[ bank ] b%".format(nn).postln;
    };
    r[\bank]
};

~incBank = { var b; b = ~getBank.() + 1; ~setBank.(b) };
~decBank = { var b; b = (~getBank.() - 1).max(0); ~setBank.(b) };

~installBankButtons = {
    var r, def;
    r = ~ccRouter;
    if(r.isNil) { ^nil };

    (r[\defs][\bankButtons]).tryPerform(\free);

    def = MIDIdef.cc(\_ccrouter_bank, { |val, cc, chan, src|
        var routerChanIn, uidIn, okUID, pressBack, pressNext;
        var backCC, nextCC;

        routerChanIn = r[\chan] ? 7;
        uidIn        = src.tryPerform(\uid) ? src;
        okUID        = r[\filterByUID].if({ (r[\uid].notNil) and: { uidIn == r[\uid] } }, { true });

        backCC = 106; nextCC = 107;

        if(okUID and: { chan == routerChanIn }) {
            pressNext = (cc == nextCC) and: { val > 0 };  // typically 127
            pressBack = (cc == backCC) and: { val == 0 }; // typically 0
            if(pressNext) { ~incBank.() };
            if(pressBack) { ~decBank.() };
        };
    });

    r[\defs][\bankButtons] = def;
    "[ bank ] handlers installed".postln;
};

// -------------------- Name Helpers --------------------
~bankTagStr = { |bank| var out; out = ("b" ++ bank).asString };

~withBankName = { |baseSym|
    var r, bank, baseStr, pretty;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    bank    = r[\bank] ? 0;
    baseStr = baseSym.asString;         // "t1r1" or "f3"
    pretty  = baseStr.replace("r", "-r");
    ( ~bankTagStr.(bank) ++ "-" ++ pretty ).asSymbol
};

~withBankNames = { |syms| var out; out = syms.collect { |s| ~withBankName.(s) }; out };

// -------------------- Learning --------------------
// Faders 77..84 (factory template)
~learnFaders = {
    var r, wantCCs, baseNames, names, idx, got, def, headerChanOne, devName;

    r         = ~ccRouter ?? { ~installCCByNameRouter.() };
    wantCCs   = (77..84);
    baseNames = [\f1,\f2,\f3,\f4,\f5,\f6,\f7,\f8];
    names     = ~withBankNames.(baseNames);
    idx       = 0;
    got       = IdentityDictionary.new;

    headerChanOne = ((r[\chan] ? 7) + 1);
    devName = r[\devSubstr] ? "Launch Control XL";
    ("LEARN: Move faders 1→8 on '%', channel % …".format(devName, headerChanOne)).postln;

    MIDIdef(\_ccrouter_learnFaders).free;

    def = MIDIdef.cc(\_ccrouter_learnFaders, { |val, cc, chan, src|
        var uid, ep, name, expect, routerChan, okChan, accepted, slotName;

        uid  = src.tryPerform(\uid) ? src;
        ep   = MIDIClient.sources.detect { |e| e.uid == uid }
            ? MIDIClient.destinations.detect { |e| e.uid == uid };
        name = ep.notNil.if({ ep.tryPerform(\name) ? { ep.device ? "" } }, { "uid:%".format(uid) });

        routerChan = r[\chan] ? 7;
        expect     = wantCCs[idx];

        if(idx == 0 and: { chan != routerChan }) {
            r[\chan] = chan;
            ("LEARN set router channel = % (one-based %)").format(chan, chan+1).postln;
            routerChan = chan;
        };

        okChan   = (chan == routerChan);
        accepted = okChan and: { cc == expect };

        ("LEARN Faders recv cc:% chan(zero):% val:% dev:%  expect:% idx:%  okChan:% -> %")
            .format(cc, chan, val, name, expect, idx, okChan, accepted).postln;

        if(accepted) {
            slotName = names[idx];
            got[slotName] = (cc: cc, chan: chan, uid: uid);
            ("% ✔ % → cc:% (chan:% dev:%)")
                .postf(slotName, cc, chan+1, name).postln;

            if(r[\uid].isNil) {
                r[\uid] = uid;
                ("LEARN set router UID = % (%).").format(uid, name).postln;
            };

            idx = idx + 1;
            if(idx >= names.size) {
                def.free;
                got.keysValuesDo { |k, rec| r[\ccMap][k] = rec };
                ("[ ccLoad  ('ok': true, 'names': %) ]").format(got.keys).postln;
            };
        };
    });

    def.permanent_(true);
    r[\defs][\learnFaders] = def;
    r
};

~ccMakeRowLearner = { |label, ccList, baseNames|
    var r, idx, got, def, headerChanOne, devName, names;

    r             = ~ccRouter ?? { ~installCCByNameRouter.() };
    idx           = 0;
    got           = IdentityDictionary.new;
    headerChanOne = ((r[\chan] ? 7) + 1);
    devName       = r[\devSubstr] ? "Launch Control XL";
    names         = ~withBankNames.(baseNames);

    ("LEARN " ++ label ++ ": press controls in order on '%', channel % …")
        .format(devName, headerChanOne).postln;

    MIDIdef(\_ccrouter_learnRow).free;

    def = MIDIdef.cc(\_ccrouter_learnRow, { |val, cc, chan, src|
        var uid, ep, name, expect, routerChan, okChan, accepted, slotName;

        uid  = src.tryPerform(\uid) ? src;
        ep   = MIDIClient.sources.detect { |e| e.uid == uid }
            ? MIDIClient.destinations.detect { |e| e.uid == uid };
        name = ep.notNil.if({ ep.tryPerform(\name) ? { ep.device ? "" } }, { "uid:%".format(uid) });

        routerChan = r[\chan] ? 7;
        expect     = ccList[idx];

        if(idx == 0 and: { chan != routerChan }) {
            r[\chan] = chan;
            ("LEARN set router channel = % (one-based %)").format(chan, chan+1).postln;
            routerChan = chan;
        };

        okChan   = (chan == routerChan);
        accepted = okChan and: { cc == expect };

        ("LEARN " ++ label ++ " recv cc:% chan(zero):% val:% dev:%  expect:% idx:%  okChan:% -> %")
            .format(cc, chan, val, name, expect, idx, okChan, accepted).postln;

        if(accepted) {
            slotName = names[idx];
            got[slotName] = (cc: cc, chan: chan, uid: uid);
            ("% ✔ % → cc:% (chan:% dev:%)")
                .postf(slotName, cc, chan+1, name).postln;

            if(r[\uid].isNil) {
                r[\uid] = uid;
                ("LEARN set router UID = % (%).").format(uid, name).postln;
            };

            idx = idx + 1;
            if(idx >= names.size) {
                def.free;
                got.keysValuesDo { |k, rec| r[\ccMap][k] = rec };
                ("[ ccLoad  ('ok': true, 'names': %) ]").format(got.keys).postln;
            };
        };
    });

    def.permanent_(true);
    r[\defs][\learnRow] = def;
    r
};

// Rows (edit CC lists if your template differs)
~learnRow1 = { var ccList, base;
    ccList = [13,14,15,16,17,18,19,20];
    base   = [\t1r1,\t2r1,\t3r1,\t4r1,\t5r1,\t6r1,\t7r1,\t8r1];
    ~ccMakeRowLearner.( "Row1", ccList, base )
};

~learnRow2 = { var ccList, base;
    ccList = [21,22,23,24,25,26,27,28];
    base   = [\t1r2,\t2r2,\t3r2,\t4r2,\t5r2,\t6r2,\t7r2,\t8r2];
    ~ccMakeRowLearner.( "Row2", ccList, base )
};

~learnRow3 = { var ccList, base;
    ccList = [29,30,31,32,33,34,35,36];
    base   = [\t1r3,\t2r3,\t3r3,\t4r3,\t5r3,\t6r3,\t7r3,\t8r3];
    ~ccMakeRowLearner.( "Row3", ccList, base )
};

// -------------------- Binding --------------------
~ccBind = { |name, target, param, spec, lag = 0.0|
    var r, bindsForKey, binding, defSpec;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    bindsForKey = r[\binds][name] ? Array.new;
    defSpec = spec ? ControlSpec(0, 127, \lin, 1, 0);

    binding = ( target: target, param: param, spec: defSpec, lag: lag );

    bindsForKey = bindsForKey.add(binding);
    r[\binds][name] = bindsForKey;

    ("[ bind ] % → %.%  (spec: %, lag: %)"
        .format(name, target, param, defSpec, lag)).postln;

    r
};

~ccApplyBinding = { |name, midiVal|
    var r, bindsForKey, applyOne;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    bindsForKey = r[\binds][name];
    if(bindsForKey.isNil or: { bindsForKey.isEmpty }) { ^nil };

    applyOne = { |b|
        var target, param, spec, lag, value;

        target = b[\target];
        param  = b[\param];
        spec   = b[\spec] ? ControlSpec(0, 127, \lin, 1, 0);
        lag    = b[\lag] ? 0.0;

        value = spec.map(midiVal / 127.0);

        if(target.isKindOf(Function)) {
            target.value(value);
        }{
            if(Pdef.all.hasKey(target)) {
                Pdef(target).set(param, value);
            }{
                Ndef(target).set(param, value);
            };
        };
    };

    bindsForKey.do(applyOne);
};

// -------------------- Persistence --------------------
~saveMap = { |path|
    var r, fpath, count;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[ saveMap  ('info': router not installed) ]".postln; ^nil };

    fpath = path ? (r[\mapFile] ? ~ccMapDefaultPath.());
    r[\mapFile] = fpath;

    ~ensureDir.(fpath);
    r[\ccMap].writeArchive(fpath);

    count = r[\ccMap].size;
    ("[ saveMap  ('ok': true, 'count': %, 'path': %) ]").format(count, fpath).postln;
    fpath
};

~loadMap = { |path|
    var r, fpath, exists, loaded, asId, count;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[ loadMap  ('info': router not installed) ]".postln; ^nil };

    fpath = path ? (r[\mapFile] ? ~ccMapDefaultPath.());
    exists = File.exists(fpath);
    if(exists.not) {
        ("[ loadMap  ('info': no file, 'path': %) ]").format(fpath).postln;
        ^nil
    };

    loaded = Object.readArchive(fpath);
    asId = loaded.isKindOf(IdentityDictionary).if({ loaded }, {
        var id; id = IdentityDictionary.new;
        loaded.keysValuesDo { |k, v| id[k] = v };
        id
    });

    r[\ccMap] = asId;
    count = r[\ccMap].size;
    ("[ loadMap  ('ok': true, 'count': %, 'path': %) ]").format(count, fpath).postln;
    count
};

// -------------------- Inspect --------------------
// Quick stats (helps confirm we actually have entries)
~mapStats = {
    var r, total, banks, sample;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[mapStats] router not installed".warn; ^nil };

    total  = r[\ccMap].size;
    banks  = r[\ccMap].keys.collect(_.asString).collect { |s| s.copyRange(0, s.indexOf($-)-1) }.as(Set); // "b0-..." → "b0"
    sample = r[\ccMap].keys.as(Array).copyTo(8);

    ("[mapStats] entries:% banks:% sample:%")
        .format(total, banks.as(Array).sort, sample).postln;
};

// Print EVERYTHING (ignores bank filter)
~printMapAll = {
    var r, keys;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[printMapAll] router not installed".warn; ^nil };

    keys = r[\ccMap].keys.as(Array);
    keys = keys.collect(_.asString).sort;  // simple lexicographic

    "---- CC Map (ALL KEYS) ----".postln;
    keys.do { |ks|
        var k, v;
        k = ks.asSymbol;
        v = r[\ccMap][k];
        "% -> cc:% chan:% uid:%".format(k, v[\cc], v[\chan]+1, v[\uid]).postln;
    };
    "---------------------------".postln;
};

// Bank-filtered print (defensive; works on SC 3.10+)
// Prints all keys (ignores bank filter)
~printMapAll = {
    var r, keys;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[printMapAll] router not installed".warn; ^nil };

    keys = r[\ccMap].keys.as(Array).collect(_.asString).sort;

    "---- CC Map (ALL KEYS) ----".postln;
    keys.do { |ks|
        var k, v; k = ks.asSymbol; v = r[\ccMap][k];
        "% -> cc:% chan:% uid:%".format(k, v[\cc], v[\chan]+1, v[\uid]).postln;
    };
    "---------------------------".postln;
};

// Quick stats to confirm totals/banks
~mapStats = {
    var r, total, banks, sample, names;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[mapStats] router not installed".warn; ^nil };

    names  = r[\ccMap].keys.as(Array).collect(_.asString);
    total  = names.size;
    banks  = names.collect { |s| s.copyRange(0, s.indexOf($-)-1) }
                  .reject(_.isNil).as(Set).as(Array).sort; // "b0-..." -> "b0"
    sample = names.sort.copyTo(8);

    ("[mapStats] entries:% banks:% sample:%")
        .format(total, banks, sample).postln;
};

// Bank-filtered print (works on SC 3.10+ and always posts a message)
// Prints all keys (ignores bank filter)
~printMapAll = {
    var r, keys;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[printMapAll] router not installed".warn; ^nil };

    keys = r[\ccMap].keys.as(Array).collect(_.asString).sort;

    "---- CC Map (ALL KEYS) ----".postln;
    keys.do { |ks|
        var k, v; k = ks.asSymbol; v = r[\ccMap][k];
        "% -> cc:% chan:% uid:%".format(k, v[\cc], v[\chan]+1, v[\uid]).postln;
    };
    "---------------------------".postln;
};

// Quick stats to confirm totals/banks
~mapStats = {
    var r, names, total, banks, sampleEnd, sample;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[mapStats] router not installed".warn; ^nil };

    names = r[\ccMap].keys.as(Array).collect(_.asString);
    total = names.size;

    banks = names.collect { |s|
        var dashIdx;
        dashIdx = s.indexOf($-);
        if(s.beginsWith("b") and: { dashIdx.notNil }) {
            s.copyRange(0, dashIdx - 1)   // "b0-…" -> "b0"
        }{
            "UNBANKED"
        }
    }.as(Set).as(Array).sort;

    sampleEnd = (total - 1).clip(0, 7);
    sample = names.sort.copyRange(0, sampleEnd);

    ("[mapStats] entries:% banks:% sample:%")
        .format(total, banks, sample).postln;
};

// Bank-filtered print (works on SC 3.10+ and always posts a message)
~printMap = { |bank = nil|
    var r, b, prefix, keys;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.isNil) { "[printMap] router not installed".warn; ^nil };

    b = bank ?? { r[\bank] ? 0 };
    prefix = ("b" ++ b ++ "-").asString;

    // Get only matching keys; turn into Strings and sort safely
    keys = r[\ccMap].keys.as(Array)
        .select { |k| k.asString.beginsWith(prefix) }
        .collect(_.asString)
        .sort;

    ("---- CC Map (bank % only) ----".format(b)).postln;

    if(keys.isEmpty) {
        "[printMap] no keys for prefix %, total map size %"
            .format(prefix, r[\ccMap].size).postln;
        "------------------------------".postln;
        ^nil
    };

    // Optional nicer order: r1→r3 t1..t8, then f1..f8 (fallback to lexicographic)
    keys = keys.sort { |a, c|
        var isFa, isFc, ra, rc, ta, tc, fa, fc;

        isFa = a.contains("-f");  isFc = c.contains("-f");
        if(isFa != isFc) { ^(isFa.not) };  // rows before faders

        if(isFa and: { isFc }) {
            fa = a.findRegexp("f(\\d+)");  fc = c.findRegexp("f(\\d+)");
            if(fa.isNil or: { fc.isNil }) { ^(a < c) };
            ^(fa[1].asInteger < fc[1].asInteger)
        }{
            ra = a.findRegexp("r(\\d+)");  rc = c.findRegexp("r(\\d+)");
            ta = a.findRegexp("t(\\d+)");  tc = c.findRegexp("t(\\d+)");
            if(ra.isNil or: { rc.isNil } or: { ta.isNil } or: { tc.isNil }) { ^(a < c) };
            (ra[1].asInteger < rc[1].asInteger) or: {
                (ra[1].asInteger == rc[1].asInteger) and: {
                    ta[1].asInteger < tc[1].asInteger
                }
            }
        }
    };

    keys.do { |ks|
        var v;
        v = r[\ccMap][ks.asSymbol];
        "% -> cc:% chan:% uid:%".format(ks, v[\cc], v[\chan]+1, v[\uid]).postln;
    };
    "------------------------------".postln;
};

~ccDumpCCMap = { ~printMap.() };

~clearLearners = {
    var r;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    r[\defs].keysValuesDo { |k, d|
        if([ \globalRouter, \bankButtons ].includes(k).not) { d.tryPerform(\free) };
    };
    "[ learners cleared ]".postln;
};

// -------------------- Self-init exactly once (no scheduling) --------------------
if(~lcxlAutoInitDone.not) {
    ~lcxlAutoInitDone = true;

    if(MIDIClient.initialized.not) { MIDIClient.init };

    ~installCCByNameRouter.();
    ~loadMap.(nil);
    ~installBankButtons.();

    "[lcxl] init complete".postln;
}

