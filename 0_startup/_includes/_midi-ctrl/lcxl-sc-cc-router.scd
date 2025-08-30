/* =========================================================
   LCXL CC Router (UID-safe)
   - Fader learner (77..84)
   - Row learners R1/R2/R3 (exact CC sequences)
   - Bind CC name -> Ndef parameter
   - Save/Load (uid, channel, ccMap)
   - Startup compatibility shims:
       ~lcxlMapPath.()   // function returning the path
       ~loadMap.()       // wrapper to load map from disk
       ~saveMap.()       // wrapper to save map to disk
   Notes:
   - No auto-run/defer block here; your startup.scd can call ~loadMap.()
   - No ~_names; all vars declared at the top of functions.
========================================================= */

// -------------------------------
// CONFIG: default save/load path
// -------------------------------
~ccMapPath = "/Users/isaaclinder/_includes/_midi-ctrl/lcxl-track-mute.map";

// ----------------------------------------------------
// INTERNAL STATE (kept in ~ccRouter IdentityDictionary)
// ----------------------------------------------------
~installCCByNameRouter = {
    var routerExists, init, onCC, def, chanOne;
    routerExists = ~ccRouter.notNil and: { ~ccRouter.isKindOf(IdentityDictionary) };
    if(routerExists) {
        chanOne = ((~ccRouter[\chan] ? 7) + 1);
        "[ ccRouter (installed)  ('filterByUID': %, 'uid': %, 'chan': %) ]"
            .postf(~ccRouter[\filterByUID], ~ccRouter[\uid], chanOne).postln;
        ^~ccRouter
    };

    init = {
        var r;
        r = IdentityDictionary.new;
        r[\name]        = "CCRouter";
        r[\uid]         = nil;                 // Integer UID of selected device
        r[\filterByUID] = true;                // limit handling to the selected device
        r[\chan]        = 7;                   // zero-based channel (prints as 8)
        r[\devSubstr]   = "Launch Control XL"; // default device name substring
        r[\ccMap]       = IdentityDictionary.new;  // name -> (cc, chan, uid)
        r[\binds]       = IdentityDictionary.new;  // name -> binding record
        r[\defs]        = IdentityDictionary.new;  // internal MIDIdef registry
        r
    };

    ~ccRouter = init.value;
    "[ ccRouter (installed)  ('filterByUID': %) ]".postf(~ccRouter[\filterByUID]).postln;

    onCC = { |val, cc, chan, src|
        var r, uid, okDevice, okChan;
        var recCC, recChan, recUID, ccMatch, chanMatch, uidMatch;
        r = ~ccRouter;
        uid = src.tryPerform(\uid) ? src;

        okDevice = r[\filterByUID].if({
            (r[\uid].notNil) and: { uid == r[\uid] }
        },{
            true
        });

        okChan = (chan == (r[\chan] ? 7));

        if(okDevice and: { okChan }) {
            r[\ccMap].keysValuesDo { |key, rec|
                recCC   = rec[\cc];
                recChan = rec[\chan];
                recUID  = rec[\uid];
                ccMatch   = recCC == cc;
                chanMatch = recChan == chan;
                uidMatch  = recUID.isNil or: { recUID == uid };
                if(ccMatch and: { chanMatch } and: { uidMatch }) {
                    ~ccApplyBinding.(key, val);
                };
            };
        };
    };

    def = MIDIdef.cc(\_ccrouter_global, onCC);
    ~ccRouter[\defs][\globalRouter] = def;

    ~ccRouter
};

// ---------------------------------------
// HELPERS: endpoint lookup & safe src info
// ---------------------------------------
~ccFindEndpointByUID = { |uid|
    var ep;
    ep = MIDIClient.sources.detect { |e| e.uid == uid };
    ep ?? { MIDIClient.destinations.detect { |e| e.uid == uid } }
};

