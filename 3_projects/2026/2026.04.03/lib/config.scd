// config.scd — tempo, return FX setup, initial state
(
~link.tempo = 90/60;
// ~inlineFX[\t1].set(\hpfreq,  100,  \lpfreq,  18000);
// FX nodes are created at startup in mixer-channel-16s.scd — do not call ~fxSetup here.
// To set initial param values use e.g: ~r3fx[\setBiscuit].(drive: 0.5, clock: 30000);

// ~toscPadSyncAll.();
// ~toscMixSyncAll.();
~toscStateLoad.(\t0403);
)
