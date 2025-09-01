/* LaunchControl XL — Multi-Bank Router (underscore, stable)
   ---------------------------------------------------------
   - Key names: \bN_f1..f8, \bN_tX_rY (e.g. \b0_f1, \b0_t1_r1)
   - Bank buttons: Back CC106 (val==0) dec; Next CC107 (val>0) inc — global listener
   - On load: adopts UID + channel from saved map
   - Bindings: prefer Ndef, then Pdef (only if it works), else ~onCCValue
*/

// ==================== Config / Path ====================
~ccMapDefaultPath = {
    "/Users/isaaclinder/Music/supercollider/0_startup/_includes/_midi-ctrl/lcxl-router.map"
};

~ccMapPendingPath = ~ccMapPendingPath ? nil;
~lcxlAutoInitDone = ~lcxlAutoInitDone ? false;
~lcxlDebug = ~lcxlDebug ? false;  // set true to see routing debug

// ==================== Helpers ====================
~ensureDir = { |path|
    var dir, ok;
    dir = PathName(path).pathOnly;
    if(dir.notNil and: { dir.size > 0 }) {
        if(File.exists(dir).not) {
            ok = File.mkdir(dir);
            if(ok.not) { ("[ saveMap ] couldn't create dir: " ++ dir).warn; };
        };
    };
    dir
};

~setMapPath = { |path|
    var finalPath, r;
    finalPath = path ? ~ccMapDefaultPath.();
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    if(r.notNil) { r[\mapFile] = finalPath }{ ~ccMapPendingPath = finalPath };
    ("[ mapPath set ] %").format(finalPath).postln;
    finalPath
};

// ==================== Router ====================
~installCCByNameRouter = {
    var routerExists, init, onCC, def, r;

    routerExists = ~ccRouter.notNil and: { ~ccRouter.isKindOf(IdentityDictionary) };
    if(routerExists) { ^~ccRouter };

    init = {
        var rr;
        rr = IdentityDictionary.new;
        rr[\uid]         = nil;                 // adopted from learn or load
        rr[\filterByUID] = true;                // allow nil (adopt first seen UID)
        rr[\chan]        = 7;                   // 0-based in SC; LCXL shows this as channel 8
        rr[\devSubstr]   = "Launch Control XL";
        rr[\ccMap]       = IdentityDictionary.new;
        rr[\binds]       = IdentityDictionary.new;
        rr[\defs]        = IdentityDictionary.new;
        rr[\bank]        = 0;
        rr[\mapFile]     = (~ccMapPendingPath ? ~ccMapDefaultPath.());
        rr
    };

    ~ccRouter = init.value;
    r = ~ccRouter;

    onCC = { |val, cc, chan, src|
        var uid, allowDevice, okChan, bankTag, keyString;
        var recCC, recChan, recUID, ccMatch, chanMatch, uidMatch;

        uid = src.tryPerform(\uid) ? src;

        // Accept first device to set UID when filterByUID is true but UID is nil
        allowDevice = r[\filterByUID].if({ r[\uid].isNil or: { uid == r[\uid] } }, { true });
        if(r[\uid].isNil and: { allowDevice }) {
            r[\uid] = uid; ("[ router ] adopted UID: %").format(uid).postln;
        };

        okChan  = (chan == (r[\chan] ? 7));
        bankTag = ("b" ++ r[\bank] ++ "_").asString;

        if(~lcxlDebug) {
            ("[ onCC ] val:% cc:% chan:% uid:% bankTag:% okChan:%"
                .format(val, cc, chan, uid, bankTag, okChan)).postln;
        };

        if(allowDevice and: { okChan }) {
            r[\ccMap].keysValuesDo { |key, rec|
                recCC   = rec[\cc]; recChan = rec[\chan]; recUID = rec[\uid];
                ccMatch = recCC == cc; chanMatch = recChan == chan;
                uidMatch= recUID.isNil or: { recUID == uid };
                keyString = key.asString;
                if(keyString.beginsWith(bankTag) and: { ccMatch } and: { chanMatch } and: { uidMatch }) {
                    if(~lcxlDebug) { ("[ route ] % matched".format(key)).postln };
                    ~ccApplyBinding.(key, val);
                };
            };
        };
    };

    def = MIDIdef.cc(\_ccrouter_global, onCC);
    r[\defs][\globalRouter] = def;
    r
};