~ccSafeSrcInfo = { |src|
    var uid, ep, name;
    uid  = src.tryPerform(\uid) ? src;
    ep   = ~ccFindEndpointByUID.(uid);
    name = ep.notNil.if({ ep.tryPerform(\name) ? { ep.device ? "" } }, { "uid:%".format(uid) });
    (uid: uid, name: name, endpoint: ep)
};

// ---------------------------------------
// CONFIG: device selection & channel
// ---------------------------------------
~setCCDeviceByName = { |substr = "Launch Control XL"|
    var ep, uid;
    ep = MIDIClient.sources.detect { |e| e.name.asString.contains(substr) };
    ep ?? { ep = MIDIClient.destinations.detect { |e| e.name.asString.contains(substr) } };

    if(ep.isNil) {
        "[ ccDevice  ('error': device not found, 'substr': %) ]".postf(substr).postln;
        ^nil
    };

    uid = ep.uid;
    ~ccRouter[\uid] = uid;
    ~ccRouter[\devSubstr] = substr;
    "[ ccDevice  ('uid': %, 'name': %) ]".postf(uid, ep.name).postln;
    uid
};

~setCCDeviceByUID = { |uid|
    var ep, nameStr;
    ep = ~ccFindEndpointByUID.(uid);
    nameStr = ep.notNil.if({ ep.name }, { "?" });
    ~ccRouter[\uid] = uid;
    "[ ccDevice  ('uid': %, 'name': %) ]".postf(uid, nameStr).postln;
    uid
};

~setCCChannel = { |oneBased = 8|
    var zero;
    zero = (oneBased - 1).clip(0, 15);
    ~ccRouter[\chan] = zero;
    "[ ccChan   ('chan': %) ]".postf(zero + 1).postln;
    zero
};

// ---------------------------------------
// LEARNERS: faders (strict 77..84), deterministic
// ---------------------------------------
~learnFaders = {
    var r, wantCCs, names, idx, got, def, headerChanOne, devName;

    r       = ~ccRouter ? { ~installCCByNameRouter.() };
    wantCCs = (77..84);                                 // LCXL Factory faders
    names   = [\f1,\f2,\f3,\f4,\f5,\f6,\f7,\f8];
    idx     = 0;
    got     = IdentityDictionary.new;

    headerChanOne = ((r[\chan] ? 7) + 1);
    devName = r[\devSubstr] ? "Launch Control XL";

    ("LEARN: Move faders 1→8 on '%', channel % (Factory template)…"
        .format(devName, headerChanOne)).postln;

    MIDIdef(\_ccrouter_learnFaders).free;  // ensure clean

    def = MIDIdef.cc(\_ccrouter_learnFaders, { |val, cc, chan, src|
        var uid, ep, name, expect, routerChan, okChan, accepted, slotName;

        uid  = src.tryPerform(\uid) ? src;
        ep   = MIDIClient.sources.detect { |e| e.uid == uid }
            ? MIDIClient.destinations.detect { |e| e.uid == uid };
        name = ep.notNil.if({ ep.tryPerform(\name) ? { ep.device ? "" } }, { "uid:%".format(uid) });

        routerChan = r[\chan] ? 7;   // zero-based, live each event
        expect     = wantCCs[idx];

        if(idx == 0 and: { chan != routerChan }) {
            r[\chan] = chan;
            ("LEARN set router channel = % (one-based %)"
                .format(chan, chan+1)).postln;
            routerChan = chan;
        };

        okChan   = (chan == routerChan);
        accepted = okChan and: { cc == expect };

        ("LEARN recv cc:% chan(zero):% val:% dev:%  expect:% idx:%  okChan:% -> %"
            .format(cc, chan, val, name, expect, idx, okChan, accepted)).postln;

        if(accepted) {
            slotName = names[idx];
            got[slotName] = (cc: cc, chan: chan, uid: uid);
            ("% ✔ % → cc:% (chan:% dev:%)").postf(slotName, cc, chan+1, name).postln;

            if(r[\uid].isNil) {  // capture UID once
                r[\uid] = uid;
                ("LEARN set router UID = % (%).".format(uid, name)).postln;
            };

            idx = idx + 1;

            if(idx >= names.size) {
                def.free;
                got.keysValuesDo { |k, rec| r[\ccMap][k] = rec };
                ("[ ccLoad  ('ok': true, 'names': %) ]".format(got.keys)).postln;
            };
        };
    });
};

