// Config — tempo + sample loads
(
~link.tempo = 100/60;
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/Codeine_Drum_Kit/DrumLoops/");
~loadSamps.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamps.("~/Music/supercollider/_samples/_mono/jttcot/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
~r1fx[\greyhole].set(\delayTime, 2.0, \damp, 0.1, \size, 3.0, \diff, 0.707, \feedback, 0.2, \modDepth, 0.1, \modFreq, 2.0);
~r2fx[\combDelay].set(\maxdt, 0.7, \dt, 1.1, \dec, 1.1);
)

