
(
// 2025-12-08 08_20 track template main

~trkId = \t2025_12_08;  // optional track id

~loadTrack = {
    var dir;
    dir = thisProcess.nowExecutingPath.dirname;

    (dir +/+ "10_track_defs.scd").load;
    (dir +/+ "20_track_patterns.scd").load;
    (dir +/+ "30_track_live.scd").load;
};

~startTrack = {
    var clock;
    clock = TempoClock.default;
    clock.tempo = 120 / 60;  // set track tempo here
    Pdef(\bd_main_2025_12_08).play(clock);
};

~stopTrack = {
    Pdef(\bd_main_2025_12_08).stop;
};
)
