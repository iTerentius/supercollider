(
// Launch Control XL → CC Router (full include)
// - Declares vars at top of each Function
// - No nil-safe (?.) ops, no stray semicolons
// - Treats MIDIdef src as UID integer when filtering with srcID:

var st, rawChan, tripleKeyOf, ensureBindingSlot, rebuildReverseMap, postBank;

// minimal guard config (doesn't override your existing one)
if(~lcxl_config.isNil) { ~lcxl_config = (midiChan: 9) };
if(~lcxl.isNil) { ~lcxl = (bank: 0, defs: IdentityDictionary.new) };

// state
st = IdentityDictionary.new;
st[\defs]  = IdentityDictionary.new;       // MIDIdef slots created by this file
st[\ccMap] = IdentityDictionary.new;       // key -> (cc, chan(1-based), uid)
st[\rmap]  = IdentityDictionary.new;       // reverse: "uid:chan:cc" -> key

// helpers
rawChan = { (~lcxl_config[\midiChan] ? 9) - 1 };  // convert 1-based to 0-based
tripleKeyOf = { |uid, chan, cc| (uid.asString ++ ":" ++ chan.asString ++ ":" ++ cc.asString) };

ensureBindingSlot = { |name|
    var defs;
    defs = st[\defs];
    if(defs[name].notNil) { defs[name].free };
};

rebuildReverseMap = {
    var rmap;
    rmap = IdentityDictionary.new;
    st[\ccMap].keysValuesDo { |k, v|
        var tkey;
        tkey = tripleKeyOf.(v[\uid], v[\chan], v[\cc]);
        rmap[tkey] = k;
    };
    st[\rmap] = rmap;
};

postBank = { |b| ("[ bank  b" ++ b ++ " ]").postln };

// -------- SAVE / LOAD (text file next to your startup) --------
~ccSave = {
    var path, f;
    path = PathName(thisProcess.nowExecutingPath).parentPath ++ "_lcxl_cc_map.txt";
    f = File(path, "w");
    st[\ccMap].keysValuesDo { |k, v|
        f.write("% % % %\n".format(k, v[\cc], v[\chan], v[\uid]));
    };
    f.close;
    ("[lcxl] map saved to " ++ path).postln;
};

~ccLoad = {
    var path, str, lines;
    path = PathName(thisProcess.nowExecutingPath).parentPath ++ "_lcxl_cc_map.txt";
    if(File.exists(path).not) { "[lcxl] no saved map".warn; ^nil };

    str   = File.use(path, "r", { |f| f.readAllString });
    lines = str.split(Char.nl);

    st[\ccMap] = IdentityDictionary.new;
    lines.do { |line|
        if(line.size > 0) {
            var parts, key;
            parts = line.split($ );
            if(parts.size >= 4) {
                key = parts[0].asSymbol;
                st[\ccMap][key] = (
                    cc:   parts[1].asInteger,
                    chan: parts[2].asInteger,   // 1-based stored
                    uid:  parts[3].asInteger
                );
            };
        };
    };
    rebuildReverseMap.();
    "[lcxl] map loaded".postln;
};

// -------- ROUTER (CC by saved name → calls ~ccBind if present) --------
~installCCByNameRouter = {
    var name, defs;
    name = \lcxl_router_any;
    defs = st[\defs];

    ensureBindingSlot.(name);
    defs[name] = MIDIdef.cc(name, { |val, num, chan, src|
        // src is UID int when we pass srcID: below
        var humanChan, tkey, key;
        humanChan = chan + 1;                          // store/lookup in 1-based
        tkey      = tripleKeyOf.(src, humanChan, num); // src is already uid
        key       = st[\rmap][tkey];

        if(key.notNil and: { ~ccBind.notNil }) { ~ccBind.(key, val) };
    }, chan: rawChan.(), srcID: MIDIClient.sources.collect(_.uid));

    "[ lcxl→router ready  raw chan mode ]".postln;
};

// -------- (optional) SIMPLE LEARN STUBS (no-ops for now) --------
~learnFaders = { "[lcxl learn faders]".postln };
~learnRow    = { |row=1| ("[lcxl learn row " ++ row ++ "]").postln };

// -------- BANK API (bridge may hook into this) --------
~setBank = { |b|
    ~lcxl[\bank] = b;
    postBank.(b);
};

"[ lcxl  ready ]".postln;
)

