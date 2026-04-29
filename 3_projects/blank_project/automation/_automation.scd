// _automation.scd — template for a return FX automation Pdef.
// Copy this file, rename it (e.g. biscuit.scd), and:
//   1. Change pfx to your Pdefn prefix (e.g. \bsct_)
//   2. Change the Pdef key (e.g. \bCtl)
//   3. Fill in \args and Pdefn parameters for your FX synth
//   4. Add an entry to ~autoSlots in lib/slots.scd
//   5. Add safeLoad.("automation/yourfile.scd") to score.scd
//
// Re-eval this file at any time to update Pdefns while preserving sync.
(
var pfx = \auto_;    // ← change: Pdefn prefix for this automation

///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\myAuto,
    Pbindef(\myAuto_pb,
        \type,  Pfunc({ ~myFxNode.notNil.if(\set, \rest) }),
        \id,    Pfunc({ ~myFxNode.tryPerform(\nodeID) }),
        \args,  #[\param1, \param2],

        \param1, Pn(Pdefn((pfx ++ "param1").asSymbol), inf),
        \param2, Pn(Pdefn((pfx ++ "param2").asSymbol), inf),

        \dur,   Pn(Pdefn((pfx ++ "durs").asSymbol), inf),
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////

// DUR
Pdefn((pfx ++ "dur_0").asSymbol, 1);
Pdefn((pfx ++ "durs").asSymbol, Pseq([Pn(Pdefn((pfx ++ "dur_0").asSymbol), 4)], 1));

// PARAM 1
Pdefn((pfx ++ "param1_0").asSymbol, 1.0);
Pdefn((pfx ++ "param1").asSymbol,   Pseq([Pn(Pdefn((pfx ++ "param1_0").asSymbol), 4)], 1));

// PARAM 2
Pdefn((pfx ++ "param2_0").asSymbol, 0.5);
Pdefn((pfx ++ "param2").asSymbol,   Pseq([Pn(Pdefn((pfx ++ "param2_0").asSymbol), 4)], 1));
)
