// apc_param_router.locked.uid.v12b.scd  2025-10-09 America Chicago
// Knob mapping fixed: 48..55 -> strip by CC, 16..23 -> strip by channel
// Adds RAW note logging for grid diagnostics  no right parens in comments

(
~apcParam = ~apcParam ? IdentityDictionary.new;

if(~apcParam[\bankIdx].isNil)    { ~apcParam[\bankIdx]    = 0 };
if(~apcParam[\prefix].isNil)     { ~apcParam[\prefix]     = "" };
if(~apcParam[\debug].isNil)      { ~apcParam[\debug]      = false };
if(~apcParam[\palette].isNil)    { ~apcParam[\palette]    = (selected: 127, unselected: 10, on: 127, off: 0) };
if(~apcParam[\pdefMap].isNil)    { ~apcParam[\pdefMap]    = IdentityDictionary.new };
if(~apcParam[\handlers].isNil)   { ~apcParam[\handlers]   = IdentityDictionary.new };

if(~apcParam[\faderCC].isNil)    { ~apcParam[\faderCC]    = 7 };
if(~apcParam[\masterChan].isNil) { ~apcParam[\masterChan] = 0 };
if(~apcParam[\masterCC].isNil)   { ~apcParam[\masterCC]   = 14 };
if(~apcParam[\bankNotes].isNil)  { ~apcParam[\bankNotes]  = (82..89) };
if(~apcParam[\gridChan].isNil)   { ~apcParam[\gridChan]   = 0 };
if(~apcParam[\gridNotes].isNil)  { ~apcParam[\gridNotes]  = (0..39) };

~apcDetectUID = {
    var ep, both, uid;
    ep = MIDIClient.sources.detect { |e|
        both = (e.device.asString ++ " " ++ e.name.asString).toLower;
        both.contains("apc40")
    };
    uid = ep !? { ep.uid };
    if(uid.notNil) { ~apcParam[\srcID] = uid };
    uid
};

~apcParam[\dbgSay] = { |...xs| var on; on = ~apcParam[\debug] ? false; if(on) { xs.postln } };

~apcParam[\makeKey] = { |bank, strip1, slotSym|
    var pfx, k;
    pfx = ~apcParam[\prefix];
    k = (pfx ++ "b" ++ bank ++ "_s" ++ strip1 ++ "_" ++ slotSym.asString).asSymbol;
    ^k
};

~apcParam[\ensureOut] = {
    var dest, o, both;
    dest = MIDIClient.destinations.detect { |e|
        both = (e.device.asString ++ " " ++ e.name.asString).toLower;
        both.contains("apc40")
    };
    if(dest.isNil) { ^nil };
    o = MIDIOut.newByName(dest.device, dest.name);
    ~apcParam[\out] = o; o
};

~apcParam[\ledNote] = { |note, vel| var o; o = ~apcParam[\out]; if(o.isNil) { o = ~apcParam[\ensureOut].() }; if(o.notNil) { o.noteOn(0, note, vel) } };

~apcParam[\refreshBankLEDs] = {
    var notes, pal, bank;
    notes = ~apcParam[\bankNotes];
    pal   = ~apcParam[\palette];
    bank  = ~apcParam[\bankIdx] ? 0;
    if(notes.isNil) { ^thisThread };
    8.do { |k| var on, n, v; on = (bank == k); n = notes.wrapAt(k); v = on.if(pal[\selected], pal[\unselected]); ~apcParam[\ledNote].(n, v) };
    ~apcParam[\dbgSay].("[APC] leds refreshed bank " ++ bank);
};

~apcParam[\refreshGridLED] = { |note| var pal, p, on; pal = ~apcParam[\palette]; p = ~apcParam[\pdefMap][note]; on = (p.notNil and: { Pdef(p).isPlaying }).if(pal[\on], pal[\off]); ~apcParam[\ledNote].(note, on) };

~apcMapPdef = { |note, pdefName| var n; n = note; ~apcParam[\pdefMap][n] = pdefName.asSymbol; ~apcParam[\refreshGridLED].(n) };
~apcUnmapPdef = { |note| var n; n = note; ~apcParam[\pdefMap].removeAt(n); ~apcParam[\ledNote].(n, ~apcParam[\palette][\off]) };

~apcArmLocked = {
    var srcUID, dbg;
    if(~apcParam[\srcID].isNil or: { ~apcParam[\srcID].isNumber.not }) { ~apcDetectUID.() };
    srcUID = ~apcParam[\srcID];
    dbg    = ~apcParam[\debug] ? false;

    MIDIdef.free(\apc40_note_raw);
    MIDIdef.free(\apc40_bank_note);
    MIDIdef.free(\apc40_grid_on);
    MIDIdef.free(\apc40_cc);

    // RAW note logger to confirm pads
    MIDIdef.noteOn(\apc40_note_raw, { |vel, note, chan, src|
        if(srcUID.notNil and: { src != srcUID }) { ^nil };
        if(dbg) { "[APC RAW NOTE] note:% vel:% chan0:%".format(note, vel, chan).postln };
    }, nil, nil, srcUID);

    // bank select
    MIDIdef.noteOn(\apc40_bank_note, { |vel, note, chan, src|
        var idx;
        if(srcUID.notNil and: { src != srcUID }) { ^nil };
        idx = ~apcParam[\bankNotes].indexOf(note);
        if(idx.notNil) {
            ~apcParam[\bankIdx] = idx;
            ("[APC SAFE] bank -> " ++ idx).postln;
            ~apcParam[\refreshBankLEDs].();
        };
    }, nil, nil, srcUID);

    // grid toggle  ch gridChan
    MIDIdef.noteOn(\apc40_grid_on, { |vel, note, chan, src|
        var p;
        if(srcUID.notNil and: { src != srcUID }) { ^nil };
        if(chan != (~apcParam[\gridChan] ? 0)) { ^nil };
        if(~apcParam[\gridNotes].includes(note)) {
            p = ~apcParam[\pdefMap][note];
            if(p.notNil) {
                if(Pdef(p).isPlaying) { Pdef(p).stop } { Pdef(p).play };
                ~apcParam[\refreshGridLED].(note);
            };
        };
    }, nil, ~apcParam[\gridChan] ? 0, srcUID);

    // CCs
    MIDIdef.cc(\apc40_cc, { |val, cc, chan, src|
        var v01, bank, strip1, key, h, knobA, knobB;
        if(srcUID.notNil and: { src != srcUID }) { ^nil };
        if(dbg) { "[APC RAW] cc:% val:% chan0:%".format(cc, val, chan).postln };

        v01  = val / 127.0;
        bank = ~apcParam[\bankIdx] ? 0;

        // master
        if((chan == (~apcParam[\masterChan] ? 0)) and: { cc == (~apcParam[\masterCC] ? 14) }) {
            key = (~apcParam[\prefix] ++ "master_f").asSymbol;
            if(~ccEmit.notNil) { ~ccEmit.(key, v01) };
            h = ~apcParam[\handlers][key];
            if(h.notNil) { h.(v01) };
            if(dbg) { "[APC PEAK] cc:% val:% chan0:%".format(cc, val, chan).postln };
            ^nil;
        };

        // faders  cc 7 ch 0..7
        if((cc == (~apcParam[\faderCC] ? 7)) and: { chan >= 0 } and: { chan <= 7 }) {
            strip1 = chan + 1;
            key = ~apcParam[\makeKey].(bank, strip1, \f);
            if(~ccEmit.notNil) { ~ccEmit.(key, v01) };
            h = ~apcParam[\handlers][key];
            if(h.notNil) { h.(v01) };
            if(dbg) { "[APC PEAK] cc:% val:% chan0:%".format(cc, val, chan).postln };
            ^nil;
        };

        // knobs 16..23 -> strip by channel, 48..55 -> strip by CC
        knobA = (cc >= 16) and: (cc <= 23);  // likely sends row
        knobB = (cc >= 48) and: (cc <= 55);  // top device row

        if(knobA and: { chan >= 0 } and: { chan <= 7 }) {
            strip1 = chan + 1;
            key = ~apcParam[\makeKey].(bank, strip1, \r1);
            if(~ccEmit.notNil) { ~ccEmit.(key, v01) };
            h = ~apcParam[\handlers][key];
            if(h.notNil) { h.(v01) };
            if(dbg) { "[APC PEAK] cc:% val:% chan0:%".format(cc, val, chan).postln };
            ^nil;
        };

        if(knobB and: { chan >= 0 } and: { chan <= 7 }) {
            strip1 = (cc - 48) + 1; // cc48 -> s1
            key = ~apcParam[\makeKey].(bank, strip1, \r1);
            if(~ccEmit.notNil) { ~ccEmit.(key, v01) };
            h = ~apcParam[\handlers][key];
            if(h.notNil) { h.(v01) };
            if(dbg) { "[APC PEAK] cc:% val:% chan0:%".format(cc, val, chan).postln };
            ^nil;
        };

        if(dbg) { "[APC MISS] no branch cc % ch %".format(cc, chan).postln };
    }, nil, nil, srcUID);

    ~apcParam[\ensureOut].();
    ~apcParam[\refreshBankLEDs].();
    ~apcParam[\dbgSay].("[APC armed] uid " ++ srcUID);
};

~apcRefresh = {
    var notes;
    ~apcParam[\refreshBankLEDs].();
    notes = ~apcParam[\pdefMap].keys;
    notes.do(~apcParam[\refreshGridLED]);
};
)

