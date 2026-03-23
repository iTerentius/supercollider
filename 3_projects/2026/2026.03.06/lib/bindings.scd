// Bindings — LaunchPad Mini + APC40 Mk2
(
// --- Bank 1: voice launchers + FX sends ---
~lpBindB.(1, [1, 1], \bd1,     10);
~lpBindB.(1, [1, 2], \sd1,     15);
~lpBindB.(1, [1, 3], \hh1,     20);
~lpBindB.(1, [1, 4], \roll,    30);
~lpBindB.(1, [1, 5], \ms20,    40);
~lpBindB.(1, [1, 6], \thingA,  50);
~lpBindB.(1, [1, 7], \neutron, 22);
~lpBindB.(1, [1, 8], \modelD,  12);
~lpBindB.(1, [3,  1],  \bCtl, 21);

~lpBindB.(1, [5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~t1, ~r1));
~lpBindB.(1, [6, 1], \bd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\bd1_fx_2, ~t1, ~r2));
~lpBindB.(1, [7, 1], \bd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\bd1_fx_3, ~t1, ~r3));
~lpBindB.(1, [8, 1], \bd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\bd1_fx_4, ~t1, ~r4));

~lpBindB.(1, [5, 2], \sd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\sd1_fx_1, ~t2, ~r1));
~lpBindB.(1, [6, 2], \sd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\sd1_fx_2, ~t2, ~r2));
~lpBindB.(1, [7, 2], \sd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\sd1_fx_3, ~t2, ~r3));
~lpBindB.(1, [8, 2], \sd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\sd1_fx_4, ~t2, ~r4));

~lpBindB.(1, [5, 3], \hh1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\hh1_fx_1, ~t3, ~r1));
~lpBindB.(1, [6, 3], \hh1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\hh1_fx_2, ~t3, ~r2));
~lpBindB.(1, [7, 3], \hh1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\hh1_fx_3, ~t3, ~r3));
~lpBindB.(1, [8, 3], \hh1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\hh1_fx_4, ~t3, ~r4));

~lpBindB.(1, [5, 4], \roll_fx_1, 41, nil, nil, ~makeFxSendTdef.(\roll_fx_1, ~t4, ~r1));
~lpBindB.(1, [6, 4], \roll_fx_2, 81, nil, nil, ~makeFxSendTdef.(\roll_fx_2, ~t4, ~r2));
~lpBindB.(1, [7, 4], \roll_fx_3,  5, nil, nil, ~makeFxSendTdef.(\roll_fx_3, ~t4, ~r3));
~lpBindB.(1, [8, 4], \roll_fx_4, 35, nil, nil, ~makeFxSendTdef.(\roll_fx_4, ~t4, ~r4));

~lpBindB.(1, [5, 5], \ms20_fx_1, 41, nil, nil, ~makeFxSendTdef.(\ms20_fx_1, ~t5, ~r1));
~lpBindB.(1, [6, 5], \ms20_fx_2, 81, nil, nil, ~makeFxSendTdef.(\ms20_fx_2, ~t5, ~r2));
~lpBindB.(1, [7, 5], \ms20_fx_3,  5, nil, nil, ~makeFxSendTdef.(\ms20_fx_3, ~t5, ~r3));
~lpBindB.(1, [8, 5], \ms20_fx_4, 35, nil, nil, ~makeFxSendTdef.(\ms20_fx_4, ~t5, ~r4));

~lpBindB.(1, [5, 6], \thingA_fx_1, 41, nil, nil, ~makeFxSendTdef.(\thingA_fx_1, ~t6, ~r1));
~lpBindB.(1, [6, 6], \thingA_fx_2, 81, nil, nil, ~makeFxSendTdef.(\thingA_fx_2, ~t6, ~r2));
~lpBindB.(1, [7, 6], \thingA_fx_3,  5, nil, nil, ~makeFxSendTdef.(\thingA_fx_3, ~t6, ~r3));
~lpBindB.(1, [8, 6], \thingA_fx_4, 35, nil, nil, ~makeFxSendTdef.(\thingA_fx_4, ~t6, ~r4));

