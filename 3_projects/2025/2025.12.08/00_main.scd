
(
// 2025-12-08 08_20 track template main

~trkId = \t2025_12_08;  // optional track id

~loadTrack = {
    var dir;
    dir = thisProcess.nowExecutingPath.dirname;

    (dir +/+ "10_defs.scd").load;
    (dir +/+ "20_patterns.scd").load;
    (dir +/+ "30_live.scd").load;
};

~startTrack = {
    var clock;
    clock = TempoClock.default;
    clock.tempo = 120 / 60;  // set track tempo here
    Pdef(\bd_main).play(clock);
};

~stopTrack = {
    Pdef(\bd_main).stop;
};
)

TempoClock.default.tempo_(90/60);
~loadTrack.();
