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
~lpBindB.(2, [1, 1], \bass,  12);



// --- APC40 Mk2 pads (bank 1) ---
~apcBindB.(1, 32, \bd1,      4, \orange);
~apcBindB.(1, 33, \sd1,      4, \yellow);
~apcBindB.(1, 34, \hh1,      4, \cyan);
~apcBindB.(1, 35, \roll,     4, \blue);
~apcBindB.(1, 36, \ms20,     4, \purple);
~apcBindB.(1, 37, \thingA,   4, \pink);
~apcBindB.(1, 38, \neutron,  4, \orange);
~apcBindB.(1, 39, \modelD,   4, \yellow);
~apcBindB.(2, 32, \bass,   4, \yellow);

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
// Bank 2: FX sends — bd1+sd1 (col 1), hh1+roll (col 2)

// Toggles
~lpBindBToggleFn.(1, [2, 1],                              
  ~bd1_phrA_fnA,
  ~bd1_phrA_fnB,
50, 50 );
~lpBindBToggleFn.(1, [2, 2],                              
  ~sd1_phrA_fnA,
  ~sd1_phrA_fnB,
50, 50 );
~lpBindBToggleFn.(1, [2, 3],                              
  ~hh1_phrA_fnA,
  ~hh1_phrA_fnB,
50, 50 );
~apcBindToggleFn.(2, 24,
  ~bd1_phrA_fnA,
  ~bd1_phrA_fnB,
  \green, \blue
);
~apcBindToggleFn.(2, 25,
  ~sd1_phrA_fnA,
  ~sd1_phrA_fnB,
  \green, \blue
);
~apcBindToggleFn.(2, 26,
  ~hh1_phrA_fnA,
  ~hh1_phrA_fnB,
  \green, \blue
);
~toscPadBindToggleFn.(1, 1, 2,
  ~bd1_phrA_fnA,
  ~bd1_phrA_fnB,
  \green, \blue, "phrB", "phr0"
);
~toscPadBindToggleFn.(1, 2, 2,
  ~sd1_phrA_fnA,
  ~sd1_phrA_fnB,
  \green, \blue, "phrA", "phr0"
);
~toscPadBindToggleFn.(1, 3, 2,
  ~hh1_phrA_fnA,
  ~hh1_phrA_fnB,
  \green, \blue, "phrA", "phr0"
);

~toscPadPaintAll.();

// Refresh APC40 LEDs — clear stale pulse states then repaint
if(~apcOut.notNil) {
    ~apcPadMap.keysDo { |n| ~apcPadLEDch.(n, 0, ~apcCfg[\playMode] ? 9) };
    AppClock.sched(0.05, { ~apcRepaintAll.(); nil });
};
)
