// score.scd — evaluate to load project
// Load order: samples → s.sync → config → fx → slots → parts → bindings
(
var dir = thisProcess.nowExecutingPath.dirname;
var safeLoad = { |path|
    try {
        (dir +/+ path).load;
    } { |err|
        ("Score: FAILED " ++ path).postln;
        err.errorString.postln;
    };
};
{
    // (dir +/+ "lib/samples.scd").load;
    // s.sync;  // wait for Buffer.read /done callbacks
    // safeLoad.("lib/config.scd");
    safeLoad.("fx.scd");
    safeLoad.("synths.scd");

    // safeLoad.("lib/slots.scd");       // define ~slots before parts + bindings
    // --- automation Pdefs (FX control, tempo, etc.) ---
    // safeLoad.("automation/ilfx/v1_crush.scd");
    // --- parts (one per voice, in any order) ---
    safeLoad.("parts/v1_kit.scd");
    safeLoad.("parts/all.scd");
    safeLoad.("parts/v1.scd");
    safeLoad.("parts/v2.scd");
    safeLoad.("parts/v3.scd");
    safeLoad.("automation/biscuit.scd");
    safeLoad.("automation/spectral.scd");
    // --- bindings last (reads ~slots + ~autoSlots + ~phrFns populated by parts) ---
    safeLoad.("bindings.scd");
    safeLoad.("tosc_biscuit.scd");
    // --- optional: stem recording (loads ~stemDiskStart, ~stemMidiWrite) ---
    // "_includes/mixer-channel-stem-record.scd".loadRelative;
    "Score loaded.".postln;
}.fork(AppClock);
)
