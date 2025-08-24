/*  apc40mk2-track-mute.scd  — per-button (kind,chan,num) mapping with robust learn
    ------------------------------------------------------------------
    Akai APC40 mkII bottom row → orbits 0..7 with LEDs + persistence
    - Learns device (UID) and binds output automatically on first learn event
    - Learns 8 buttons as NOTE or CC (per button): stores {kind, chan, num}
    - Locks learn to the first-seen channel (learnChan) to avoid multi-channel floods
    - NOTE learn accepts noteOn OR noteOff (some APC rows send only noteOff)
    - CC path uses rising-edge (<=0 → >0) so momentary CCs toggle once
    - LEDs use NOTE/CC velocity on the per-button channel
    - Back-compat: loads old maps that had note[]/cc[] + a single chan
    - Passive at load: safe to re-evaluate; no MIDI init here
*/

// Uncomment if you DON'T init MIDI earlier:
// MIDIClient.init;
// MIDIIn.connectAll;

"apc40mk2-track-mute.scd LOADED (definitions only)".postln;

// --------------------------- Helpers ---------------------------
~stamp = { Date.getDate.stamp };
~pp = { |tag, data| ("[" ++ ~stamp.() ++ "] " ++ tag ++ "  " ++ data.asString).postln };
~edgeKey = { |chan, num| (chan * 128 + num) };  // CC press cache key

// -------------------------- State ------------------------------
~apc = (
    device: nil,          // captured at bind time (for name fallback)
    srcUid: nil,          // learned source UID
    chan: nil,            // first-seen channel (informational)
    out: nil,             // MIDIOut to APC destination
    orbitCount: 8,
    orbitMute: Array.fill(8, false),

    // Unified mapping: Array(8) of Events with \kind, \chan, \num per button
    map: nil,             // e.g. [ (kind:\note, chan:0, num:50), ..., 8 items ]

    // LED palette (APC40 mkII NOTE/CC velocity)
    // Common: 0 off, 1 green, 2 green blink, 3 red, 4 red blink, 5 yellow, 6 yellow blink
    onVal: 1,             // ON = green
    offVal: 0,            // OFF
    strictChan: false     // require learned device; per-button channels still used
);

// learn buffer (+ channel lock)
~apcLearn = (active: false, seen: IdentitySet.new, list: List.new, learnChan: nil);

// CC rising-edge cache: key = chan*128+num → last value
~apcPress = IdentityDictionary.new;

// ---------------------- Free old responders --------------------
MIDIdef.free(\apc_cc);
MIDIdef.free(\apc_note);
MIDIdef.free(\apc_noteOff);
MIDIdef.free(\apc_spy);
MIDIdef.free(\_apc_dev_cc);
MIDIdef.free(\_apc_dev_note);

// ----------------- Your mute/FX application hook ----------------
~apcApplyMuteState = { |orbit, muted|
    var f;
    ~pp.("call", (fn: muted.if("~fxonlyOn","~fxonlyOff"), orbit: orbit));
    if(muted) { f = ~fxonlyOn ? nil;  if(f.isKindOf(Function)) { f.(orbit) } }
    {          f = ~fxonlyOff ? nil; if(f.isKindOf(Function)) { f.(orbit) } };
};

// ---------------- Bind APC output by learned src UID ----------
~apcBindOutputForSrcUID = { |uid|
    var ep, dst, out, idx;
    ep  = MIDIClient.sources.detect { |m| m.uid == uid };
    if(ep.notNil) { ~apc[\device] = ep.device };
    dst = if(ep.notNil) { MIDIClient.destinations.detect { |d| d.device == ep.device } } { nil };

    if(dst.notNil) {
        if(MIDIOut.respondsTo(\newByName)) {
            out = MIDIOut.newByName(dst.device, dst.name);
        }{
            idx = MIDIClient.destinations.indexOf(dst);
            out = MIDIOut.new(idx);
        };
        ~apc[\out] = out;
        ~pp.("deviceLearn", (matchedDest: (device: dst.device, name: dst.name)));
    }{
        ~apc[\out] = nil;
        ~pp.("deviceLearn", (warn: "No APC40 mkII destination found; LEDs disabled"));
    };
};

