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
~lpBindB.(1, [2, 1], \bass,  12);
~lpBindB.(4, [1,  1],  \bCtl, 21);
~lpBindB.(4, [2,  1],  \freeze, 30);

~lpBindB.(2, [1, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~t1, ~r1));
~lpBindB.(2, [2, 1], \bd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\bd1_fx_2, ~t1, ~r2));
~lpBindB.(2, [3, 1], \bd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\bd1_fx_3, ~t1, ~r3));
~lpBindB.(2, [4, 1], \bd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\bd1_fx_4, ~t1, ~r4));
~lpBindB.(2, [5, 1], \bd1_fx_5, 10, nil, nil, ~makeFxSendTdef.(\bd1_fx_5, ~t1, ~r5));

~lpBindB.(2, [1, 2], \sd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\sd1_fx_1, ~t2, ~r1));
~lpBindB.(2, [2, 2], \sd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\sd1_fx_2, ~t2, ~r2));
~lpBindB.(2, [3, 2], \sd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\sd1_fx_3, ~t2, ~r3));
~lpBindB.(2, [4, 2], \sd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\sd1_fx_4, ~t2, ~r4));
~lpBindB.(2, [5, 2], \sd1_fx_5, 10, nil, nil, ~makeFxSendTdef.(\sd1_fx_5, ~t2, ~r5));

~lpBindB.(2, [1, 3], \hh1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\hh1_fx_1, ~t3, ~r1));
~lpBindB.(2, [2, 3], \hh1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\hh1_fx_2, ~t3, ~r2));
~lpBindB.(2, [3, 3], \hh1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\hh1_fx_3, ~t3, ~r3));
~lpBindB.(2, [4, 3], \hh1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\hh1_fx_4, ~t3, ~r4));
~lpBindB.(2, [5, 3], \hh1_fx_5, 10, nil, nil, ~makeFxSendTdef.(\hh1_fx_5, ~t3, ~r5));

~lpBindB.(2, [1, 4], \roll_fx_1, 41, nil, nil, ~makeFxSendTdef.(\roll_fx_1, ~t4, ~r1));
~lpBindB.(2, [2, 4], \roll_fx_2, 81, nil, nil, ~makeFxSendTdef.(\roll_fx_2, ~t4, ~r2));
~lpBindB.(2, [3, 4], \roll_fx_3,  5, nil, nil, ~makeFxSendTdef.(\roll_fx_3, ~t4, ~r3));
~lpBindB.(2, [4, 4], \roll_fx_4, 35, nil, nil, ~makeFxSendTdef.(\roll_fx_4, ~t4, ~r4));
~lpBindB.(2, [5, 4], \roll_fx_5, 10, nil, nil, ~makeFxSendTdef.(\roll_fx_5, ~t4, ~r5));

~lpBindB.(2, [1, 5], \ms20_fx_1, 41, nil, nil, ~makeFxSendTdef.(\ms20_fx_1, ~t5, ~r1));
~lpBindB.(2, [2, 5], \ms20_fx_2, 81, nil, nil, ~makeFxSendTdef.(\ms20_fx_2, ~t5, ~r2));
~lpBindB.(2, [3, 5], \ms20_fx_3,  5, nil, nil, ~makeFxSendTdef.(\ms20_fx_3, ~t5, ~r3));
~lpBindB.(2, [4, 5], \ms20_fx_4, 35, nil, nil, ~makeFxSendTdef.(\ms20_fx_4, ~t5, ~r4));
~lpBindB.(2, [5, 5], \ms20_fx_5, 10, nil, nil, ~makeFxSendTdef.(\ms20_fx_5, ~t5, ~r5));

~lpBindB.(2, [1, 6], \thingA_fx_1, 41, nil, nil, ~makeFxSendTdef.(\thingA_fx_1, ~t6, ~r1));
~lpBindB.(2, [2, 6], \thingA_fx_2, 81, nil, nil, ~makeFxSendTdef.(\thingA_fx_2, ~t6, ~r2));
~lpBindB.(2, [3, 6], \thingA_fx_3,  5, nil, nil, ~makeFxSendTdef.(\thingA_fx_3, ~t6, ~r3));
~lpBindB.(2, [4, 6], \thingA_fx_4, 35, nil, nil, ~makeFxSendTdef.(\thingA_fx_4, ~t6, ~r4));
~lpBindB.(2, [5, 6], \thingA_fx_5, 10, nil, nil, ~makeFxSendTdef.(\thingA_fx_5, ~t6, ~r5));

