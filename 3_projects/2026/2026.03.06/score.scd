// Score — evaluate to load project
// Capture dir now (thisProcess.nowExecutingPath is set during eval, not in the fork).
// Fork + s.sync so Buffer.read callbacks complete before parts access ~sTree.
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
    s.sync;  // wait for all Buffer.read /done callbacks to fire
    safeLoad.("lib/config.scd");
    safeLoad.("lib/fx.scd");
    safeLoad.("parts/thingA.scd");
    safeLoad.("parts/bd1.scd");
    safeLoad.("parts/sd1.scd");
    safeLoad.("parts/hh1.scd");
    safeLoad.("parts/roll.scd");
    safeLoad.("parts/ms20.scd");
    safeLoad.("parts/neutron.scd");
    safeLoad.("parts/model_d.scd");
    safeLoad.("parts/bass8.scd");
    safeLoad.("automation/biscuit.scd");
    safeLoad.("lib/bindings.scd");
    "Score loaded.".postln;
}.fork(AppClock);
)