// ==================== Banking ====================
~getBank = { var r; r = ~ccRouter ?? { ~installCCByNameRouter.() }; r[\bank] ? 0 };

~setBank = { |n|
    var r, nn;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    nn = n.max(0);
    if(nn != (r[\bank] ? 0)) { r[\bank] = nn; "[ bank ] b%".format(nn).postln; };
    r[\bank]
};

~incBank = { ~setBank.(~getBank.() + 1) };
~decBank = { ~setBank.( (~getBank.() - 1).max(0) ) };

~installBankButtons = {
    var r, def;
    r = ~ccRouter; if(r.isNil) { ^nil };
    (r[\defs][\bankButtons]).tryPerform(\free);

    // Global listen (no filter) so buttons always change bank
    def = MIDIdef.cc(\_ccrouter_bank, { |val, cc, chan, src|
        if(cc == 107 and: { val > 0 }) {
            ~incBank.();
            ("[ bank ] Next → b% (val:% chan:% uid:%)")
                .format(~getBank.(), val, chan, src.tryPerform(\uid) ? src).postln;
        };
        if(cc == 106 and: { val == 0 }) {
            ~decBank.();
            ("[ bank ] Back → b% (val:% chan:% uid:%)")
                .format(~getBank.(), val, chan, src.tryPerform(\uid) ? src).postln;
        };
    });

    def.permanent_(true);
    r[\defs][\bankButtons] = def;
    "[ bank ] handlers installed (global CC106/107)".postln;
};

// ==================== Name Helpers ====================
~withBankName = { |baseSym|
    var r, bank, baseStr;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    bank = r[\bank] ? 0;
    baseStr = baseSym.asString;
    ("b" ++ bank ++ "_" ++ baseStr).asSymbol
};

~withBankNames = { |syms|
    var out;
    out = syms.collect { |s| ~withBankName.(s) };
    out
};

// ==================== Learning ====================
~learnFaders = {
    var r, wantCCs, baseNames, names, idx, got, def;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    wantCCs   = (77..84);
    baseNames = [\f1,\f2,\f3,\f4,\f5,\f6,\f7,\f8];
    names     = ~withBankNames.(baseNames);
    idx = 0; got = IdentityDictionary.new;

    MIDIdef(\_ccrouter_learnFaders).free;

    def = MIDIdef.cc(\_ccrouter_learnFaders, { |val, cc, chan, src|
        var uid, expect, routerChan, okChan, accepted, slotName;
        uid = src.tryPerform(\uid) ? src;
        routerChan = r[\chan] ? 7;
        expect = wantCCs[idx];
        okChan = (chan == routerChan);
        accepted = okChan and: { cc == expect };

        if(accepted) {
            slotName = names[idx];
            got[slotName] = (cc: cc, chan: chan, uid: uid);
            ("% ✔ % → cc:% (chan:%)".format(slotName, cc, chan)).postln;
            if(r[\uid].isNil) { r[\uid] = uid };
            idx = idx + 1;

            if(idx >= names.size) {
                def.free;
                got.keysValuesDo { |k, v| r[\ccMap][k] = v };
                ("[ ccLoad ('ok': true, 'names': %) ]").format(got.keys).postln;
            };
        };
    });

    def.permanent_(true);
    r[\defs][\learnFaders] = def;
    r
};

~ccMakeRowLearner = { |label, ccList, baseNames|
    var r, idx, got, def, names;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    idx = 0; got = IdentityDictionary.new;
    names = ~withBankNames.(baseNames);

    MIDIdef(\_ccrouter_learnRow).free;

    def = MIDIdef.cc(\_ccrouter_learnRow, { |val, cc, chan, src|
        var uid, expect, routerChan, okChan, accepted, slotName;
        uid = src.tryPerform(\uid) ? src; routerChan = r[\chan] ? 7;
        expect = ccList[idx];
        okChan = (chan == routerChan);
        accepted = okChan and: { cc == expect };

        if(accepted) {
            slotName = names[idx];
            got[slotName] = (cc: cc, chan: chan, uid: uid);
            ("% ✔ % → cc:% (chan:%)".format(slotName, cc, chan)).postln;
            if(r[\uid].isNil) { r[\uid] = uid };
            idx = idx + 1;

            if(idx >= names.size) {
                def.free;
                got.keysValuesDo { |k, v| r[\ccMap][k] = v };
                ("[ ccLoad ('ok': true, 'names': %) ]").format(got.keys).postln;
            };
        };
    });

    def.permanent_(true);
    r[\defs][\learnRow] = def;
    r
};

