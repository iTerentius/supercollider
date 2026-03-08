// Config — tempo + sample loads
(
~link.tempo = 110/60;
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/Codeine_Drum_Kit/DrumLoops/");
~loadSamps.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamps.("~/Music/supercollider/_samples/_mono/jttcot/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
// ~setR1.set(\room, 1.0,  \damp, 0.5,  \mix, 1.5);
~setR2.set(\maxdt, 0.7, \dt,   1.1,  \dec, 1.1);

~setR1.set(
  \roomsize, 10,  
  \revtime, 1,  
  \damping, 0.1,
  \inputbw, 0.2,  
  \spread,  15, 
  \drylevel,  0.6,  
  \earlyreflevel, 0.2,  
  \taillevel, 0.8,  
  \maxroomsize, 300,  
);

)
