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
    (dir +/+ "lib/samples.scd").load;
    s.sync;  // wait for Buffer.read /done callbacks
    safeLoad.("lib/config.scd");
    safeLoad.("lib/fx.scd");
    safeLoad.("lib/slots.scd");       // define ~slots before parts + bindings

    safeLoad.("automation/biscuit.scd");       // define ~slots before parts + bindings
    safeLoad.("automation/spectral.scd");       // define ~slots before parts + bindings
    safeLoad.("automation/tempo.scd");       // define ~slots before parts + bindings
    safeLoad.("automation/ilfx/crush.scd");       // define ~slots before parts + bindings
    // --- parts (one per voice, in any order) ---
    safeLoad.("parts/v1_808k.scd");
    safeLoad.("parts/v1_808hh.scd");
    safeLoad.("parts/v1_808sn.scd");
    safeLoad.("parts/v2_bass.scd");
    safeLoad.("parts/v3_harpy.scd");
    safeLoad.("parts/v4_dk.scd");
    safeLoad.("parts/v5_smp1.scd");
    // --- bindings last (reads ~slots + ~phrFns populated by parts) ---
    safeLoad.("lib/bindings.scd");
    safeLoad.("lib/tosc_biscuit.scd");
    // --- optional: stem recording (loads ~stemDiskStart, ~stemMidiWrite) ---
    // "_includes/mixer-channel-stem-record.scd".loadRelative;
    "Score loaded.".postln;
}.fork(AppClock);
)
