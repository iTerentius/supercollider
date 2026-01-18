// Score - evaluate this to load project
(
"lib/config.scd".loadRelative;
"lib/harmony.scd".loadRelative;
"parts/kit.scd".loadRelative;
"parts/bass.scd".loadRelative;
"parts/melody.scd".loadRelative;
"parts/pad.scd".loadRelative;
"parts/synth.scd".loadRelative;
"automation/cc_mods.scd".loadRelative;
"lib/bindings.scd".loadRelative;
)

// Conductor
(
Pdef(\v1,
    Pbindef(\v1_pbd,
        \type, \phrase,
        \scale, Scale.minor,
        \root, Pn(Pdefn(\root_degs), inf),
        \dur, 4,
        \instrument, Pseq([
            \bass,
            \mel,
            \synth_layer,  // composite: MIDI + SC
        ], inf),
    )
);
)

// Arrangement
(
Pdef(\score,
    Pseq([
        Psection([\perc], 8, sync: true),
        Psection([\perc, \v1], 16, sync: true),
    ], inf)
);
)