~lpBindB.(2, [1, 7], \ntron_fx_1, 41, nil, nil, ~makeFxSendTdef.(\ntron_fx_1, ~t7, ~r1));
~lpBindB.(2, [2, 7], \ntron_fx_2, 81, nil, nil, ~makeFxSendTdef.(\ntron_fx_2, ~t7, ~r2));
~lpBindB.(2, [3, 7], \ntron_fx_3,  5, nil, nil, ~makeFxSendTdef.(\ntron_fx_3, ~t7, ~r3));
~lpBindB.(2, [4, 7], \ntron_fx_4, 35, nil, nil, ~makeFxSendTdef.(\ntron_fx_4, ~t7, ~r4));
~lpBindB.(2, [5, 7], \ntron_fx_5, 10, nil, nil, ~makeFxSendTdef.(\ntron_fx_5, ~t7, ~r5));

~lpBindB.(2, [1, 8], \mD_fx_1, 41, nil, nil, ~makeFxSendTdef.(\mD_fx_1, ~t8, ~r1));
~lpBindB.(2, [2, 8], \mD_fx_2, 81, nil, nil, ~makeFxSendTdef.(\mD_fx_2, ~t8, ~r2));
~lpBindB.(2, [3, 8], \mD_fx_3,  5, nil, nil, ~makeFxSendTdef.(\mD_fx_3, ~t8, ~r3));
~lpBindB.(2, [4, 8], \mD_fx_4, 35, nil, nil, ~makeFxSendTdef.(\mD_fx_4, ~t8, ~r4));
~lpBindB.(2, [5, 8], \mD_fx_5, 10, nil, nil, ~makeFxSendTdef.(\mD_fx_5, ~t8, ~r5));

~lpBindB.(3, [1, 1], \bass_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bass_fx_1, ~t9, ~r1));
~lpBindB.(3, [2, 1], \bass_fx_2, 81, nil, nil, ~makeFxSendTdef.(\bass_fx_2, ~t9, ~r2));
~lpBindB.(3, [3, 1], \bass_fx_3,  5, nil, nil, ~makeFxSendTdef.(\bass_fx_3, ~t9, ~r3));
~lpBindB.(3, [4, 1], \bass_fx_4, 35, nil, nil, ~makeFxSendTdef.(\bass_fx_4, ~t9, ~r4));
~lpBindB.(3, [5, 1], \bass_fx_5, 10, nil, nil, ~makeFxSendTdef.(\bass_fx_5, ~t9, ~r5));

~lpBindB.(4, [2, 1], \r3_fx_r1, 41, nil, nil, ~makeFxSendTdef.(\r3_fx_r1, ~r3, ~r1));


// --- APC40 Mk2 pads (bank 1) ---
~apcBindB.(1, 32, \bd1,      4, \orange);
~apcBindB.(1, 33, \sd1,      4, \yellow);
~apcBindB.(1, 34, \hh1,      4, \cyan);
~apcBindB.(1, 35, \roll,     4, \blue);
~apcBindB.(1, 36, \ms20,     4, \purple);
~apcBindB.(1, 37, \thingA,   4, \pink);
~apcBindB.(1, 38, \neutron,  4, \orange);
~apcBindB.(1, 39, \modelD,   4, \yellow);
~apcBindB.(2, 32, \bass,   4, \green);
~apcBindB.(4, 32, \bCtl,   4, \cyan);
~apcBindB.(4, 33, \freeze,   4, \blue);
// --- Grid Layout ---
// 5 rows x 8 columns of clip launch pads (notes 0-39)
// Row 0 (top):    32,33,34,35,36,37,38,39
// Row 1:          24,25,26,27,28,29,30,31
// Row 2:          16,17,18,19,20,21,22,23
// Row 3:           8, 9,10,11,12,13,14,15
// Row 4 (bottom):  0, 1, 2, 3, 4, 5, 6, 7

~apcBindB.(2, 32, \bd1_fx_1, 1, \blue,   nil, ~fxSendStop[\bd1_fx_1]);
~apcBindB.(2, 24, \bd1_fx_2, 1, \cyan,   nil, ~fxSendStop[\bd1_fx_2]);
~apcBindB.(2, 16,  \bd1_fx_3, 1, \pink,   nil, ~fxSendStop[\bd1_fx_3]);
~apcBindB.(2, 8,  \bd1_fx_4, 1, \purple, nil, ~fxSendStop[\bd1_fx_4]);
~apcBindB.(2, 0,  \bd1_fx_5, 1, \orange, nil, ~fxSendStop[\bd1_fx_5]);