// -------------------- Source match helper ---------------------
~apcSrcMatches = { |src|
    var ep;
    if(~apc[\srcUid].notNil) { ^(src.asInteger == ~apc[\srcUid]) };
    ep = MIDIClient.sources.detect { |m| m.uid == src.asInteger };
    if(ep.isNil) { ^false };
    if(~apc[\device].isNil) { ^false };
    ((ep.device ? "").contains(~apc[\device]) or: { (ep.name ? "").contains(~apc[\device]) })
};

// ----------------------- LED helpers (Note/CC) ----------------
~apcLed = { |i, isOn|
    var val, spec, chan, num, kind;
    if(~apc[\out].isNil) { ^nil };
    if(~apc[\map].isNil) { ^nil };

    spec = ~apc[\map][i];
    if(spec.isNil) { ^nil };

    val  = isOn.if(~apc[\onVal], ~apc[\offVal]);
    chan = spec[\chan] ? 0;
    num  = spec[\num];
    kind = spec[\kind];

    if(kind == \note) { ~apc[\out].noteOn(chan, num, val) };
    if(kind == \cc)   { ~apc[\out].control(chan, num, val) };
};

~apcRefreshLeds = {
    if(~apc[\map].isNil) { ^nil };
    ~apc[\orbitCount].do { |i| ~apcLed.(i, ~apc[\orbitMute][i].not) }; // lit = NOT muted
};

// -------------------------- Toggling ---------------------------
~toggleOrbitAPC = { |i|
    if(i < 0 or: { i >= ~apc[\orbitCount] }) { ^nil };
    ~apc[\orbitMute][i] = ~apc[\orbitMute][i].not;
    ~apcApplyMuteState.(i, ~apc[\orbitMute][i]);
    ~pp.("orbit", (index: i, muted: ~apc[\orbitMute][i]));
    ~apcLed.(i, ~apc[\orbitMute][i].not);
};

// ---------------------- Learn helpers -------------------------
~apcLatchSrcAndChanIfNeeded = { |chan, src|
    // If device not latched yet, latch it and bind output
    if(~apc[\srcUid].isNil) {
        ~apc[\srcUid] = src.asInteger;
        ~pp.("deviceLearn", (srcUid: ~apc[\srcUid], chan: chan));
        ~apcBindOutputForSrcUID.(~apc[\srcUid]);
    };
    // Lock learn channel on first valid event
    if(~apcLearn[\learnChan].isNil) {
        ~apcLearn[\learnChan] = chan;
        ~pp.("learn", (lockChan: chan));
    };
};

~apcLearnAdd = { |kind, chan, num|
    var key, evt;
    key = (kind.asString ++ ":" ++ chan ++ ":" ++ num).asSymbol;
    if(~apcLearn[\seen].includes(key).not) {
        ~apcLearn[\seen].add(key);
        evt = (kind: kind, chan: chan, num: num);
        ~apcLearn[\list].add(evt);
        ~pp.("learn", (count: ~apcLearn[\list].size, kind: kind, chan: chan, num: num));
        if(~apcLearn[\list].size == ~apc[\orbitCount]) { ~finishAPCLearn.() };
    };
};

// ------------------------- Device learn ------------------------
~startAPCDeviceLearn = {
    ~apc[\srcUid] = nil; ~apc[\chan] = nil; ~apc[\out] = nil;
    ~pp.("deviceLearn", (info: "Press ANY APC40 mkII control now…"));

    MIDIdef.cc(\_apc_dev_cc, { |val, num, chan, src|
        if(~apc[\srcUid].isNil) {
            ~apc[\srcUid] = src.asInteger; ~apc[\chan] = chan;
            ~pp.("deviceLearn", (srcUid: ~apc[\srcUid], chan: ~apc[\chan]));
            MIDIdef.free(\_apc_dev_cc); MIDIdef.free(\_apc_dev_note);
            ~apcBindOutputForSrcUID.(~apc[\srcUid]);
        };
    });

    MIDIdef.noteOn(\_apc_dev_note, { |vel, note, chan, src|
        if(~apc[\srcUid].isNil) {
            ~apc[\srcUid] = src.asInteger; ~apc[\chan] = chan;
            ~pp.("deviceLearn", (srcUid: ~apc[\srcUid], chan: ~apc[\chan]));
            MIDIdef.free(\_apc_dev_cc); MIDIdef.free(\_apc_dev_note);
            ~apcBindOutputForSrcUID.(~apc[\srcUid]);
        };
    });
};

// ------------------------ Bottom-row learn ---------------------
~startAPCLearn = {
    ~apcPress.clear;
    ~apcLearn = (active: true, seen: IdentitySet.new, list: List.new, learnChan: nil);
    ~pp.("learn", (info: "Press bottom buttons 1→8 (left→right) once"));
};

