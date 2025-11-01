// lcxl_param_router.locked.uid.v9.scd  2025-09-26 19:16
// LCXL router using UID filter with optional prefix and strictChan
// Keys default to \bN_sM_r1|r2|r3|f, set ~lcxlParam[\prefix] = "lx_" to prefix keys
// Vars declared at top, no ) in comments
(
var ep, uid;

// state and config
~lcxlParam = ~lcxlParam ? ();

~lcxlParam[\bankIdx]   = (~lcxlParam[\bankIdx] ? 0).clip(0,7);
~lcxlParam[\bankNotes] = ~lcxlParam[\bankNotes] ? [73,74,75,76,89,90,91,92];
~lcxlParam[\palette]   = ~lcxlParam[\palette] ? (selected: 127, unselected: 10);

// CC maps
~lcxlParam[\r1] = ~lcxlParam[\r1] ? [13,14,15,16,17,18,19,20];
~lcxlParam[\r2] = ~lcxlParam[\r2] ? [29,30,31,32,33,34,35,36];
~lcxlParam[\r3] = ~lcxlParam[\r3] ? [49,50,51,52,53,54,55,56];
~lcxlParam[\f ] = ~lcxlParam[\f ] ? [77,78,79,80,81,82,83,84];

~lcxlParam[\chan0]     = ~lcxlParam[\chan0] ? 8;   // nil disables channel filtering
~lcxlParam[\strictChan]= ~lcxlParam[\strictChan] ? true;
~lcxlParam[\ledChan0]  = ~lcxlParam[\ledChan0] ? 8;
~lcxlParam[\prefix]    = ~lcxlParam[\prefix] ? ""; // set to "lx_" if you want prefixed keys
~lcxlParam[\debug]     = ~lcxlParam[\debug] ? false;
~lcxlParam[\handlers]  = ~lcxlParam[\handlers] ? IdentityDictionary.new;

// bind api
~lcxlBindParam   = { |key, func| ~lcxlParam[\handlers][key] = func; "[LCXL] bind %".format(key).postln; func };
~lcxlUnbindParam = { |key| ~lcxlParam[\handlers].removeAt(key) };

// midi out for LED refresh
~lcxlParam[\ensureOut] = {
    var dest, out, found;
    dest = MIDIClient.destinations.detect { |e| e.device == "Launch Control XL" and: { e.name == "Launch Control XL" } };
    if(dest.isNil) { ^nil };
    found = MIDIOut.findPort(dest.device, dest.name);
    out = if(found.notNil) { MIDIOut.newByName(dest.device, dest.name) } { MIDIOut.new(0) };
    ~lcxlParam[\out] = out; out
};

~lcxlParam[\refreshLEDs] = {
    var out, pal, chan, notes, val, id, sel;
    out = ~lcxlParam[\out]; if(out.isNil) { out = ~lcxlParam[\ensureOut].() };
    if(out.isNil) { ^nil };
    pal = ~lcxlParam[\palette];
    chan = ~lcxlParam[\ledChan0] ? 0;
    notes = ~lcxlParam[\bankNotes];
    8.do { |k| sel = ((~lcxlParam[\bankIdx] ? 0) == k);
        val = sel.if { pal[\selected] } { pal[\unselected] };
        id = notes[k];
        if(val > 0) { out.noteOn(chan, id, val) } { out.noteOff(chan, id, 0) };
    };
    ~lcxlPdefRefresh.();   // <— add this line
    "[LCXL] leds refreshed bank %".format(~lcxlParam[\bankIdx] ? 0).postln;
};

// resolve and store UID once on load
ep  = MIDIClient.sources.detect { |x| x.device == "Launch Control XL" and: { x.name == "Launch Control XL" } };
uid = ep.notNil.if({ ep.uid }, { ~lcxlParam[\srcID] });
~lcxlParam[\srcID] = uid;

// internal helper to build key
~lcxlParam[\makeKey] = { |bank, strip1, slotSym|
    var pfx, k;
    pfx = ~lcxlParam[\prefix] ? "";
    k = (pfx ++ "b" ++ bank ++ "_s" ++ strip1 ++ "_" ++ slotSym.asString).asSymbol;
    k
};

~lcxlArmLocked = {
    var srcUID, chan0, strict, r1, r2, r3, f, notes, debugOn;

    srcUID  = ~lcxlParam[\srcID];
    chan0   = ~lcxlParam[\chan0];     // may be nil to relax filter
    strict  = ~lcxlParam[\strictChan] ? true;
    debugOn = ~lcxlParam[\debug] ? false;

    r1 = ~lcxlParam[\r1]; r2 = ~lcxlParam[\r2]; r3 = ~lcxlParam[\r3]; f = ~lcxlParam[\f ];
    notes = ~lcxlParam[\bankNotes];

    MIDIdef.free(\lcxl_bank_note);
    MIDIdef.free(\lcxl_cc_full);

    MIDIdef.noteOn(\lcxl_bank_note, { |vel, note, chan, src|
        var idx;
        if(strict and: { chan0.notNil and: { chan != chan0 } }) { ^nil };
        idx = notes.indexOf(note);
        if(idx.notNil) { ~lcxlParam[\bankIdx] = idx; "[LCXL SAFE] bank -> %".format(idx).postln; ~lcxlParam[\refreshLEDs].() };
    }, nil, chan0, srcUID);

    MIDIdef.cc(\lcxl_cc_full, { |val, cc, chan, src|
        var bank, idx, strip1, slot, key, v01, fn;
        if(strict and: { chan0.notNil and: { chan != chan0 } }) { ^nil };
        bank = ~lcxlParam[\bankIdx] ? 0; v01 = val / 127.0;
        idx = r1.indexOf(cc);
        if(idx.notNil) { strip1 = idx + 1; slot = \r1 } {
            idx = r2.indexOf(cc);
            if(idx.notNil) { strip1 = idx + 1; slot = \r2 } {
                idx = r3.indexOf(cc);
                if(idx.notNil) { strip1 = idx + 1; slot = \r3 } {
                    idx = f.indexOf(cc);
                    if(idx.notNil) { strip1 = idx + 1; slot = \f } { ^nil }
                }
            }
        };
        key = ~lcxlParam[\makeKey].(bank, strip1, slot);
        if(~ccEmit.notNil) { ~ccEmit.(key, v01) };
        fn = ~lcxlParam[\handlers][key];
        if(fn.notNil) { fn.(v01) };
        if(debugOn) { ["[LCXL cc]", key, "cc", cc, "chan0", chan, "v01", v01].postln };
    }, nil, chan0, srcUID);

    ~lcxlParam[\ensureOut].();
    ~lcxlParam[\refreshLEDs].();
    "[LCXL SAFE] re-armed on uid %  chan0 %  strict %".format(srcUID, chan0, strict).postln;
};





// -----------------------------------------------------------------------------
// PDEF LAUNCHER INLINE ADDON  timestamp 2025-10-13 22:55 CDT
// Row: "above bank" on LCXL sending NOTE ON channel 8 notes [41,42,43,44,57,58,59,60]
// Does not touch your bank row logic. Unique MIDIdef name; safe to re-eval.
// -----------------------------------------------------------------------------

// exact notes left to right
~lcxlP_rowNotes = ~lcxlP_rowNotes ? [41, 42, 43, 44, 57, 58, 59, 60];

// palette map for this row only, defaulting to your router palette when available
// ~lcxlP_palette = ~lcxlP_palette ? ( 
//     off: 0,
//     amber: ((~lcxlParam !? { ~lcxlParam[\palette][\unselected] }) ?? { 21 }),
//     green: ((~lcxlParam !? { ~lcxlParam[\palette][\selected] }) ?? { 127 })
// );
~lcxlP_palette = (
    off: 0,
    amber: 21,
    green: 60
);

// state
~lcxlP_state = ~lcxlP_state ? IdentityDictionary[
    \idxToPdef -> IdentityDictionary.new,
    \playing   -> IdentityDictionary.new
];

// helpers
~lcxlP_getBank = {
    var b;
    b = (~lcxlParam !? { ~lcxlParam[\bankIdx] }) ?? { 0 };
    b.asInteger.max(0)
};

~lcxlP_idxFrom = { |bank, strip|
    var b, s;
    b = bank.asInteger.max(0);
    s = strip.asInteger.clip(0, 7);
    (b * 8) + s
};

~lcxlP_parseKey = { |keySym|
    var s, parts, bank, strip, snum;
    s = keySym.asString;
    parts = s.split($_);
    if((parts.size != 3) or: { parts[0][0] != $b } or: { parts[1][0] != $s } or: { parts[2] != "p" }) { ^[0,0] };
    bank  = parts[0].copyRange(1, parts[0].size-1).asInteger ? 0;
    snum  = parts[1].copyRange(1, parts[1].size-1).asInteger ? 1;  // 1..8
    strip = (snum - 1).clip(0, 7);  // internal 0..7
    [bank, strip]
};

// LED for one key on the same note number
~lcxlP_ledKey = { |keySym, mode=\off|
    var strip, noteNum, out, chan, pal, vel;
    strip = ~lcxlP_parseKey.(keySym)[1];
    if(strip.isNil) { ^nil };
    noteNum = ~lcxlP_rowNotes.wrapAt(strip.asInteger.clip(0,7));
    out = (~lcxlParam !? { ~lcxlParam[\out] }) ?? { MIDIOut.newByName("Launch Control XL", "Launch Control XL") };
    chan = (~lcxlParam !? { ~lcxlParam[\ledChan0] }) ?? { (~lcxlParam !? { ~lcxlParam[\chan0] }) ?? { 8 } };
    pal = ~lcxlP_palette;

    vel = switch(mode,
        \off,   { pal[\off] },
        \amber, { pal[\amber] },
        \green, { pal[\green] },
        { pal[\off] }
    );

    out.noteOn(chan.asInteger, noteNum, vel);
};

// public api
~lcxlBindPdef = { |keySym, pdefName|
    var bank, strip, idx;
    bank = ~lcxlP_parseKey.(keySym)[0];
    strip = ~lcxlP_parseKey.(keySym)[1];
    idx = ~lcxlP_idxFrom.(bank, strip);
    ~lcxlP_state[\idxToPdef][idx] = pdefName.asSymbol;
    if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledKey.(keySym, \amber) };
    ["[LCXL PDEF assign]", keySym, "->", pdefName].postln;
};

