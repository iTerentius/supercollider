(
// =============================================================================
// Helpers
// =============================================================================

// --- FX Send Toggle Tdef ---
// Creates a Tdef that toggles a post-send on/off, suitable for single-pad
// LP Mini / APC40 bindings with LED state tracking via isPlaying.
//
// SC gotcha: protect{} does NOT fire on thread kill (stop/stopQ is a hard
// primitive kill). The while+flag pattern lets the Tdef exit naturally so
// cleanup runs. Pass the returned stopper as onStop to ~lpBind.
//
// Usage:
//   ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1);
//   ~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~fxSendStop[\bd1_fx_1]);
//
//   // or inline (makeFxSendTdef returns the stopper):
//   ~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1));
//
// ~fxSendStop[name] — stopper dict, accessible for rebinding or other use

~fxSendStop = IdentityDictionary.new;

~makeFxSendTdef = { |name, src, ret, level=1|
    var flag = false, node = nil;
    var stopper = { flag = false };

    Tdef(name, {
        protect {
            flag = true;
            node.tryPerform(\free);
            node = ~ensurePostSend.(src, ret, level);
            while { flag } { 0.2.wait };
        } {
            node.tryPerform(\free);
            node = nil;
            flag = false;
        }
    });

    ~fxSendStop[name] = stopper;
    stopper
};


"Helpers loaded.".postln;
)


