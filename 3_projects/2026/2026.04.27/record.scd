
// Load CC logger before starting if not already in startup
"_includes/cc-logger.scd".loadRelative;

(
~stemStop = ~stemDiskStart.(
  tracks:  [~t1, ~t2, ~t3 ],    // MixerChannels to record
  returns: [~r1, ~r2, ~r3,  ~r4,  ~r5],               // return channels
  fileBase: "naipa",                   // filename prefix
  dirPath: "~/Music/recordings",     // output directory (auto-created)
  clock: ~link,                      // for beat-synced start (nil = default)
  autoSplit: true,                   // auto-split interleaved WAV into stems via ffmpeg
  splitCodec: \pcm_s24le,            // codec for split files
  captureHistory: true,              // saves jam_<timestamp>.history.scd (live code log)
  captureMidi: true,                 // saves jam_<timestamp>.mid (one track per stem)
  captureCC: true                    // saves jam_<timestamp>.cc.scd (debounced CC/OSC changes)
);
)

// --- Stop recording (scheduled, on beat) ---
~stemStop.();                 // stop 4 beats from now

History.start();
History.end();
History.saveStory("~/Music/supercollider/3_projects/2026/2026.04.27/at1.scd");
History.loadStory("~/Music/supercollider/3_projects/2026/2026.04.27/at1.scd");
History.play();
History.stop();

