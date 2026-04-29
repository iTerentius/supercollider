// scratch.scd — experimental workspace, not loaded by score.scd

// Quick inline FX deploy/swap:
// ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1);
// ~ilfx[\v1_crush].set(\bits, 6, \rate, 8000);
// ~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;

// Check what's running:
// Pdef.all;
// ~ilfx;
// ~fxSendStop;

// Manual send (bypass LP/APC toggle):
// ~ensurePostSend.(~t1, ~r1, 0.3);
