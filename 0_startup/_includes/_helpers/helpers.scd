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

// =============================================================================
// Project state save / restore
// =============================================================================
// Unified save/load covering both TOSC (~oscState) and APC (~apcState).
// Use a per-project key, e.g. \2026_04_03.
//
// Save:  ~projectStateSave.(\myproject)   — call manually at any stable point
// Load:  ~projectStateLoad.(\myproject)   — call from lib/config.scd on startup
//
// Load re-fires all stored callbacks so SC params match last saved positions.
// TOSC controls are also pushed the saved values (visual resync).
// APC physical knobs stay wherever they are — no feedback possible — but SC
// params are correct; the next knob touch snaps to physical position as usual.

~projectStateSave = { |key = \default|
    Archive.global.put((\projectState_ ++ key).asSymbol, (
        tosc: ~oscState.copy,
        apc:  ~apcState.copy
    ));
    ("Project state saved:" + key +
        "(" ++ (~oscState.size + ~apcState.size) ++ "controls).").postln;
};

~projectStateLoad = { |key = \default|
    var state = Archive.global.at((\projectState_ ++ key).asSymbol);
    if(state.notNil) {
        state[\tosc] !? { |s|
            s.keysValuesDo { |addr, val| ~toscSend.(addr, val) };
        };
        state[\apc] !? { |s|
            s.keysValuesDo { |k, val|
                ~apcState[k] = val;
                ~apcParamBindings[k] !? { |cb| cb.(val) };
            };
        };
        ("Project state loaded:" + key +
            "(" ++ (state[\tosc].size + state[\apc].size) ++ "controls).").postln;
    } {
        ("Project state not found:" + key).warn;
    };
};

// easier patterning with "x---x---x---x---"
~p = { |str, rep=1, dur=1| 
  var array = str.collectAs({ |char| 
    if(char == $x, { dur }, { Rest(dur) }) 
  }, Array);
  Pseq(array, rep);
};
~deg = { |str, rep=1, dur=1|
    var array = str.collectAs({ |char|
      if(char.isDecDigit, { char.digitValue }, { Rest(dur) })
    }, Array);
    Pseq(array, rep);
  };
~hit = { |str, note, rep=inf, dur=0.125 |
      Pseq(str.collectAs({ |c| if(c == $x, note, Pn(Rest(), 1)) }, Array), rep)
  };
"Helpers loaded.".postln;
)


