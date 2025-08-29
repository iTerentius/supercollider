~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12");

~printTree.();

~listKeys.();

{ PlayBuf.ar(1, ~getSample.(\123), doneAction:2) * 0.5 }.play;


PathName(~sampleRoot).entries.do(_.postln);


{ PlayBuf.ar(1, ~getSampl0e.(\bass_drums), doneAction:2) * 0.4 }.play;
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

~printTopKeys.();               // just the top folders
~printTree.();                  // whole nested tree of names
~listKeys.(\drums, \kicks);     // list only the samples in that subfolder
