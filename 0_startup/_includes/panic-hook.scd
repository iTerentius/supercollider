(
// ---------------- Project root + robust relative loader ----------------
~projRoot = (~projRoot ? {
    var p = thisProcess.nowExecutingPath;
    if(p.notNil) {
        // this file lives in .../<project>/_includes/panic-hook.scd
        // step up to _includes/, then up again to <project> root
        var incDir = PathName(p).parentPath;           // .../<project>/_includes
        var root   = PathName(incDir).parentPath;      // .../<project>
        root
    } { nil }
}).value;

~pathJoin = { |a, b| (a.asString +/+ b.asString).standardizePath };

~loadAbs = { |abs|
    if(File.exists(abs)) { abs.load } { ("[panic] missing: " ++ abs).warn };
};

~loadRel = { |rel|
    if(~projRoot.isNil) {
        "[panic] ~projRoot is nil. Set it once: ~projRoot = \"/path/to/your/project\";".warn;
    }{
        ~loadAbs.( ~pathJoin.(~projRoot, rel) );
    };
};

~loadAny = { |rels|
    if(~projRoot.isNil) {
        "[panic] ~projRoot is nil. Set it once: ~projRoot = \"/path/to/your/project\";".warn;
    }{
        var abs = rels.collect { |r| ~pathJoin.(~projRoot, r) }
                      .detect { |p| File.exists(p) };
        if(abs.notNil) { abs.load } { ("[panic] missing any of: " ++ rels).warn };
    };
};

// ---------------- Panic recovery hook ----------------
~panicHook !? { CmdPeriod.remove(~panicHook) };
~panicHook = {
    {
        "[panic] rebuilding mixer + MIDI routers…".postln;

        // 1) Rebuild mixer (try both folder spellings you use)
        ~loadAny.(["_includes/mixer-channel.scd", "_/includes/mixer-channel.scd"]);

        // 2) Re-arm LCXL (mixer binder + bank LEDs)
        ~loadRel.("_includes/_midi-ctrl/lcxl_mixer_auto_bind.scd");
        ~loadRel.("_includes/_midi-ctrl/lcxl_mixer_bank_buttons.scd");

        // 3) Re-arm Launch Control (non-XL) param router (8 banks)
        ~loadRel.("_includes/_midi-ctrl/lcn_param_router.scd");

        // 4) Re-arm the short-name bind hub
        ~loadRel.("_includes/_midi-ctrl/cc_bind_hub.scd");

        // 5) CLEAR ALL PARAM BINDS so you start fresh
        try { ~lcxlParam.notNil.if({ ~lcxlParam[\handlers].clear; "[panic] cleared LCXL binds".postln }) };
        try { ~lcn.notNil.if({ ~lcn[\handlers].clear; "[panic] cleared LC binds".postln }) };

        // 6) Repaint LEDs (optional)
        try { ~lcxlAB_BTN.notNil.if({ ~lcxlAB_BTN[\refreshLEDs].() }) };
        try { ~lcn.notNil.if({ ~lcn[\refreshLEDs].() }) };

        "[panic] done.".postln;
    }.defer(0.2); // tiny settle time after Cmd+.
};
CmdPeriod.add(~panicHook);

// Manual trigger if you want:
~recoverAll = { ~panicHook.value };

// One-time print
("[panic] armed. projRoot=" ++ (~projRoot ?? { "<nil>" })).postln;
)

