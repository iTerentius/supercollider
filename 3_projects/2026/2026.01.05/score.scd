(
Pdef(\score,
    Pseq([
      Psection([\perc_1_m, \voices], 32, sync: true),
      // SECTION B: The Rest (Transition/Bridge)
      Psection([\perc_1_m, ], { Pdefn(\kit_1_deg_1).source.list.size / 4 }, {
        Pbindef(\kit_1_pbd, \degree, Pdefn(\kit_1_deg_1));
        }, sync: true),
    ], inf)
);
)
Pdef(\score).play(~link);
Pdef(\score).stopQ(4);

// (
// Pbindef(\kit_1_pbd, \degree,  Pn(Pdefn(\kit_1_deg_0), inf));
// )
