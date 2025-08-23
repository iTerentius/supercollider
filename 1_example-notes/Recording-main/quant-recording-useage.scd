(
// Example (using your ~vars set above):
~recPath = Platform.userHomeDir +/+ "Music/SuperCollider\ Recordings";
// ~recPath = Platform.userHomeDir +/+ "/Volumes/Hypostatic\ Work/Hypostatic\ Sound/sc_recordings/";
~recFileName = "jam";
~recChannels = 4;

// start on the next bar; stop manually whenever you want
~quantRecord.(nil, ~recChannels, ~recPath, ~recFileName);
)

s.stopRecording; // stop recording
