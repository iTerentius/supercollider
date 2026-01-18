// Score - main entry point and arrangement
// Evaluate this file to load the entire project

// Load configuration and library
(
"lib/config.scd".loadRelative;
"lib/harmony.scd".loadRelative;

// Load parts
"parts/kit.scd".loadRelative;
"parts/bass.scd".loadRelative;
"parts/melody.scd".loadRelative;
"parts/pads.scd".loadRelative;

// Load automation
"automation/cc_mods.scd".loadRelative;

// Load bindings last (needs parts defined)
"lib/bindings.scd".loadRelative;
)

// Conductor patterns - these drive the melodic parts
(
// Stack 1: Bass only
Pdef(\v1_stack_1, Ppar([
    Pdef(\bass_1),
], 1));

// Stack 2: Bass + melody 1
Pdef(\v1_stack_2, Ppar([
    Pdef(\bass_1),
    Pdef(\mel_1),
]));

// Stack 3: Full melodic
Pdef(\v1_stack_3, Ppar([
    Pdef(\bass_1),
    Pdef(\mel_1),
    Pdef(\mel_2),
]));

// Main melodic conductor using \phrase type
Pdef(\v1,
    Pbindef(\v1_pbd,
        \type, \phrase,
        \scale, Scale.minor,
        \root, Pn(Pdefn(\root_degs), inf),
        \div, Pseq([4], inf),
        \step1, Pseq([9, 7, 5, 3], inf),
        \legato, 1,
        \dur, 4,
        \instrument, Pseq([
            \v1_stack_1,
            \v1_stack_2,
            \v1_stack_3,
        ], inf),
    )
);

// Pad conductor
Pdef(\v2,
    Pbindef(\v2_pbd,
        \type, \phrase,
        \dur, 4,
        \instrument, Pseq([
            \drone,
            \chords,
        ], inf),
    )
);
)

// Main score arrangement using Psection
(
Pdef(\score,
    Pseq([
        Psection([\perc_1_m, \v1], 32, sync: true),
        Psection([\perc_1_m, \v2], 16, sync: true),
        Psection([\v2], 16, sync: true),
        Psection([\kit_1], 8,
            { Pbindef(\kit_1_pbd, \degree, Pn(Pdefn(\kit_deg_2), inf)); },
            sync: true),
        Psection([\perc_1_m, \v1, \v2], 32,
            { Pbindef(\kit_1_pbd, \degree, Pn(Pdefn(\kit_degs), inf)); },
            sync: true),
    ], inf)
);
)