~finishAPCLearn = {
    var arr;
    ~apcLearn[\active] = false;  // stop immediately
    arr = ~apcLearn[\list].asArray;
    if(arr.size == ~apc[\orbitCount]) {
        ~apc[\map] = arr;
        ~pp.("LEARN COMPLETE ✅", (map: arr));
        ~apcLearn = (active: false, seen: IdentitySet.new, list: List.new, learnChan: nil);
        ~apcSaveMap.();     // persist immediately
        ~apcRefreshLeds.(); // light all when done
    }{
        ~pp.("LEARN INCOMPLETE", (got: arr.size, need: ~apc[\orbitCount]));
        ~apcLearn[\active] = true;
    };
};

// -------------------- Unified input handlers -------------------
// CC path (rising-edge toggle by (chan,num))
MIDIdef.cc(\apc_cc, { |val, num, chan, src|
    var idx, key, prev;

    // Learn phase ------------------------------------------------
    if(~apcLearn[\active]) {
        ~apcLatchSrcAndChanIfNeeded.(chan, src);
        if(~apcSrcMatches.(src) and: { chan == (~apcLearn[\learnChan] ? chan) }) {
            if(val > 0) { ~apcLearnAdd.(\cc, chan, num) };
        };
        key = ~edgeKey.(chan, num);
        ~apcPress[key] = val;
        ^nil;
    };

    // Normal phase -----------------------------------------------
    if(~apc[\map].notNil and: { ~apcSrcMatches.(src) }) {
        key  = ~edgeKey.(chan, num);
        prev = ~apcPress[key] ? 0;
        ~apcPress[key] = val;  // update first

        if((val > 0) and: { prev <= 0 }) {
            idx = ~apc[\map].detectIndex { |ev| ev[\kind] == \cc and: { ev[\chan] == chan } and: { ev[\num] == num } };
            if(idx.notNil) { ~toggleOrbitAPC.(idx) };
        };
    };
});

// NOTE path (toggle on note-on; identify by (chan,num))
MIDIdef.noteOn(\apc_note, { |vel, note, chan, src|
    var idx;

    // Learn phase
    if(~apcLearn[\active]) {
        ~apcLatchSrcAndChanIfNeeded.(chan, src);
        if(~apcSrcMatches.(src) and: { chan == (~apcLearn[\learnChan] ? chan) }) {
            if(vel > 0) { ~apcLearnAdd.(\note, chan, note) };
        };
        ^nil;
    };

    // Normal phase
    if(~apc[\map].notNil and: { vel > 0 } and: { ~apcSrcMatches.(src) }) {
        idx = ~apc[\map].detectIndex { |ev| ev[\kind] == \note and: { ev[\chan] == chan } and: { ev[\num] == note } };
        if(idx.notNil) { ~toggleOrbitAPC.(idx) };
    };
});

// NOTE OFF: participate in LEARN only (some APC rows send noteOff on press)
MIDIdef.noteOff(\apc_noteOff, { |vel, note, chan, src|
    if(~apcLearn[\active]) {
        ~apcLatchSrcAndChanIfNeeded.(chan, src);
        if(~apcSrcMatches.(src) and: { chan == (~apcLearn[\learnChan] ? chan) }) {
            ~apcLearnAdd.(\note, chan, note);
        };
        ^nil;
    };
    // Normal phase: ignore to prevent double toggles (noteOn is used)
});

// ----------------------- Persistence ---------------------------
~apcMapPath = {
    var base;
    base = if(thisProcess.nowExecutingPath.notNil) {
        PathName(thisProcess.nowExecutingPath).pathOnly
    }{
        Platform.userHomeDir
    };
    base +/+ "apc40mk2-track-mute.map";
};

~apcSaveMap = {
    var data, path;
    path = ~apcMapPath.();
    data = (
        device: (~apc[\device] ? "APC40 mkII"),
        srcUid: ~apc[\srcUid],
        chan:   ~apc[\chan],  // informational only
        map:    ~apc[\map]    // authoritative new format
    );
    data.writeArchive(path);
    ~pp.("savedMap", (path: path, data: data));
};

