(
Pdef(\modelD, Pbind(
    \instrument,   \modelD,
    \out,          ~t3.inbus.index,

    // --- pitch / gate ---
    \scale,        Pn(Pdefn(\mD_scale), inf),
    \degree,       Pn(Pdefn(\mD_degs),  inf),
    \octave,       Pn(Pdefn(\mD_octs),  inf),
    \dur,          Pn(Pdefn(\mD_durs),  inf),
    \stretch,      Pn(Pdefn(\mD_strs),  inf),
    \legato,       Pn(Pdefn(\mD_legs),  inf),
    \amp,          Pn(Pdefn(\mD_amps),  inf),

    // --- glide ---
    \glide,        Pn(Pdefn(\mD_glides), inf),

    // --- osc 1 ---
    \osc1Wave,     Pn(Pdefn(\mD_osc1Wave), inf),
    \osc1Oct,      Pn(Pdefn(\mD_osc1Oct),  inf),

    // --- osc 2 ---
    \osc2Wave,     Pn(Pdefn(\mD_osc2Wave), inf),
    \osc2Oct,      Pn(Pdefn(\mD_osc2Oct),  inf),
    \osc2Fine,     Pn(Pdefn(\mD_osc2Fine), inf),

    // --- osc 3 ---
    \osc3Wave,     Pn(Pdefn(\mD_osc3Wave),    inf),
    \osc3Oct,      Pn(Pdefn(\mD_osc3Oct),     inf),
    \osc3Fine,     Pn(Pdefn(\mD_osc3Fine),    inf),
    \osc3KbdTrack, Pn(Pdefn(\mD_osc3KbdTrack), inf),
    \osc3Freq,     Pn(Pdefn(\mD_osc3Freq),    inf),

    // --- oscillator mixer ---
    \osc1Lvl,      Pn(Pdefn(\mD_osc1Lvl),  inf),
    \osc2Lvl,      Pn(Pdefn(\mD_osc2Lvl),  inf),
    \osc3Lvl,      Pn(Pdefn(\mD_osc3Lvl),  inf),
    \noiseLvl,     Pn(Pdefn(\mD_noiseLvl), inf),
    \noiseType,    Pn(Pdefn(\mD_noiseType), inf),

    // --- filter ---
    \cutoff,       Pn(Pdefn(\mD_cutoff),     inf),
    \emphasis,     Pn(Pdefn(\mD_emphasis),   inf),
    \kbdAmt,       Pn(Pdefn(\mD_kbdAmt),    inf),
    \contourAmt,   Pn(Pdefn(\mD_contourAmt), inf),
    \drive,        Pn(Pdefn(\mD_drive),      inf),

    // --- filter contour ---
    \fAtk,         Pn(Pdefn(\mD_fAtk), inf),
    \fDcy,         Pn(Pdefn(\mD_fDcy), inf),
    \fSus,         Pn(Pdefn(\mD_fSus), inf),

    // --- amp contour ---
    \aAtk,         Pn(Pdefn(\mD_aAtk), inf),
    \aDcy,         Pn(Pdefn(\mD_aDcy), inf),
    \aSus,         Pn(Pdefn(\mD_aSus), inf),

    // --- decay switch ---
    \decayOn,      Pn(Pdefn(\mD_decayOn), inf),

    // --- mod wheel ---
    \modWheel,     Pn(Pdefn(\mD_modWheel),   inf),
    \modToOsc,     Pn(Pdefn(\mD_modToOsc),   inf),
    \modToFilter,  Pn(Pdefn(\mD_modToFilter), inf),
    \modSource,    Pn(Pdefn(\mD_modSource),  inf),
));
~lpBind.([1,  7], \modelD,  12);
)

