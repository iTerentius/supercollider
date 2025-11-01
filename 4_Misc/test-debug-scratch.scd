~lcxlKill.();  // just in case
~lcxlArmOnce.();
(
// file: lcxl_boot_all_v1_3b_diag_noHUI.scd
// timestamp 2025-10-19 16:53 UTC-05:00
// purpose: diagnostic build that EXCLUDES the Launch Control XL HUI endpoint and prints clocks
// usage: eval this file, then run ~lcxlKill.(); ~lcxlArmOnce.(); move knobs/pads and watch prints.

var say, findLCXL, ensureOut, installCC, installNote, paintAll, paintBanks, paintProw, v01, mapSpec;

// shared state
~lcxl = ~lcxl ? IdentityDictionary.new;
~lcxl[\srcName]    = ~lcxl[\srcName]    ? "Launch Control XL";
~lcxl[\chan]       = (~lcxl[\chan] ? 0).clip(0, 15);
~lcxl[\uid]        = ~lcxl[\uid] ? nil;
~lcxl[\out]        = ~lcxl[\out] ? nil;
~lcxl[\debug]      = true;
~lcxl[\prefix]     = ~lcxl[\prefix] ? "";
~lcxl[\bankIdx]    = (~lcxl[\bankIdx] ? 0).clip(0, 7);
~lcxl[\handlers]   = ~lcxl[\handlers] ? IdentityDictionary.new;
~lcxl[\specs]      = ~lcxl[\specs] ? IdentityDictionary.new;
~lcxl[\pAssign]    = ~lcxl[\pAssign] ? IdentityDictionary.new;
~lcxl[\palette]    = ~lcxl[\palette] ? (off: 12, green: 60, amber: 63);
~lcxl[\bankNotes]  = ~lcxl[\bankNotes] ? [73, 74, 75, 76, 89, 90, 91, 92];
~lcxl[\prowNotes]  = ~lcxl[\prowNotes] ? [41, 42, 43, 44, 57, 58, 59, 60];
~lcxl[\ccRows]     = ~lcxl[\ccRows] ? (
    r1: [13, 14, 15, 16, 17, 18, 19, 20],
    r2: [29, 30, 31, 32, 33, 34, 35, 36],
    r3: [49, 50, 51, 52, 53, 54, 55, 56],
    f:  [77, 78, 79, 80, 81, 82, 83, 84]
);

say = { |... args| if(~lcxl[\debug]) { args.postln } };
v01 = { |val| (val.linlin(0, 127, 0, 1.0)).clip(0, 1) };
mapSpec = { |spec, x01| var v; v = x01.clip(0,1); if(spec.isKindOf(ControlSpec)) { ^spec.map(v) } { ^x01 } };

// prefer non-HUI endpoint
findLCXL = {
    var srcs, chosen, idx, uid;
    srcs = MIDIClient.sources;
    chosen = srcs.detect { |ep| ep.device.notNil and: { ep.device.asString.find(~lcxl[\srcName]).notNil } and: { ep.name.asString.find("HUI").isNil } };
    if(chosen.isNil) {
        // fallback to any match if non-HUI not found
        chosen = srcs.detect { |ep| ep.device.notNil and: { ep.device.asString.find(~lcxl[\srcName]).notNil } };
    };
    if(chosen.isNil) { "[LCXL diag noHUI] not found".postln; ^nil };
    idx = srcs.indexOf(chosen); uid = chosen.uid;
    ~lcxl[\uid] = uid; ~lcxl[\srcIndex] = idx;
    ("[LCXL diag noHUI] picked src uid:" + uid + " idx:" + idx + " name:" + chosen.name).postln;
    ^uid;
};

// prefer non-HUI dest
ensureOut = {
    if(~lcxl[\out].isNil) {
        var dests, chosen, out;
        dests = MIDIClient.destinations;
        chosen = dests.detect { |d| d.device.notNil and: { d.device.asString.find(~lcxl[\srcName]).notNil } and: { d.name.asString.find("HUI").isNil } };
        if(chosen.isNil) {
            chosen = dests.detect { |d| d.device.notNil and: { d.device.asString.find(~lcxl[\srcName]).notNil } };
        };
        if(chosen.isNil) { "[LCXL diag noHUI] no destination".postln; ^nil };
        out = MIDIOut.newByName(chosen.device, chosen.name);
        if(out.notNil) { ~lcxl[\out] = out; ("[LCXL diag noHUI] out " ++ chosen.device ++ " / " ++ chosen.name).postln };
    };
    ^~lcxl[\out];
};

// vanilla LED write
~lcxlNoteLED = { |note, vel| var out; out = ensureOut.(); if(out.isNil) { ^nil }; out.noteOn(~lcxl[\chan], note, vel) };

paintBanks = { var sel; sel = ~lcxl[\bankIdx].clip(0,7);
    ~lcxl[\bankNotes].do { |n,i| var v; v = if(i==sel) { ~lcxl[\palette][\green] } { ~lcxl[\palette][\amber] }; ~lcxlNoteLED.(n, v) }
};

paintProw = { ~lcxl[\prowNotes].do { |n,i|
    var b,s,key,assigned,playing,want; b = ~lcxl[\bankIdx]; s = (i%4)+1; key = ("b"++b++"_s"++s++"_p").asSymbol;
    assigned = ~lcxl[\pAssign][key].notNil; playing = (assigned and: { Pdef(~lcxl[\pAssign][key]).isPlaying });
    want = if(playing) { ~lcxl[\palette][\green] } { if(assigned) { ~lcxl[\palette][\amber] } { ~lcxl[\palette][\off] } };
    ~lcxlNoteLED.(n, want);
} };

paintAll = { paintBanks.(); paintProw.() };

~lcxlMakeKey = { |bank, strip, rowSym| var pre; pre = ~lcxl[\prefix] ? ""; ^((pre ++ "b" ++ bank ++ "_s" ++ strip ++ "_" ++ rowSym.asString).asSymbol) };

~lcxlBindParam = { |keySym, fn, spec| var key; key = keySym.asSymbol; ~lcxl[\handlers][key] = fn; if(spec.notNil) { ~lcxl[\specs][key] = spec }; say.("[LCXL bind]", key); ^key };
~lcxlBindAt = { |bank=0, strip=1, row=\r1, fn, spec| var k; k = ~lcxlMakeKey.(bank.clip(0,7), strip.clip(1,8), row); ~lcxlBindParam.(k, fn, spec) };
~lcxlPN_assign = { |keySym, pdefKey| ~lcxl[\pAssign][keySym.asSymbol] = pdefKey.asSymbol; paintProw.(); keySym };
~lcxlPN_unassign = { |keySym| ~lcxl[\pAssign].removeAt(keySym.asSymbol); paintProw.(); keySym };

installCC = {
    var name, rows, chan, uid;
    name = \lcxl_cc_full_diag_noHUI; rows = ~lcxl[\ccRows]; chan = ~lcxl[\chan]; uid = ~lcxl[\uid];
    MIDIdef.cc(name, { |val, cc, chanIn, src|
        var bank, strip, rowSym, key, fn, spec, x, mapped;
        ("[LCXL diag noHUI cc] clock:" + thisThread.clock.asString + " srcUid:" + src.uid + " cc:" + cc + " v:" + val).postln;
        if(src.uid != uid) { ^nil };
        bank = ~lcxl[\bankIdx]; strip = nil; rowSym = nil;
        rows.keysValuesDo { |sym, arr| var idx; idx = arr.indexOf(cc); if(idx.notNil) { rowSym = sym; strip = idx+1 } };
        if(rowSym.isNil or: { strip.isNil }) { ^nil };
        key = ~lcxlMakeKey.(bank, strip, rowSym); fn = ~lcxl[\handlers][key]; spec = ~lcxl[\specs][key];
        x = v01.(val);
        if(fn.notNil) { mapped = mapSpec.(spec, x); fn.(mapped) };
        say.("[LCXL cc]", key, "cc", cc, "v", val, "x", x);
    }, nil, chan, uid);
    "[LCXL diag noHUI] CC armed".postln;
};

installNote = {
    var name, uid, chan, banks, prow;
    name = \lcxl_note_diag_noHUI; uid = ~lcxl[\uid]; chan = ~lcxl[\chan];
    banks = ~lcxl[\bankNotes]; prow = ~lcxl[\prowNotes];

    MIDIdef.noteOn(name, { |vel, num, chanIn, src|
        var idx, i, b, s, key, p;
        ("[LCXL diag noHUI noteOn] clock:" + thisThread.clock.asString + " srcUid:" + src.uid + " num:" + num + " vel:" + vel).postln;
        if(src.uid != uid) { ^nil };
        if(banks.includes(num)) { idx = banks.indexOf(num).clip(0,7); ~lcxl[\bankIdx] = idx; paintBanks.(); ^nil };
        if(prow.includes(num)) {
            i = prow.indexOf(num); b = ~lcxl[\bankIdx]; s = (i%4)+1; key = ("b"++b++"_s"++s++"_p").asSymbol; p = ~lcxl[\pAssign][key];
            if(p.notNil) { if(vel>0) { if(Pdef(p).isPlaying) { Pdef(p).stop } { Pdef(p).play }; paintProw.(); } }{
                "[LCXL diag noHUI] no assign for %".format(key).postln; ~lcxlNoteLED.(num, ~lcxl[\palette][\off]); paintProw.();
            }; ^nil;
        };
    }, nil, chan, uid);

    MIDIdef.noteOff(\lcxl_note_off_diag_noHUI, { |vel, num, chanIn, src|
        ("[LCXL diag noHUI noteOff] clock:" + thisThread.clock.asString + " srcUid:" + src.uid + " num:" + num).postln;
        if(src.uid != uid) { ^nil };
        if(~lcxl[\prowNotes].includes(num)) { paintProw.() };
    }, nil, chan, uid);

    "[LCXL diag noHUI] Note armed".postln;
};

~lcxlArmOnce = {
    if(findLCXL.().isNil) { "[LCXL diag noHUI] device not found".postln; ^nil };
    ensureOut.();
    installCC.();
    installNote.();
    paintAll.();
    "[LCXL diag noHUI] armed".postln;
};

~lcxlKill = {
    MIDIdef.free(\lcxl_cc_full_diag_noHUI);
    MIDIdef.free(\lcxl_note_diag_noHUI);
    MIDIdef.free(\lcxl_note_off_diag_noHUI);
    "[LCXL diag noHUI] freed".postln;
};

)