~apcBindB.(2, 33, \sd1_fx_1, 1, \blue,   nil, ~fxSendStop[\sd1_fx_1]);
~apcBindB.(2, 25, \sd1_fx_2, 1, \cyan,   nil, ~fxSendStop[\sd1_fx_2]);
~apcBindB.(2, 17,  \sd1_fx_3, 1, \pink,   nil, ~fxSendStop[\sd1_fx_3]);
~apcBindB.(2, 9,  \sd1_fx_4, 1, \purple, nil, ~fxSendStop[\sd1_fx_4]);
~apcBindB.(2, 1,  \sd1_fx_5, 1, \orange, nil, ~fxSendStop[\sd1_fx_5]);

~apcBindB.(2, 34, \hh1_fx_1, 1, \blue,   nil, ~fxSendStop[\hh1_fx_1]);
~apcBindB.(2, 26, \hh1_fx_2, 1, \cyan,   nil, ~fxSendStop[\hh1_fx_2]);
~apcBindB.(2, 18, \hh1_fx_3, 1, \pink,   nil, ~fxSendStop[\hh1_fx_3]);
~apcBindB.(2, 10, \hh1_fx_4, 1, \purple, nil, ~fxSendStop[\hh1_fx_4]);
~apcBindB.(2, 2,  \hh1_fx_5, 1, \orange, nil, ~fxSendStop[\hh1_fx_5]);

~apcBindB.(2, 35, \roll_fx_1, 1, \blue,   nil, ~fxSendStop[\roll_fx_1]);
~apcBindB.(2, 27, \roll_fx_2, 1, \cyan,   nil, ~fxSendStop[\roll_fx_2]);
~apcBindB.(2, 19, \roll_fx_3, 1, \pink,   nil, ~fxSendStop[\roll_fx_3]);
~apcBindB.(2, 11, \roll_fx_4, 1, \purple, nil, ~fxSendStop[\roll_fx_4]);
~apcBindB.(2, 3,  \roll_fx_5, 1, \orange, nil, ~fxSendStop[\roll_fx_5]);

~apcBindB.(2, 36, \ms20_fx_1, 1, \blue,   nil, ~fxSendStop[\ms20_fx_1]);
~apcBindB.(2, 28, \ms20_fx_2, 1, \cyan,   nil, ~fxSendStop[\ms20_fx_2]);
~apcBindB.(2, 20, \ms20_fx_3, 1, \pink,   nil, ~fxSendStop[\ms20_fx_3]);
~apcBindB.(2, 12, \ms20_fx_4, 1, \purple, nil, ~fxSendStop[\ms20_fx_4]);
~apcBindB.(2, 4,  \ms20_fx_5, 1, \orange, nil, ~fxSendStop[\ms20_fx_5]);

~apcBindB.(2, 37, \thingA_fx_1, 1, \blue,   nil, ~fxSendStop[\thingA_fx_1]);
~apcBindB.(2, 29, \thingA_fx_2, 1, \cyan,   nil, ~fxSendStop[\thingA_fx_2]);
~apcBindB.(2, 21, \thingA_fx_3, 1, \pink,   nil, ~fxSendStop[\thingA_fx_3]);
~apcBindB.(2, 13, \thingA_fx_4, 1, \purple, nil, ~fxSendStop[\thingA_fx_4]);
~apcBindB.(2, 5,  \thingA_fx_5, 1, \orange, nil, ~fxSendStop[\thingA_fx_5]);

~apcBindB.(2, 38, \ntron_fx_1, 1, \blue,   nil, ~fxSendStop[\ntron_fx_1]);
~apcBindB.(2, 30, \ntron_fx_2, 1, \cyan,   nil, ~fxSendStop[\ntron_fx_2]);
~apcBindB.(2, 22, \ntron_fx_3, 1, \pink,   nil, ~fxSendStop[\ntron_fx_3]);
~apcBindB.(2, 14, \ntron_fx_4, 1, \purple, nil, ~fxSendStop[\ntron_fx_4]);
~apcBindB.(2, 6,  \ntron_fx_5, 1, \orange, nil, ~fxSendStop[\ntron_fx_5]);

