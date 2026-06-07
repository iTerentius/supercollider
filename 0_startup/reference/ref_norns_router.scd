// =============================================================================
// NORNS ROUTER  (_includes/norns-router.scd)
// =============================================================================
// Norns Shield (arcologies BEACON cells) → SC → Deluge MIDI workflow.
// Globals: ~delugeOut, ~song, ~play, ~stop, ~toggle, ~oneshot
//
// Trigger path: BEACON cell fires /arc/trigger with its integer ID →
//   SC OSCdef looks up ~song[id] and calls the handler.
// No MIDI from Norns needed; tempo sync is Deluge MIDI clock → TempoClock.

// --- Register handlers in ~song ---
// Keys are the integer IDs set on each BEACON cell in arcologies (1-99).
~song[1] = { ~toggle.(\bassline) };
~song[2] = { ~oneshot.(\fill, 2) };   // 2-bar one-shot
~song[3] = { ~play.(\pad) };           // always restart

// --- Utility functions ---
~play.(\bassline);              // Pdef(\bassline).play(TempoClock.default)
~stop.(\bassline);              // Pdef(\bassline).stop
~toggle.(\bassline);            // play if stopped, stop if playing

~oneshot.(\fill);               // play for 1 bar then stop
~oneshot.(\fill, 2);            // play for 2 bars then stop

// --- OSCdef (already set up by norns-router.scd) ---
// Listens on /arc/trigger, port 57120 (SC default). msg[3] is the integer ID.
// To inspect incoming messages:
OSCdef(\arcRouter).trace;
OSCdef(\arcRouter).trace(false);  // stop

// --- Deluge MIDI out ---
// Auto-detected by "Deluge" in device/name. Re-evaluate after connecting device.
MIDIClient.destinations.do { |ep, i| [i, ep.device, ep.name].postln };  // find port name

~delugeOut = MIDIOut.newByName("Deluge", "Deluge MIDI 1");  // manual fallback
~delugeOut.latency = s.latency;

// --- Pbind using ~delugeOut ---
Pdef(\bassline, Pbind(
    \type,     \midi,
    \midiout,  ~delugeOut,
    \chan,     0,            // Deluge synth track (0-indexed)
    \midinote, Pseq([36, 43, 36, 48], inf),
    \dur,      0.5,
    \sustain,  0.1,
));

// --- Deluge clock sync (optional — keeps TempoClock in step with Deluge tempo changes) ---
// See ref_norns_router.scd for the MIDI clock sync snippet.
// Not needed if you always set tempo from SC; useful if Deluge drives tempo live.

// --- Loading ---
// In startup.scd, uncomment:
//   "_includes/norns-router.scd".loadRelative;
// Load song file per project (not at boot):
//   "path/to/mysong.scd".load;
// Or start from 2_Templates/norns-song-template.scd.

// --- Future work (not implemented) ---
// Grid state: SC as second serialosc listener; read active arcologies metabolism
//   zones to weight Prand choices (arcologies as shared state machine).
