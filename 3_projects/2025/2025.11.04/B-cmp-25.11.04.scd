
// Pattern composition
(
~groove_kit1 = Ppar([~groove_bd1, ~groove_sd1, ~groove_hh1]);
~fill_kit1 = Ppar([~fill_bd1, ~fill_sd1, ~fill_hh1]);

Pdef(\kit_1, 
  Pseq([
    Pfindur(14, ~groove_kit1),
    Pfindur(2, ~fill_kit1 ),
    Pfindur(12, Ppar([Pbind(\type, \rest, \dur, 1), ~groove_bd1, ~groove_hh1], inf)),
    Pfindur(2, ~fill_kit1 ),
  ], inf);
);
~lcxlBindPdef.(\b2_s1_p, \kit_1);
)
Pdef(\kit_1).play;
Pdef(\kit_1).stop;
