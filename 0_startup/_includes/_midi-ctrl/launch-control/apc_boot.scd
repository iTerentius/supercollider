/* 2025-10-18 14:45 — apc_boot.scd final pads-only: latch on press, sticky LEDs, panic + startup refresh */
/* rules: single () block, declare vars at top of funcs, no ) in comments */

(
/* ------------ config and state ------------ */
~apcParam    = ~apcParam    ? IdentityDictionary.new;
~apcPadMap   = ~apcPadMap   ? IdentityDictionary.new;   // note -> Pdef key
~apcIsDown   = ~apcIsDown   ? IdentityDictionary.new;   // note -> bool
~apcLedState = ~apcLedState ? IdentityDictionary.new;   // note -> last color
~apcParam[\gridChan] = (~apcParam[\gridChan] ? 0);
~apcParam[\colors]   = (~apcParam[\colors]   ? IdentityDictionary[\off -> 0, \amber -> 126, \green -> 21]);

/* ------------ APC out and Generic Mode ------------ */
~apcForceAPCOut = {
    var out, dev, nam;
    if(MIDIClient.initialized.not) { MIDIClient.init; };
    MIDIIn.connectAll;
    out = nil;
    MIDIClient.destinations.do { |ep|
        dev = ep.device !? { ep.device.asString } ?? "";
        nam = ep.name !? { ep.name.asString } ?? "";
        if(out.isNil and: { (dev == "APC40 mkII") and: { nam == "APC40 mkII" } }) {
            out = MIDIOut.newByName(ep.device, ep.name);
        };
    };
    if(out.isNil) {
        // soft fallback: first dest containing APC
        MIDIClient.destinations.do { |ep|
            dev = ep.device !? { ep.device.asString } ?? "";
            nam = ep.name !? { ep.name.asString } ?? "";
            if(out.isNil and: { (dev.contains("APC") or: { nam.contains("APC") }) }) {
                out = MIDIOut.newByName(ep.device, ep.name);
            };
        };
    };
    if(out.isNil) { "[APC] could not open APC out".warn } { ~apcOut = out };
    ~apcOut
};

~apcPadLED = { |note, color|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.notNil) {
        out.latency = 0.0;
        out.noteOn(0, note, color);
        out.noteOn(1, note, color); // some firmwares prefer ch 1
    };
};

~apcLEDSet = { |note, color|
    ~apcLedState[note] = color;
    ~apcPadLED.(note, color);
    AppClock.sched(0.03, { ~apcPadLED.(note, color) }); // little reinforcement
};

~apcIntroGenericMode = {
    var out, msg;
    out = ~apcOut ?? { ~apcForceAPCOut.() };
    if(out.isNil) { "[APC] no MIDIOut for SysEx".warn; ^false };
    msg = Int8Array[240, 71, 127, 41, 96, 0, 4, 64, 1, 1, 0, 247];
    out.sysex(msg);
    "[APC] set Generic Mode".postln; true
};

/* ------------ simple pattern helpers (no custom group) ------------ */
~apcPadPlay = { |key| Pdef(key).play };
~apcPadStop = { |key| Pdef(key).stop };

/* ------------ LED state painter from Pdef state ------------ */
~apcLEDByState = { |note, key|
    var colors, want;
    colors = ~apcParam[\colors];
    want = Pdef(key).isPlaying.if(colors[\green], colors[\amber]);
    ~apcLEDSet.(note, want);
};

/* ------------ assign a pad to a Pdef ------------ */
~apcAssignPad = { |note, key|
    var colors;
    colors = ~apcParam[\colors];
    ~apcPadMap[note] = key;
    ~apcLEDSet.(note, colors[\amber]);
    ["map[" ++ note ++ "], " ++ key].postln;
};

/* ------------ repaint all mapped pads ------------ */
~apcRepaintAll = {
    if(~apcPadMap.notNil and: { ~apcPadMap.size > 0 }) {
        ~apcPadMap.keysValuesDo { |n, k| ~apcLEDByState.(n, k) };
        "[APC] LEDs repainted".postln;
    }{
        "[APC] no pads mapped to repaint".postln;
    };
};

/* ------------ listener: latch on press, ignore release ------------ */
~apcInstallGridListener = {
    var nameOn, nameOff;
    nameOn = \apc40_grid_any_on; nameOff = \apc40_grid_any_off;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);

    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var key;
        key = ~apcPadMap[num];
        if(key.notNil) {
            if(vel > 0) {
                ~apcIsDown[num] = true;
                if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) };
                ~apcLEDByState.(num, key);
            }{
                // vel 0 release packet on noteOn path: just repaint, do not toggle
                ~apcIsDown[num] = false;
                ~apcLEDByState.(num, key);
            };
        };
    });

    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        var key, hadDown;
        key = ~apcPadMap[num];
        if(key.notNil) {
            hadDown = ~apcIsDown[num] ? false;
            if(hadDown.not) {
                // fallback for devices that only emit release: treat as press toggle
                if(Pdef(key).isPlaying) { ~apcPadStop.(key) } { ~apcPadPlay.(key) };
            };
            ~apcIsDown[num] = false;
            ~apcLEDByState.(num, key);
        };
    });

    "[APC grid note-mode armed]".postln; true
};

/* ------------ panic recovery ------------ */
CmdPeriod.remove(~apcCmdPeriodHook);
~apcCmdPeriodHook = {
    AppClock.sched(0.0, {
        if(MIDIClient.initialized.not) { MIDIClient.init; };
        MIDIIn.connectAll;
        ~apcForceAPCOut.();
        ~apcIntroGenericMode.();
        ~apcInstallGridListener.();
        ~apcRepaintAll.();
        "[APC] recovered after panic".postln; nil
    });
};
CmdPeriod.add(~apcCmdPeriodHook);

/* ------------ boot actions ------------ */
~apcForceAPCOut.();
~apcIntroGenericMode.();
~apcInstallGridListener.();

/* clear any lingering pad lights from previous sessions */
if(~apcOut.notNil) {
    0.to(63).do { |n| ~apcPadLED.(n, ~apcParam[\colors][\off]) }; // grid off
    "[APC] LEDs cleared".postln;
};
AppClock.sched(0.25, { ~apcRepaintAll.() });  // repaint after MIDI settles
)

