// Arrangement — story-level Pdefns + Psection macro structure
// Parts files define vocabulary (words) and phrases (sentences _a/_b/_c).
// This file sequences them into sections and a song arc.
// Re-eval individual voice blocks to update that voice's story.
// Re-eval the Pdef(\score) block to restart the macro arrangement.

///////////////////////////////////////////////////////////////
// STORIES — override \voice_param story Pdefns here
// Default (from parts file): Pn(Pdefn(\voice_param_a), 1)
///////////////////////////////////////////////////////////////

// BD1
(
"parts/bd1.scd".loadRelative;
Pdefn(\bd1_durs, Pseq([
    Pn(Pdefn(\bd1_durs_a), 4),
    Pn(Pdefn(\bd1_durs_b), 2),
    Pn(Pdefn(\bd1_durs_c), 2),
], 1));

Pdefn(\bd1_degs, Pseq([
    Pn(Pdefn(\bd1_degs_a), 4),
    Pn(Pdefn(\bd1_degs_b), 2),
], 1));
)

// SD1
(
"parts/sd1.scd".loadRelative;
Pdefn(\sd1_durs, Pseq([
    Pn(Pdefn(\sd1_durs_a), 4),
    Pn(Pdefn(\sd1_durs_b), 1),
    // Pn(Pdefn(\sd1_durs_c), 1),
], 1));

Pdefn(\sd1_degs, Pseq([
    Pn(Pdefn(\sd1_degs_a), 4),
], 1));
)

// HH1
(
"parts/hh1.scd".loadRelative;
Pdefn(\hh1_durs, Pseq([
    Pn(Pdefn(\hh1_durs_a), 4),
    Pn(Pdefn(\hh1_durs_b), 4),
    Pn(Pdefn(\hh1_durs_c), 2),
], 1));

Pdefn(\hh1_degs, Pseq([
    Pn(Pdefn(\hh1_degs_a), 4),
    Pn(Pdefn(\hh1_degs_b), 2),
], 1));
)

// ROLL
(
Pdefn(\roll_durs, Pseq([
    Pn(Pdefn(\roll_durs_b), 2),    // whole notes — sparse intro
    Pn(Pdefn(\roll_durs_a), 4),    // euclidean
    Pn(Pdefn(\roll_durs_c), 2),    // triplet
], 1));

Pdefn(\roll_degs, Pseq([
    Pn(Pdefn(\roll_degs_a), 4),
    Pn(Pdefn(\roll_degs_b), 2),
], 1));
)

// MS20
(
Pdefn(\ms20_durs, Pseq([
    Pn(Pdefn(\ms20_durs_a), 4),
    Pn(Pdefn(\ms20_durs_b), 2),
], 1));

Pdefn(\ms20_degs, Pseq([
    Pn(Pdefn(\ms20_degs_a), 4),
    Pn(Pdefn(\ms20_degs_b), 2),
    Pn(Pdefn(\ms20_degs_c), 2),
], 1));
)

// THINGA
(
Pdefn(\thingA_durs, Pseq([
    Pn(Pdefn(\thingA_durs_a), 4),
], 1));

Pdefn(\thingA_degs, Pseq([
    Pn(Pdefn(\thingA_degs_a), 4),
    Pn(Pdefn(\thingA_degs_b), 2),
], 1));
)

// NEUTRON
(
Pdefn(\ntron_durs, Pseq([
    Pn(Pdefn(\ntron_durs_a), 4),
    Pn(Pdefn(\ntron_durs_b), 4),
    Pn(Pdefn(\ntron_durs_c), 2),
], 1));

Pdefn(\ntron_degs, Pseq([
    Pn(Pdefn(\ntron_degs_a), 4),
    Pn(Pdefn(\ntron_degs_b), 4),
], 1));
)

// MODEL D
(
Pdefn(\mD_durs, Pseq([
    Pn(Pdefn(\mD_durs_a), 4),
    Pn(Pdefn(\mD_durs_b), 2),
], 1));

Pdefn(\mD_degs, Pseq([
    Pn(Pdefn(\mD_degs_a), 4),
    Pn(Pdefn(\mD_degs_b), 2),
    Pn(Pdefn(\mD_degs_c), 2),
], 1));
)

// BISCUIT
(
Pdefn(\bsct_durs, Pseq([
    Pn(Pdefn(\bsct_durs_a), 4),
    Pn(Pdefn(\bsct_durs_b), 2),
], 1));
)

///////////////////////////////////////////////////////////////
// MACRO ARRANGEMENT — Psection controls which voices are on
// Re-eval this block independently to restart without reloading
///////////////////////////////////////////////////////////////
(
Pdef(\score, Pseq([
    Psection([\bd1, \hh1],                          16, sync: true),
    Psection([\bd1, \sd1, \hh1],                    16, sync: true),
    Psection([\bd1, \sd1, \hh1, \roll],             16, sync: true),
    Psection([\bd1, \sd1, \hh1, \roll, \ms20],      16, sync: true),
    Psection([\bd1, \sd1, \hh1, \roll, \ms20, \neutron, \modelD], 32, sync: true),
], 1));
)
Pdef(\score).play;