~learnRow1 = { ~ccMakeRowLearner.( "Row1", [13,14,15,16,17,18,19,20], [\t1r1,\t2r1,\t3r1,\t4r1,\t5r1,\t6r1,\t7r1,\t8r1] ) };
~learnRow2 = { ~ccMakeRowLearner.( "Row2", [21,22,23,24,25,26,27,28], [\t1r2,\t2r2,\t3r2,\t4r2,\t5r2,\t6r2,\t7r2,\t8r2] ) };
~learnRow3 = { ~ccMakeRowLearner.( "Row3", [29,30,31,32,33,34,35,36], [\t1r3,\t2r3,\t3r3,\t4r3,\t5r3,\t6r3,\t7r3,\t8r3] ) };

// ==================== Binding ====================
~ccBind = { |name, target, param, spec, lag = 0.0|
    var r, bindsForKey, binding, defSpec;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    bindsForKey = r[\binds][name] ? Array.new;
    // default to 0..1 for musical params unless spec is provided
    defSpec = spec ? ControlSpec(0, 1, \lin);
    binding = ( target: target, param: param, spec: defSpec, lag: lag );
    r[\binds][name] = bindsForKey.add(binding);
    ("[ bind ] % → %.% (spec:% lag:% bank:b%)"
        .format(name, target, param, defSpec, lag, ~getBank.())).postln;
    r
};

// *** Final, robust binder: try Ndef, then Pdef, else ~onCCValue ***
~ccApplyBinding = { |name, midiVal|
    var r, bindsForKey, valueFrom127, trigged;
    var target, param, spec, lag, value, ok;

    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    bindsForKey = r[\binds][name];
    if(bindsForKey.isNil or: { bindsForKey.isEmpty }) { ^nil };

    trigged = false;
    valueFrom127 = { |s| (s ? ControlSpec(0, 1, \lin)).map(midiVal / 127.0) };

    bindsForKey.do { |b|
        target = b[\target];
        param  = b[\param];
        spec   = b[\spec];
        lag    = b[\lag] ? 0.0;
        value  = valueFrom127.(spec);
        ok     = false;

        // 1) Ndef, unconditionally (avoids Ndef.all emptiness issues)
        try {
            Ndef(target).set(param, value);
            ("[ cc ] % → Ndef(%).% = %").format(name, target, param, value).postln;
            ok = true;
        } { |e| };

        // 2) Pdef if Ndef wasn't set successfully
        if(ok.not) {
            try {
                Pdef(target).set(param, value);
                ("[ cc ] % → Pdef(%).% = %").format(name, target, param, value).postln;
                ok = true;
            } { |e| };
        };

        // 3) Fallback hook
        if(ok.not) {
            if(~onCCValue.notNil) {
                ~onCCValue.(name, value, midiVal);
                ("[ cc ] % → ~onCCValue (val:% raw:%)").format(name, value, midiVal).postln;
                ok = true;
            } {
                ("[ cc ] % had a binding but target wasn't found (no Pdef/Ndef/Function)")
                    .format(name).warn;
            };
        };

        if(ok) { trigged = true };
    };

    trigged
};

// ==================== Persistence ====================
~saveMap = { |path|
    var r, fpath, count;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    fpath = path ? (r[\mapFile] ? ~ccMapDefaultPath.());
    r[\mapFile] = fpath;
    ~ensureDir.(fpath);
    r[\ccMap].writeArchive(fpath);
    count = r[\ccMap].size;
    ("[ saveMap ('ok':true,'count':%,'path':%) ]").format(count, fpath).postln;
    fpath
};