// ----------------------------------------------------
// ROW LEARNER GENERATOR + row wrappers
// ----------------------------------------------------
~ccMakeRowLearner = { |label, ccList, names|
    var r, idx, got, def, headerChanOne, devName;

    r       = ~ccRouter ? { ~installCCByNameRouter.() };
    idx     = 0;
    got     = IdentityDictionary.new;
    headerChanOne = ((r[\chan] ? 7) + 1);
    devName = r[\devSubstr] ? "Launch Control XL";

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
            ("LEARN set router channel = % (one-based %)")
                .format(chan, chan+1).postln;
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

    def
};

// Row 1 (your dump): 13,14,15,16,17,18,19,20
~learnRow1 = {
    var ccList, names;
    ccList = [13,14,15,16,17,18,19,20];
    names  = [\t1r1,\t2r1,\t3r1,\t4r1,\t5r1,\t6r1,\t7r1,\t8r1];
    ~ccMakeRowLearner.( "Row1", ccList, names )
};

// Row 2 (your dump): 20,29,30,31,32,33,34,35
~learnRow2 = {
    var ccList, names;
    ccList = [20,29,30,31,32,33,34,35];
    names  = [\t1r2,\t2r2,\t3r2,\t4r2,\t5r2,\t6r2,\t7r2,\t8r2];
    ~ccMakeRowLearner.( "Row2", ccList, names )
};

// Row 3 (your dump): 35,36,49,50,51,52,53,54
~learnRow3 = {
    var ccList, names;
    ccList = [35,36,49,50,51,52,53,54];
    names  = [\t1r3,\t2r3,\t3r3,\t4r3,\t5r3,\t6r3,\t7r3,\t8r3];
    ~ccMakeRowLearner.( "Row3", ccList, names )
};

// ---------------------------------------
// BINDINGS: name -> target param control
// ---------------------------------------
~ccBind = { |name, target, param, spec|
    var r, rec, ndef, kind, bindRec, specUse;

    r       = ~ccRouter;
    rec     = r[\ccMap][name];
    specUse = spec ? ControlSpec(0, 1, \lin);   // portable default here

    if(rec.isNil) {
        "[ ccBind  ('error': 'no mapping for %') ]".postf(name).postln;
        ^nil
    };

    if(target.isKindOf(Symbol)) {
        ndef = Ndef(target);
        kind = \ndef;
    }{
        ndef = target;
        kind = (ndef.isKindOf(NodeProxy) or: { ndef.isKindOf(Ndef) }).if({ \ndef }, { \unknown })
    };

    if(kind != \ndef) {
        "[ ccBind  ('error': unsupported target kind) ]".postln;
        ^nil
    };

    bindRec = (kind: \ndef, name: name, ndef: ndef.key, param: param, spec: specUse);
    r[\binds][name] = bindRec;

    "[ ccBind+  ('kind': ndef, 'name': %, 'param': %, 'ndef': %) ]"
        .postf(name, param, ndef.key).postln;
    r[\binds][name]
};

~ccApplyBinding = { |name, val|
    var r, bindRec, spec, norm, scaled, ndef;

    r = ~ccRouter;
    bindRec = r[\binds][name];
    if(bindRec.isNil) { ^nil };

    spec   = bindRec[\spec] ? ControlSpec(0, 1, \lin);
    norm   = val / 127.0;
    scaled = spec.map(norm);

    ndef = Ndef(bindRec[\ndef]);
    ndef.set(bindRec[\param], scaled);
};

// ---------------------------------------
// UTILITIES: dump/clear current mappings
// ---------------------------------------
~ccDumpCCMap = {
    var r;
    r = ~ccRouter ? { ~installCCByNameRouter.() };
    r[\ccMap].keysValuesDo { |k, rec|
        "% -> chan:%  cc:%  uid:%".postf(k, rec[\chan]+1, rec[\cc], rec[\uid]).postln;
    };
    r[\ccMap].keys
};

