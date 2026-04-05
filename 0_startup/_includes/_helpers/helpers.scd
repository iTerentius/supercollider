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
    var flag = false;
    var stopper = { flag = false };

    Tdef(name, {
        protect {
            flag = true;
            ~ensurePostSend.(src, ret, level);  // increments refcount; creates send if first user
            while { flag } { 0.2.wait };
        } {
            ~releasePostSend.(src, ret);  // decrements refcount; frees send only when last user stops
            flag = false;
        }
    });

    ~fxSendStop[name] = stopper;
    stopper
};

// easier patterning with "x---x---x---x---"
~p = { |str, rep=1, dur=1| 
  var array = str.collectAs({ |char| 
    if(char == $x, { dur }, { Rest(dur) }) 
  }, Array);
  Pseq(array, rep);
};
"Helpers loaded.".postln;
)