~apcBindB.(2, 39, \mD_fx_1, 1, \blue,   nil, ~fxSendStop[\mD_fx_1]);
~apcBindB.(2, 31, \mD_fx_2, 1, \cyan,   nil, ~fxSendStop[\mD_fx_2]);
~apcBindB.(2, 24, \mD_fx_3, 1, \pink,   nil, ~fxSendStop[\mD_fx_3]);
~apcBindB.(2, 16, \mD_fx_4, 1, \purple, nil, ~fxSendStop[\mD_fx_4]);
~apcBindB.(2, 7,  \mD_fx_5, 1, \orange, nil, ~fxSendStop[\mD_fx_5]);

~apcBindB.(3, 32, \bass_fx_1, 1, \blue,   nil, ~fxSendStop[\bass_fx_1]);
~apcBindB.(3, 24, \bass_fx_2, 1, \cyan,   nil, ~fxSendStop[\bass_fx_2]);
~apcBindB.(3, 15, \bass_fx_3, 1, \pink,   nil, ~fxSendStop[\bass_fx_3]);
~apcBindB.(3,  8, \bass_fx_4, 1, \purple, nil, ~fxSendStop[\bass_fx_4]);
~apcBindB.(3, 0,  \bass_fx_5, 1, \orange, nil, ~fxSendStop[\bass_fx_5]);

~apcBindB.(4, 24, \r3_fx_r1, 4, nil, nil, ~fxSendStop[\r3_fx_r1]);

// BD1
~bd1_phrA_fnA = {                                                       
  Pbindef(\pbd_bd1,                                                   
    \dur, Pseq([                                                    
        Pn(Pdefn(\bd1_durs_b), 2),                                  
        Pn(Pdefn(\bd1_durs_c), 2),                                  
        Pn(Pdefn(\bd1_durs_a), 4)
      ], inf),                           
    \degree, Pseq([                                                 
        Pn(Pdefn(\bd1_degs_a), 4),                                  
        Pn(Pdefn(\bd1_degs_b), 2)
      ], inf))                           
};
~bd1_phrA_fnB = {                                                       
  Pbindef(\pbd_bd1,                                                   
    \dur,    Pseq([Pn(Pdefn(\bd1_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\bd1_degs_a), 4)], inf))                
};                                                                      

// SD1
~sd1_phrA_fnA = {                                                       
  Pbindef(\pbd_sd1,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\sd1_durs_a), 4),
      Pn(Pdefn(\sd1_durs_b), 1),
      // Pn(Pdefn(\sd1_durs_c), 1),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\sd1_degs_a), 4),                                  
      Pn(Pdefn(\sd1_degs_b), 2)
    ], inf))                           
      };
~sd1_phrA_fnB = {                                                       
  Pbindef(\pbd_sd1,                                                   
    \dur,    Pseq([Pn(Pdefn(\sd1_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\sd1_degs_a), 4)], inf))                
};                                                                      

// HH1
~hh1_phrA_fnA = {                                                       
  Pbindef(\pbd_hh1,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\hh1_durs_a), 4),
      Pn(Pdefn(\hh1_durs_b), 4),
      Pn(Pdefn(\hh1_durs_c), 2),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\hh1_degs_a), 4),                                  
      Pn(Pdefn(\hh1_degs_b), 2)
    ], inf))                           
      };
~hh1_phrA_fnB = {                                                       
  Pbindef(\pbd_hh1,                                                   
    \dur,    Pseq([Pn(Pdefn(\hh1_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\hh1_degs_a), 4)], inf))                
};                                                                      

// ROLL
~roll_phrA_fnA = {                                                       
  Pbindef(\pbd_roll,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\roll_durs_b), 2),
      Pn(Pdefn(\roll_durs_a), 4),
      Pn(Pdefn(\roll_durs_c), 2),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\roll_degs_a), 4),                                  
      Pn(Pdefn(\roll_degs_b), 2)
    ], inf))                           
};
~roll_phrA_fnB = {                                                       
  Pbindef(\pbd_roll,                                                   
    \dur,    Pseq([Pn(Pdefn(\roll_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\roll_degs_a), 4)], inf))                
};                                                                      

// MS20
~ms20_phrA_fnA = {                                                       
  Pbindef(\pbd_ms20,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\ms20_durs_a), 4),
      Pn(Pdefn(\ms20_durs_b), 2),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\ms20_degs_a), 4),
      Pn(Pdefn(\ms20_degs_b), 2),
      Pn(Pdefn(\ms20_degs_c), 2),
    ], inf))                           
};
~ms20_phrA_fnB = {                                                       
  Pbindef(\pbd_ms20,                                                   
    \dur,    Pseq([Pn(Pdefn(\ms20_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\ms20_degs_a), 4)], inf))                
};                                                                      

