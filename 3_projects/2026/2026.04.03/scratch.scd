// scratch.scd — experimental workspace, not loaded by score.scd

// Quick inline FX deploy/swap:
~ilfx[\v2_crush] = ~fxLib[\bitcrush].(~t1);
~ilfx[\v2_crush].set(\bits, 6, \rate, 8000);
~ilfx[\v2_crush].free; ~ilfx[\v2_crush] = nil;
~ilfx[\v2_ringmod] = ~fxLib[\ringmod].(~t1);
~ilfx[\v2_ringmod].set(\freq, 80);
~ilfx[\v2_ringmod].free; ~ilfx[\v2_ringmod] = nil;
~ilfx[\v2_fold] = ~fxLib[\fold].(~t1);
~ilfx[\v2_fold].set(\gain, 3);
~ilfx[\v2_fold].free; ~ilfx[\v2_fold] = nil;
~ilfx[\v2_glitch] = ~fxLib[\glitch].(~t1);
~ilfx[\v2_glitch].set(\rate, 0.5);
~ilfx[\v2_glitch].free; ~ilfx[\v2_glitch] = nil;
// Pitch shimmer — two detuned, pitch-shifted delay lines
// Params: \shift (semitones offset, e.g. 12), \time (0.01–0.5), \mix (0–1)
~ilfx[\v2_shimmer] = ~fxLib[\shimmer].(~t1);
~ilfx[\v2_shimmer].set(\mix, 0.6,  \shift, 24,  \time,  0.5);
~ilfx[\v2_shimmer].free; ~ilfx[\v1_shimmer] = nil;
// Stutter — tape-stop/freeze-style repeating buffer
// Params: \rate (0.5–4 repeats/beat), \mix (0–1)
// Note: uses TGrains, approximate stutter not quantized
~ilfx[\v2_stutter] = ~fxLib[\stutter].(~t1);
~ilfx[\v2_stutter].set(\mix, 0.3,  \rate, 16, );
~ilfx[\v2_stutter].free; ~ilfx[\v2_stutter] = nil;
~ilfx[\v2_biscuit] = ~ufn[\biscuit].(~t2);
~ilfx[\v2_stutter].set(\mix, 0.5,  \rate, 16);
~ilfx[\v2_stutter].free; ~ilfx[\v1_stutter] = nil;
// Check what's running:
// Pdef.all;
// ~ilfx;
// ~fxSendStop;

// Manual send (bypass LP/APC toggle):
// ~ensurePostSend.(~t1, ~r1, 0.3);
