
(
~dirt.doNotReadYet = true;  // index only; real audio loads lazily on first play

~dirt.loadSoundFiles("~/Music/supercollider/_samples/808s_by_SHD/808_kit/*");  // -> 808_kit, Classic, Layered, ...
~dirt.loadSoundFiles("~/Music/supercollider/_samples/Ghosthack/*");      // -> hoarder
~dirt.loadSoundFiles("~/Music/supercollider/_samples/Hoarder/");      // -> hoarder
~dirt.loadSoundFiles("~/Music/supercollider/_samples/Cat-Water/");      // -> hoarder
)

///////////////////////////////////////////////////////////////////////////////////////////
"load.scd".loadRelative;

~fxSetSend.(\ins1,  \s1,  0.0);
~fxSetSend.(\ins2,  \s1,  0.0);
~fxSetSend.(\ins3,  \s1,  0.0);
~fxSetSend.(\ins4,  \s1,  0.8);
~fxSetSend.(\ins5,  \s1,  0.8);
~fxSetSend.(\ins9,  \s1,  0.0);

~fxSetSend.(\ins1,  \s2,  0.0);
~fxSetSend.(\ins2,  \s2,  0.0);
~fxSetSend.(\ins3,  \s2,  0.0);
~fxSetSend.(\ins4,  \s2,  0.9);
~fxSetSend.(\ins5,  \s2,  0.9);
~fxSetSend.(\ins9,  \s2,  0.0);

~fxSetSend.(\ins1,  \s3,  0.0);
~fxSetSend.(\ins2,  \s3,  0.0);
~fxUnsetSend.(\ins3,  \s3,  0.0);
~fxSetSend.(\ins4,  \s3,  0.3);
~fxSetSend.(\ins5,  \s3,  1.0);
~fxSetSend.(\ins9,  \s3,  1.0);

~fxSetSend.(\ins1,  \s4,  0.0);
~fxSetSend.(\ins2,  \s4,  0.9);
~fxSetSend.(\ins3,  \s4,  0.0);
~fxSetSend.(\ins4,  \s4,  1.0);
~fxSetSend.(\ins5,  \s4,  1.0);
~fxSetSend.(\ins9,  \s4,  1.0);
~fxUnsetSend.(\kk1,  \s3,  0.2);
~fxRoute.(\fxsDistort, \fxsGreyhole,  1.0);
~fxUnroute.(\fxsDistort, \fxsGreyhole,  0.7);


// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
(
Ndef(\fxsGreyhole).set(
  \delayTime,  0.5, 
  \size,  0.4, 
  \damp,  0.0,  
  \diff,  0.2,  
  \feedback, 0.5,  
  \modDepth,  0.8,  
  \modFreq, 0.5,  
  \mix, 1.0,  
);
)
Ndef(\lfo1, {LFSaw.ar(0.25)});
Ndef(\fxsGreyhole).map(\modFreq,  { Ndef.kr(\lfo1).range(0.01,  2.0)});
Ndef(\fxsGreyhole).map(\size,  Ndef(\lfo1));
Ndef(\fxsGreyhole).map(\diff,  Ndef(\lfo1));

(
Ndef(\lfoRate, {
  LFPulse.ar(1/16 + SinOsc.ar(8, 0.5),  2)
});
)

Ndef(\lfo2, { LFPulse.ar(0.025)});

(
Ndef(\fxsMod).set(\rate,  0.25,  \depth, 0.005);
Ndef(\fxsGlitch).set(\rate, 8,  \mix, 1,   \amp,  2);
Ndef(\fxsGlitch).map(\freeze, Ndef(\lfo2));
)

Ndef(\fxsDistort).xset(\brate, 11400, \bbits, 8, \bits, 6, \clock,  18000, \bmix, 0.8,  \wfmix, 1.0,  \shape,  3, \fxMode, 2,   \gain,  2,  \naked, 1,   \dressed,  1);
Ndef(\fxsDistort).xset(\clock, 8000, \bits,  6,  \fxMode,  1,  \shape, 3);
Ndef(\fxsDistort).clear;

~fxInit.();
~fxState[\tracks];
(
~insSlotsCheck.();
~stemStop = ~stemDiskStart.(
    tracks:  [
      ~ndefAsChan.(Ndef(\ins1)),  
      ~ndefAsChan.(Ndef(\ins2)),  
      ~ndefAsChan.(Ndef(\ins3)),  
      ~ndefAsChan.(Ndef(\ins4)),  
      ~ndefAsChan.(Ndef(\ins5)),  
    ],    // MixerChannels to record
    returns: [
      ~ndefAsChan.(Ndef(\fxsBitcrush)),  
      ~ndefAsChan.(Ndef(\fxsDistort)),  
      ~ndefAsChan.(Ndef(\fxsGreyhole)),  
      ~ndefAsChan.(Ndef(\fxsMod)),  
      ~ndefAsChan.(Ndef(\fxsGlitch)),  
    ],               // return channels
    fileBase: "2026.07.20-b",                   // filename prefix
    dirPath: "~/Music/recordings",     // output directory (auto-created)
    clock: ~link,                      // for beat-synced start (nil = default)
    autoSplit: true,                   // auto-split interleaved WAV into stems via ffmpeg
    splitCodec: \pcm_s24le,            // codec for split files
    captureHistory: true,              // saves jam_<timestamp>.history.scd (live code log)
    captureMidi: true                  // saves jam_<timestamp>.mid (one track per stem)
);
)
// --- Stop recording (scheduled, on beat) ---
~stemStop.(beats: 4);                 // stop 4 beats from now

// --- Stop immediately ---
~stemStopNow.();

History.loadStory("/Users/isaaclinder/Music/recordings/2026.07.20_2026-07-26_07-14-28/2026.07.20-b_2026-08-22_22-39-20.history.scd")
History.play
History.stop
