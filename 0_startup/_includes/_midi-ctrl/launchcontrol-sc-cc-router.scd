// launchcontrol-sc-cc-router.scd
// Drop-in CC router for Novation Launch Control (original, not XL)
// Two rows of 8 knobs, multi-bank learning and binding
// Timestamp: 2025-09-12 17:36 America/Chicago

// Notes
// - Avoid numbering with a parenthesis in comments to keep scnvim eval happy
// - All function vars are declared at the top of their blocks
// - No names use ~_ prefix
// - Key naming scheme matches LCXL style but uses k for knobs
//   Example key for bank 0, row 1, knob 3 is: \b0_k3_r1
// - Rows are 1 and 2; Knobs are 1..8
// - Banks default to 4. You can change ~lc.banks

(
~lc = (
    deviceName: "Launch Control",
    banks: 4,
    bank: 0,
    chan: nil,              // nil means accept any channel; set 0..15 to restrict
    srcUid: nil,            // restrict by MIDI source UID if desired
    ccMap: IdentityDictionary.new,  // key: \bX_kY_rZ -> (cc: num, chan: ch, uid: uid)
    learnActive: false,
    learnRow: nil,          // 1 or 2
    learnIndex: 0,          // 0-based while learning
    learnBank: 0,
    bankCCPrev: nil,        // optional CC numbers to move bank
    bankCCNext: nil,
    bankCCChan: nil,        // channel restriction for bank switching
    mapPath: Platform.userHomeDir +/+ "Music/supercollider/_midi_maps/launchcontrol_ccmap.json"
);

// Utilities

~lcEnsureMapDir = {
    var dir;
    dir = PathName(~lc.mapPath).pathOnly;
    if(dir.notNil and: { dir.size > 0 }) {
        File.mkdir(dir);
    };
};

~lcKey = { |bank, row, knob|
    var b, r, k;
    b = bank.asInteger.max(0);
    r = row.asInteger.max(1);
    k = knob.asInteger.max(1);
    ("b" ++ b ++ "_k" ++ k ++ "_r" ++ r).asSymbol;
};

~lcSetDeviceByName = { |name|
    var devs, match;
    var result;
    devs = MIDIClient.sources;
    match = devs.detect { |src| src.device.contains(name) or: { src.name.contains(name) } };
    if(match.notNil) {
        ~lc.srcUid = match.uid;
        ("[lc] bound to device uid:" + match.uid + " name:" + match.device + " port:" + match.name).postln;
        result = match.uid;
    }{
        ("[lc] device not found by name: " + name).warn;
        result = nil;
    };
    result;
};

~lcSetDeviceByUid = { |uid|
    var found;
    found = MIDIClient.sources.detect { |s| s.uid == uid };
    if(found.notNil) {
        ~lc.srcUid = uid;
        ("[lc] bound to device uid:" + uid + " name:" + found.device + " port:" + found.name).postln;
    }{
        ("[lc] uid not found: " + uid).warn;
    };
};

~lcSetChan = { |ch|
    var c;
    c = if(ch.isNil) { nil } { ch.asInteger.clip(0,15) };
    ~lc.chan = c;
    ("[lc] channel set to: " ++ (c.isNil.if({ "any" }, { c }))).postln;
};

~lcSetBank = { |bank|
    var b, maxb;
    maxb = (~lc.banks - 1).max(0);
    b = bank.asInteger.clip(0, maxb);
    ~lc.bank = b;
    ("[lc] bank -> " ++ b).postln;
};

~lcNextBank = {
    var b, maxb;
    maxb = (~lc.banks - 1).max(0);
    b = (~lc.bank + 1) % (maxb + 1);
    ~lc.bank = b;
    ("[lc] bank -> " ++ b).postln;
};

~lcPrevBank = {
    var b, maxb;
    maxb = (~lc.banks - 1).max(0);
    b = (~lc.bank - 1);
    if(b < 0) { b = maxb };
    ~lc.bank = b;
    ("[lc] bank -> " ++ b).postln;
};

~lcConfigureBankButtons = { |prevCC=nil, nextCC=nil, chan=nil|
    var c;
    ~lc.bankCCPrev = prevCC;
    ~lc.bankCCNext = nextCC;
    c = if(chan.isNil) { nil } { chan.asInteger.clip(0,15) };
    ~lc.bankCCChan = c;
    ("[lc] bank buttons prev:" + prevCC + " next:" + nextCC + " chan:" + c).postln;
};

~lcStartLearnRow = { |row=1, bank=nil|
    var r, b;
    r = row.asInteger.clip(1,2);
    b = if(bank.isNil) { ~lc.bank } { bank.asInteger };
    ~lc.learnActive = true;
    ~lc.learnRow = r;
    ~lc.learnIndex = 0;
    ~lc.learnBank = b;
    ("[lc] learning row " ++ r ++ " for bank " ++ b ++ " turn knobs in order").postln;
};

~lcStopLearn = {
    ~lc.learnActive = false;
    ~lc.learnRow = nil;
    ~lc.learnIndex = 0;
    ("[lc] learning stopped").postln;
};

~lcPrintMapAll = {
    var keys;
    keys = ~lc.ccMap.keys.asArray.sort;
    "-> IdentityDictionary[".postln;
    keys.do { |k|
        var e;
        e = ~lc.ccMap[k];
        ("  (" ++ k.asString ++ " -> ('cc': " ++ e[\cc] ++ ", 'uid': " ++ e[\uid] ++ ", 'chan': " ++ e[\chan] ++ "))").postln;
    };
    "]".postln;
};

~lcSaveMap = {
    var json, file, alist;
    var keys;
    ~lcEnsureMapDir.();
    keys = ~lc.ccMap.keys.asArray;
    alist = keys.collect { |k|
        var e;
        e = ~lc.ccMap[k];
        (key: k.asString, cc: e[\cc], chan: e[\chan], uid: e[\uid]);
    };
    json = alist.asJSON;
    file = File(~lc.mapPath, "w");
    if(file.isOpen) {
        file.write(json);
        file.close;
        ("[lc] saved map -> " ++ ~lc.mapPath).postln;
    }{
        ("[lc] failed to write " ++ ~lc.mapPath).warn;
    };
};

~lcLoadMap = {
    var file, txt, data;
    if(File.exists(~lc.mapPath).not) {
        ("[lc] map not found at " ++ ~lc.mapPath).postln;
        ^nil;
    };
    file = File(~lc.mapPath, "r");
    if(file.isOpen) {
        txt = file.readAllString;
        file.close;
        data = txt.parseJSON;
        if(data.isArray) {
            data.do { |row|
                var keySym, entry;
                keySym = row[\key].asSymbol;
                entry = (cc: row[\cc].asInteger, chan: row[\chan], uid: row[\uid]);
                ~lc.ccMap[keySym] = entry;
            };
            ("[lc] loaded map <- " ++ ~lc.mapPath).postln;
        }{
            ("[lc] parse error in " ++ ~lc.mapPath).warn;
        };
    }{
        ("[lc] failed to read " ++ ~lc.mapPath).warn;
    };
};

// CC router and learner
~lcInstallRouter = {
    var defName;
    defName = \lc_router;
    MIDIdef.cc(defName, { |val, num, chan, src|
        var okSrc, okChan, uid, isBankPrev, isBankNext, bankChOk;
        uid = src.uid;

        okSrc = if(~lc.srcUid.isNil) { true } { uid == ~lc.srcUid };
        okChan = if(~lc.chan.isNil) { true } { chan == ~lc.chan };

        // bank switches
        bankChOk = if(~lc.bankCCChan.isNil) { true } { chan == ~lc.bankCCChan };
        isBankPrev = (~lc.bankCCPrev.notNil) and: { num == ~lc.bankCCPrev } and: { bankChOk };
        isBankNext = (~lc.bankCCNext.notNil) and: { num == ~lc.bankCCNext } and: { bankChOk };

        if(isBankPrev and: { val > 0 }) { ~lcPrevBank.(); ^nil };
        if(isBankNext and: { val > 0 }) { ~lcNextBank.(); ^nil };

        // learning flow
        if(~lc.learnActive and: { okSrc } and: { okChan }) {
            var idx, row, knob, key;
            idx = ~lc.learnIndex;
            if(idx < 8) {
                row = ~lc.learnRow;
                knob = idx + 1;
                key = ~lcKey.(~lc.learnBank, row, knob);
                ~lc.ccMap[key] = (cc: num.asInteger, chan: chan.asInteger, uid: uid);
                ("LEARN row:" + row + " knob:" + knob + " -> cc:" + num + " chan:" + chan + " uid:" + uid).postln;
                ~lc.learnIndex = idx + 1;
                if(~lc.learnIndex >= 8) {
                    ~lcStopLearn.();
                    ~lcSaveMap.();
                };
            };
        };
    });
    ("[lc] router installed").postln;
};

// Binding helpers

~ccUnbind = { |key|
    var defKey;
    var removed;
    defKey = ("lc_cc_" ++ key.asString).asSymbol;
    removed = MIDIdef.cc(defKey);
    if(removed.notNil) {
        removed.free;
        ("[lc] unbound " ++ key.asString).postln;
    }{
        ("[lc] nothing to unbind for " ++ key.asString).postln;
    };
};

~ccBind = { |key, action, spec|
    var entry, ccnum, ch, uid, defKey;
    var mapper, sp;
    sp = spec ? ControlSpec(0,1,\lin,0,0);
    entry = ~lc.ccMap[key];
    if(entry.isNil) {
        ("[lc] no map for " ++ key.asString).warn;
        ^nil;
    };
    ccnum = entry[\cc];
    ch = entry[\chan];
    uid = entry[\uid];
    defKey = ("lc_cc_" ++ key.asString).asSymbol;

    mapper = { |val|
        var res, v;
        v = sp.map(val / 127);
        res = action.value(v);
        res;
    };

    MIDIdef.cc(defKey, { |val, num, chan, src|
        var ok1, ok2, ok3;
        ok1 = num == ccnum;
        ok2 = chan == ch;
        ok3 = src.uid == uid;
        if(ok1 and: { ok2 } and: { ok3 }) {
            mapper.value(val);
        };
    }).permanent_(true);

    ("[lc] bound " ++ key.asString ++ " cc:" ++ ccnum ++ " chan:" ++ ch ++ " uid:" ++ uid).postln;
};

~ccBindParam = { |key, ndefName, param, spec|
    var action, sp;
    sp = spec ? ControlSpec(0,1,\lin,0,0);
    action = { |v|
        var proxy;
        proxy = Ndef(ndefName);
        proxy.set(param, v);
    };
    ~ccBind.(key, action, sp);
};

// Convenience: bind a whole row of 8 knobs to one Ndef's 8 params
~ccBindRowToParams = { |bank=nil, row=1, ndefName, params, spec|
    var b, r;
    var count, i, sp;
    sp = spec ? ControlSpec(0,1,\lin,0,0);
    b = if(bank.isNil) { ~lc.bank } { bank.asInteger };
    r = row.asInteger.clip(1,2);
    count = params.size.min(8);
    i = 0;
    while({ i < count }, {
        var keySym;
        keySym = ~lcKey.(b, r, i+1);
        ~ccBindParam.(keySym, ndefName, params[i], sp);
        i = i + 1;
    });
};

// Boot and defaults
~lcInstallRouter.();
~lcLoadMap.();

// Optional bind by known UID, uncomment if desired
// ~lcSetDeviceByUid.(-261725438);

// Also add XL-style aliases so your startup can keep calling ~ccLoad and ~ccSave
~ccLoad = { ~lcLoadMap.() };
~ccSave = { ~lcSaveMap.() };

);

