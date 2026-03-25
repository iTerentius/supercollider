// config.scd — tempo, return FX setup, initial state
(
~link.tempo = 120/60;

// Return bus FX — swap any slot by calling a different ~fxSetup key.
// Page/slot args wire up the TouchOSC FX page (nil = skip TOSC).
~fxSetup[\r1_greyhole].(1,  1);
~fxSetup[\r2_combDelay].(1, 2);
// ~fxSetup[\r3_biscuit].(1, 3);   // external hardware
~fxSetup[\r4_chorus].(1,  4);
~fxSetup[\r5_spectral].(1, 5);

// ~toscPadSyncAll.();
// ~toscMixSyncAll.();
// ~toscStateLoad.(\myproject);
)