~lcxlUnbindPdef = { |keySym|
    var bank, strip, idx;
    bank = ~lcxlP_parseKey.(keySym)[0];
    strip = ~lcxlP_parseKey.(keySym)[1];
    idx = ~lcxlP_idxFrom.(bank, strip);
    ~lcxlP_state[\idxToPdef].removeAt(idx);
    ~lcxlP_state[\playing].put(idx, false);
    if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledKey.(keySym, \off) };
};

~lcxlPdefHandle = { |keySym, vel=127|
    var bank, strip, idx, nameSym, wasPlaying, p;
    if(vel <= 0) { ^nil };
    bank = ~lcxlP_parseKey.(keySym)[0];
    strip = ~lcxlP_parseKey.(keySym)[1];
    idx = ~lcxlP_idxFrom.(bank, strip);
    nameSym = ~lcxlP_state[\idxToPdef][idx];
    if(nameSym.isNil) { ["[LCXL PDEF]", "no-assign", keySym].postln; if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledKey.(keySym, \off) }; ^nil };
    p = Pdef(nameSym);
    wasPlaying = ~lcxlP_state[\playing][idx] ? false;
    if(wasPlaying) {
        p.stop;
        ~lcxlP_state[\playing].put(idx, false);
        if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledKey.(keySym, \amber) };
        ["[LCXL PDEF stop]", nameSym, keySym].postln;
    }{
        p.play;
        ~lcxlP_state[\playing].put(idx, true);
        if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledKey.(keySym, \green) };
        ["[LCXL PDEF play]", nameSym, keySym].postln;
    };
    ^p
};

