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

// --- Return → return FX send matrix (Bank 4 LP / Bank 4 APC) ---
// LP:  col = src return index+1, row = dst return index+2
//      (row 1 per column is reserved for Pdef fx control toggles)
// APC: pad = (4 - dstIdx) * 8 + srcIdx  (col=src, row from bottom=dst)
// Color tracks destination return (same palette as voice→return sends).
~slotRets.do { |src, si|
    ~slotRets.do { |dst, di|
        if(si != di) {
            var key     = ("r" ++ (si + 1) ++ "_fx_r" ++ (di + 1)).asSymbol;
            var stopper = ~makeFxSendTdef.(key, src, dst);
            ~lpBindB.(4, [di + 2, si + 1], key, ~slotFxLpCols[di], nil, nil, stopper);
            ~apcBindB.(4, (4 - di) * 8 + si, key, 4, nil, nil, stopper);
        };
    };
};

// --- Bank 4 utility ---
~lpBindB.(4, [8, 8], \tempo, 41, nil, 4);
~apcBindB.(4, 7, \tempo, 4, 4);

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
