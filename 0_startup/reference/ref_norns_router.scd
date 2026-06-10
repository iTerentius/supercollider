// =============================================================================
// NORNS ROUTER  (_includes/norns-router.scd)
// =============================================================================
// Norns Shield (arcologies BEACON cells) → SC → Deluge MIDI workflow.
// Globals: ~delugeOut, ~song, ~play, ~stop, ~toggle, ~oneshot
//
// Signal path:
//   BEACON cell fires /arc/trigger (OSC, WiFi) → SC OSCdef → ~song[id] handler
//   SC Pdef pattern (MIDI, USB) → Deluge synth tracks
//   Deluge MIDI clock (USB) → SC TempoClock (optional, keeps tempo locked)

// =============================================================================
// PHYSICAL CONNECTIONS
// =============================================================================
//
// Standalone rack topology (RasPad3 as SC device):
//
//   [Deluge] ──USB──────────────────────► [Anker hub] ──► [SC device]
//   [LCXL]   ──USB──► [Norns]
//   [Norns]  ──WiFi (OSC /arc/trigger)──► [SC device]
//   [Norns]  ──WiFi (Ableton Link)──────► [SC device]
//
// SC device is the USB host. Deluge plugs into the powered hub.
// SC sees Deluge as both a MIDI output destination (patterns out)
// and a MIDI input source (clock in).
//
// Tempo sync chain:
//   Deluge MIDI clock ──► SC (~link.tempo updated from 24ppqn pulses)
//   SC ~link ──► Norns via Ableton Link (local WiFi only, no internet)
//
// Norns set to Link mode (not internal clock, not MIDI clock).
// SC and Norns share beat phase automatically via Link.
// Deluge↔Link phase alignment is loose — start Deluge and Link together.
//
// Norns and SC must be on the same local network (shared WiFi router or
// small travel router in the rack). Set the SC device's IP in arcologies:
//   Norns PARAMS → BEACON / OSC → IP OCTET 1-4 + OSC PORT
//
// LCXL stays connected to Norns; Norns passthrough mod routes it to Deluge
// for param modulation. No change to that part of the rig.
//
// Port reference:
//   Norns OSC send port:  configured in PARAMS → BEACON / OSC → OSC PORT
//   SC OSC receive port:  57120 (SC default, set in norns-router.scd OSCdef)
//   Deluge MIDI channel:  set per Pdef \chan (0-indexed)
//
// macOS dev setup (laptop instead of RasPad3):
//   Same topology — Mac replaces RasPad3, Deluge USB into Mac directly or hub.
//   Norns and Mac on same WiFi network. No other changes.

// =============================================================================
// TEMPO SYNC  (SC → Deluge MIDI clock, SC is master)
// =============================================================================
// SC ~link is tempo master. Clock pulses sent to Deluge at 24ppqn.
// Tempo changes propagate to Norns via Link and to Deluge via MIDI clock.
// Set Deluge to external/slave clock mode.
//
// Change tempo from SC:
~link.tempo = 120/60;
~link.tempo = 90/60;

// Start/stop Deluge clock (defined in norns-router.scd):
~startDelugeClock.();
~stopDelugeClock.();

// The clock uses ~link.sched(1/24) so it automatically tracks tempo changes.
// Beat phase between SC and Norns stays aligned via Link protocol.

// =============================================================================
// SONG HANDLERS
// =============================================================================
// Keys match the integer ID set on each BEACON cell in arcologies (1-99).
// ~song entries are plain Functions — retrigger cooldown is set per-cell on the
// Norns grid (BEACON RETRIG param, in beats) and sent in the OSC message.
~song[1] = { ~toggle.(\bassline) };
~song[2] = { ~toggle.(\arp) };
~song[3] = { ~toggle.(\pad) };
~song[4] = { ~oneshot.(\fill, 2) };
~song[5] = { ~toggle.(\chaos) };

// Handler receives (id:) event — id available if needed:
~song[6] = { |ev| ev.id.postln; ~toggle.(\thing) };

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================
~play.(\bassline);              // Pdef(\bassline).play(~link), registers in ~activePdefs
~stop.(\bassline);              // Pdef(\bassline).stop, removes from ~activePdefs
~toggle.(\bassline);            // play if stopped / stop if playing — tracks state

~oneshot.(\fill);               // play for 1 bar then auto-stop
~oneshot.(\fill, 2);            // play for 2 bars then stop

// Stop all song patterns (only those started via this router):
~songStop.();                   // call when pausing arcologies

// Inspect what's currently tracked as playing:
~activePdefs.postln;

// =============================================================================
// OSC LISTENER
// =============================================================================
// Set up automatically by norns-router.scd on load.
// Listens on /arc/trigger, port 57120. msg[1] is the integer ID.
// OSCdef msg format: [path, arg1, arg2, ...] — time is a separate function param.

// Debug — trace incoming messages while testing BEACON cells:
OSCdef(\arcRouter).trace;
OSCdef(\arcRouter).trace(false);  // stop

// =============================================================================
// DELUGE MIDI OUT
// =============================================================================
// Auto-detected at load by "Deluge" in device/name string.
// If it fails (device not yet connected), re-evaluate norns-router.scd or:
MIDIClient.destinations.do { |ep, i| [i, ep.device, ep.name].postln };  // find name
~delugeOut = MIDIOut.newByName("Deluge", "Deluge MIDI 1");               // set manually
~delugeOut.latency = s.latency;

// Pbind pattern to Deluge:
Pdef(\bassline, Pbind(
    \type,     \midi,
    \midiout,  ~delugeOut,
    \chan,     0,            // Deluge synth track (0-indexed)
    \midinote, Pseq([36, 43, 36, 48], inf),
    \dur,      0.5,
    \sustain,  0.1,
));

// =============================================================================
// LOADING
// =============================================================================
// In startup.scd, uncomment:
//   "_includes/norns-router.scd".loadRelative;
//
// Load a song file per project (not at boot — the router is infrastructure,
// song handlers are project-specific):
//   "3_projects/2026/2026.06.07/song.scd".load;
//
// Start a new project from the template:
//   "2_Templates/norns-song-template.scd".load;

// =============================================================================
// FUTURE WORK (not implemented)
// =============================================================================
// Grid state: SC as second serialosc listener via monomeSC/serialosc.
//   Read active arcologies metabolism zones to weight Prand note choices,
//   turning arcologies into a shared state machine rather than just a
//   trigger source.