~lcxlPdefRefresh = {
    var bank = ~lcxlP_getBank.();
    8.do { |c|
        var idx = ~lcxlP_idxFrom.(bank, c);
        var nameSym = ~lcxlP_state[\idxToPdef][idx];
        var isPlaying = ~lcxlP_state[\playing][idx] ? false;
        var key = ("b" ++ bank ++ "_s" ++ (c + 1) ++ "_p").asSymbol;
        if(nameSym.isNil) { ~lcxlP_ledKey.(key, \off) } { ~lcxlP_ledKey.(key, if(isPlaying) { \green } { \amber }) };
    };
};

// dedicated note-on listener for the p-row, unique name and tight note filter
~lcxlPdefArm = {
    var name, chan, row;
    name = \lcxl_pdef_row_note_safe_v2;

    // free only our def if it exists
    MIDIdef(name).free;

    chan = (~lcxlParam !? { ~lcxlParam[\chan0] }) ?? { 8 };
    row  = ~lcxlP_rowNotes;

    MIDIdef.noteOn(name, { |vel, note, chIn, src|
        var col, bank, key;
        if(chIn != chan) { ^nil };
        col = row.indexOf(note);
        if(col.isNil) { ^nil };
        bank = ~lcxlP_getBank.();
        key = ("b" ++ bank ++ "_s" ++ (col + 1) ++ "_p").asSymbol;
        ~lcxlPdefHandle.(key, vel);
    }, nil, chan, nil);

    ["[LCXL PDEF armed]", "chan", chan, "notes", row].postln;
};

// allow external rearmers to call once they are done
~lcxlPdefRearm = {
    ~lcxlPdefArm.();
    ~lcxlPdefRefresh.();
    "[LCXL PDEF rearmed]".postln;
};

// arm & paint on load
~lcxlPdefArm.();
~lcxlPdefRefresh.();

// -----------------------------------------------------------------------------
// end PDEF addon
// -----------------------------------------------------------------------------
)
