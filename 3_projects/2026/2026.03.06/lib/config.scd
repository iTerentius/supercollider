// Config — tempo + sample loads
(
~link.tempo = 100/60;
// ~r2fx[\combDelay].set(\maxdt, 2.0, \dt, 1.0, \dec, 1.0);
// ~r1fx[\greyhole].set(\diff,  0.01);
~fxSetup[\greyhole].(~r1, ~r1fx, ds: 1, page: 1, slot: 1);
~fxSetup[\combDelay].(~r2, ~r2fx, ds: 2, page: 1, slot: 2);
~fxSetup[\biscuit].(~r3, ~r3fx, ds: 3, page: 1, slot: 3);
~fxSetup[\chorus].(~r4, ~r4fx, ds: 4, page: 1, slot: 4);
~fxSetup[\spectral].(~r5, ~r5fx, ds: 5, page: 1, slot: 5);
//
// ~toscPadSyncAll.();
// ~toscMixSyncAll.()
// ~toscStateLoad.("2026_03_06".asSymbol);  // restore saved fader/filter positions
)
// ~toscSync.();
// ~toscStateSave.("2026_03_06".asSymbol);
// ~toscPadClearAll.();

