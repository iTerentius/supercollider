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
)
