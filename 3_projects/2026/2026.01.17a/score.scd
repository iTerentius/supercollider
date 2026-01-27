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
  // Pdef(\mel), 
  // Pdef(\pad), 
],  inf));

Pdef(\v1,
    Pbindef(\v1_pbd,
        \type, \phrase,
        \scale, Scale.minor,
        \root, Pn(Pdefn(\root_degs), inf),
        \dur, 4,
        \instrument, Pseq([
          \v1_stack_0,  
          \v1_stack_1,  
          \v1_stack_2,  
        ], inf),
    )
);
)

// Arrangement
(
Pdef(\score,
    Pseq([
        // Psection([\perc], 64, sync: true),
        Psection([\perc, \v1], 64, sync: true),
    ], inf)
);
)
Pdef(\score).play(~link);
Pdef(\score).stopQ(4);
Pdef(\score).clear;

(
Tdef(\conductor, {
    loop {
        Pbindef(\perc_pbd, \degree, Pn(Plazy({ Pdefn(\kit_deg_0) }), inf), \dur, Pn(Plazy({ Pdefn(\kit_dur_1) }), inf));
        32.wait;
        Pbindef(\perc_pbd, \degree, Pn(Plazy({ Pdefn(\kit_deg_0a) }), inf), \dur, Pn(Plazy({ Pdefn(\kit_dur_2) }), inf));
        32.wait;
        Pbindef(\perc_pbd, \degree, Pn(Plazy({ Pdefn(\kit_deg_0b) }), inf), \dur, Pn(Plazy({ Pdefn(\kit_dur_0) }), inf));
        32.wait;
    }
});
)
Tdef(\conductor).play(~link); Pdef(\score).play(~link);
Tdef(\conductor).play(~link);
Tdef(\conductor).stop; Pdef(\score).stopQ(4);
Tdef(\conductor).clear;
Pbindef(\perc_pbd).clear;
Pbindef(\bass).clear;

  (                                                                       
  Pdef(\conductor, Pbind(                                                 
    \type, \rest,                                                         
    \dur, 16,                                                             
    \change, Pseq([                                                       
      Pfunc({ Pbindef(\perc_pbd, \degree, Pn(Plazy({ Pdefn(\kit_deg_0) }),
   inf), \dur, Pn(Plazy({ Pdefn(\kit_dur_1) }), inf)); nil }),            
      Pfunc({ Pbindef(\perc_pbd, \degree, Pn(Plazy({ Pdefn(\kit_deg_0a)   
  }), inf), \dur, Pn(Plazy({ Pdefn(\kit_dur_1) }), inf)); nil }),         
      Pfunc({ Pbindef(\perc_pbd, \degree, Pn(Plazy({ Pdefn(\kit_deg_0b)   
  }), inf), \dur, Pn(Plazy({ Pdefn(\kit_dur_0) }), inf)); nil }),         
    ], inf),                                                              
  ));                                                                     
  )                                                                       
  Pdef(\conductor).play(~link);                                           
