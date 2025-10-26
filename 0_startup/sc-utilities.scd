// Recording
// (
// ~prepRecord = {
//   ~recPath = Platform.userHomeDir +/+ "Music/SuperCollider\ Recordings";
//   // ~recPath = Platform.userHomeDir +/+ "/Volumes/Hypostatic\ Work/Hypostatic\ Sound/sc_recordings/";
//   ~recFileName = "jam";
//   ~recChannels = 4;
// }
// // Example (using your ~vars set above):
//
// // start on the next bar; stop manually whenever you want
// ~quantRecord.(nil, ~recChannels, ~recPath, ~recFileName);
// ) 

// s.stopRecording; // stop recording

// don’t pass sends; just pass channels you actually want stems for
~stopStems = ~stemDiskStart.(
  [~t2, ~t3, ~t4],   // track stems (dry)
  [~r1],            // return stem (this is the reverb bus)
  "songB"           // file base name
);

// when you want to stop, on a musical offset
~stopStems.(1);

~lcnBindParam.(\b0_s1_r1, {|x| ("[LC] \b0_s1_r1: "++x).postln;});

~lcxlBindParam.(\b0_s1_r1, {|x| ("[LCXL] \b0_s1_r1: "++x).postln;});
~lcxlBindPdef.(\b0_s5_p, \yesorno);

~apcBindParam.(\b0_s1_r1, {|x| ("[APC] \b0_s1_r1: "++x).postln;});
~apcBindParam.(\b0_d2, {|x| ("[APC] \b0_d2: "++x).postln;});
~apcBindParam.(\b0_s1_f, {|x| ("[APC] \b0_s1_f: "++x).postln;});
