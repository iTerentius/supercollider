/*  lcxl-track-mute.scd
    ------------------------------------------------------------------
    LaunchControl XL bottom-row → SuperCollider orbit mutes (0..7)
    - Learn device+channel from first press
    - Learn bottom row (NOTE or CC) by pressing 1→8 once (left→right)
    - LEDs via Novation SysEx (template/channel-agnostic)
    - Calls ~fxonlyOn.(i) / ~fxonlyOff.(i)
    - Persists mapping; auto-loads next time
    ------------------------------------------------------------------ */

// --- If you DON'T init MIDI earlier, uncomment these lines ---
// MIDIClient.init;
// MIDIIn.connectAll;

// --------------------------- Helpers ---------------------------
~stamp = { Date.getDate.stamp };
~pp = { |tag, data| ("[" ++ ~stamp.() ++ "] " ++ tag ++ "  " ++ data.asString).postln };

// -------------------------- State ------------------------------
~lcxl = (
    device: nil,          // device name captured at bind time (for persistence fallback)
    srcUid: nil,          // learned source UID
    chan: nil,            // learned channel (0-15)
    out: nil,             // MIDIOut to LCXL destination
    template: nil,        // active template (0..15) if we see it via SysEx
    orbitCount: 8,
    orbitMute: Array.fill(8, false),
    // mapping (exactly one of these will be set)
    type: nil,            // \note or \cc
    note: nil,            // Array of 8 note numbers (left→right)
    cc: nil,              // Array of 8 CC numbers (left→right)
    // LED values (Novation Launchpad-style)
    onVal: 60,            // green full
    offVal: 12,           // off
    strictChan: false     // set true if you want to require learned channel on input
);

// learn buffer (for bottom-row learn)
~learn = (active: false, type: nil, seen: IdentitySet.new, list: List.new);

// ---------------------- Free old responders --------------------
MIDIdef.free(\lcxl_cc);
MIDIdef.free(\lcxl_note);
MIDIdef.free(\lcxl_template);
MIDIdef.free(\_lcxl_dev_cc);
MIDIdef.free(\_lcxl_dev_note);

// ----------------- Your mute/FX application hook ----------------
~applyMuteState = { |orbit, muted|
    // Log which function we’re calling, then call if defined
    ~pp.("call", (fn: muted.if("~fxonlyOn","~fxonlyOff"), orbit: orbit));
    if(muted) {
        var f; f = ~fxonlyOn ? nil;
        if(f.isKindOf(Function)) { f.(orbit) };
    } {
        var f; f = ~fxonlyOff ? nil;
        if(f.isKindOf(Function)) { f.(orbit) };
    };
};

// ---------------- Bind LCXL output by learned src UID ----------
~bindOutputForSrcUID = { |uid|
    var ep, dst, out, idx;

    ep  = MIDIClient.sources.detect { |m| m.uid == uid };
    if(ep.notNil) { ~lcxl[\device] = ep.device };
    dst = if(ep.notNil) {
        MIDIClient.destinations.detect { |d| d.device == ep.device }
    }{
        nil
    };

    if(dst.notNil) {
        if(MIDIOut.respondsTo(\newByName)) {
            out = MIDIOut.newByName(dst.device, dst.name);
        }{
            idx = MIDIClient.destinations.indexOf(dst);
            out = MIDIOut.new(idx);
        };
        ~lcxl[\out] = out;
        ~pp.("deviceLearn", (matchedDest: (device: dst.device, name: dst.name)));
    }{
        ~lcxl[\out] = nil;
        ~pp.("deviceLearn", (warn: "No LCXL destination found; LEDs disabled"));
    };
};

// -------------------- Source match helpers ---------------------
~srcIsLCXL = { |src|
    var ep;
    if(~lcxl[\srcUid].notNil) { ^(src.asInteger == ~lcxl[\srcUid]) };
    ep = MIDIClient.sources.detect { |m| m.uid == src.asInteger };
    if(ep.isNil) { ^false };
    if(~lcxl[\device].isNil) { ^false };
    ((ep.device ? "").contains(~lcxl[\device]) or: { (ep.name ? "").contains(~lcxl[\device]) })
};

