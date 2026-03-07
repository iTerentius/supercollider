// =============================================================================
// STEM RECORDING  (_includes/mixer-channel-stem-record.scd)
// =============================================================================
// NOT loaded by default. Load manually:
//   "_includes/mixer-channel-stem-record.scd".loadRelative;
// Globals: ~stemDiskStart, ~stemStopNow, ~stemRec

// --- Start recording stems from mixer channels ---
// Returns a stopper function
~stemStop = ~stemDiskStart.(
    tracks:  [~t1, ~t2, ~t3, ~t4],    // MixerChannels to record
    returns: [~r1, ~r2],               // return channels
    fileBase: "jam",                   // filename prefix
    dirPath: "~/Music/recordings",     // output directory (auto-created)
    clock: ~link,                      // for beat-synced start (nil = default)
    autoSplit: true,                   // auto-split interleaved WAV into stems via ffmpeg
    splitCodec: \pcm_s24le             // codec for split files
);

// --- Stop recording (scheduled, on beat) ---
~stemStop.(beats: 4);                 // stop 4 beats from now

// --- Stop immediately ---
~stemStopNow.();

// Output:
//   ~/Music/recordings/jam_2025-10-26_21-45-00.wav          (interleaved N-ch)
//   ~/Music/recordings/jam_2025-10-26_21-45-00.stemnames.txt (channel names)
//   ~/Music/recordings/jam_2025-10-26_21-45-00-stems/       (split stereo WAVs)

// --- Record everything ---
~stemStop = ~stemDiskStart.(
    tracks:  [~t1, ~t2, ~t3, ~t4, ~t5, ~t6, ~t7, ~t8, ~t9, ~t10, ~t11, ~t12],
    returns: [~r1, ~r2, ~r3, ~r4],
    fileBase: "full_session"
);
