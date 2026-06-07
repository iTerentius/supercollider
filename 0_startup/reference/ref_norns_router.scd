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
// TEMPO SYNC  (Deluge MIDI clock → ~link → Norns via Link)
// =============================================================================
// Deluge is tempo master. Enable MIDI clock out in Deluge MIDI settings.
// Evaluate this block once after boot; re-evaluate if Deluge reconnects.
//
// Setting ~link.tempo propagates to all Link peers (including Norns) automatically.
// LinkClock manages beat phase internally — do not attempt to set ~link.beats.
// Beat phase between SC and Norns stays aligned via Link protocol.
// Deluge↔Link phase is loose (tempo matches; start them together for alignment).
(
var times = Array.new(24);
var last;

MIDIdef.midiClock(\delugeSync, {
    var now = Main.elapsedTime;
    if(last.notNil) {
        var dt = now - last;
        if(dt > 0.008 and: { dt < 0.125 }) {   // valid range: ~20-300 BPM
            times = times.add(dt).keep(-24);     // rolling 1-beat window
            if(times.size >= 8) {
                ~link.tempo = 1.0 / (times.mean * 24);
            };
        };
    };
    last = now;
});
)

// Stop clock sync:
// MIDIdef(\delugeSync).free;

// Find Deluge MIDI source if clock isn't arriving:
MIDIClient.sources.do { |ep, i| [i, ep.device, ep.name].postln };

// =============================================================================
// SONG HANDLERS
// =============================================================================
// Keys match the integer ID set on each BEACON cell in arcologies (1-99).
~song[1] = { ~toggle.(\bassline) };
~song[2] = { ~toggle.(\arp) };
~song[3] = { ~toggle.(\pad) };
~song[4] = { ~oneshot.(\fill, 2) };   // 2-bar one-shot
~song[5] = { ~toggle.(\chaos) };

// Handler receives (id:) event — id available if needed:
~song[6] = { |ev| ev.id.postln; ~toggle.(\thing) };

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================
~play.(\bassline);              // Pdef(\bassline).play(TempoClock.default)
~stop.(\bassline);              // Pdef(\bassline).stop
~toggle.(\bassline);            // play if stopped, stop if playing

~oneshot.(\fill);               // play for 1 bar then stop
~oneshot.(\fill, 2);            // play for 2 bars then stop

// =============================================================================
// OSC LISTENER
// =============================================================================
// Set up automatically by norns-router.scd on load.
// Listens on /arc/trigger, port 57120. msg[3] is the integer ID.

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
