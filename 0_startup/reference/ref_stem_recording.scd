// =============================================================================
// STEM RECORDING  (_includes/mixer-channel-stem-record.scd)
// =============================================================================
// NOT loaded by default. Load manually:
//   "_includes/mixer-channel-stem-record.scd".loadRelative;
// Globals: ~stemDiskStart, ~stemStopNow, ~stemRec, ~stemMidiWrite, ~stemMidiUnpatch
//
// Optional kwargs (both default false):
//   captureHistory: true  — History.start fires at the scheduled recording start beat.
//                           History.end + History.write(path) fire in the finalize
//                           Routine, before stem splitting.
//                           Output: jam_<timestamp>.history.scd alongside .wav
//
//   captureMidi:    true  — Patches Event.eventTypes[\note] while recording.
//                           This handler fires for every pattern note event (audio or
//                           MIDI), including \pBm/\pBs buffer events.
//                           Per event: extracts ~midinote (degree→scale→midinote),
//                           ~sustain (note dur in ticks), ~amp → velocity, \out bus
//                           → track index.
//                           Track→voice mapping is automatic from the tracks/returns
//                           arrays passed to stemDiskStart (no ~slots dependency).
//                           MIDI track order matches audio stem order.
//                           At finalize: restores the original handler, groups events
//                           by track, calls ~stemMidiWrite.
//                           Output: jam_<timestamp>.mid (Type-1 MIDI, one track/stem)
//                           Emergency unpatch: ~stemMidiUnpatch.()
//
// ~stemMidiWrite can also be called standalone for a pattern snapshot:
//   See bottom of this file for usage.

// --- Start recording stems from mixer channels ---
// Returns a stopper function
~stemStop = ~stemDiskStart.(
    tracks:  [~t1, ~t2, ~t3, ~t4],    // MixerChannels to record
    returns: [~r1, ~r2],               // return channels
    fileBase: "jam",                   // filename prefix
    dirPath: "~/Music/recordings",     // output directory (auto-created)
    clock: ~link,                      // for beat-synced start (nil = default)
    autoSplit: true,                   // auto-split interleaved WAV into stems via ffmpeg
    splitCodec: \pcm_s24le,            // codec for split files
    captureHistory: true,              // saves jam_<timestamp>.history.scd (live code log)
    captureMidi: true                  // saves jam_<timestamp>.mid (one track per stem)
);

// --- Stop recording (scheduled, on beat) ---
~stemStop.(beats: 4);                 // stop 4 beats from now

// --- Stop immediately ---
~stemStopNow.();

// Output (captureHistory+captureMidi both true):
//   ~/Music/recordings/jam_<ts>.wav              (interleaved N-ch audio)
//   ~/Music/recordings/jam_<ts>.stemnames.txt    (channel names)
//   ~/Music/recordings/jam_<ts>-stems/           (split stereo WAVs via ffmpeg)
//   ~/Music/recordings/jam_<ts>.history.scd      (live code log with timestamps)
//   ~/Music/recordings/jam_<ts>.mid              (Type-1 MIDI, one track per stem)
//
// MIDI notes reflect \degree/\scale/\octave → midinote for each event.
// For sample voices (\pBm/\pBs), this is the pitch-intent (affecting PlayBuf rate,
// not absolute concert pitch unless samples are tuned to A=440). The MIDI file will
// correctly reflect the harmonic/rhythmic structure of the session.
// Track order in .mid matches tracks/returns array order passed to stemDiskStart.
//
// Emergency MIDI unpatch (if recording stops unexpectedly):
//   ~stemMidiUnpatch.()
//
// Standalone MIDI write (pattern snapshot, no live capture):
//   ~stemMidiWrite.(path, tracksEvents, bpm, ppq)
//   Where tracksEvents is Array of Arrays of (tick:, pitch:, dur:, vel:) Events.

// --- Record everything ---
~stemStop = ~stemDiskStart.(
    tracks:  [~t1, ~t2, ~t3, ~t4, ~t5, ~t6, ~t7, ~t8, ~t9, ~t10, ~t11, ~t12],
    returns: [~r1, ~r2, ~r3, ~r4],
    fileBase: "full_session"
);