~loadMap = { |path|
    var r, fpath, exists, loaded, asId, count, firstUID, firstChan;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    fpath = path ? (r[\mapFile] ? ~ccMapDefaultPath.());
    exists = File.exists(fpath);
    if(exists.not) { ("[ loadMap ('info':no file,'path':%) ]").format(fpath).postln; ^nil };

    loaded = Object.readArchive(fpath);
    asId = loaded.isKindOf(IdentityDictionary).if({ loaded }, {
        var id; id = IdentityDictionary.new;
        loaded.keysValuesDo { |k, v| id[k] = v }; id
    });

    // Adopt first UID/chan from the map so routing works immediately
    firstUID = nil; firstChan = nil;
    asId.keysDo { |k|
        var v; v = asId[k];
        if(firstUID.isNil) { firstUID = v[\uid] };
        if(firstChan.isNil) { firstChan = v[\chan] };
    };

    r[\ccMap] = asId;
    if(r[\uid].isNil and: { firstUID.notNil }) {
        r[\uid] = firstUID; ("[ router ] adopted UID from map: %").format(firstUID).postln;
    };
    if(firstChan.notNil and: { r[\chan] != firstChan }) {
        r[\chan] = firstChan;
        ("[ router ] adopted channel from map: % (0-based; device sees %)"
            .format(firstChan, firstChan+1)).postln;
    };

    count = r[\ccMap].size;
    ("[ loadMap ('ok':true,'count':%,'path':%) ]").format(count, fpath).postln;
    count
};

// ==================== Inspect ====================
~printMap = { |bank = nil|
    var r, b, prefix, keys;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    b = bank ?? { r[\bank] ? 0 };
    prefix = ("b" ++ b ++ "_").asString;

    keys = r[\ccMap].keys.as(Array)
        .select { |k| k.asString.beginsWith(prefix) }
        .collect(_.asString)
        .sort;

    ("---- CC Map (bank % only) ----".format(b)).postln;
    if(keys.isEmpty) { "[printMap] no keys".postln; "------------------------------".postln; ^nil };

    // Order rows r1→r3 t1..t8, then f1..f8
    keys = keys.sort { |a, c|
        var isFa, isFc, ra, rc, ta, tc, fa, fc;
        isFa = a.contains("_f"); isFc = c.contains("_f");
        if(isFa != isFc) { ^(isFa.not) }; // rows first
        if(isFa and: { isFc }) { // compare faders
            fa = a.findRegexp("f(\\d+)"); fc = c.findRegexp("f(\\d+)");
            if(fa.isNil or: { fc.isNil }) { ^(a < c) };
            ^(fa[1].asInteger < fc[1].asInteger)
        }{
            ra = a.findRegexp("r(\\d+)"); rc = c.findRegexp("r(\\d+)");
            ta = a.findRegexp("t(\\d+)"); tc = c.findRegexp("t(\\d+)");
            if(ra.isNil or: { rc.isNil } or: { ta.isNil } or: { tc.isNil }) { ^(a < c) };
            (ra[1].asInteger < rc[1].asInteger) or: {
                (ra[1].asInteger == rc[1].asInteger) and: { ta[1].asInteger < tc[1].asInteger }
            }
        }
    };

    keys.do { |ks|
        var v;
        v = r[\ccMap][ks.asSymbol];
        "% -> cc:% chan:% uid:%".format(ks, v[\cc], v[\chan], v[\uid]).postln;
    };
    "------------------------------".postln;
};

~printMapAll = {
    var r, keys;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    keys = r[\ccMap].keys.as(Array).collect(_.asString).sort;
    "---- CC Map (ALL KEYS) ----".postln;
    keys.do { |ks|
        var v; v = r[\ccMap][ks.asSymbol];
        "% -> cc:% chan:% uid:%".format(ks, v[\cc], v[\chan], v[\uid]).postln;
    };
    "---------------------------".postln;
};

// ==================== Migration helper (dash → underscore) ====================
~migrateNamesToUnderscore = {
    var r, src, dst, changed;
    r = ~ccRouter ?? { ~installCCByNameRouter.() };
    src = r[\ccMap]; if(src.isNil) { ^nil };
    dst = IdentityDictionary.new; changed = 0;

    src.keysValuesDo { |k, v|
        var s, nk;
        s  = k.asString;
        nk = s.contains("-").if({ s.replace("-", "_").asSymbol }, { k });
        if(nk != k) { changed = changed + 1 };
        dst[nk] = v;
    };

    r[\ccMap] = dst; ~saveMap.();
    ("[migrate] renamed % keys to underscores; total now %").format(changed, dst.size).postln;
};

// ==================== Self-init ====================
if(~lcxlAutoInitDone.not) {
    ~lcxlAutoInitDone = true;
    if(MIDIClient.initialized.not) { MIDIClient.init };
    ~installCCByNameRouter.();
    ~loadMap.(nil);
    ~installBankButtons.();
    "[lcxl] init complete".postln;
}

