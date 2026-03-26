// config.scd — tempo, return FX setup, initial state
(
~link.tempo = 120/60;

~fxSetup[\greyhole].(~r1, ~r1fx, ds: 1, page: 1, slot: 1);
~fxSetup[\combDelay].(~r2, ~r2fx, ds: 2, page: 1, slot: 2);
~fxSetup[\biscuit].(~r3, ~r3fx, ds: 3, page: 1, slot: 3);
~fxSetup[\chorus].(~r4, ~r4fx, ds: 4, page: 1, slot: 4);
~fxSetup[\spectral].(~r5, ~r5fx, ds: 5, page: 1, slot: 4);

// ~toscPadSyncAll.();
// ~toscMixSyncAll.();
// ~toscStateLoad.(\myproject);
)
