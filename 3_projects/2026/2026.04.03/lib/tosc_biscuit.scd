// tosc_biscuit.scd — OSCdefs for custom biscuit TOSC page (sc-fx-002.tosc)
// Receives real-world values from /tosc/fx/2/biscuit/{param} → sets synth directly.
// Re-eval to rebind without restarting.
// To comment a param back into Pdef(\bCtl), remove it from the lists below
// and uncomment the corresponding line in automation/biscuit.scd.
(
// Continuous params — set synth directly
[\drive, \clock, \filterFreq, \filterQ, \stepRate, \sf0, \sf1, \sf2, \sf3,
 \delTime, \delFB, \naked, \dressed].do { |param|
    OSCdef(
        ("bsct_tosc_" ++ param).asSymbol,
        { |msg| ~r3fx[\biscuit].set(param, msg[1]) },
        ("/tosc/fx/2/biscuit/" ++ param)
    );
};

// Discrete params — round to integer
[\fxMode, \shape, \pitchShift, \filterType, \bits].do { |param|
    OSCdef(
        ("bsct_tosc_" ++ param).asSymbol,
        { |msg| ~r3fx[\biscuit].set(param, msg[1].round.asInteger) },
        ("/tosc/fx/2/biscuit/" ++ param)
    );
};

// Bit manipulation b1-b8  (-1=invert  0=mute  1=pass)
(1..8).do { |n|
    OSCdef(
        ("bsct_tosc_b" ++ n).asSymbol,
        { |msg| ~r3fx[\biscuit].set(("b" ++ n).asSymbol, msg[1].round.asInteger) },
        ("/tosc/fx/2/biscuit/b" ++ n)
    );
};
)

/*
// ── Pdefn version (archived) ─────────────────────────────────────────────────
// Use this if you want TOSC to update Pdefns so pattern automation coexists.
// Also uncomment the matching lines in automation/biscuit.scd so the Pdef
// picks up the Pdefn values, then re-eval both files.
// Restore full pattern control: Pdefn(\bsct_drive, Pn(Pdefn(\bsct_drive_0), inf))
(
[\drive, \clock, \filterFreq, \filterQ, \stepRate, \sf0, \sf1, \sf2, \sf3,
 \delTime, \delFB, \naked, \dressed].do { |param|
    OSCdef(
        ("bsct_tosc_" ++ param).asSymbol,
        { |msg| Pdefn(("bsct_" ++ param).asSymbol, msg[1]) },
        ("/tosc/fx/2/biscuit/" ++ param)
    );
};

[\fxMode, \shape, \pitchShift, \filterType, \bits].do { |param|
    OSCdef(
        ("bsct_tosc_" ++ param).asSymbol,
        { |msg| Pdefn(("bsct_" ++ param).asSymbol, msg[1].round.asInteger) },
        ("/tosc/fx/2/biscuit/" ++ param)
    );
};

(1..8).do { |n|
    OSCdef(
        ("bsct_tosc_b" ++ n).asSymbol,
        { |msg| Pdefn(("bsct_b" ++ n).asSymbol, msg[1].round.asInteger) },
        ("/tosc/fx/2/biscuit/b" ++ n)
    );
};
)
// ─────────────────────────────────────────────────────────────────────────────
*/
