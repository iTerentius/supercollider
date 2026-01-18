// Scratch - play/stop commands for live coding and testing
// Keep your experimental commands here to avoid cluttering main files

// --- TEMPO ---
// ~link.tempo = 110/60;
// ~link.tempo = 120/60;

// --- FULL SCORE ---
// Pdef(\score).play(~link);
// Pdef(\score).stopQ(4);

// --- INDIVIDUAL PARTS ---
// Pdef(\perc_1_m).play(~link);
// Pdef(\perc_1_m).stopQ(4);

// Pdef(\v1).play(~link);
// Pdef(\v1).stopQ(8);

// Pdef(\v2).play(~link);
// Pdef(\v2).stopQ(4);

// --- DIRECT PART ACCESS ---
// Pdef(\bass_1).play(~link);
// Pdef(\bass_1).stopQ(4);

// Pdef(\mel_1).play(~link);
// Pdef(\mel_1).stopQ(4);

// Pdef(\mel_2).play(~link);
// Pdef(\mel_2).stopQ(4);

// Pdef(\drone).play(~link);
// Pdef(\drone).stopQ(4);

// Pdef(\chords).play(~link);
// Pdef(\chords).stopQ(4);

// --- CC MODULATORS ---
// Pdef(\cc_mod_1).play(~link);
// Pdef(\cc_mod_1).stopQ(4);

// Pdef(\cc_mod_2).play(~link);
// Pdef(\cc_mod_2).stopQ(4);

// --- MANUAL CC ---
// ~mOut.control(15, 20, 127);
// ~mOut.control(15, 21, 127);

// --- LIVE TWEAKS ---
// Pbindef(\bass_1_pbd, \degree, Pseq((0..7), inf));
// Pbindef(\bass_1_pbd, \degree, 0);
// Pbindef(\kit_1_pbd, \degree, Pn(Pdefn(\kit_deg_2), inf));

// --- CLEANUP ---
// Pdef.clear;
