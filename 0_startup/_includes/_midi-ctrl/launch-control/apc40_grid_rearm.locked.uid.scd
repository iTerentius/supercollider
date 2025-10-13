// 2025-10-12 21:20 CDT  APC40 mkII grid rearm  deferred to next SystemClock tick

(
{
    var dir;

    /* load launcher once, do not arm yet */
    dir = thisProcess.nowExecutingPath.dirname;
    if(~apcGridInit.isNil) {
        dir.loadRelative("apc40mk2_grid_launcher.locked.uid.scd");
    };

    /* defer the actual init to avoid resuming the running startup Routine */
    SystemClock.sched(0.0, {
        var fixed, ok;

        /* optional hard bind  set once in startup before loading this file
           example  ~apcGridFixed = (uid: 762601288, dest: 4) */
        fixed = ~apcGridFixed;

        if(~apcGridInit.isNil) {
            "[rearm] apc grid launcher missing  skipped".warn;
            ^nil
        };

        if(fixed.notNil and: { fixed[\uid].notNil and: { fixed[\dest].notNil } }) {
            ok = ~apcGridInit.(fixed[\uid], fixed[\dest]);
            if(ok) { "[rearm] apc40 mkII grid ready fixed ids".postln };
            ^nil
        };

        ok = ~apcGridAutoInit.();
        if(ok) { "[rearm] apc40 mkII grid ready auto".postln } { "[rearm] apc40 mkII not connected  skipped".postln };

        nil
    });

    nil
}.value
)

