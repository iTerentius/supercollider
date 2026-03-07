(
// file: lcxl_pdef_row.routerhook.s1to8.v1.scd
// timestamp 2025-10-14 03:10 CDT
// Purpose: P-row Pdef launcher using keys \bX_s1..s8_p with a lightweight note hook.
//          Does not create any MIDIdefs and does not modify your bank logic or refreshers.
//          Use by calling the hook at the top of your existing LCXL note handler:
//              if( ~lcxlPN_noteHook.(vel, note, chan, src) ) { ^nil };

// exact P-row notes left->right (physical 1..8 maps to indices 0..7)
~lcxlP_rowNotes = ~lcxlP_rowNotes ? [41, 42, 43, 44, 57, 58, 59, 60];

// colors for this row
~lcxlP_palette = ~lcxlP_palette ? (off: 0, amber: 21, green: 60);

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

~lcxlP_idxFrom = { |bank, strip0|
    var b, s;
    b = bank.asInteger.max(0);
    s = strip0.asInteger.clip(0, 7);
    (b * 8) + s
};

// parse \bX_sY_p  where Y in 1..8  -> [bank, strip0]
~lcxlP_parseKey = { |keySym|
    var s, parts, bank, strip, snum;
    s = keySym.asString;
    parts = s.split($_);
    if((parts.size != 3) or: { parts[0][0] != $b } or: { parts[1][0] != $s } or: { parts[2] != "p" }) {
        ^[0, 0]
    };
    bank  = parts[0].copyRange(1, parts[0].size-1).asInteger ? 0;
    snum  = parts[1].copyRange(1, parts[1].size-1).asInteger ? 1;  // 1..8
    strip = (snum - 1).clip(0, 7);  // 0..7 internal
    [bank, strip]
};

// LED for one visible strip
~lcxlP_ledForStrip = { |strip0, mode=\off|
    var noteNum, out, chan, pal, vel, vals;
    noteNum = ~lcxlP_rowNotes.wrapAt(strip0.asInteger.clip(0, 7));
    out  = (~lcxlParam !? { ~lcxlParam[\out] }) ?? { MIDIOut.newByName("Launch Control XL", "Launch Control XL") };
    chan = (~lcxlParam !? { ~lcxlParam[\ledChan0] }) ?? { (~lcxlParam !? { ~lcxlParam[\chan0] }) ?? { 8 } };
    pal = ~lcxlP_palette;
    vals = IdentityDictionary[\off->pal[\off], \amber->pal[\amber], \green->pal[\green]];
    vel = vals[mode] ? pal[\off];
    out.noteOn(chan.asInteger, noteNum, vel);
};

// public api
~lcxlBindPdef = { |keySym, pdefName|
    var bank, strip0, idx, nameSym;
    #bank, strip0 = ~lcxlP_parseKey.(keySym);
    idx = ~lcxlP_idxFrom.(bank, strip0);
    nameSym = pdefName.asSymbol;
    ~lcxlP_state[\idxToPdef][idx] = nameSym;
    if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledForStrip.(strip0, \amber) };
    ["[lcxl pdef assign]", keySym, "->", nameSym].postln;
};

~lcxlUnbindPdef = { |keySym|
    var bank, strip0, idx;
    #bank, strip0 = ~lcxlP_parseKey.(keySym);
    idx = ~lcxlP_idxFrom.(bank, strip0);
    ~lcxlP_state[\idxToPdef].removeAt(idx);
    ~lcxlP_state[\playing].put(idx, false);
    if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledForStrip.(strip0, \off) };
    ["[lcxl pdef unassign]", keySym].postln;
};

~lcxlPdefHandle = { |keySym, vel=127|
    var bank, strip0, idx, nameSym, wasPlaying, p;
    if(vel <= 0) { ^nil };
    #bank, strip0 = ~lcxlP_parseKey.(keySym);
    idx = ~lcxlP_idxFrom.(bank, strip0);
    nameSym = ~lcxlP_state[\idxToPdef][idx];
    if(nameSym.isNil) {
        ["[lcxl pdef]", "no-assign", keySym].postln;
        if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledForStrip.(strip0, \off) };
        ^nil
    };
    p = Pdef(nameSym);
    wasPlaying = ~lcxlP_state[\playing][idx] ? false;
    if(wasPlaying) {
        p.stop;
        ~lcxlP_state[\playing].put(idx, false);
        if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledForStrip.(strip0, \amber) };
        ["[lcxl pdef stop]", nameSym, keySym].postln;
    }{
        p.play;
        ~lcxlP_state[\playing].put(idx, true);
        if(bank == ~lcxlP_getBank.()) { ~lcxlP_ledForStrip.(strip0, \green) };
        ["[lcxl pdef play]", nameSym, keySym].postln;
    };
    ^p
};

~lcxlPdefRefresh = {
    var bank, c, idx, nameSym, isPlaying, mode;
    bank = ~lcxlP_getBank.();
    c = 0;
    while { c < 8 } {
        idx = ~lcxlP_idxFrom.(bank, c);
        nameSym = ~lcxlP_state[\idxToPdef][idx];
        isPlaying = ~lcxlP_state[\playing][idx] ? false;
        mode = if(nameSym.isNil) { \off } { if(isPlaying) { \green } { \amber } };
        ~lcxlP_ledForStrip.(c, mode);
        c = c + 1;
    };
    "[lcxl pdef] leds refreshed".postln;
};

// NOTE HOOK (call at top of your LCXL note handler)
// returns true if consumed (so your bank code should bail early)
~lcxlPN_noteHook = { |vel, note, chan, src|
    var row, col0, bank, key, wantChan, lcxlUID;
    row = ~lcxlP_rowNotes;
    wantChan = (~lcxlParam !? { ~lcxlParam[\chan0] }) ?? { 8 };
    if(chan != wantChan) { ^false };
    // optional UID guard if your config provides a srcID
    lcxlUID = ~lcxlParam[\srcID];
    if(lcxlUID.notNil and: { src.respondsTo(\uid) and: { src.uid != lcxlUID } }) { ^false };
    col0 = row.indexOf(note);
    if(col0.isNil) { ^false };
    if(vel <= 0) { ^true };
    bank = ~lcxlP_getBank.();
    key  = ("b" ++ bank ++ "_s" ++ (col0 + 1) ++ "_p").asSymbol;  // s1..s8
    ~lcxlPdefHandle.(key, vel);
    ^true
};
)
