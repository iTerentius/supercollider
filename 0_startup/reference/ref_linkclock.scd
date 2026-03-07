// =============================================================================
// LINKCLOCK  (configured in startup.scd)
// =============================================================================
// Globals: ~link

~link.tempo = 130/60;                 // set BPM
~link.tempo;                          // get current tempo (beats per sec)
~link.beats;                          // current beat position
~link.beatsPerBar;                    // default 4

// All Pdefs quantize to 4 beats by default:
Pdef.defaultQuant = 4;

// Play a pattern on the link clock:
Pdef(\x).play(~link, quant: 4);
