// samples.scd — loaded first (before s.sync) so buffers are ready for parts
(
// ~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
) 
~sTree.keys.postln;
  ~sTree[\mm].postln;
  (\_mono == '_mono').postln;
