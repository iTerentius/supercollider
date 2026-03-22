// Score — evaluate to load project
// Capture dir now (thisProcess.nowExecutingPath is set during eval, not in the fork).
// Fork + s.sync so Buffer.read callbacks complete before parts access ~sTree.
(
var dir = thisProcess.nowExecutingPath.dirname;
{
    (dir +/+ "lib/samples.scd").load;
    s.sync;  // wait for all Buffer.read /done callbacks to fire
    (dir +/+ "lib/config.scd").load;
    (dir +/+ "lib/fx.scd").load;
    (dir +/+ "parts/thingA.scd").load;
    (dir +/+ "parts/bd1.scd").load;
    (dir +/+ "parts/sd1.scd").load;
    (dir +/+ "parts/hh1.scd").load;
    (dir +/+ "parts/roll.scd").load;
    (dir +/+ "parts/ms20.scd").load;
    (dir +/+ "parts/neutron.scd").load;
    (dir +/+ "parts/model_d.scd").load;
    (dir +/+ "parts/bass8.scd").load;
    (dir +/+ "automation/biscuit.scd").load;
    (dir +/+ "lib/bindings.scd").load;
    "Score loaded.".postln;
}.fork(AppClock);
)
