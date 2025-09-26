// lcn_param_router.locked.uid.v3.scd  2025-09-26 18:13
// Endpoint-locked LCN router using UID filter. Keys: \bN_sM_r1 \bN_sM_r2
// Vars declared at top, no ) in comments
(
var ep, uid;

~lcn = ~lcn ? ();
~lcn[\bankIdx] = (~lcn[\bankIdx] ? 0).clip(0,7);
~lcn[\chan0]   = ~lcn[\chan0] ? 9;   // zero-based 9 equals MIDI ch 10
~lcn[\config]  = ~lcn[\config] ? IdentityDictionary.new;
~lcn[\config].put(\btnNotes, (~lcn[\config][\btnNotes] ? [9,10,11,12,25,26,27,28]));
~lcn[\config].put(\r1,       (~lcn[\config][\r1] ? [21,22,23,24,25,26,27,28]));
~lcn[\config].put(\r2,       (~lcn[\config][\r2] ? [41,42,43,44,45,46,47,48]));
~lcn[\config].put(\strictChan, (~lcn[\config][\strictChan] ? true));

~lcn[\handlers] = ~lcn[\handlers] ? IdentityDictionary.new;
~lcnBindParam   = { |key, func| ~lcn[\handlers][key] = func; "[LC] bind %".format(key).postln };
~lcnUnbindParam = { |key| ~lcn[\handlers].removeAt(key) };
~lcn[\dispatch] = { |key, val| var fn; fn = ~lcn[\handlers][key]; if(fn.notNil) { fn.(val) } { ["[LC no-handler]", key, val].postln } };

// resolve and store UID once
ep  = MIDIClient.sources.detect { |x| x.device == "Launch Control" and: { x.name == "Launch Control" } };
uid = ep.notNil.if({ ep.uid }, { ~lcn[\srcID] });
~lcn[\srcID] = uid;  // store UID so defs survive CoreMIDI re-inits

~lcnArmLocked = {
    var chan0, btn, r1, r2, strict, srcUID;
    chan0  = ~lcn[\chan0] ? 9;
    btn    = ~lcn[\config][\btnNotes];
    r1     = ~lcn[\config][\r1];
    r2     = ~lcn[\config][\r2];
    strict = ~lcn[\config][\strictChan] ? true;
    srcUID = ~lcn[\srcID];

    MIDIdef.free(\lcn_bank_note_locked);
    MIDIdef.free(\lcn_cc_locked);

    MIDIdef.noteOn(\lcn_bank_note_locked, { |vel, note, chan, src| var idx;
        if(strict and: { chan != chan0 }) { ^nil };
        idx = btn.indexOf(note);
        if(idx.notNil) { ~lcn[\bankIdx] = idx; "[LC] bank -> %".format(idx).postln };
    }, nil, chan0, srcUID);  // src = UID

    MIDIdef.cc(\lcn_cc_locked, { |val, cc, chan, src|
        var idx, strip, key, v01, bank;
        if(strict and: { chan != chan0 }) { ^nil };
        v01 = val / 127.0; bank = ~lcn[\bankIdx] ? 0;
        idx = r1.indexOf(cc);
        if(idx.notNil) { strip = idx + 1; key = ("b" ++ bank ++ "_s" ++ strip ++ "_r1").asSymbol; ~lcn[\dispatch].(key, v01); ^nil };
        idx = r2.indexOf(cc);
        if(idx.notNil) { strip = idx + 1; key = ("b" ++ bank ++ "_s" ++ strip ++ "_r2").asSymbol; ~lcn[\dispatch].(key, v01); ^nil };
    }, nil, chan0, srcUID);  // src = UID

    "[LC] locked and armed on uid %  chan0 %".format(srcUID, chan0).postln;
};
)
