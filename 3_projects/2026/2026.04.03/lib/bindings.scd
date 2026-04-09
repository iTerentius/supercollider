// bindings.scd — generated from ~slots. Do not edit by hand.
// To add/move/recolor voices: edit lib/slots.scd only.
(
// --- Voice launchers (LP + APC) ---
~slots.do { |sl|
    ~lpBindB.(sl[\lp][\b], [sl[\lp][\r], sl[\lp][\c]], sl[\n], sl[\lp][\col]);
    ~apcBindB.(sl[\apc][\b], sl[\apc][\p], sl[\n], 4, sl[\apc][\col]);
};

// --- FX send matrix (voice × return) ---
// LP:  Bank 2, sub-bank overflow for >8 voices (col 9+ → sub-bank 2, etc.)
//      rows 1-N = returns, cols = voice index within sub-bank
// APC: Bank 2, same pad column as Bank 1, rows top→bottom = returns
~slots.do { |sl, vi|
    var lpFxSub = (vi / 8).floor.asInteger + 1;
    var lpFxCol = (vi % 8) + 1;
    ~slotRets.do { |ret, ri|
        var key     = (sl[\n].asString ++ "_fx_" ++ (ri + 1)).asSymbol;
        var apcPad  = sl[\apc][\p] - (8 * ri);
        var stopper = ~makeFxSendTdef.(key, sl[\t], ret);
        ~lpBindSB.(3, lpFxSub, [ri + 1, lpFxCol], key, ~slotFxLpCols[ri], nil, nil, stopper);
        ~apcBindB.(3, apcPad, key, 1, ~slotFxApcCols[ri], nil, stopper);
    };
};

// --- Return → return FX send matrix (Bank 4 LP / Bank 4 APC) ---
// LP:  Bank 4, sub-bank overflow for >8 returns (src col 9+ → sub-bank 2, etc.)
//      col = src return index within sub-bank, row = dst return index+2
//      (row 1 per column is reserved for Pdef fx control toggles)
// APC: pad = (4 - dstIdx) * 8 + srcIdx  (col=src, row from bottom=dst)
// Color tracks destination return (same palette as voice→return sends).
~slotRets.do { |src, si|
    var lpSub = (si / 8).floor.asInteger + 1;
    var lpCol = (si % 8) + 1;
    ~slotRets.do { |dst, di|
        if(si != di) {
            var key     = ("r" ++ (si + 1) ++ "_fx_r" ++ (di + 1)).asSymbol;
            var stopper = ~makeFxSendTdef.(key, src, dst);
            ~lpBindSB.(4, lpSub, [di + 2, lpCol], key, ~slotFxLpCols[di], nil, nil, stopper);
            ~apcBindB.(4, (4 - di) * 8 + si, key, 4, nil, nil, stopper);
        };
    };
};

// --- FX automation launcher bindings (generated from ~autoSlots in slots.scd) ---
~autoSlots.do { |sl|
    ~lpBindB.(sl[\lp][\b], [sl[\lp][\r], sl[\lp][\c]], sl[\n], sl[\lp][\col], nil, 4, sl[\onStop]);
    sl[\apc] !? { |a| ~apcBindB.(a[\b], a[\p], sl[\n], 4, a[\col]) };
};

// --- Phrase variant toggle bindings (Bank 5 LP / Bank 5 APC) ---
// Add per-voice below after defining ~phrFns in your parts files.
// Pattern:
 ~lpBindBVariants.(1, [
      [[2, 1], ~phrFns[\v1_808k][\a], 21],
      [[3, 1], ~phrFns[\v1_808k][\b], 9],
      [[4, 1], ~phrFns[\v1_808k][\c], 9],
      [[5, 1], ~phrFns[\v1_808k][\d], 9],
  ],  1);
  ~lpBindBVariants.(1, [
    [[2, 2], ~phrFns[\v1_808hh][\a], 21],
    [[3, 2], ~phrFns[\v1_808hh][\b], 9],
    [[4, 2], ~phrFns[\v1_808hh][\c], 9],
  ],  1);
  ~lpBindBVariants.(1, [
      [[2, 3], ~phrFns[\v1_808sn][\a], 21],
      [[3, 3], ~phrFns[\v1_808sn][\b], 9],
  ],  1);
  ~lpBindBVariants.(1, [
      [[2, 4], ~phrFns[\v2_bass][\a], 21],
      [[3, 4], ~phrFns[\v2_bass][\b], 9],
  ],  1);

  // ~lpBindBToggleFn.(1, [2, 5], ~phrFns[\v2_bass][\a], ~phrFns[\v2_bass][\b]);

  ~apcBindToggleFnB.(1, 24, ~phrFns[\v1_808k][\a], ~phrFns[\v1_808k][\b], \green, \blue);
  ~lpBindBToggleFn.(2, [1, 1],
      // ON: create node, play automation
      {
          ~ilfx[\v2_crush] = ~fxLib[\bitcrush].(~t1);
          ~ilfx[\v2_crush].set(\bits, 6, \rate, 8000);
          Pdef(\crush).play(~link);
      },
      // OFF: stop automation, free node
      {
          Pdef(\crush).stop;
          ~ilfx[\v2_crush].free;
          ~ilfx[\v2_crush] = nil;
      }
  );
// --- Any other fixed/special bindings below (bCtl, spectral, etc.) ---
// ~lpBindB.(4, [1, 1], \bCtl, 21);
// ~apcBindB.(4, 32, \bCtl, 4, \cyan);

// Refresh APC40 LEDs
if(~apcOut.notNil) {
    ~apcPadMap.keysDo { |n| ~apcPadLEDch.(n, 0, ~apcCfg[\playMode] ? 9) };
    AppClock.sched(0.05, { ~apcRepaintAll.(); nil });
};
)