// ----------------------- LED helpers (SysEx) -------------------
// Novation: F0 00 20 29 02 11 78 <template> <index> <value> F7
~syxSet = { |template, index, value|
    var bytes;
    if(~lcxl[\out].isNil) { ^nil };
    bytes = Int8Array[
        240, 0, 32, 41, 2, 17, 120,
        template.clip(0,15), index.clip(0,127), value.clip(0,127), 247
    ];
    ~lcxl[\out].sysex(bytes);
};

// Bottom row “channel” buttons on LCXL are indices 32..39 (left→right)
~led = { |i, isOn|
    var idx, val;
    if(~lcxl[\out].isNil) { ^nil };
    idx = 32 + i;
    val = isOn.if(~lcxl[\onVal], ~lcxl[\offVal]);
    if(~lcxl[\template].isNil) {
        16.do { |t| ~syxSet.(t, idx, val) };  // broadcast until we know the template
    }{
        ~syxSet.(~lcxl[\template], idx, val);
    };
};

~refreshLeds = {
    var i;
    ~lcxl[\orbitCount].do { |ii| ~led.(ii, ~lcxl[\orbitMute][ii].not) };  // lit = NOT muted
};

// -------------------------- Toggling ---------------------------
~toggleOrbit = { |i|
    if(i < 0 or: { i >= ~lcxl[\orbitCount] }) { ^nil };
    ~lcxl[\orbitMute][i] = ~lcxl[\orbitMute][i].not;
    ~applyMuteState.(i, ~lcxl[\orbitMute][i]);
    ~pp.("orbit", (index: i, muted: ~lcxl[\orbitMute][i]));
    ~led.(i, ~lcxl[\orbitMute][i].not);
};

// ------------------------- Device learn ------------------------
~startDeviceLearn = {
    ~lcxl[\srcUid] = nil; ~lcxl[\chan] = nil; ~lcxl[\out] = nil;
    ~pp.("deviceLearn", (info: "Press ANY LCXL control now…"));

    MIDIdef.cc(\_lcxl_dev_cc, { |val, num, chan, src|
        var uid;
        if(~lcxl[\srcUid].isNil) {
            uid = src.asInteger;
            ~lcxl[\srcUid] = uid;
            ~lcxl[\chan]   = chan;
            ~pp.("deviceLearn", (srcUid: ~lcxl[\srcUid], chan: ~lcxl[\chan]));
            MIDIdef.free(\_lcxl_dev_cc); MIDIdef.free(\_lcxl_dev_note);
            ~bindOutputForSrcUID.(uid);
        };
    });

    MIDIdef.noteOn(\_lcxl_dev_note, { |vel, note, chan, src|
        var uid;
        if(~lcxl[\srcUid].isNil) {
            uid = src.asInteger;
            ~lcxl[\srcUid] = uid;
            ~lcxl[\chan]   = chan;
            ~pp.("deviceLearn", (srcUid: ~lcxl[\srcUid], chan: ~lcxl[\chan]));
            MIDIdef.free(\_lcxl_dev_cc); MIDIdef.free(\_lcxl_dev_note);
            ~bindOutputForSrcUID.(uid);
        };
    });
};

// ------------------------ Bottom-row learn ---------------------
~startLearn = {
    ~learn = (active: true, type: nil, seen: IdentitySet.new, list: List.new);
    ~pp.("learn", (info: "Press bottom buttons 1→8 (left→right) once"));
};

~finishLearn = {
    var arr;
    ~learn[\active] = false; // stop immediately
    arr = ~learn[\list].asArray;
    if(arr.size == ~lcxl[\orbitCount]) {
        if(~learn[\type] == \cc) { ~lcxl[\cc] = arr; ~lcxl[\type] = \cc }
        {                              ~lcxl[\note] = arr; ~lcxl[\type] = \note };
        ~pp.("LEARN COMPLETE ✅", (type: ~lcxl[\type], map: arr));
        ~learn = (active: false, type: nil, seen: IdentitySet.new, list: List.new);
        ~saveMap.();          // persist immediately
        ~refreshLeds.();      // light all when done
    }{
        ~pp.("LEARN INCOMPLETE", (got: arr.size, need: ~lcxl[\orbitCount]));
        ~learn[\active] = true;
    };
};