// Back-compat: convert old note[]/cc[] + single chan → per-button map
~apcConvertOld = { |data|
    var arr, ch;
    arr = Array.newClear(~apc[\orbitCount]);
    ch  = (data[\chan] ? 0).asInteger;

    if(data[\note].notNil) {
        data[\note].do { |n, i| if(n.notNil) { arr[i] = (kind:\note, chan: ch, num: n) } };
    }{
        if(data[\cc].notNil) {
            data[\cc].do { |c, i| if(c.notNil) { arr[i] = (kind:\cc, chan: ch, num: c) } };
        };
    };

    if(arr.every { |e| e.notNil }) { arr } { nil };
};

~apcLoadMap = {
    var path, data, dst, out, idx, converted;
    path = ~apcMapPath.();

    if(File.exists(path).not) {
        ~pp.("loadMap", (info: "no file", path: path));
        ^nil
    };

    data = Object.readArchive(path);
    if(data.isKindOf(Event).not) {
        ~pp.("loadMap", (warn: "bad file"));
        ^nil
    };

    // Restore device + identity
    ~apc[\device] = data[\device];
    ~apc[\srcUid] = data[\srcUid];
    ~apc[\chan]   = data[\chan];

    // Restore map (new) or convert (old)
    if(data[\map].notNil) {
        ~apc[\map] = data[\map];
    }{
        converted = ~apcConvertOld.(data);
        if(converted.notNil) { ~apc[\map] = converted };
    };

    // Re-bind output by UID, else by device name
    if(~apc[\srcUid].notNil) { ~apcBindOutputForSrcUID.(~apc[\srcUid]) };
    if(~apc[\out].isNil and: { ~apc[\device].notNil }) {
        dst = MIDIClient.destinations.detect { |d|
            (d.device ? "").contains(~apc[\device]) or: { (d.name ? "").contains(~apc[\device]) }
        };
        if(dst.notNil) {
            if(MIDIOut.respondsTo(\newByName)) {
                out = MIDIOut.newByName(dst.device, dst.name);
            }{
                idx = MIDIClient.destinations.indexOf(dst);
                out = MIDIOut.new(idx);
            };
            ~apc[\out] = out;
        };
    };

    ~pp.("loadMap", (ok: (~apc[\out].notNil), data: (map: ~apc[\map], device: ~apc[\device], srcUid: ~apc[\srcUid])));
    if(~apc[\map].notNil) { ~apcRefreshLeds.() };
};

~apcClearSavedMap = {
    var path;
    path = ~apcMapPath.();
    if(File.exists(path)) {
        File.delete(path);
        ~pp.("savedMapCleared", (path: path));
    }{
        "no map file".postln;
    };
};

// ------------------------- Utilities ---------------------------
~apcUseDefaultBottomRow = { |kind=\note, num=50, baseChan=0|
    // APC40 mkII bottom row is note 50 on chans 0..7 by default
    var map = Array.fill(8, { |i| (kind: kind, chan: baseChan + i, num: num) });
    ~apc[\map] = map;
    ~apcSaveMap.();
    ~apcRefreshLeds.();
    ~pp.("defaultMap", (map: map));
};

~apcStatus = {
    ~pp.("status", (
        device: ~apc[\device],
        srcUid: ~apc[\srcUid], firstChanSeen: ~apc[\chan],
        mapped: (~apc[\map].notNil),
        map: ~apc[\map],
        ledsReady: (~apc[\out].notNil),
        strictChan: ~apc[\strictChan],
        onVal: ~apc[\onVal], offVal: ~apc[\offVal]
    ));
};

~apcTestLeds = {
    var oldOn;
    if(~apc[\out].isNil or: { ~apc[\map].isNil }) { ~pp.("ledTest", (info: "no APC output or no map")); ^nil };
    oldOn = ~apc[\onVal];
    ~apc[\onVal] = ~apc[\onVal] ?? { 1 };
    ~apc[\orbitCount].do { |ii| ~apcLed.(ii, true) };
    SystemClock.sched(0.4, {
        ~apc[\orbitCount].do { |ii| ~apcLed.(ii, false) };
        ~apc[\onVal] = oldOn; nil
    });
};

// Optional CC spy for debugging
~apcEnableSpy = {
    MIDIdef.cc(\apc_spy, { |val, num, chan, src|
        if(~apcSrcMatches.(src)) { ~pp.("apc_cc", (num: num, val: val, chan: chan)) }
    }, nil, 1);
    "APC CC spy enabled".postln;
};
~apcDisableSpy = { MIDIdef.free(\apc_spy); "APC CC spy disabled".postln; };

// --------------------------- End ---------------------------

