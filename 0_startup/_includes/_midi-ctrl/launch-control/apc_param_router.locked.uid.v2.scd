// apc_param_router.locked.uid.v3.scd  2025-10-11 14:16:18 America/Chicago
// APC40 mkII router using UID filter  LCXL-style structure  no right parens in comments

(
var ep, uid;

// state and config
~apcParam = ~apcParam ? ();

~apcParam[\bankIdx]   = (~apcParam[\bankIdx] ? 0).clip(0,7);
~apcParam[\palette]   = ~apcParam[\palette] ? (selected: 127, unselected: 0); // LED values
~apcParam[\prefix]    = ~apcParam[\prefix] ? ""; // optional key prefix
~apcParam[\handlers]  = ~apcParam[\handlers] ? IdentityDictionary.new;
~apcParam[\snapshotMuteMs] = ~apcParam[\snapshotMuteMs] ? 0.15;
~apcParam[\masterCC]  = ~apcParam[\masterCC] ? 7; // also accept 14

// key builder parity with LCXL
~apcParam[\makeKey] = { |bank, strip, role|
    var pfx, b, s, r;
    pfx = ~apcParam[\prefix] ? "";
    b = bank.asInteger; s = strip.asInteger; r = role.asSymbol;
    (pfx ++ "b" ++ b ++ "_s" ++ s ++ "_" ++ r).asSymbol
};

// midi out for LED refresh  track select LEDs use note 0x33 sent on channels 0..7
~apcParam[\ensureOut] = {
    var dest, out, found;
    dest = MIDIClient.destinations.detect { |e| (e.device++" "++e.name).toLower.contains("apc40 mk") };
    if(dest.isNil) { ^nil };
    found = MIDIOut.findPort(dest.device, dest.name);
    out = if(found.notNil) { MIDIOut.newByName(dest.device, dest.name) } { MIDIOut.new(0) };
    ~apcParam[\out] = out; out
};

~apcParam[\refreshLEDs] = {
    var out, pal, bank, note, ch, val;
    out = ~apcParam[\out]; if(out.isNil) { out = ~apcParam[\ensureOut].() };
    if(out.isNil) { ^nil };
    pal = ~apcParam[\palette];
    bank = (~apcParam[\bankIdx] ? 0).clip(0,7);
    note = 16r33; // track select LED id
    8.do { |k|
        ch = k;
        val = (bank == k).if { pal[\selected] } { pal[\unselected] };
        if(val > 0) { out.noteOn(ch, note, val) } { out.noteOff(ch, note, 0) };
    };
    "[APC] leds refreshed bank %".format(bank).postln;
};

// resolve and store UID once on load
ep  = MIDIClient.sources.detect { |x| (x.device++" "++x.name).toLower.contains("apc40 mk") };
uid = ep.notNil.if({ ep.uid }, { ~apcParam[\srcID] });
~apcParam[\srcID] = uid;

// public bind api
~apcBindParam   = { |key, func| var k; k = key.asSymbol; ~apcParam[\handlers][k] = func; "[apc] bind %".format(k).postln; func };
~apcUnbindParam = { |key| var k; k = key.asSymbol; ~apcParam[\handlers].removeAt(k) };

// bank setter used by all sources
~apcParam[\setBankSafe] = { |i|
    var idx, now, win;
    idx = i.clip(0,7);
    now = SystemClock.seconds;
    win = ~apcParam[\snapshotMuteMs] ? 0.15;
    if(~apcParam[\bankIdx] != idx) {
        ~apcParam[\bankIdx] = idx;
        "[APC SAFE] bank -> %".format(idx).postln;
        ~apcParam[\snapshotMuteUntil] = now + win;
        ~apcParam[\refreshLEDs].();
    };
};

// main arm function LCXL-style
~apcArmLocked = { |strict=false, chan0=nil|
    var srcUID, debugOn;
    srcUID = ~apcParam[\srcID];
    debugOn = ~apcParam[\debug] ? false;

    // free prior defs
    MIDIdef.free(\apc40_cc);
    MIDIdef.free(\apc40_bank_lr);
    MIDIdef.free(\apc40_bank_stripbtn);

    // bank left right buttons  notes 0x3C 0x3D on press
    MIDIdef.noteOn(\apc40_bank_lr, { |vel, note, chan, src|
        var b;
        if(strict and: { chan0.notNil and: { chan != chan0 } }) { ^nil };
        if(src != srcUID) { ^nil };
        b = ~apcParam[\bankIdx] ? 0;
        if(vel > 0) {
            if(note == 16r3C) { ~apcParam[\setBankSafe].(b - 1) };
            if(note == 16r3D) { ~apcParam[\setBankSafe].(b + 1) };
        };
    }, nil, chan0, srcUID);

    // per strip buttons set bank based on their channel  notes 0x30..0x34 on press
    MIDIdef.noteOn(\apc40_bank_stripbtn, { |vel, note, chan, src|
        var isStrip;
        if(strict and: { chan0.notNil and: { chan != chan0 } }) { ^nil };
        if(src != srcUID) { ^nil };
        isStrip = (note >= 16r30) and: { note <= 16r34 }; // record solo activator trackselect stop
        if(isStrip and: { vel > 0 }) { ~apcParam[\setBankSafe].(chan.clip(0,7)) };
    }, nil, chan0, srcUID);

    // device control knobs cc 16..23 and 48..55  do not change bank
    MIDIdef.cc(\apc40_cc, { |val, cc, chan, src|
        var bank, strip1, v01, key, fn, now, muteUntil, isDev;
        if(strict and: { chan0.notNil and: { chan != chan0 } }) { ^nil };
        if(src != srcUID) { ^nil };
        v01 = val / 127.0;
        now = SystemClock.seconds;
        muteUntil = ~apcParam[\snapshotMuteUntil] ? 0.0;
        isDev = (((cc >= 16) and: { cc <= 23 }) or: { (cc >= 48) and: { cc <= 55 } });
        if(isDev.not) { ^nil };
        if(now < muteUntil) { ^nil };

        bank = ~apcParam[\bankIdx] ? 0;
        strip1 = (cc % 8) + 1;
        key = ~apcParam[\makeKey].(bank, strip1, \r1);
        if(~ccEmit.notNil) { ~ccEmit.(key, v01) };
        fn = ~apcParam[\handlers][key];
        if(fn.notNil) { fn.(v01) };
        if(debugOn) { ["[APC cc]", key, "cc", cc, "chan0", chan, "v01", v01].postln };
    }, nil, chan0, srcUID);

    ~apcParam[\ensureOut].();
    ~apcParam[\refreshLEDs].();
    "[APC SAFE] re-armed on uid %  chan0 %  strict %".format(srcUID, chan0, strict).postln;
};

~apcArmLocked.();
)

