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

// ~hit.("x--x_-", note, rep, stepDur)  — 'x' fires note, '_' sustains previous note.
// Returns Pbind(\degree, ..., \dur, ...) — drop \dur from ~kitBase and use
// Pchain(Pdefn(\x), ~kitBase) instead of Pchain(Pbind(\degree, Pdefn(\x)), ~kitBase).
~hit = { |str, note, rep=inf, stepDur=0.125|
    var degrees = [], durs = [], i = 0;
    while { i < str.size } {
        if(str[i] == $x) {
            var span = 1;
            while { (i + span) < str.size && (str[i+span] == $_) } { span = span + 1 };
            degrees = degrees.add(note);
            durs    = durs.add(span * stepDur);
            i = i + span;
        } {
            degrees = degrees.add(Rest());
            durs    = durs.add(stepDur);
            i = i + 1;
        }
    };
    Pbind(\degree, Pseq(degrees, rep), \dur, Pseq(durs, rep))
};

// ~deg.("0--2-4", rep, dur) — digits set scale degree, anything else = rest.
// Returns a plain value pattern (degree only); pair with a separate \dur in Pbind.
~deg = { |str, rep=1, dur=1|
    var array = [], i = 0, c, j, inner, commaIdx, deg, len;
    while { i < str.size } {
        c = str[i];
        if (c == $[) {
            j = i + 1;
            while { (j < str.size) and: { str[j] != $] } } { j = j + 1 };
            inner = str.copyRange(i + 1, j - 1);
            commaIdx = inner.detectIndex({ |ch| ch == $, });
            if (commaIdx.notNil) {
                deg = inner.copyRange(0, commaIdx - 1).asInteger;
                len = inner.copyRange(commaIdx + 1, inner.size - 1).asInteger;
            } {
                deg = inner.asInteger;
                len = 1;
            };
            len.do { array = array.add(deg) };
            i = j + 1;
        } {
            if (c.isDecDigit) { array = array.add(c.digitValue) }
                              { array = array.add(Rest(dur)) };
            i = i + 1;
        };
    };
    Pseq(array, rep)
};

// ~p.("x---x---", rep, dur) — 'x' = dur value, anything else = rest. Plain value pattern.
~p = { |str, rep=1, dur=1|
    Pseq(str.collectAs({ |c| if(c == $x, dur, Rest(dur)) }, Array), rep)
};
"Helpers loaded.".postln;
)


