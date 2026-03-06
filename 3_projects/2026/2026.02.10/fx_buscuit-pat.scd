(
Pdef(\bCtl, Pbind(
    \type,       \set,
    \id,         Pfunc({ ~r3_fx.nodeID }),
    \args,       #[\drive, \clock, \bits,
                   \b1, \b2, \b3, \b4, \b5, \b6, \b7, \b8,
                   \fxMode, \shape,
                   \delTime, \delFB,
                   \pitchShift,
                   \stepRate, \sf0, \sf1, \sf2, \sf3,
                   \filterType, \filterFreq, \filterQ,
                   \naked, \dressed],

    // --- input ---
    \drive,      Pn(Pdefn(\bsct_drive),  inf),

    // --- bitcrusher ---
    \clock,      Pn(Pdefn(\bsct_clock),  inf),
    \bits,       Pn(Pdefn(\bsct_bits),   inf),

    // --- bit manipulation ---
    \b1,         Pn(Pdefn(\bsct_b1), inf),
    \b2,         Pn(Pdefn(\bsct_b2), inf),
    \b3,         Pn(Pdefn(\bsct_b3), inf),
    \b4,         Pn(Pdefn(\bsct_b4), inf),
    \b5,         Pn(Pdefn(\bsct_b5), inf),
    \b6,         Pn(Pdefn(\bsct_b6), inf),
    \b7,         Pn(Pdefn(\bsct_b7), inf),
    \b8,         Pn(Pdefn(\bsct_b8), inf),

    // --- fx mode ---
    \fxMode,     Pn(Pdefn(\bsct_fxMode), inf),

    // --- waveshaper (fxMode=0) ---
    \shape,      Pn(Pdefn(\bsct_shape),  inf),

    // --- delay (fxMode=1) ---
    \delTime,    Pn(Pdefn(\bsct_delTime), inf),
    \delFB,      Pn(Pdefn(\bsct_delFB),  inf),

    // --- pitch shifter (fxMode=2) ---
    \pitchShift, Pn(Pdefn(\bsct_pitchShift), inf),

    // --- step filter (fxMode=3) ---
    \stepRate,   Pn(Pdefn(\bsct_stepRate), inf),
    \sf0,        Pn(Pdefn(\bsct_sf0), inf),
    \sf1,        Pn(Pdefn(\bsct_sf1), inf),
    \sf2,        Pn(Pdefn(\bsct_sf2), inf),
    \sf3,        Pn(Pdefn(\bsct_sf3), inf),

    // --- analog output filter ---
    \filterType, Pn(Pdefn(\bsct_filterType), inf),
    \filterFreq, Pn(Pdefn(\bsct_filterFreq), inf),
    \filterQ,    Pn(Pdefn(\bsct_filterQ),    inf),

    // --- wet/dry ---
    \naked,      Pn(Pdefn(\bsct_naked),   inf),
    \dressed,    Pn(Pdefn(\bsct_dressed), inf),

    \dur,        Pn(Pdefn(\bsct_durs), inf),
));
~lpBind.([8, 3], \bCtl, 35);
~apcAssignPad.(7,  \bCtl);
)
