// CC Automation patterns
(
Pdef(\cc_mod_1,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.cc,
        \midicmd, \control,
        \ctlNum, ~cfg.cc.mod1,
        \dur, 1/16,
        \control, Pseg([0, 127, 127, 0], [4, 4, 4], \sin, inf)
    )
);

Pdef(\cc_mod_2,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.cc,
        \midicmd, \control,
        \ctlNum, ~cfg.cc.mod2,
        \dur, 1/4,
        \control, Pseg([0, 127, 0], [1, 4], \sin, inf)
    )
);
)