~lpBindB.(1, [5, 7], \ntron_fx_1, 41, nil, nil, ~makeFxSendTdef.(\ntron_fx_1, ~t7, ~r1));
~lpBindB.(1, [6, 7], \ntron_fx_2, 81, nil, nil, ~makeFxSendTdef.(\ntron_fx_2, ~t7, ~r2));
~lpBindB.(1, [7, 7], \ntron_fx_3,  5, nil, nil, ~makeFxSendTdef.(\ntron_fx_3, ~t7, ~r3));
~lpBindB.(1, [8, 7], \ntron_fx_4, 35, nil, nil, ~makeFxSendTdef.(\ntron_fx_4, ~t7, ~r4));

~lpBindB.(1, [5, 8], \mD_fx_1, 41, nil, nil, ~makeFxSendTdef.(\mD_fx_1, ~t8, ~r1));
~lpBindB.(1, [6, 8], \mD_fx_2, 81, nil, nil, ~makeFxSendTdef.(\mD_fx_2, ~t8, ~r2));
~lpBindB.(1, [7, 8], \mD_fx_3,  5, nil, nil, ~makeFxSendTdef.(\mD_fx_3, ~t8, ~r3));
~lpBindB.(1, [8, 8], \mD_fx_4, 35, nil, nil, ~makeFxSendTdef.(\mD_fx_4, ~t8, ~r4));

~lpBindB.(1, [5, 8], \bass_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bass_fx_1, ~t9, ~r1));
~lpBindB.(1, [6, 8], \bass_fx_2, 81, nil, nil, ~makeFxSendTdef.(\bass_fx_2, ~t9, ~r2));
~lpBindB.(1, [7, 8], \bass_fx_3,  5, nil, nil, ~makeFxSendTdef.(\bass_fx_3, ~t9, ~r3));
~lpBindB.(1, [8, 8], \bass_fx_4, 35, nil, nil, ~makeFxSendTdef.(\bass_fx_4, ~t9, ~r4));

~lpBindB.(2, [4, 1], \r3_fx_r1, 41, nil, nil, ~makeFxSendTdef.(\r3_fx_r1, ~r3, ~r1));


// --- APC40 Mk2 pads (bank 1) ---
~apcBindB.(1, 32, \bd1,      4, \orange);
~apcBindB.(1, 33, \sd1,      4, \yellow);
~apcBindB.(1, 34, \hh1,      4, \cyan);
~apcBindB.(1, 35, \roll,     4, \blue);
~apcBindB.(1, 36, \ms20,     4, \purple);
~apcBindB.(1, 37, \thingA,   4, \pink);
~apcBindB.(1, 38, \neutron,  4, \orange);
~apcBindB.(1, 39, \modelD,   4, \yellow);
~apcBindB.(4, 32, \bCtl,   4, \cyan);

~apcBindB.(1, 24, \bd1_fx_1, 1, \blue,   nil, ~fxSendStop[\bd1_fx_1]);
~apcBindB.(1, 16, \bd1_fx_2, 1, \cyan,   nil, ~fxSendStop[\bd1_fx_2]);
~apcBindB.(1, 8,  \bd1_fx_3, 1, \pink,   nil, ~fxSendStop[\bd1_fx_3]);
~apcBindB.(1, 0,  \bd1_fx_4, 1, \purple, nil, ~fxSendStop[\bd1_fx_4]);

~apcBindB.(1, 25, \sd1_fx_1, 1, \blue,   nil, ~fxSendStop[\sd1_fx_1]);
~apcBindB.(1, 17, \sd1_fx_2, 1, \cyan,   nil, ~fxSendStop[\sd1_fx_2]);
~apcBindB.(1, 9,  \sd1_fx_3, 1, \pink,   nil, ~fxSendStop[\sd1_fx_3]);
~apcBindB.(1, 1,  \sd1_fx_4, 1, \purple, nil, ~fxSendStop[\sd1_fx_4]);

