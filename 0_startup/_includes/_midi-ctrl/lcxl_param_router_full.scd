
// lcxl_param_router.full.v5.scd  2025-09-26 14:13
// Unified LCXL param router
// - Keys: \bN_sM_r1 \bN_sM_r2 \bN_sM_r3 \bN_sM_f
// - Vars at top of funcs, no ) in comments, no env locals as locals
(
~lcxlParam = ~lcxlParam ? ();
~lcxlParam[\bankIdx]   = (~lcxlParam[\bankIdx] ? 0).clip(0,7);
~lcxlParam[\bankNotes] = ~lcxlParam[\bankNotes] ? [73, 74, 75, 76, 89, 90, 91, 92];
~lcxlParam[\palette]   = ~lcxlParam[\palette] ? (selected: 127, unselected: 10);

// CC layout per strip s1..s8. Change if your template differs
~lcxlParam[\r1] = ~lcxlParam[\r1] ? [13, 14, 15, 16, 17, 18, 19, 20];
~lcxlParam[\r2] = ~lcxlParam[\r2] ? [29, 30, 31, 32, 33, 34, 35, 36];
~lcxlParam[\r3] = ~lcxlParam[\r3] ? [49, 50, 51, 52, 53, 54, 55, 56];
~lcxlParam[\f ] = ~lcxlParam[\f ] ? [77, 78, 79, 80, 81, 82, 83, 84];

~lcxlParam[\srcID]    = ~lcxlParam[\srcID] ? nil;
~lcxlParam[\chan0]    = ~lcxlParam[\chan0] ? 8;   // zero-based 8 equals MIDI ch 9
~lcxlParam[\ledChan0] = ~lcxlParam[\ledChan0] ? 8;
~lcxlParam[\strict]   = ~lcxlParam[\strict] ? false;

~lcxlParam[\defs]     = ~lcxlParam[\defs] ? Array.new;
~lcxlParam[\handlers] = ~lcxlParam[\handlers] ? IdentityDictionary.new;
~lcxlParam[\debug]    = ~lcxlParam[\debug] ? false;

// helpers
~lcxlParam[\to01]    = { |v| v / 127 };
~lcxlParam[\normUID] = { |s| var u; u = nil; if(s.notNil) { if(s.respondsTo(\uid)) { u = s.uid } { u = s.asInteger } }; u };
~lcxlParam[\findEP]  = { |uid| MIDIClient.sources.detect { |x| x.uid == uid } };

~lcxlParam[\learnSrc] = { |s|
    var already, u, ep;
    already = ~lcxlParam[\srcID];
    if(already.isNil) {
        u = ~lcxlParam[\normUID].(s);
        if(u.notNil) {
            ep = ~lcxlParam[\findEP].(u);
            if(ep.notNil) { ~lcxlParam[\srcID] = ep; "[lcxl] src learned %".format(u).postln };
        };
    };
};

~lcxlParam[\keyFor] = { |bankIndex, strip1, slot| ("b" ++ bankIndex ++ "_s" ++ strip1 ++ "_" ++ slot).asSymbol };
~lcxlBindParam   = { |key, func| ~lcxlParam[\handlers][key] = func; "[lcxl] bind %".format(key).postln };
~lcxlUnbindParam = { |key| ~lcxlParam[\handlers].removeAt(key) };

~lcxlParam[\ensureOut] = {
    var dest, found, out;
    dest = MIDIClient.destinations.detect { |ep| ep.device == "Launch Control XL" and: { ep.name == "Launch Control XL" } };
    if(dest.isNil) { "[lcxl] dest not found".postln; ^nil };
    found = MIDIOut.findPort(dest.device, dest.name);
    out = if(found.notNil) { MIDIOut.newByName(dest.device, dest.name) } { MIDIOut.new(0) };
    ~lcxlParam[\out] = out; out
};

~lcxlParam[\refreshLEDs] = {
    var out, pal, chan, notes, i, k, sel, val, id;
    out = ~lcxlParam[\out];
    if(out.isNil) { out = ~lcxlParam[\ensureOut].() };
    if(out.isNil) { "[lcxl] cannot refresh leds. no midi out".postln; ^nil };
    pal = ~lcxlParam[\palette];
    chan = ~lcxlParam[\ledChan0] ? 0;
    notes = ~lcxlParam[\bankNotes];
    8.do { |i| k = i; sel = ((~lcxlParam[\bankIdx] ? 0) == k);
        val = sel.if { pal[\selected] } { pal[\unselected] };
        if(notes.notNil and: { k < notes.size }) { id = notes[k]; if(val > 0) { out.noteOn(chan, id, val) } { out.noteOff(chan, id, 0) }; };
    };
    "[lcxl] leds refreshed bank %".format(~lcxlParam[\bankIdx] ? 0).postln;
};

~lcxlParam[\unbindAll] = { ~lcxlParam[\defs].do { |k| MIDIdef.free(k) }; ~lcxlParam[\defs] = Array.new };

~lcxlParam[\armBanks] = {
    var notes, chan0, strict, name;
    notes = ~lcxlParam[\bankNotes];
    chan0 = ~lcxlParam[\chan0] ? 0;
    strict = ~lcxlParam[\strict] ? false;
    MIDIdef.free(\lcxl_bank_note); name = \lcxl_bank_note;
    MIDIdef.noteOn(name, { |vel, note, chan, src| var idx;
        ~lcxlParam[\learnSrc].(src);
        if(strict and: { chan != chan0 }) { ^nil };
        idx = notes.indexOf(note);
        if(idx.notNil) { ~lcxlParam[\bankIdx] = idx; "[lcxl] bank -> %".format(idx).postln; ~lcxlParam[\refreshLEDs].(); };
    });
    ~lcxlParam[\defs].add(name);
};

~lcxlParam[\srcMatch] = { |incoming| var i, l; i = ~lcxlParam[\normUID].(incoming); l = ~lcxlParam[\normUID].(~lcxlParam[\srcID]); i.notNil and: { l.notNil } and: { i == l } };

~lcxlParam[\armCC] = {
    var r1, r2, r3, f, chan0, strict, name;
    r1 = ~lcxlParam[\r1]; r2 = ~lcxlParam[\r2]; r3 = ~lcxlParam[\r3]; f = ~lcxlParam[\f];
    chan0 = ~lcxlParam[\chan0] ? 0; strict = ~lcxlParam[\strict] ? false;
    MIDIdef.free(\lcxl_cc_full); name = \lcxl_cc_full;
    MIDIdef.cc(name, { |val, cc, chan, src|
        var bank, idx, strip1, slot, key, fn, v01;
        ~lcxlParam[\learnSrc].(src);
        if(strict and: { chan != chan0 }) { ^nil };
        if(~lcxlParam[\srcID].notNil and: { ~lcxlParam[\srcMatch].(src).not }) { ^nil };
        bank = ~lcxlParam[\bankIdx] ? 0; v01 = ~lcxlParam[\to01].(val);
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
        key = ~lcxlParam[\keyFor].(bank, strip1, slot.asString);
        fn = ~lcxlParam[\handlers][key];
        if(fn.notNil) { fn.(v01) };
        if(~lcxlParam[\debug]) { ["[param]", key, v01].postln };
    });
    ~lcxlParam[\defs].add(name);
};

~lcxlParam[\unbindAll].();
~lcxlParam[\armBanks].();
~lcxlParam[\armCC].();
~lcxlParam[\ensureOut].();
~lcxlParam[\refreshLEDs].();
"[lcxl param router] armed r1 r2 r3 f  chan0 %  bank %".format(~lcxlParam[\chan0], ~lcxlParam[\bankIdx]).postln;
)
