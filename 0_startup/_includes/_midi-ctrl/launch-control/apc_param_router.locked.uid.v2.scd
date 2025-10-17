/* 2025-10-16 APC40 mkII router drop-in with auto MIDI init and LED follow */

(
/* settings and state */
~apcAutoStart = ~apcAutoStart ?? { true };      // set to false before eval if you want manual start
~apcPressMode = ~apcPressMode  ?? { \toggle };  // \toggle or \gate

~apcPadMap    = ~apcPadMap    ? IdentityDictionary.new;
~apcColorVel  = (green: 122, amber: 126, yellow: 124, off: 0);

~apcOut = ~apcOut ? nil;
~apcSrcUID = ~apcSrcUID ? nil;

~apcGridWatchActive = ~apcGridWatchActive ? false;
~apcGridPeriod = ~apcGridPeriod ? 0.25;
~apcGridTicker = ~apcGridTicker ? nil;

/* free any old handlers to avoid duplicates across recompiles */
~apcFreeMIDIDefs = {
    var names;
    names = [\apc_grid_on, \apc_grid_off, \apc_any_on, \apc_any_off, \apc_debug, \apc_debug_off];
    names.do { |n| var d; d = MIDIdef(n); if(d.notNil) { d.free } };
    "APC MIDIdefs cleared".postln;
};

/* choose APC source and destination, connect inputs, open output */
~apcPickPorts = {
    var dests, srcs, didx, sidx, out;
    MIDIClient.init;
    MIDIIn.disconnectAll;
    MIDIIn.connectAll;

    srcs = MIDIClient.sources;
    dests = MIDIClient.destinations;

    sidx = srcs.detectIndex { |e| e.device.contains("APC40") || e.name.contains("APC40") };
    didx = dests.detectIndex { |e| e.device.contains("APC40") || e.name.contains("APC40") };

    if(sidx.isNil or: { didx.isNil }) {
        "APC40 mkII source or destination not found".warn;
        ^nil
    };

    ~apcSrcUID = srcs[sidx].uid;
    out = MIDIOut.newByName(dests[didx].device, dests[didx].name);
    out.latency = 0;
    ~apcOut = out;

    ["[APC] picked srcUID", ~apcSrcUID, "dest", dests[didx].device, dests[didx].name].postln;
    ^true
};

/* send the Akai Introduction sysex so RGB velocity colors are honored */
~apcIntro = { |mode=1|
    var out, syx;
    out = ~apcOut;
    if(out.isNil) { "[APC] no ~apcOut for Intro".warn }{
        if(mode == 1) {
            syx = Int8Array[0xF0, 0x47, 0x7F, 0x29, 0x60, 0x00, 0x04, 0x41, 0x00, 0x01, 0x00, 0xF7];
            out.sysex(syx);
            "[APC] Intro sent mode 1".postln;
        }{
            syx = Int8Array[0xF0, 0x47, 0x7F, 0x29, 0x60, 0x00, 0x04, 0x42, 0x00, 0x01, 0x00, 0xF7];
            out.sysex(syx);
            "[APC] Intro sent mode 2".postln;
        };
    };
};

/* set one grid pad LED color by symbolic name using velocity colors */
~apcPadLED = { |note, color=\amber|
    var out, vel;
    out = ~apcOut;
    vel = ~apcColorVel[color] ? 0;
    if(out.notNil) {
        out.noteOn(0, note, vel); // grid pads ignore channel, color comes from velocity
    };
    ^vel
};

/* paint LED by actual Pdef state */
~apcLEDByState = { |note, key|
    var playing;
    playing = Pdef(key).isPlaying;
    if(playing) { ~apcPadLED.(note, \green) } { ~apcPadLED.(note, \amber) };
};

/* assign a pad to a Pdef key and paint its current state */
~apcAssignPad = { |note, key|
    var k;
    k = key.asSymbol;
    ~apcPadMap[note] = k;
    ~apcLEDByState.(note, k);
    ["[APC] assigned", note, k].postln;
    ^k
};

/* compatibility alias so your existing calls still work */
~apcGL2AssignNote = { |note, key|
    var r;
    r = ~apcAssignPad.(note, key);
    ^r
};

/* set press mode at runtime and re-arm handlers */
~apcSetPressMode = { |mode|
    var m;
    m = mode.asSymbol;
    if([ \toggle, \gate ].includes(m).not) { m = \toggle };
    ~apcPressMode = m;
    ~apcArmGrid.();
    ["[APC] press mode", m].postln;
    ^m
};

/* arm grid note handlers bound to the APC source UID */
/* optional quick debug toggle */
~apcDebug = ~apcDebug ? false;

/* re-arm with captured references so MIDIdef closures always see the map */
~apcArmGrid = {
    var uid, mode, padMap, padLED, ledByState;

    /* capture references once so closures use the same objects */
    uid        = ~apcSrcUID;
    mode       = ~apcPressMode;
    padMap     = ~apcPadMap;      // IdentityDictionary (mutable, shared)
    padLED     = ~apcPadLED;      // Function
    ledByState = ~apcLEDByState;  // Function

    /* free old */
    MIDIdef(\apc_grid_on).free;
    MIDIdef(\apc_grid_off).free;

    MIDIdef.noteOn(
        \apc_grid_on,
        { |vel, num, chan, src|
            var key, isPlaying;
            if(~apcDebug == true) { ["[apc_grid_on]", num, "vel", vel, "chan", chan, "src", src].postln };
            key = padMap[num];
            if(key.notNil) {
                if(mode == \toggle) {
                    isPlaying = Pdef(key).isPlaying;
                    if(isPlaying) {
                        Pdef(key).stop;
                        padLED.value(num, \amber);
                    }{
                        Pdef(key).play;
                        padLED.value(num, \green);
                    };
                }{
                    if(vel > 0) {
                        Pdef(key).play;
                        padLED.value(num, \green);
                    };
                };
            }{
                if(~apcDebug == true) { ["[apc_grid_on] no assign for", num].postln };
            };
        },
        nil, nil, uid
    );

    if(mode == \gate) {
        MIDIdef.noteOff(
            \apc_grid_off,
            { |vel, num, chan, src|
                var key;
                if(~apcDebug == true) { ["[apc_grid_off]", num, "vel", vel].postln };
                key = padMap[num];
                if(key.notNil) {
                    Pdef(key).stop;
                    padLED.value(num, \amber);
                };
            },
            nil, nil, uid
        );
    };

    /* repaint using the captured helper so LEDs match current truth */
    padMap.keysValuesDo { |n, k| ledByState.value(n, k) };

    ["[APC] armed grid for uid", uid, "mode", mode, "assigns", padMap.keys.size].postln;
    uid
};

/* watcher using AppClock.sched so there is no Routine to stop or resume */
~apcGridWatchStop = {
    var was;
    was = (~apcGridWatchActive == true);
    ~apcGridWatchActive = false;
    if(was) { "[APC] grid watch stop requested".postln };
};

~apcGridWatchStart = { |period=0.25|
    var already;
    already = (~apcGridWatchActive == true);
    ~apcGridPeriod = period;

    if(already) {
        "[APC] grid watch already running, period updated".postln;
        ^\running
    };

    ~apcGridWatchActive = true;
    ~apcGridTicker = AppClock.sched(0.0, {
        var p;
        p = ~apcGridPeriod ? 0.25;
        if(~apcGridWatchActive == true) {
            ~apcPadMap.keysValuesDo { |n, k| ~apcLEDByState.(n, k) };
            p
        }{
            ~apcGridTicker = nil;
            "[APC] grid watch exited".postln;
            nil
        }
    });

    "[APC] grid watch started".postln;
    ^\started
};

/* one-call boot that runs automatically when the file is evaluated */
~apcRouterBoot = {
    var ok1;
    ok1 = ~apcPickPorts.();
    if(ok1.notNil) {
        ~apcIntro.(1);
        ~apcArmGrid.();
        ~apcGridWatchStart.(~apcGridPeriod ? 0.25);
        "[APC] router boot complete".postln;
    }{
        "[APC] router boot failed to pick ports".warn;
    };
    ^ok1
};

/* autorun at load unless disabled */
if(~apcAutoStart == true) {
    AppClock.sched(0.05, { ~apcRouterBoot.(); nil });
};
)

