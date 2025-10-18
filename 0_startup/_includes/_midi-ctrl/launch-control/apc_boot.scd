/* 2025-10-17 APC40 mkII router — watchdog + full Panic recover + robust arming */

(
/* free possibly colliding names */
~apcFreeMIDIDefs = {
    var names;
    names = [\apc_grid_on, \apc_grid_off, \apc_grid_on_any, \apc_grid_off_any];
    names.do { |n| var d; d = MIDIdef(n); if(d.notNil) { d.free } };
    "[APC] MIDIdefs cleared".postln;
};

/* arm handlers with UID filter and ANY fallback, repaint on release in toggle mode */
~apcArmGrid = {
    var uid, mode, map, padLED, ledByState;

    uid        = ~apcSrcUID;
    mode       = ~apcPressMode;
    map        = ~apcPadMap;
    padLED     = ~apcPadLED;
    ledByState = ~apcLEDByState;

    ~apcFreeMIDIDefs.();

    MIDIdef.noteOn(
        \apc_grid_on,
        { |vel, num, chan, src|
            var key, isPlaying;
            key = map[num];
            if(key.notNil) {
                if(mode == \toggle) {
                    isPlaying = Pdef(key).isPlaying;
                    if(isPlaying) { Pdef(key).stop; padLED.(num, \amber) } { Pdef(key).play; padLED.(num, \green) };
                    SystemClock.sched(0.02, { ledByState.(num, key); nil });
                }{
                    if(vel > 0) {
                        Pdef(key).play; padLED.(num, \green);
                        SystemClock.sched(0.02, { ledByState.(num, key); nil });
                    };
                };
            };
        },
        nil, nil, uid
    );

    MIDIdef.noteOff(
        \apc_grid_off,
        { |vel, num, chan, src|
            var key;
            key = map[num];
            if(key.notNil) {
                if(mode == \gate) { Pdef(key).stop; padLED.(num, \amber) } { ledByState.(num, key) };
            };
        },
        nil, nil, uid
    );

    /* ANY fallbacks to survive UID filter weirdness or post-Panic oddities */
    MIDIdef.noteOn(
        \apc_grid_on_any,
        { |vel, num, chan, src|
            if(src == uid) {
                var key, isPlaying;
                key = map[num];
                if(key.notNil) {
                    if(mode == \toggle) {
                        isPlaying = Pdef(key).isPlaying;
                        if(isPlaying) { Pdef(key).stop; padLED.(num, \amber) } { Pdef(key).play; padLED.(num, \green) };
                        SystemClock.sched(0.02, { ledByState.(num, key); nil });
                    }{
                        if(vel > 0) {
                            Pdef(key).play; padLED.(num, \green);
                            SystemClock.sched(0.02, { ledByState.(num, key); nil });
                        };
                    };
                };
            };
        }
    );

    MIDIdef.noteOff(
        \apc_grid_off_any,
        { |vel, num, chan, src|
            if(src == uid) {
                var key;
                key = map[num];
                if(key.notNil) {
                    if(mode == \gate) { Pdef(key).stop; padLED.(num, \amber) } { ledByState.(num, key) };
                };
            };
        }
    );

    /* repaint current truth */
    map.keysValuesDo { |n, k| ledByState.(n, k) };

    ["[APC] armed grid for uid", uid, "mode", mode, "assigns", map.keys.size].postln;
    uid
};

/* full boot: pickPorts -> Intro -> arm -> start watcher -> repaint */
~apcRouterBoot = {
    var ok1;
    ok1 = ~apcPickPorts.();
    if(ok1.notNil) {
        ~apcIntro.(1);
        ~apcArmGrid.();
        ~apcGridWatchStart.(~apcGridPeriod ? 0.25);
        ~apcPadMap.keysValuesDo { |n, k| ~apcLEDByState.(n, k) };
        "[APC] router boot complete".postln;
    }{
        "[APC] router boot failed to pick ports".warn;
    };
    ok1
};

/* Panic hook now does a full recover including pickPorts */
~apcInstallPanicHook = {
    var fn;
    if(~apcCmdPeriodHook.notNil) { CmdPeriod.remove(~apcCmdPeriodHook) };
    fn = {
        var delay;
        ~apcGridWatchStop.();
        delay = 0.15;
        AppClock.sched(delay, {
            ~apcPickPorts.();      // reconnect inputs and output
            ~apcIntro.(1);         // re-enter RGB-velocity mode
            ~apcArmGrid.();        // reinstall handlers
            ~apcGridWatchStart.(~apcGridPeriod ? 0.25);
            ~apcPadMap.keysValuesDo { |n, k| ~apcLEDByState.(n, k) }; // repaint to truth
            "[APC] recovered after Panic".postln;
            nil
        });
    };
    ~apcCmdPeriodHook = fn;
    CmdPeriod.add(fn);
    "[APC] CmdPeriod panic hook installed".postln;
};

/* watchdog that keeps the router alive across other includes re-arming or freeing defs */
~apcWatchdogStop = {
    var was;
    was = (~apcWatchdogActive == true);
    ~apcWatchdogActive = false;
    if(was) { "[APC] watchdog stop requested".postln };
};

~apcWatchdogStart = { |period=0.5|
    var tick;
    ~apcWatchdogActive = true;
    ~apcWatchdogPeriod = period;
    tick = {
        var need;
        need = (MIDIdef(\apc_grid_on).isNil or: { MIDIdef(\apc_grid_off).isNil });
        if(need) {
            "[APC] watchdog re-arming handlers".postln;
            ~apcArmGrid.();
        };
        if(~apcWatchdogActive == true) {
            AppClock.sched(~apcWatchdogPeriod ? 0.5, { tick.value; nil })
        }{
            "[APC] watchdog exited".postln;
        };
    };
    AppClock.sched(0.25, { tick.value; nil });
    "[APC] watchdog started".postln;
};

/* autorun on eval */
if(~apcAutoStart == true) {
    AppClock.sched(0.05, {
        ~apcRouterBoot.();
        ~apcInstallPanicHook.();
        ~apcWatchdogStart.(0.5);
        nil
    });
};
)

