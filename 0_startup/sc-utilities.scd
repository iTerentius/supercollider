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
// Run these in order if starting fresh
~lcxl_config[\midiChan] = 9
~installCCByNameRouter.();
~setBank.(0);
~learnFaders.();
~learnRow1.();
~learnRow2.();
~learnRow3.();
~printMapAll.();
~ccSanity.();

// Example bind
~ccBindParam.(\b0_f1, \track, \amp, ControlSpec(0, 0.5, \lin, 0, 0));

// Persist
~ccSave.();
~ccLoad.();

// Sample Loader
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

~printTree.();

~listKeys.();

{ PlayBuf.ar(1, ~getSample.(\cat_water), doneAction:2) * 0.5 }.play;


PathName(~sampleRoot).entries.do(_.postln);


{ PlayBuf.ar(1, ~getSampl0e.(\bass_drums), doneAction:2) * 0.4 }.play;

~printTopKeys.();               // just the top folders
~printTree.();                  // whole nested tree of names
~listKeys.(\drums, \kicks);     // list only the samples in that subfolder
