// =============================================================================
// MIDI SETUP  (_includes/midi-setup.scd)
// =============================================================================
// Globals: ~mOut, ~lcxlSrcUid, ~lcSrcUid

// --- Send MIDI to DAW (via IAC / VirMIDI) ---
~mOut.noteOn(0, 60, 100);             // chan, note, vel
~mOut.noteOff(0, 60);
~mOut.control(0, 1, 64);              // chan, cc, val
~mOut.latency;                        // matched to s.latency

// --- Use in a Pbind for DAW instruments ---
Pdef(\daw, Pbind(
    \type, \midi,
    \midiout, ~mOut,
    \chan, 0,
    \midinote, Pseq([60, 64, 67], inf),
    \dur, 0.5
));
