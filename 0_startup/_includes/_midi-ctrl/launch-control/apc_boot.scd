/* 2025-10-18 10:22 — apc_boot.scd unified boot plus panic recovery (pads only) */
/* rules: one block eval, no ) in comments, vars declared at top of functions */

(
~apcEnsureServerAndGroup = {
    var g;
    if(s.serverRunning.not) { s.boot; };
    g = s.defaultGroup;
    g
};

~apcEnsurePatternGroup = {
    var g, alive;
    g = ~apcPdefGroup;
    alive = g.notNil and: { g.server === s } and: { g.isPlaying };
    if(alive.not) {
        ~apcEnsureServerAndGroup.();
        g = Group.head(s, s.defaultGroup);
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

~apcPlayToGroup = { |key|
    var g;
    g = ~apcEnsurePatternGroup.();
    Pdef(key).play(target: g);
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
        srcIdx = nil;
        MIDIClient.sources.do { |ep, i|
            var match;
            match = ep.device.notNil and: { ep.device.asString.contains("APC40") };
            if(match and: { srcIdx.isNil }) { srcIdx = i; };
        };
        if(srcIdx.notNil) {
            "[APC] source found".postln;
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

