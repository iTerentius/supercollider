
(
Pdef(\neutron, Pbind(
    \instrument, \neutron,
    \out,        Pn(Pdefn(\ntron_out),  inf), 

    // --- pitch / gate ---
    \scale,      Pn(Pdefn(\ntron_scale),   inf),
    \octave,     Pn(Pdefn(\ntron_octs),    inf),
    \degree,     Pn(Pdefn(\ntron_degs),    inf),
    \dur,        Pn(Pdefn(\ntron_durs),    inf),
    \stretch,    Pn(Pdefn(\ntron_strs),    inf),
    \legato,     Pn(Pdefn(\ntron_legs),    inf),
    \amp,        Pn(Pdefn(\ntron_amps),    inf),

    // --- osc 1 ---
    \osc1Blend,  Pn(Pdefn(\ntron_osc1Blend), inf),
    \osc1PW,     Pn(Pdefn(\ntron_osc1PW),   inf),
    \osc1Oct,    Pn(Pdefn(\ntron_osc1Oct),  inf),

    // --- osc 2 ---
    \osc2Blend,  Pn(Pdefn(\ntron_osc2Blend), inf),
    \osc2PW,     Pn(Pdefn(\ntron_osc2PW),    inf),
    \osc2Oct,    Pn(Pdefn(\ntron_osc2Oct),   inf),
    \osc2Semi,   Pn(Pdefn(\ntron_osc2Semi),  inf),
    \osc2Fine,   Pn(Pdefn(\ntron_osc2Fine),  inf),
    \osc2Track,  Pn(Pdefn(\ntron_osc2Track), inf),
    \sync,       Pn(Pdefn(\ntron_sync),      inf),

    // --- mixer ---
    \osc1Lvl,    Pn(Pdefn(\ntron_osc1Lvl),  inf),
    \osc2Lvl,    Pn(Pdefn(\ntron_osc2Lvl),  inf),
    \subLvl,     Pn(Pdefn(\ntron_subLvl),   inf),
    \noiseLvl,   Pn(Pdefn(\ntron_noiseLvl), inf),

    // --- lfo ---
    \lfoRate,    Pn(Pdefn(\ntron_lfoRate),   inf),
    \lfoShape,   Pn(Pdefn(\ntron_lfoShape),  inf),
    \lfoToOsc1,  Pn(Pdefn(\ntron_lfoToOsc1), inf),
    \lfoToOsc2,  Pn(Pdefn(\ntron_lfoToOsc2), inf),
    \lfoToPW1,   Pn(Pdefn(\ntron_lfoToPW1),  inf),
    \lfoToPW2,   Pn(Pdefn(\ntron_lfoToPW2),  inf),
    \lfoToFilt,  Pn(Pdefn(\ntron_lfoToFilt), inf),

    // --- filter ---
    \cutoff,     Pn(Pdefn(\ntron_cutoff),    inf),
    \res,        Pn(Pdefn(\ntron_res),       inf),
    \filterMode, Pn(Pdefn(\ntron_filterMode), inf),
    \keyTrack,   Pn(Pdefn(\ntron_keyTrack),  inf),
    \env1Amt,    Pn(Pdefn(\ntron_env1Amt),   inf),

    // --- env 1 (filter) ---
    \atk1,       Pn(Pdefn(\ntron_atk1), inf),
    \dcy1,       Pn(Pdefn(\ntron_dcy1), inf),
    \sus1,       Pn(Pdefn(\ntron_sus1), inf),
    \rel1,       Pn(Pdefn(\ntron_rel1), inf),

    // --- env 2 (amp) ---
    \atk2,       Pn(Pdefn(\ntron_atk2), inf),
    \dcy2,       Pn(Pdefn(\ntron_dcy2), inf),
    \sus2,       Pn(Pdefn(\ntron_sus2), inf),
    \rel2,       Pn(Pdefn(\ntron_rel2), inf),

    // --- drive ---
    \drive,      Pn(Pdefn(\ntron_drive),      inf),
    \driveTone,  Pn(Pdefn(\ntron_driveTone),  inf),
    \driveLevel, Pn(Pdefn(\ntron_driveLevel), inf),

    // --- delay ---
    \delTime,    Pn(Pdefn(\ntron_delTime), inf),
    \delFB,      Pn(Pdefn(\ntron_delFB),   inf),
    \delMix,     Pn(Pdefn(\ntron_delMix),  inf),
));
~lpBind.([1, 6], \neutron, 22);
)
