// Config — tempo + sample loads
(
~link.tempo = 100/60;
// ~r2fx[\combDelay].set(\maxdt, 2.0, \dt, 1.0, \dec, 1.0);
// ~r1fx[\greyhole].set(\diff,  0.01);
~fxSetup[\r1_greyhole].(1,  1);
~fxSetup[\r2_combDelay].(1, 2);
~fxSetup[\r3_biscuit].(1, 3);
~fxSetup[\r4_chorus].(1,  4);
~fxSetup[\r5_spectral].(1,  5);
//
// ~toscPadSyncAll.();
// ~toscMixSyncAll.()
// ~toscStateLoad.("2026_03_06".asSymbol);  // restore saved fader/filter positions
)
// ~fxSetup[\r1_greyhole].(1,  1);
// ~fxSetup[\r2_combDelay].(1, 2);
// ~fxSetup[\r3_biscuit].(1, 3);
// ~fxSetup[\r4_chorus].(1,  4);

// ~toscSync.();
// ~toscStateSave.("2026_03_06".asSymbol);
// ~toscPadClearAll.();