~apcBindB.(1, 26, \hh1_fx_1, 1, \blue,   nil, ~fxSendStop[\hh1_fx_1]);
~apcBindB.(1, 18, \hh1_fx_2, 1, \cyan,   nil, ~fxSendStop[\hh1_fx_2]);
~apcBindB.(1, 10, \hh1_fx_3, 1, \pink,   nil, ~fxSendStop[\hh1_fx_3]);
~apcBindB.(1,  2, \hh1_fx_4, 1, \purple, nil, ~fxSendStop[\hh1_fx_4]);

~apcBindB.(1, 27, \roll_fx_1, 1, \blue,   nil, ~fxSendStop[\roll_fx_1]);
~apcBindB.(1, 19, \roll_fx_2, 1, \cyan,   nil, ~fxSendStop[\roll_fx_2]);
~apcBindB.(1, 11, \roll_fx_3, 1, \pink,   nil, ~fxSendStop[\roll_fx_3]);
~apcBindB.(1,  3, \roll_fx_4, 1, \purple, nil, ~fxSendStop[\roll_fx_4]);

~apcBindB.(1, 28, \ms20_fx_1, 1, \blue,   nil, ~fxSendStop[\ms20_fx_1]);
~apcBindB.(1, 20, \ms20_fx_2, 1, \cyan,   nil, ~fxSendStop[\ms20_fx_2]);
~apcBindB.(1, 12, \ms20_fx_3, 1, \pink,   nil, ~fxSendStop[\ms20_fx_3]);
~apcBindB.(1,  4, \ms20_fx_4, 1, \purple, nil, ~fxSendStop[\ms20_fx_4]);

~apcBindB.(1, 29, \thingA_fx_1, 1, \blue,   nil, ~fxSendStop[\thingA_fx_1]);
~apcBindB.(1, 21, \thingA_fx_2, 1, \cyan,   nil, ~fxSendStop[\thingA_fx_2]);
~apcBindB.(1, 13, \thingA_fx_3, 1, \pink,   nil, ~fxSendStop[\thingA_fx_3]);
~apcBindB.(1,  5, \thingA_fx_4, 1, \purple, nil, ~fxSendStop[\thingA_fx_4]);

~apcBindB.(1, 30, \ntron_fx_1, 1, \blue,   nil, ~fxSendStop[\ntron_fx_1]);
~apcBindB.(1, 22, \ntron_fx_2, 1, \cyan,   nil, ~fxSendStop[\ntron_fx_2]);
~apcBindB.(1, 14, \ntron_fx_3, 1, \pink,   nil, ~fxSendStop[\ntron_fx_3]);
~apcBindB.(1,  6, \ntron_fx_4, 1, \purple, nil, ~fxSendStop[\ntron_fx_4]);

~apcBindB.(1, 31, \mD_fx_1, 1, \blue,   nil, ~fxSendStop[\mD_fx_1]);
~apcBindB.(1, 23, \mD_fx_2, 1, \cyan,   nil, ~fxSendStop[\mD_fx_2]);
~apcBindB.(1, 15, \mD_fx_3, 1, \pink,   nil, ~fxSendStop[\mD_fx_3]);
~apcBindB.(1,  7, \mD_fx_4, 1, \purple, nil, ~fxSendStop[\mD_fx_4]);

~apcBindB.(1, 31, \bass_fx_1, 1, \blue,   nil, ~fxSendStop[\bass_fx_1]);
~apcBindB.(1, 23, \bass_fx_2, 1, \cyan,   nil, ~fxSendStop[\bass_fx_2]);
~apcBindB.(1, 15, \bass_fx_3, 1, \pink,   nil, ~fxSendStop[\bass_fx_3]);
~apcBindB.(1,  7, \bass_fx_4, 1, \purple, nil, ~fxSendStop[\bass_fx_4]);

~apcBindB.(4, 24, \r3_fx_r1, 4, nil, nil, ~fxSendStop[\r3_fx_r1]);

