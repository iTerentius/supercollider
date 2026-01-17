// evals
(
~link.tempo = 110/60;
"kit_1.scd".loadRelative;
"melodic.scd".loadRelative;

Pdef(\score,
    Pseq([
      Psection([\perc_1_m, \v1], 32, sync: true),  
      Psection([\perc_1_m, \v2], 16, sync: true),
      Psection([\v2], 16, sync: true),
      Psection([\kit_1_pbd, ], 8, 
      { Pbindef(\kit_1_pbd, \degree, Pn(Pdefn(\kit_1_deg_2),  inf)); },
      sync: true),

      Psection([\perc_1_m, \v1, \v2], 32, 
      { Pbindef(\kit_1_pbd,   \degree, Pn(Pdefn(\kit_1_degs),  inf)); },  
      sync: true),

    ], inf)
);
)
Pdef(\score).play(~link);
Pdef(\score).stopQ(4);

// (
// Pbindef(\kit_1_pbd, \degree,  Pn(Pdefn(\kit_1_deg_0), inf));
// )
Pdefn(\kit_1_degs).source.list.size 

Pdef(\perc_1_m).play(~link);
Pdef(\perc_1_m).stop;
Pbindef(\kit_1_pbd, \degree, Pdefn(\kit_1_deg_2));