~ccClearMap = {
    var r;
    r = ~ccRouter ? { ~installCCByNameRouter.() };
    r[\ccMap] = IdentityDictionary.new;
    "[ ccMap ('cleared': true) ]".postln;
    true
};

// ---------------------------------------
// SAVE / LOAD map (uid, chan, ccMap)
// ---------------------------------------
~ccSaveMap = { |path|
    var r, dir, pack, ok;
    r = ~ccRouter ? { ~installCCByNameRouter.() };

    pack = (
        uid:   r[\uid],
        chan:  r[\chan],          // zero-based
        ccMap: r[\ccMap].copy
    );

    dir = PathName(path).parentPath;
    if(dir.notNil and: { File.exists(dir).not }) { PathName(dir).mkdir };

    ok = pack.writeArchive(path);
    if(ok) {
        "[ saveMap  ('ok': true, 'path': %) ]".format(path).postln;
    }{
        "[ saveMap  ('ok': false, 'path': %) ]".format(path).postln;
    };
    ok
};

~ccLoadMap = { |path|
    var r, hasFile, pack, map, chanOne;
    r = ~ccRouter ? { ~installCCByNameRouter.() };
    hasFile = File.exists(path);

    if(hasFile.not) {
        "[ loadMap  ('info': no file, 'path': %) ]".format(path).postln;
        ^Set[]
    };

    pack = Object.readArchive(path);
    if(pack.isKindOf(Event).not and: { pack.isKindOf(Dictionary).not }) {
        "[ loadMap  ('error': bad archive, 'path': %) ]".format(path).postln;
        ^Set[]
    };

    r[\uid]  = pack[\uid] ? r[\uid];
    r[\chan] = pack[\chan] ? r[\chan];

    map = pack[\ccMap];
    if(map.isKindOf(IdentityDictionary).not and: { map.isKindOf(Dictionary).not }) {
        "[ loadMap  ('error': no ccMap in archive, 'path': %) ]".format(path).postln;
        ^Set[]
    };

    r[\ccMap] = IdentityDictionary.newFrom(map);

    chanOne = ((r[\chan] ? 7) + 1);
    "[ loadMap  ('ok': true, 'uid': %, 'chan': %, 'count': %) ]"
        .format(r[\uid], chanOne, r[\ccMap].size).postln;

    r[\ccMap].keys
};

// ---------------------------------------
// OPTIONAL: quick CC probe for debugging
// ---------------------------------------
~probeCCs = {
    var r, def;
    r = ~ccRouter ? { ~installCCByNameRouter.() };

    def = MIDIdef.cc(\_ccrouter_probe, { |val, cc, chan, src|
        var info, okDev, okChan, chanOne;
        info   = ~ccSafeSrcInfo.(src);
        okDev  = r[\filterByUID].if({ (r[\uid].notNil) and: { info[\uid] == r[\uid] } }, { true });
        okChan = (chan == (r[\chan] ? 7));
        if(okDev and: { okChan }) {
            chanOne = chan + 1;
            "[ cc: %, chan: %, val: %  % ]".postf(cc, chanOne, val, info[\name]).postln;
        };
    });

    def
};

// ---------------------------------------
// STARTUP COMPATIBILITY SHIMS (for your startup.scd)
// ---------------------------------------
// Your startup calls these; they delegate to the core API above.

~lcxlMapPath = {
    var p;
    p = ~ccMapPath ? "/Users/isaaclinder/_includes/_midi-ctrl/lcxl-track-mute.map";
    p
};

~loadMap = {
    var path, keys;
    path = ~lcxlMapPath.().asString;
    keys = ~ccLoadMap.(path);
    keys
};

~saveMap = {
    var path, ok;
    path = ~lcxlMapPath.().asString;
    ok = ~ccSaveMap.(path);
    ok
};