// -------------------- Unified input handlers -------------------
// Template change SysEx → remember active template
MIDIdef.sysex(\lcxl_template, { |data, src|
    var ok;
    ok = (data.size >= 10)
        and: { data[0] == 240 }
        and: { data[1..6] == Int8Array[0,32,41,2,17,119] };  // 0x77 "w"
    if(ok) {
        ~lcxl[\template] = data[7].clip(0, 15);
        ~pp.("template", (current: ~lcxl[\template]));
        if(~lcxl[\type].notNil) { ~refreshLeds.() };
    };
});

// CC path
MIDIdef.cc(\lcxl_cc, { |val, num, chan, src|
    var idx;
    // Learn phase
    if(~learn[\active]) {
        if((val > 0) and: { ~learn[\type].isNil or: { ~learn[\type] == \cc } }) {
            if(~lcxl[\srcUid].isNil or: { src.asInteger == ~lcxl[\srcUid] }) {
                ~learn[\type] = \cc;
                if(~learn[\seen].includes(num).not) {
                    ~learn[\seen].add(num); ~learn[\list].add(num);
                    ~pp.("learn", (cc: num, count: ~learn[\list].size));
                    if(~learn[\list].size == ~lcxl[\orbitCount]) { ~finishLearn.(); ^nil };
                };
            };
        };
        ^nil;
    };
    // Normal phase
    if(~lcxl[\type] == \cc and: { ~lcxl[\cc].notNil } and: { val > 0 }) {
        if((~lcxl[\srcUid].isNil or: { src.asInteger == ~lcxl[\srcUid] })
            and: { (~lcxl[\strictChan].not) or: { chan == ~lcxl[\chan] } }) {
            idx = ~lcxl[\cc].indexOf(num);
            if(idx.notNil) { ~toggleOrbit.(idx) };
        };
    };
});

// NOTE path
MIDIdef.noteOn(\lcxl_note, { |vel, note, chan, src|
    var idx;
    // Learn phase
    if(~learn[\active]) {
        if((vel > 0) and: { ~learn[\type].isNil or: { ~learn[\type] == \note } }) {
            if(~lcxl[\srcUid].isNil or: { src.asInteger == ~lcxl[\srcUid] }) {
                ~learn[\type] = \note;
                if(~learn[\seen].includes(note).not) {
                    ~learn[\seen].add(note); ~learn[\list].add(note);
                    ~pp.("learn", (note: note, count: ~learn[\list].size));
                    if(~learn[\list].size == ~lcxl[\orbitCount]) { ~finishLearn.(); ^nil };
                };
            };
        };
        ^nil;
    };
    // Normal phase
    if(~lcxl[\type] == \note and: { ~lcxl[\note].notNil } and: { vel > 0 }) {
        if((~lcxl[\srcUid].isNil or: { src.asInteger == ~lcxl[\srcUid] })
            and: { (~lcxl[\strictChan].not) or: { chan == ~lcxl[\chan] } }) {
            idx = ~lcxl[\note].indexOf(note);
            if(idx.notNil) { ~toggleOrbit.(idx) };
        };
    };
});

// ----------------------- Persistence ---------------------------
~lcxlMapPath = {
    var base;
    base = if(thisProcess.nowExecutingPath.notNil) {
        PathName(thisProcess.nowExecutingPath).pathOnly
    }{
        Platform.userHomeDir
    };
    base +/+ "lcxl-track-mute.map";
};

~saveMap = {
    var data, path;
    path = ~lcxlMapPath.();
    data = (
        device: (~lcxl[\device] ? "Launch Control XL"),
        srcUid: ~lcxl[\srcUid],
        chan:   ~lcxl[\chan],
        type:   ~lcxl[\type],
        note:   ~lcxl[\note],
        cc:     ~lcxl[\cc]
    );
    data.writeArchive(path);
    ~pp.("savedMap", (path: path, data: data));
};

