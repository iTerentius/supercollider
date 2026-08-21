
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
    // --- automation Pdefs (FX control, tempo, etc.) ---
    safeLoad.("lib/fxSends.scd");
    // --- parts (one per voice, in any order) ---
    safeLoad.("parts/kitA.scd");
    safeLoad.("parts/synthsA.scd");
    safeLoad.("parts/synthsB.scd");
    safeLoad.("parts/midiA.scd");
    // --- bindings last (reads ~slots + ~autoSlots + ~phrFns populated by parts) ---
    // safeLoad.("lib/bindings.scd");
    // --- optional: stem recording (loads ~stemDiskStart, ~stemMidiWrite) ---
    // "_includes/mixer-channel-stem-record.scd".loadRelative;
    "Score loaded.".postln;
}.fork(AppClock);
)
