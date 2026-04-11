// bindings.scd — generated from ~slots. Do not edit by hand.
// To add/move/recolor voices: edit lib/slots.scd only.
(
// --- Voice launchers (LP + APC) ---
~slots.do { |sl|
    ~lpBindB.(sl[\lp][\b], [sl[\lp][\r], sl[\lp][\c]], sl[\n], sl[\lp][\col]);
    ~apcBindB.(sl[\apc][\b], sl[\apc][\p], sl[\n], 4, sl[\apc][\col]);
};

// --- FX send matrix (channel × return) ---
// Deduplicated by mixer channel: one column per unique ~t, not per voice.
// Voices sharing the same ~tN (e.g. 808k/hh/sn all on ~t1) get one shared send pad.
// LP:  Bank 3, sub-bank overflow for >8 channels
//      rows 1-N = returns, cols = channel index within sub-bank
// APC: Bank 3, same pad column as the first voice on that channel, rows top→bottom = returns
{ var seen, trackSlots;
  seen = Set.new;
  trackSlots = ~slots.select { |sl|
      if(seen.includes(sl[\t])) { false } { seen.add(sl[\t]); true }
  };
  trackSlots.do { |sl, ci|
      var lpFxSub = (ci / 8).floor.asInteger + 1;
      var lpFxCol = (ci % 8) + 1;
      ~slotRets.do { |ret, ri|
          var key     = (sl[\t].name.asString ++ "_fx_" ++ (ri + 1)).asSymbol;
          var apcPad  = sl[\apc][\p] - (8 * ri);
          var stopper = ~makeFxSendTdef.(key, sl[\t], ret);
          ~lpBindSB.(3, lpFxSub, [ri + 1, lpFxCol], key, ~slotFxLpCols[ri], nil, nil, stopper);
          ~apcBindB.(3, apcPad, key, 1, ~slotFxApcCols[ri], nil, stopper);
      };
  };
}.value;

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
  ~lpBindBVariants.(1, [
      [[2, 5], ~phrFns[\v3_harpy][\def], 21],
      [[3, 5], ~phrFns[\v3_harpy][\c], 9],
      [[4, 5], ~phrFns[\v3_harpy][\b], 9],
  ],  0);

  // ~lpBindBToggleFn.(1, [2, 5], ~phrFns[\v2_bass][\a], ~phrFns[\v2_bass][\b]);

  ~apcBindToggleFnB.(1, 24, ~phrFns[\v1_808k][\a], ~phrFns[\v1_808k][\b], \green, \blue);
  ~lpBindBToggleFn.(2, [1, 1],
      // ON: create node, play automation
      {
          ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1);
          ~ilfx[\v1_crush].set(\bits, 6, \rate, 8000);
          Pdef(\crush).play(~link);
      },
      // OFF: stop automation, free node
      {
          Pdef(\crush).stop;
          ~ilfx[\v1_crush].free;
          ~ilfx[\v1_crush] = nil;
      }
  );
  ~lpBindBToggleFn.(2, [1, 3],
      // ON: create node, play automation
      {
          ~ilfx[\v3_shimmer] = ~fxLib[\shimmer].(~t3);
          ~ilfx[\v3_shimmer].set(\mix, 0.3,  \shift, 24,  \time, 0.5);
      },
      // OFF: stop automation, free node
      {
          ~ilfx[\v3_shimmer].free;
          ~ilfx[\v3_shimmer] = nil;
      }
  );
  ~lpBindBToggleFn.(2, [2, 3],
      // ON: create node, play automation
      {
          ~ilfx[\v3_duck] = ~fxLib[\duck].(~t3, ~t1,  
            [\thresh, 0.7, \ratio, 6, \release, 0.4]);
      },
      // OFF: stop automation, free node
      {
          ~ilfx[\v3_duck].free;
          ~ilfx[\v3_duck] = nil;
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
