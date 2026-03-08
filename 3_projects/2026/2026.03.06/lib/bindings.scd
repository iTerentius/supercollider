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

~lpBindB.(1, [5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1));
~lpBindB.(1, [6, 1], \bd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\bd1_fx_2, ~pbd1, ~r2));
~lpBindB.(1, [7, 1], \bd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\bd1_fx_3, ~pbd1, ~r3));
~lpBindB.(1, [8, 1], \bd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\bd1_fx_4, ~pbd1, ~r4));

~lpBindB.(1, [5, 2], \sd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\sd1_fx_1, ~psd1, ~r1));
~lpBindB.(1, [6, 2], \sd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\sd1_fx_2, ~psd1, ~r2));
~lpBindB.(1, [7, 2], \sd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\sd1_fx_3, ~psd1, ~r3));
~lpBindB.(1, [8, 2], \sd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\sd1_fx_4, ~psd1, ~r4));

~lpBindB.(1, [5, 3], \hh1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\hh1_fx_1, ~phh1, ~r1));
~lpBindB.(1, [6, 3], \hh1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\hh1_fx_2, ~phh1, ~r2));
~lpBindB.(1, [7, 3], \hh1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\hh1_fx_3, ~phh1, ~r3));
~lpBindB.(1, [8, 3], \hh1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\hh1_fx_4, ~phh1, ~r4));

~lpBindB.(1, [5, 4], \roll_fx_1, 41, nil, nil, ~makeFxSendTdef.(\roll_fx_1, ~t2, ~r1));
~lpBindB.(1, [6, 4], \roll_fx_2, 81, nil, nil, ~makeFxSendTdef.(\roll_fx_2, ~t2, ~r2));
~lpBindB.(1, [7, 4], \roll_fx_3,  5, nil, nil, ~makeFxSendTdef.(\roll_fx_3, ~t2, ~r3));
~lpBindB.(1, [8, 4], \roll_fx_4, 35, nil, nil, ~makeFxSendTdef.(\roll_fx_4, ~t2, ~r4));

~lpBindB.(1, [5, 6], \thingA_fx_1, 41, nil, nil, ~makeFxSendTdef.(\thingA_fx_1, ~t3, ~r1));
~lpBindB.(1, [6, 6], \thingA_fx_2, 81, nil, nil, ~makeFxSendTdef.(\thingA_fx_2, ~t3, ~r2));
~lpBindB.(1, [7, 6], \thingA_fx_3,  5, nil, nil, ~makeFxSendTdef.(\thingA_fx_3, ~t3, ~r3));
~lpBindB.(1, [8, 6], \thingA_fx_4, 35, nil, nil, ~makeFxSendTdef.(\thingA_fx_4, ~t3, ~r4));

~lpBindB.(1, [5, 7], \ntron_fx_1, 41, nil, nil, ~makeFxSendTdef.(\ntron_fx_1, ~t5, ~r1));
~lpBindB.(1, [6, 7], \ntron_fx_2, 81, nil, nil, ~makeFxSendTdef.(\ntron_fx_2, ~t5, ~r2));
~lpBindB.(1, [7, 7], \ntron_fx_3,  5, nil, nil, ~makeFxSendTdef.(\ntron_fx_3, ~t5, ~r3));
~lpBindB.(1, [8, 7], \ntron_fx_4, 35, nil, nil, ~makeFxSendTdef.(\ntron_fx_4, ~t5, ~r4));

~lpBindB.(1, [5, 8], \mD_fx_1, 41, nil, nil, ~makeFxSendTdef.(\mD_fx_1, ~t6, ~r1));
~lpBindB.(1, [6, 8], \mD_fx_2, 81, nil, nil, ~makeFxSendTdef.(\mD_fx_2, ~t6, ~r2));
~lpBindB.(1, [7, 8], \mD_fx_3,  5, nil, nil, ~makeFxSendTdef.(\mD_fx_3, ~t6, ~r3));
~lpBindB.(1, [8, 8], \mD_fx_4, 35, nil, nil, ~makeFxSendTdef.(\mD_fx_4, ~t6, ~r4));

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

~apcBindB.(1, 24, \bd1_fx_1, 1, \blue,   nil, ~fxSendStop[\bd1_fx_1]);
~apcBindB.(1, 16, \bd1_fx_2, 1, \cyan,   nil, ~fxSendStop[\bd1_fx_2]);
~apcBindB.(1, 8,  \bd1_fx_3, 1, \pink,   nil, ~fxSendStop[\bd1_fx_3]);
~apcBindB.(1, 0,  \bd1_fx_4, 1, \purple, nil, ~fxSendStop[\bd1_fx_4]);
)