// THINGA
~thingA_phrA_fnA = {                                                       
  Pbindef(\pbd_thingA,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\thingA_durs_a), 4),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\thingA_degs_a), 4),
      Pn(Pdefn(\thingA_degs_b), 2),
    ], inf))                           
};
~thingA_phrA_fnB = {                                                       
  Pbindef(\pbd_thingA,                                                   
    \dur,    Pseq([Pn(Pdefn(\thingA_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\thingA_degs_a), 4)], inf))                
};                                                                      

// NEUTRON
~ntron_phrA_fnA = {                                                       
  Pbindef(\pbd_ntron,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\ntron_durs_a), 4),
      Pn(Pdefn(\ntron_durs_b), 4),
      Pn(Pdefn(\ntron_durs_c), 2),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\ntron_degs_a), 4),
      Pn(Pdefn(\ntron_degs_b), 4),
    ], inf))                           
};
~ntron_phrA_fnB = {                                                       
  Pbindef(\pbd_ntron,                                                   
    \dur,    Pseq([Pn(Pdefn(\ntron_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\ntron_degs_a), 4)], inf))                
};                                                                      

// MODEL D
~mD_phrA_fnA = {                                                       
  Pbindef(\pbd_mD,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\mD_durs_a), 4),
      Pn(Pdefn(\mD_durs_b), 2),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\mD_degs_a), 4),
      Pn(Pdefn(\mD_degs_b), 2),
      Pn(Pdefn(\mD_degs_c), 2),
    ], inf))                           
};
~mD_phrA_fnB = {                                                       
  Pbindef(\pbd_mD,                                                   
    \dur,    Pseq([Pn(Pdefn(\mD_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\mD_degs_a), 4)], inf))                
};                                                                      

// BASS
~bass_phrA_fnA = {                                                       
  Pbindef(\pbd_bass,                                                   
    \dur, Pseq([                                                    
      Pn(Pdefn(\bass_durs_a), 4),
      Pn(Pdefn(\bass_durs_b), 2),
    ],  inf), 
     \degree, Pseq([                                                 
      Pn(Pdefn(\bass_degs_a), 4),
      Pn(Pdefn(\bass_degs_b), 2),
      Pn(Pdefn(\bass_degs_c), 2),
    ], inf))                           
};
~bass_phrA_fnB = {                                                       
  Pbindef(\pbd_bass,                                                   
    \dur,    Pseq([Pn(Pdefn(\bass_durs_a), 4)], inf),                
    \degree, Pseq([Pn(Pdefn(\bass_degs_a), 4)], inf))                
};                                                                      

~lpBindBToggleFn.(5, [1,  1],
  ~bd1_phrA_fnA,  
  ~bd1_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  2],
  ~sd1_phrA_fnA,  
  ~sd1_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  3],
  ~hh1_phrA_fnA,  
  ~hh1_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  4],
  ~roll_phrA_fnA,  
  ~roll_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  5],
  ~ms20_phrA_fnA,  
  ~ms20_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  6],
  ~thingA_phrA_fnA,  
  ~thingA_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  7],
  ~ntron_phrA_fnA,  
  ~ntron_phrA_fnB,  
);
~lpBindBToggleFn.(5, [1,  8],
  ~mD_phrA_fnA,  
  ~mD_phrA_fnB,  
);
~lpBindBToggleFn.(6, [1,  1],
  ~bass_phrA_fnA,  
  ~bass_phrA_fnB,  
);

~apcBindToggleFnB.(5, 32,
  ~bd1_phrA_fnA,  
  ~bd1_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 33,
  ~sd1_phrA_fnA,  
  ~sd1_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 34,
  ~hh1_phrA_fnA,  
  ~hh1_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 35,
  ~roll_phrA_fnA,  
  ~roll_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 36,
  ~ms20_phrA_fnA,  
  ~ms20_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 37,
  ~thingA_phrA_fnA,  
  ~thingA_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 38,
  ~ntron_phrA_fnA,  
  ~ntron_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(5, 39,
  ~mD_phrA_fnA,  
  ~mD_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
~apcBindToggleFnB.(6, 32,
  ~bass_phrA_fnA,  
  ~bass_phrA_fnB,  
  \green, \blue, "phrA", "phr0"
);
// Refresh APC40 LEDs — clear stale pulse states then repaint
if(~apcOut.notNil) {
    ~apcPadMap.keysDo { |n| ~apcPadLEDch.(n, 0, ~apcCfg[\playMode] ? 9) };
    AppClock.sched(0.05, { ~apcRepaintAll.(); nil });
};
)