~loadMap = {
    var path, data, dst, out, idx;
    path = ~lcxlMapPath.();

    // Use File.exists instead of PathName(...).exists
    if(File.exists(path).not) {
        ~pp.("loadMap", (info: "no file", path: path));
        ^nil
    };

    data = Object.readArchive(path);
    if(data.isKindOf(Event).not) {
        ~pp.("loadMap", (warn: "bad file"));
        ^nil
    };

    // Restore fields
    ~lcxl[\device] = data[\device];
    ~lcxl[\srcUid] = data[\srcUid];
    ~lcxl[\chan]   = data[\chan];
    ~lcxl[\type]   = data[\type];
    ~lcxl[\note]   = data[\note];
    ~lcxl[\cc]     = data[\cc];

    // Re-bind output by UID (preferred), else match by device name
    if(~lcxl[\srcUid].notNil) {
        ~bindOutputForSrcUID.(~lcxl[\srcUid]);
    };
    if(~lcxl[\out].isNil and: { ~lcxl[\device].notNil }) {
        dst = MIDIClient.destinations.detect { |d|
            (d.device ? "").contains(~lcxl[\device]) or: { (d.name ? "").contains(~lcxl[\device]) }
        };
        if(dst.notNil) {
            if(MIDIOut.respondsTo(\newByName)) {
                out = MIDIOut.newByName(dst.device, dst.name);
            }{
                idx = MIDIClient.destinations.indexOf(dst);
                out = MIDIOut.new(idx);
            };
            ~lcxl[\out] = out;
        };
    };

    ~pp.("loadMap", (ok: (~lcxl[\out].notNil), data: data));
    if(~lcxl[\type].notNil) { ~refreshLeds.() };
};

~clearSavedMap = {
    var path, p;
    path = ~lcxlMapPath.();
    p = PathName(path);
    if(p.exists) { p.remove; ~pp.("savedMapCleared", (path: path)) } { "no map file".postln };
};

// ------------------------- Utilities ---------------------------
~lcxlStatus = {
    ~pp.("status", (
        device: ~lcxl[\device],
        srcUid: ~lcxl[\srcUid], chan: ~lcxl[\chan],
        type: ~lcxl[\type],
        map: (~lcxl[\type] == \cc).if(~lcxl[\cc], ~lcxl[\note]),
        template: ~lcxl[\template],
        ledsReady: (~lcxl[\out].notNil),
        strictChan: ~lcxl[\strictChan],
        onVal: ~lcxl[\onVal], offVal: ~lcxl[\offVal]
    ));
};

~testLeds = {   // blink LEDs to prove output path
    var oldOn;
    if(~lcxl[\out].isNil) { ~pp.("ledTest", (info: "no LCXL output")); ^nil };
    oldOn = ~lcxl[\onVal];
    ~lcxl[\onVal] = 60; // green
    ~lcxl[\orbitCount].do { |i| ~led.(i, true) };
    SystemClock.sched(0.5, {
        ~lcxl[\orbitCount].do { |i| ~led.(i, false) };
        ~lcxl[\onVal] = oldOn; nil
    });
};

~refresh = { ~refreshLeds.() };

~unmuteAll = {
    var i;
    ~lcxl[\orbitCount].do { |ii|
        if(~lcxl[\orbitMute][ii]) { ~lcxl[\orbitMute][ii] = false; ~applyMuteState.(ii, false) };
    };
    ~refreshLeds.();
    "All orbits unmuted.".postln;
};

// -------------------------- Auto-load --------------------------
// ~loadMap.();

// --------------------------- Hints -----------------------------
~pp.("hint", (a: "Run ~lcxlStatus.() to inspect",
              b: "First time: ~startDeviceLearn.() then ~startLearn.()",
              c: "Buttons toggle orbits 0..7; LED ON = not muted"));


