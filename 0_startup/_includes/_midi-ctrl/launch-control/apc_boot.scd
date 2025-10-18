/* 2025-10-18 11:45 — apc_boot.scd pads-only boot + panic recover + Generic Mode SysEx (no waits) */
/* rules: one block eval, no ) in comments, vars declared at top of functions */

(
~apcEnsureServerAndGroup = {
    var g;
    if(s.serverRunning.not) { s.boot; };
    g = s.defaultGroup;
    if(g.isPlaying.not) {
        s.sendMsg(\g_new, 1, 0, 0);
        g = Group.basicNew(s, 1);
    };
    g
};

~apcEnsurePatternGroup = {
    var g, alive, dg;
    dg = ~apcEnsureServerAndGroup.();
    g = ~apcPdefGroup;
    alive = g.notNil and: { g.server === s } and: { g.isPlaying };
    if(alive.not) {
        g = Group.head(s, dg);
        ~apcPdefGroup = g;
        "[APC] pattern group refreshed".postln;
    };
    g
};

~apcRepaintAll = {
    var haveMap;
    haveMap = ~apcPadMap.notNil and: { ~apcLEDByState.notNil };
    if(haveMap) {
        ~apcPadMap.keysValuesDo { |num, k| ~apcLEDByState.(num, k); };
        "[APC] LEDs repainted".postln;
    } {
        "[APC] repaint skipped, pad map or LED fn missing".postln;
    };
};

~apcEnsureOut = ~apcEnsureOut ? {
    var idx, out;
    if(~apcOut.notNil) { ^~apcOut };
    if(MIDIClient.initialized.not) { MIDIClient.init; };
    MIDIIn.connectAll;
    idx = nil;
    MIDIClient.destinations.do { |ep, i|
        var ok;
        ok = ep.device.notNil and: { ep.device.asString.contains("APC40") };
        if(idx.isNil and: { ok }) { idx = i; };
    };
    if(idx.notNil) {
        out = MIDIOut.newByName(MIDIClient.destinations[idx].device, MIDIClient.destinations[idx].name);
        ~apcOut = out;
    };
    ~apcOut
};

/* APC40 mkII Generic Mode 1.01.00 SysEx intro */
~apcIntroGenericMode = {
    var out, msg;
    out = ~apcEnsureOut.();
    if(out.isNil) { "[APC] no MIDIOut for SysEx".warn; ^false };
    /* F0 47 7F 29 60 00 04 40 01 01 00 F7 */
    msg = Int8Array[240, 71, 127, 41, 96, 0, 4, 64, 1, 1, 0, 247];
    out.sysex(msg);
    "[APC] set Generic Mode".postln;
    true
};

~apcPlayToGroup = { |key|
    var g;
    g = ~apcEnsurePatternGroup.();
    Pdef(key).play(protoEvent: (group: g));
};

~apcStopPdef = { |key| Pdef(key).stop; };

~apcRouterBoot = {
    var tryCount, maxTry, armOnce, srcIdx;
    tryCount = 0;
    maxTry = 40;
    armOnce = {
        var ok;
        ok = false;
        if(MIDIClient.initialized.not) { MIDIClient.init; };
        MIDIIn.connectAll;
        srcIdx = nil;
        MIDIClient.sources.do { |ep, i|
            var match;
            match = ep.device.notNil and: { ep.device.asString.contains("APC40") };
            if(match and: { srcIdx.isNil }) { srcIdx = i; };
        };
        if(srcIdx.notNil) {
            "[APC] source found".postln;
            ~apcIntroGenericMode.();
            if(~apcInstallGridListener.notNil) { ~apcInstallGridListener.(); };
            if(~apcArmGrid.notNil) { ~apcArmGrid.(); };
            ~apcRepaintAll.();
            ~apcIsArmed = true;
            ok = true;
            "[APC] grid armed".postln;
        };
        ok
    };
    AppClock.sched(0.0, {
        var period;
        period = 0.25;
        Routine({
            var ok;
            ok = (~apcIsArmed == true);
            if(ok.not) { ok = armOnce.value; };
            while({ ok.not and: { tryCount < maxTry } }) {
                tryCount = tryCount + 1;
                period.wait;
                ok = armOnce.value;
            };
            if(ok.not) { "[APC] boot timed out".warn; };
        }).play(AppClock);
        nil
    });
};

~apcInstallPanicHook = {
    var hook;
    hook = {
        AppClock.sched(0.0, {
            ~apcEnsureServerAndGroup.();
            ~apcEnsurePatternGroup.();
            ~apcIntroGenericMode.();
            if(~apcInstallGridListener.notNil) { ~apcInstallGridListener.(); };
            if(~apcArmGrid.notNil) { ~apcArmGrid.(); };
            ~apcRepaintAll.();
            "[APC] recovered after panic".postln;
            nil
        });
    };
    CmdPeriod.remove(~apcCmdPeriodHook);
    ~apcCmdPeriodHook = hook;
    CmdPeriod.add(~apcCmdPeriodHook);
    "[APC] panic hook installed".postln;
};

~apcAutoStart = true;
~apcInstallPanicHook.();
if(~apcAutoStart) { ~apcRouterBoot.(); };
)

