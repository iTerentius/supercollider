// ndef-fx-route.scd
// FX-to-FX routing for ndef-mixer.scd — DAW-style "send one return into
// another return" (reverb into delay, etc.), matrix-capable (any number of
// sources into any target, each independently live-adjustable).
//
// Requires ndef-mixer.scd loaded first (uses ~fxAddFX).
//
// Same shape as ~fxSetSend's tap/sum pattern, just retargeted from
// track->send to fx->fx: a tiny tap Ndef per connection, live \amt control,
// summed directly into the TARGET fx's own signal BEFORE its own DSP runs —
// this is genuine serial routing (the source's audio is actually processed
// by the target's effect), not a parallel "both audible at once" layer. Repeat
// ~fxRoute calls on an already-existing connection are just .set(\amt, val) —
// no rebuild, no crossfade glitch on other connections into the same target,
// same efficiency lesson as ~fxSetSend.
//
// CONSTRAINT: a fx can only be a routing TARGET if it was defined via
// ~fxRouteReg instead of a plain `Ndef(fx)[0] = {...}` — the target's [0]
// needs to be rebuildable ("normal input + whatever's currently routed in")
// whenever a connection is added/removed, so its core DSP and its normal
// input have to be registered separately rather than hardcoded inline. Any
// EXISTING fx (however it was defined) works fine as a routing SOURCE with
// no changes at all — only targets need ~fxRouteReg.
//
// Globals: ~fxRouteReg, ~fxRoute, ~fxUnroute, ~fxRouteState,
//          ~fxRouteTapName, ~fxRouteRebuild
(
~fxRouteState = Dictionary.new;   // toFx -> (core: func, baseIn: sym, from: [fromFx, ...])

~fxRouteTapName = { |fromFx, toFx| (fromFx.asSymbol ++ "_into_" ++ toFx.asSymbol).asSymbol };

// Rebuilds toFx's [0]: normal input, summed with every currently-routed-in
// tap, through its own core DSP function.
~fxRouteRebuild = { |toFx|
    var st = ~fxRouteState[toFx];
    var baseIn = st[\baseIn], core = st[\core], froms = st[\from];
    Ndef(toFx)[0] = {
        var sig = Ndef.ar(baseIn, 2);
        froms.do { |f| sig = sig + Ndef.ar(~fxRouteTapName.(f, toFx), 2) };
        core.value(sig);
    };
};

// Define a fx as a ROUTABLE TARGET — use instead of a plain [0] = {...} for
// any fx you might want other fx to route into later.
//   toFx:   the return's name, e.g. \fxsDelay
//   baseIn: its normal input Ndef, e.g. \s2_sum
//   core:   a { |sig| ... } function — just the DSP, no Ndef.ar/baseIn lookup
//           inside it, ~fxRouteRebuild supplies sig
~fxRouteReg = { |toFx, baseIn, core|
    ~fxRouteState[toFx] = (core: core, baseIn: baseIn, from: []);
    ~fxRouteRebuild.(toFx);
    ~fxAddFX.(toFx);           // same bookkeeping any return needs to reach wet_bus
};

// Route fromFx's output into toFx's own processing, live-adjustable amount.
~fxRoute = { |fromFx, toFx, amt|
    var st = ~fxRouteState[toFx];
    var tapName = ~fxRouteTapName.(fromFx, toFx);
    if(st.isNil) {
        ("~fxRoute: % was never registered via ~fxRouteReg".format(toFx)).warn;
        ^nil
    };
    if(st[\from].includes(fromFx).not) {
        st[\from] = st[\from].add(fromFx);
        Ndef(tapName).fadeTime = 0.02;
        Ndef(tapName)[0] = { |amt = 0| Ndef.ar(fromFx, 2) * amt };
        ~fxRouteRebuild.(toFx);
    };
    Ndef(tapName).set(\amt, amt);
    amt
};

// Fully remove a connection (not just amt=0) — rebuilds toFx without that
// tap at all, rather than leaving a permanently-zeroed tap around.
~fxUnroute = { |fromFx, toFx|
    var st = ~fxRouteState[toFx];
    if(st.notNil and: { st[\from].includes(fromFx) }) {
        st[\from].remove(fromFx);
        ~fxRouteRebuild.(toFx);
    };
};
)

// =============================================================================
// USAGE — matrix-style, multiple sources into one target, each independent
// =============================================================================
// Ndef(\fxsVerb)[0] = { var sig = Ndef.ar(\s1_sum, 2); FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.4) };
// ~fxAddFX.(\fxsVerb);
//
// // \fxsDelay defined as a ROUTABLE TARGET instead of a plain [0]=
// ~fxRouteReg.(\fxsDelay, \s2_sum, { |sig| CombL.ar(sig, 0.4, \dt.kr(0.375), \dec.kr(1.5)) });
//
// ~fxRoute.(\fxsVerb, \fxsDelay, 0.4);       // verb -> delay
// ~fxRoute.(\fxsBitcrush, \fxsDelay, 0.2);   // ALSO bitcrush -> delay, same target, independent amt
// ~fxRoute.(\fxsVerb, \fxsDelay, 0);         // dial to nothing without fully removing
// ~fxUnroute.(\fxsVerb, \fxsDelay);          // fully remove — rebuilds delay without that tap
//
// For a LaunchPad/APC matrix: each pad is just ~fxRoute.(rowFx, colFx, x) —
// same shape as any other ~apcBindParam/~lpBind callback, no new
// controller-binding pattern needed.
