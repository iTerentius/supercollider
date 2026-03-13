// Config — tempo + sample loads
(
~link.tempo = 100/60;
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/Codeine_Drum_Kit/DrumLoops/");
~loadSamps.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamps.("~/Music/supercollider/_samples/_mono/jttcot/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
~r2fx[\combDelay].set(\maxdt, 2.0, \dt, 0.5, \dec, 1.0);
~r1fx[\freeVerb].set(\mix,  0.5,  \room,  0.5,  \damp,  0.5);
~fxSetup[\r1_freeVerb].value;
)

