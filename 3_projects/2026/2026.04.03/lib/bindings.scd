// bindings.scd — generated from ~slots. Do not edit by hand.
// To add/move/recolor voices: edit lib/slots.scd only.
(
// --- Voice launchers (LP + APC) ---
~slots.do { |sl|
    ~lpBindB.(sl[\lp][\b], [sl[\lp][\r], sl[\lp][\c]], sl[\n], sl[\lp][\col]);
    ~apcBindB.(sl[\apc][\b], sl[\apc][\p], sl[\n], 4, sl[\apc][\col]);
};

// --- FX send matrix (voice × return) ---
// LP:  Bank 2 + overflow, rows 1-5 = returns, cols = voice index
// APC: Bank 2, same pad column as Bank 1, rows top→bottom = returns
~slots.do { |sl, vi|
    var lpFxBank = 2 + (vi / 8).floor.asInteger;
    var lpFxCol  = (vi % 8) + 1;
    ~slotRets.do { |ret, ri|
        var key     = (sl[\n].asString ++ "_fx_" ++ (ri + 1)).asSymbol;
        var apcPad  = sl[\apc][\p] - (8 * ri);
        var stopper = ~makeFxSendTdef.(key, sl[\t], ret);
        ~lpBindB.(lpFxBank, [ri + 1, lpFxCol], key, ~slotFxLpCols[ri], nil, nil, stopper);
        ~apcBindB.(2, apcPad, key, 1, ~slotFxApcCols[ri], nil, stopper);
    };
};

// --- Phrase variant toggle bindings (Bank 5 LP / Bank 5 APC) ---
// Add per-voice below after defining ~phrFns in your parts files.
// Pattern:
//   ~lpBindBToggleFn.(5, [1, 1], ~phrFns[\v1][\a], ~phrFns[\v1][\b]);
//   ~apcBindToggleFnB.(5, 32, ~phrFns[\v1][\a], ~phrFns[\v1][\b], \green, \blue, "phrA", "phr0");

// --- Any other fixed/special bindings below (bCtl, spectral, etc.) ---
// ~lpBindB.(4, [1, 1], \bCtl, 21);
// ~apcBindB.(4, 32, \bCtl, 4, \cyan);

// Refresh APC40 LEDs
if(~apcOut.notNil) {
    ~apcPadMap.keysDo { |n| ~apcPadLEDch.(n, 0, ~apcCfg[\playMode] ? 9) };
    AppClock.sched(0.05, { ~apcRepaintAll.(); nil });
};
)
