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
Pdef(\v1_stack_0, Ppar([
  Pdef(\bass),  
  // Pdef(\mel), 
  // Pdef(\pad), 
],  inf));

Pdef(\v1_stack_1, Ppar([
  Pdef(\bass),  
  // Pdef(\mel), 
  Pdef(\pad), 
],  inf));

Pdef(\v1_stack_2, Ppar([
  Pdef(\bass),  
  Pdef(\mel), 
  // Pdef(\pad), 
],  inf));

Pdef(\v1,
    Pbindef(\v1_pbd,
        \type, \phrase,
        \scale, Scale.minor,
        \root, Pn(Pdefn(\root_degs), inf),
        \dur, 2,
        \instrument, Pseq([
          \v1_stack_0,  
          // \v1_stack_1,  
          \v1_stack_2,  
        ], inf),
    )
);
)

// Arrangement
(
Pdef(\score,
    Pseq([
        Psection([\perc], 16, sync: true),
        // Psection([\perc, \v1], 32, sync: true),
    ], inf)
);
)
Pdef(\score).play(~link);
Pdef(\score).stopQ(4);
