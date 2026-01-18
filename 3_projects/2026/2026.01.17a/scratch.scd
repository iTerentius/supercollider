// Scratch - play/stop commands

// --- TEMPO ---
// ~link.tempo = 120/60;

// --- SCORE ---
// Pdef(\score).play(~link);
// Pdef(\score).stopQ(4);

// --- PARTS ---
// Pdef(\perc).play(~link);
// Pdef(\perc).stopQ(4);

// Pdef(\v1).play(~link);
// Pdef(\v1).stopQ(4);

// Pdef(\bass).play(~link);
// Pdef(\bass).stopQ(4);

// Pdef(\mel).play(~link);
// Pdef(\mel).stopQ(4);

// Pdef(\pad).play(~link);
// Pdef(\pad).stopQ(4);

// --- SYNTH (composite: MIDI + SC) ---
// Pdef(\synth_layer).play(~link);  // both MIDI + SC
// Pdef(\synth_layer).stopQ(4);

// Pdef(\synth_midi).play(~link);   // MIDI only
// Pdef(\synth_midi).stopQ(4);

// Pdef(\synth_sc).play(~link);     // SC only
// Pdef(\synth_sc).stopQ(4);

// --- CC ---
// Pdef(\cc_mod_1).play(~link);
// Pdef(\cc_mod_1).stopQ(4);

// --- CLEANUP ---
// Pdef.clear;
