// Recording
(
~prepRecord = {
  ~recPath = Platform.userHomeDir +/+ "Music/SuperCollider\ Recordings";
  // ~recPath = Platform.userHomeDir +/+ "/Volumes/Hypostatic\ Work/Hypostatic\ Sound/sc_recordings/";
  ~recFileName = "jam";
  ~recChannels = 4;
}
// Example (using your ~vars set above):

// start on the next bar; stop manually whenever you want
~quantRecord.(nil, ~recChannels, ~recPath, ~recFileName);
)

s.stopRecording; // stop recording

// Launch Control XL learn and bind
~setBank.(0); // set bank, it remembers

~setBank.(1); // set bank, it remembers

~learnRow1.();
~learnRow2.();
~learnRow3.();
~learnFaders.();

~setMapPath.("/Users/isaaclinder/Music/supercollider/0_startup/_includes/_midi-ctrl/lcxl-router.map");
// learn a control or two…
~saveMap.();     // creates the file & parent folder if missing
~printMap.();    // should list b0-… keys
~loadMap.();

~mapStats.();     // should say entries: 16 and show banks, e.g. [ "b0", ... ]
~printMapAll.();  // should list b0-... keys explicitly
~printMap.(0);    // filtered for bank 0

~ccBind.(\f1, \track, \amp);  // defaults spec inside ~ccBind body
~ccBind.(\t1r1, \track, \amp);  // defaults spec inside ~ccBind body

// Sample Loader
~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12");

~printTree.();

~listKeys.();

{ PlayBuf.ar(1, ~getSample.(\123), doneAction:2) * 0.5 }.play;


PathName(~sampleRoot).entries.do(_.postln);


{ PlayBuf.ar(1, ~getSampl0e.(\bass_drums), doneAction:2) * 0.4 }.play;

~printTopKeys.();               // just the top folders
~printTree.();                  // whole nested tree of names
~listKeys.(\drums, \kicks);     // list only the samples in that subfolder