~apcBindToggleFnB.(2, 32,
  {
    Pbindef(\pbd_bd1,
        \dur, Pseq([
          Pn(Pdefn(\bd1_durs_b), 2),
          Pn(Pdefn(\bd1_durs_c), 2),
          Pn(Pdefn(\bd1_durs_a), 4)], inf),
        \degree, Pseq([
          Pn(Pdefn(\bd1_degs_a), 4),
          Pn(Pdefn(\bd1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_bd1,
        \dur,    Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\bd1_degs_a), 4)], inf)
    )
  },
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 1, 8,
  {
    Pbindef(\pbd_bd1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_bd1,
        \dur, Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);
~toscPadBindToggleFn.(1, 2, 7,
  {
    Pbindef(\pbd_sd1,
        \dur, Pseq([
          Pn(Pdefn(\sd1_durs_a), 4),
          Pn(Pdefn(\sd1_durs_b), 1),
          // Pn(Pdefn(\sd1_durs_c), 1),
        ], inf),
        \degree, Pseq([
          Pn(Pdefn(\sd1_degs_a), 4),
          Pn(Pdefn(\sd1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_sd1,
        \dur,    Pseq([Pn(Pdefn(\sd1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\sd1_degs_a), 4)], inf)
    )
  },
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 2, 8,
  {
    Pbindef(\pbd_sd1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_sd1,
        \dur, Pseq([Pn(Pdefn(\sd1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);
~toscPadBindToggleFn.(1, 3, 7,
  {
    Pbindef(\pbd_hh1,
        \dur, Pseq([
          Pn(Pdefn(\hh1_durs_a), 4),
          Pn(Pdefn(\hh1_durs_b), 1),
          // Pn(Pdefn(\hh1_durs_c), 1),
        ],  inf), 
        \degree, Pseq([
          Pn(Pdefn(\hh1_degs_a), 4),
          Pn(Pdefn(\hh1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_hh1,
        \dur,    Pseq([Pn(Pdefn(\hh1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\hh1_degs_a), 4)], inf)
    )
  },
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 3, 8,
  {
    Pbindef(\pbd_hh1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_hh1,
        \dur, Pseq([Pn(Pdefn(\hh1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);

// --- TouchOSC Pad Bindings ---

// Bank 1: voice launchers
~toscPadBind.(1, 1, 1, \bd1,     \orange, \green);
~toscPadBind.(1, 2, 1, \sd1,     \yellow, \green);
~toscPadBind.(1, 3, 1, \hh1,     \cyan,   \green);
~toscPadBind.(1, 4, 1, \roll,    \blue,   \green);
~toscPadBind.(1, 5, 1, \ms20,    \purple, \green);
~toscPadBind.(1, 6, 1, \thingA,  \pink,   \green);
~toscPadBind.(1, 7, 1, \neutron, \orange, \green);
~toscPadBind.(1, 8, 1, \modelD,  \yellow, \green);
~toscPadBind.(1, 9, 1, \bass,  \purple, \green);
~toscPadBind.(1, 11, 1, \bCtl,    \cyan,   \green);
// Bank 2: FX sends — bd1+sd1 (col 1), hh1+roll (col 2)
~toscPadBind.(1, 1, 2, \bd1_fx_1, \blue,   \green, ~fxSendStop[\bd1_fx_1], "bd1Fx1");
~toscPadBind.(1, 1, 3, \bd1_fx_2, \cyan,   \green, ~fxSendStop[\bd1_fx_2], "bd1Fx2");
~toscPadBind.(1, 1, 4, \bd1_fx_3, \pink,   \green, ~fxSendStop[\bd1_fx_3], "bd1Fx3");
~toscPadBind.(1, 1, 5, \bd1_fx_4, \purple, \green, ~fxSendStop[\bd1_fx_4], "bd1Fx4");

~toscPadBind.(1, 2, 2, \sd1_fx_1, \blue,   \green, ~fxSendStop[\sd1_fx_1]);
~toscPadBind.(1, 2, 3, \sd1_fx_2, \cyan,   \green, ~fxSendStop[\sd1_fx_2]);
~toscPadBind.(1, 2, 4, \sd1_fx_3, \pink,   \green, ~fxSendStop[\sd1_fx_3]);
~toscPadBind.(1, 2, 5, \sd1_fx_4, \purple, \green, ~fxSendStop[\sd1_fx_4]);

~toscPadBind.(1, 3, 2, \hh1_fx_1,  \blue,   \green, ~fxSendStop[\hh1_fx_1]);
~toscPadBind.(1, 3, 3, \hh1_fx_2,  \cyan,   \green, ~fxSendStop[\hh1_fx_2]);
~toscPadBind.(1, 3, 4, \hh1_fx_3,  \pink,   \green, ~fxSendStop[\hh1_fx_3]);
~toscPadBind.(1, 3, 5, \hh1_fx_4,  \purple, \green, ~fxSendStop[\hh1_fx_4]);

~toscPadBind.(1, 4, 2, \roll_fx_1, \blue,   \green, ~fxSendStop[\roll_fx_1]);
~toscPadBind.(1, 4, 3, \roll_fx_2, \cyan,   \green, ~fxSendStop[\roll_fx_2]);
~toscPadBind.(1, 4, 4, \roll_fx_3, \pink,   \green, ~fxSendStop[\roll_fx_3]);
~toscPadBind.(1, 4, 5, \roll_fx_4, \purple, \green, ~fxSendStop[\roll_fx_4]);

~toscPadBind.(1, 11, 2, \r3_fx_r1,  \blue,   \green, ~fxSendStop[\r3_fx_r1]);

// Bank 3: FX sends — ms20+thingA (col 1), ntron+mD (col 2)
~toscPadBind.(1, 5, 2, \ms20_fx_1,   \blue,   \green, ~fxSendStop[\ms20_fx_1]);
~toscPadBind.(1, 5, 3, \ms20_fx_2,   \cyan,   \green, ~fxSendStop[\ms20_fx_2]);
~toscPadBind.(1, 5, 4, \ms20_fx_3,   \pink,   \green, ~fxSendStop[\ms20_fx_3]);
~toscPadBind.(1, 5, 5, \ms20_fx_4,   \purple, \green, ~fxSendStop[\ms20_fx_4]);

~toscPadBind.(1, 6, 2, \thingA_fx_1, \blue,   \green, ~fxSendStop[\thingA_fx_1]);
~toscPadBind.(1, 6, 3, \thingA_fx_2, \cyan,   \green, ~fxSendStop[\thingA_fx_2]);
~toscPadBind.(1, 6, 4, \thingA_fx_3, \pink,   \green, ~fxSendStop[\thingA_fx_3]);
~toscPadBind.(1, 6, 5, \thingA_fx_4, \purple, \green, ~fxSendStop[\thingA_fx_4]);

~toscPadBind.(1, 7, 2, \ntron_fx_1, \blue,   \green, ~fxSendStop[\ntron_fx_1]);
~toscPadBind.(1, 7, 3, \ntron_fx_2, \cyan,   \green, ~fxSendStop[\ntron_fx_2]);
~toscPadBind.(1, 7, 4, \ntron_fx_3, \pink,   \green, ~fxSendStop[\ntron_fx_3]);
~toscPadBind.(1, 7, 5, \ntron_fx_4, \purple, \green, ~fxSendStop[\ntron_fx_4]);

~toscPadBind.(1, 8, 2, \mD_fx_1,    \blue,   \green, ~fxSendStop[\mD_fx_1]);
~toscPadBind.(1, 8, 3, \mD_fx_2,    \cyan,   \green, ~fxSendStop[\mD_fx_2]);
~toscPadBind.(1, 8, 4, \mD_fx_3,    \pink,   \green, ~fxSendStop[\mD_fx_3]);
~toscPadBind.(1, 8, 5, \mD_fx_4,    \purple, \green, ~fxSendStop[\mD_fx_4]);

~toscPadBind.(1, 9, 2, \bass_fx_1,    \blue,   \green, ~fxSendStop[\bass_fx_1]);
~toscPadBind.(1, 9, 3, \bass_fx_2,    \cyan,   \green, ~fxSendStop[\bass_fx_2]);
~toscPadBind.(1, 9, 4, \bass_fx_3,    \pink,   \green, ~fxSendStop[\bass_fx_3]);
~toscPadBind.(1, 9, 5, \bass_fx_4,    \purple, \green, ~fxSendStop[\bass_fx_4]);

// Toggles
~toscPadBindToggleFn.(1, 1, 7,
  {
    Pbindef(\pbd_bd1,
        \dur, Pseq([
          Pn(Pdefn(\bd1_durs_b), 2),
          Pn(Pdefn(\bd1_durs_c), 2),
          Pn(Pdefn(\bd1_durs_a), 4)], inf),
        \degree, Pseq([
          Pn(Pdefn(\bd1_degs_a), 4),
          Pn(Pdefn(\bd1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_bd1,
        \dur,    Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\bd1_degs_a), 4)], inf)
    )
  },
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 1, 8,
  {
    Pbindef(\pbd_bd1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_bd1,
        \dur, Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);
~toscPadBindToggleFn.(1, 1, 7,  
  {
    Pbindef(\pbd_bd1,
        \dur, Pseq([
          Pn(Pdefn(\bd1_durs_b), 2),
          Pn(Pdefn(\bd1_durs_c), 2),
          Pn(Pdefn(\bd1_durs_a), 4)], inf),
        \degree, Pseq([
          Pn(Pdefn(\bd1_degs_a), 4),
          Pn(Pdefn(\bd1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_bd1,
        \dur,    Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\bd1_degs_a), 4)], inf)
    )
  },
  \green, \blue,  "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 1, 8,
  {
    Pbindef(\pbd_bd1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_bd1,
        \dur, Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);
~toscPadBindToggleFn.(1, 2, 7,
  {
    Pbindef(\pbd_sd1,
        \dur, Pseq([
          Pn(Pdefn(\sd1_durs_a), 4),
          Pn(Pdefn(\sd1_durs_b), 1),
          // Pn(Pdefn(\sd1_durs_c), 1),
        ], inf),
        \degree, Pseq([
          Pn(Pdefn(\sd1_degs_a), 4),
          Pn(Pdefn(\sd1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_sd1,
        \dur,    Pseq([Pn(Pdefn(\sd1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\sd1_degs_a), 4)], inf)
    )
  },
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 2, 8,
  {
    Pbindef(\pbd_sd1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_sd1,
        \dur, Pseq([Pn(Pdefn(\sd1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);
~toscPadBindToggleFn.(1, 3, 7,
  {
    Pbindef(\pbd_hh1,
        \dur, Pseq([
          Pn(Pdefn(\hh1_durs_a), 4),
          Pn(Pdefn(\hh1_durs_b), 1),
          // Pn(Pdefn(\hh1_durs_c), 1),
        ],  inf), 
        \degree, Pseq([
          Pn(Pdefn(\hh1_degs_a), 4),
          Pn(Pdefn(\hh1_degs_b), 2)], inf)
    )
  },
  {
    Pbindef(\pbd_hh1,
        \dur,    Pseq([Pn(Pdefn(\hh1_durs_a), 4)], inf),
        \degree, Pseq([Pn(Pdefn(\hh1_degs_a), 4)], inf)
    )
  },
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 3, 8,
  {
    Pbindef(\pbd_hh1,
        \dur, Pn(Pseg([2, 1/2, 1/4], [4, 8], \lin, inf))
    )
  },
  // fnB — restore default
  {
    Pbindef(\pbd_hh1,
        \dur, Pseq([Pn(Pdefn(\hh1_durs_a), 4)], inf)
    )
  },
  \green, \blue, "phrB", "phr0"
);

~toscPadPaintAll.();

// Refresh APC40 LEDs — clear stale pulse states then repaint
if(~apcOut.notNil) {
    ~apcPadMap.keysDo { |n| ~apcPadLEDch.(n, 0, ~apcCfg[\playMode] ? 9) };
    AppClock.sched(0.05, { ~apcRepaintAll.(); nil });
};
)
