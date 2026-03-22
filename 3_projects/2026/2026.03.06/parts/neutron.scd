// neutron — Behringer Neutron
// Re-eval this file to update Pdefns while preserving playback sync.
// _0 = sane default (use to reset). Add _1, _2 for variations.
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\neutron,
    Pbindef(\pbd_ntron, 
    // Pbind(
        \instrument, \neutron,
        \out,        Pn(Pdefn(\ntron_out),   inf),

        // --- pitch / gate ---
        \scale,      Pn(Pdefn(\ntron_scale),      inf),
        \octave,     Pn(Pdefn(\ntron_octs),       inf),
        \degree,     Pn(Pdefn(\ntron_degs),       inf),
        \dur,        Pn(Pdefn(\ntron_durs),       inf),
        // \timingOffset, Pn(Pdefn(\ntron_toff),     inf),  
        \timingOffset, nil,  
        \stretch,    Pn(Pdefn(\ntron_strs),       inf),
        \legato,     Pn(Pdefn(\ntron_legs),       inf),
        \amp,        Pn(Pdefn(\ntron_amps),       inf),

        // --- osc 1 ---
        \osc1Blend,  Pn(Pdefn(\ntron_osc1Blend),  inf),
        \osc1PW,     Pn(Pdefn(\ntron_osc1PW),     inf),
        \osc1Oct,    Pn(Pdefn(\ntron_osc1Oct),    inf),

        // --- osc 2 ---
        \osc2Blend,  Pn(Pdefn(\ntron_osc2Blend),  inf),
        \osc2PW,     Pn(Pdefn(\ntron_osc2PW),     inf),
        \osc2Oct,    Pn(Pdefn(\ntron_osc2Oct),    inf),
        \osc2Semi,   Pn(Pdefn(\ntron_osc2Semi),   inf),
        \osc2Fine,   Pn(Pdefn(\ntron_osc2Fine),   inf),
        \osc2Track,  Pn(Pdefn(\ntron_osc2Track),  inf),
        \sync,       Pn(Pdefn(\ntron_sync),       inf),

        // --- mixer ---
        \osc1Lvl,    Pn(Pdefn(\ntron_osc1Lvl),   inf),
        \osc2Lvl,    Pn(Pdefn(\ntron_osc2Lvl),   inf),
        \subLvl,     Pn(Pdefn(\ntron_subLvl),    inf),
        \noiseLvl,   Pn(Pdefn(\ntron_noiseLvl),  inf),

        // --- lfo ---
        \lfoRate,    Pn(Pdefn(\ntron_lfoRate),    inf),
        \lfoShape,   Pn(Pdefn(\ntron_lfoShape),   inf),
        \lfoToOsc1,  Pn(Pdefn(\ntron_lfoToOsc1),  inf),
        \lfoToOsc2,  Pn(Pdefn(\ntron_lfoToOsc2),  inf),
        \lfoToPW1,   Pn(Pdefn(\ntron_lfoToPW1),   inf),
        \lfoToPW2,   Pn(Pdefn(\ntron_lfoToPW2),   inf),
        \lfoToFilt,  Pn(Pdefn(\ntron_lfoToFilt),  inf),

        // --- filter ---
        \cutoff,     Pn(Pdefn(\ntron_cutoff),     inf),
        \res,        Pn(Pdefn(\ntron_res),        inf),
        \filterMode, Pn(Pdefn(\ntron_filterMode),  inf),
        \keyTrack,   Pn(Pdefn(\ntron_keyTrack),   inf),
        \env1Amt,    Pn(Pdefn(\ntron_env1Amt),    inf),

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
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\ntron_out,   ~t7.inbus.index);
Pdefn(\ntron_scale, Scale.minor);

// OCTAVE
Pdefn(\ntron_oct_0, 5);              // 0..8
Pdefn(\ntron_oct_1, Pseq([3, 5, 4], 1));
Pdefn(\ntron_octs, Pseq([
    // Pn(Pdefn(\ntron_oct_0), 2),
    Pn(Pdefn(\ntron_oct_1), 2),
], 1));

// DEGREE — words
Pdefn(\ntron_deg_0, 0);
Pdefn(\ntron_deg_1, Pslide((7..0),  2,  8, 1));
// sentences
Pdefn(\ntron_degs_a, Pseq([Pn(Pdefn(\ntron_deg_0), 4)], 1));   // root
Pdefn(\ntron_degs_b, Pseq([Pn(Pdefn(\ntron_deg_1), 4)], 1));   // random
// story
Pdefn(\ntron_degs, Pseq([
  Pn(Pdefn(\ntron_deg_0), 1), 
  // Pn(Pdefn(\ntron_deg_1), 1)
], 1));

// DUR — words
Pdefn(\ntron_dur_0, Pseq([1/4!2,  1/2, 11].flat,  1));
Pdefn(\ntron_dur_3, Pseq([1/4!8, Rest()*2].flat,  1));
Pdefn(\ntron_dur_1, Pseq([1/4!2, 1/2, 2,  Rest()].flat, 1));
Pdefn(\ntron_dur_2, Pbjorklund(5, 8, 1)/4);
// sentences
Pdefn(\ntron_durs_a, Pseq([Pn(Pdefn(\ntron_dur_0), 1)], 1));   // quarter notes
Pdefn(\ntron_durs_b, Pseq([Pn(Pdefn(\ntron_dur_0), 1), Pn(Pdefn(\ntron_dur_1), 4)], 1));
Pdefn(\ntron_durs_c, Pseq([Pn(Pdefn(\ntron_dur_2), 1)], 1));   // euclidean
// story
Pdefn(\ntron_durs, Pseq([
  Pn(Pdefn(\ntron_durs_a), 1), 
  // Pn(Rest(),  12), 
  Pn(Pdefn(\ntron_durs_b), 1), 
], 1));

Pdefn(\ntron_toff_0,  0);
Pdefn(\ntron_toff_1,  3);
Pdefn(\ntron_toff,  Pn(Pdefn(\ntron_toff_0),  1));
// STRETCH
Pdefn(\ntron_str_0, 1);
Pdefn(\ntron_str_1, Pseq([1!4, 2, 1/2!3].flat, 1));
Pdefn(\ntron_strs, Pseq([
    Pn(Pdefn(\ntron_str_0), 4),
    // Pn(Pdefn(\ntron_str_1), 4),
], 1));

// LEGATO
Pdefn(\ntron_leg_0, 0.8);            // 0..2+
Pdefn(\ntron_legs, Pseq([
    Pn(Pdefn(\ntron_leg_0), 4),
], 1));

// AMP
Pdefn(\ntron_amp_0, 0.4);            // 0..1
Pdefn(\ntron_amps, Pseq([
    Pn(Pdefn(\ntron_amp_0), 4),
], 1));

// OSC 1
Pdefn(\ntron_osc1Blend_0, 1.0);      // 0=saw  1=pulse
Pdefn(\ntron_osc1Blend_1, Pstep(Pseq([0, 1], 1), 1));
Pdefn(\ntron_osc1Blend, Pseq([
    Pn(Pdefn(\ntron_osc1Blend_0), 4),
    // Pn(Pdefn(\ntron_osc1Blend_1), 4),
], 1));

Pdefn(\ntron_osc1PW_0, 0.7);         // 0.01..0.99
Pdefn(\ntron_osc1PW_1, Pseg([0.1, 0.9, 0.1], [2, 4], \sin, inf));
Pdefn(\ntron_osc1PW, Pseq([
    Pn(Pdefn(\ntron_osc1PW_0), 4),
    // Pn(Pdefn(\ntron_osc1PW_1), 4),
], 1));

Pdefn(\ntron_osc1Oct_0, 1);          // -3..+3
Pdefn(\ntron_osc1Oct, Pseq([
    Pn(Pdefn(\ntron_osc1Oct_0), 4),
], 1));

// OSC 2
Pdefn(\ntron_osc2Blend_0, 0.5);      // 0=saw  0.5=pulse  1=tri
Pdefn(\ntron_osc2Blend, Pseq([
    Pn(Pdefn(\ntron_osc2Blend_0), 4),
], 1));

Pdefn(\ntron_osc2PW_0, 0.9);         // 0.01..0.99
Pdefn(\ntron_osc2PW, Pseq([
    Pn(Pdefn(\ntron_osc2PW_0), 4),
], 1));

Pdefn(\ntron_osc2Oct_0, 0);          // -3..+3
Pdefn(\ntron_osc2Oct, Pseq([
    Pn(Pdefn(\ntron_osc2Oct_0), 4),
], 1));

Pdefn(\ntron_osc2Semi_0, 0.0);       // semitones ±24
Pdefn(\ntron_osc2Semi, Pseq([
    Pn(Pdefn(\ntron_osc2Semi_0), 4),
], 1));

Pdefn(\ntron_osc2Fine_0, 0.0);       // cents ±100
Pdefn(\ntron_osc2Fine, Pseq([
    Pn(Pdefn(\ntron_osc2Fine_0), 4),
], 1));

Pdefn(\ntron_osc2Track_0, 1);        // 0/1  (0=free LFO)
Pdefn(\ntron_osc2Track, Pseq([
    Pn(Pdefn(\ntron_osc2Track_0), 4),
], 1));

Pdefn(\ntron_sync_0, 1);             // 0/1  hard sync OSC2→OSC1
Pdefn(\ntron_sync, Pseq([
    Pn(Pdefn(\ntron_sync_0), 4),
], 1));

// MIXER
Pdefn(\ntron_osc1Lvl_0, 0.7);        // 0..1
Pdefn(\ntron_osc1Lvl, Pseq([
    Pn(Pdefn(\ntron_osc1Lvl_0), 4),
], 1));

Pdefn(\ntron_osc2Lvl_0, 0.7);
Pdefn(\ntron_osc2Lvl, Pseq([
    Pn(Pdefn(\ntron_osc2Lvl_0), 4),
], 1));

Pdefn(\ntron_subLvl_0, 0.5);         // 0..1  square -1 oct
Pdefn(\ntron_subLvl, Pseq([
    Pn(Pdefn(\ntron_subLvl_0), 4),
], 1));

Pdefn(\ntron_noiseLvl_0, 0.2);       // 0..1  white noise
Pdefn(\ntron_noiseLvl, Pseq([
    Pn(Pdefn(\ntron_noiseLvl_0), 4),
], 1));

// LFO
Pdefn(\ntron_lfoRate_0, 0.2);        // 0.01..10000 Hz
Pdefn(\ntron_lfoRate, Pseq([
    Pn(Pdefn(\ntron_lfoRate_0), 4),
], 1));

Pdefn(\ntron_lfoShape_0, 0);         // 0=sin 1=tri 2=saw 3=ramp 4=square
Pdefn(\ntron_lfoShape, Pseq([
    Pn(Pdefn(\ntron_lfoShape_0), 4),
], 1));

Pdefn(\ntron_lfoToOsc1_0, 1.0);      // -1..+1
Pdefn(\ntron_lfoToOsc1, Pseq([
    Pn(Pdefn(\ntron_lfoToOsc1_0), 4),
], 1));

Pdefn(\ntron_lfoToOsc2_0, -1.0);
Pdefn(\ntron_lfoToOsc2, Pseq([
    Pn(Pdefn(\ntron_lfoToOsc2_0), 4),
], 1));

Pdefn(\ntron_lfoToPW1_0, 1.0);       // -1..+1
Pdefn(\ntron_lfoToPW1, Pseq([
    Pn(Pdefn(\ntron_lfoToPW1_0), 4),
], 1));

Pdefn(\ntron_lfoToPW2_0, 1.0);
Pdefn(\ntron_lfoToPW2, Pseq([
    Pn(Pdefn(\ntron_lfoToPW2_0), 4),
], 1));

Pdefn(\ntron_lfoToFilt_0, 0.5);      // -1..+1
Pdefn(\ntron_lfoToFilt, Pseq([
    Pn(Pdefn(\ntron_lfoToFilt_0), 4),
], 1));

// FILTER
Pdefn(\ntron_cutoff_0, Pseg([500, 2000, 500], [2, 4], \sin, 1));  // 20..20000 Hz
Pdefn(\ntron_cutoff_1, 2000);
Pdefn(\ntron_cutoff, Pseq([
    // Pn(Pdefn(\ntron_cutoff_0), 4),
    Pn(Pdefn(\ntron_cutoff_1), 4),
], 1));

Pdefn(\ntron_res_0, 0.2);            // 0..1  (self-osc above ~0.88)
Pdefn(\ntron_res, Pseq([
    Pn(Pdefn(\ntron_res_0), 4),
], 1));

Pdefn(\ntron_filterMode_0, 0);       // 0=LP  1=BP  2=HP
Pdefn(\ntron_filterMode_1, Pseq((0..2), inf));
Pdefn(\ntron_filterMode, Pseq([
    Pn(Pdefn(\ntron_filterMode_0), 4),
    // Pn(Pdefn(\ntron_filterMode_1), 4),
], 1));

Pdefn(\ntron_keyTrack_0, 0.5);       // 0..1
Pdefn(\ntron_keyTrack, Pseq([
    Pn(Pdefn(\ntron_keyTrack_0), 4),
], 1));

Pdefn(\ntron_env1Amt_0, 1.0);        // -1..+1
Pdefn(\ntron_env1Amt_1, Pseg([1, -1,  1], [2, 4], \sin, 1));        // -1..+1
Pdefn(\ntron_env1Amt, Pseq([
    // Pn(Pdefn(\ntron_env1Amt_0), 4),
    Pn(Pdefn(\ntron_env1Amt_1), 4),
], 1));

// ENV 1 (filter)
Pdefn(\ntron_atk1_0, 0.01);          // 0.001..30 sec
Pdefn(\ntron_atk1, Pseq([Pn(Pdefn(\ntron_atk1_0), 4)], 1));

Pdefn(\ntron_dcy1_0, 0.3);
Pdefn(\ntron_dcy1, Pseq([Pn(Pdefn(\ntron_dcy1_0), 4)], 1));

Pdefn(\ntron_sus1_0, 0.5);           // 0..1
Pdefn(\ntron_sus1, Pseq([Pn(Pdefn(\ntron_sus1_0), 4)], 1));

Pdefn(\ntron_rel1_0, 0.3);
Pdefn(\ntron_rel1, Pseq([Pn(Pdefn(\ntron_rel1_0), 4)], 1));

// ENV 2 (amp)
Pdefn(\ntron_atk2_0, 0.01);
Pdefn(\ntron_atk2, Pseq([Pn(Pdefn(\ntron_atk2_0), 4)], 1));

Pdefn(\ntron_dcy2_0, 0.1);
Pdefn(\ntron_dcy2, Pseq([Pn(Pdefn(\ntron_dcy2_0), 4)], 1));

Pdefn(\ntron_sus2_0, 0.9);
Pdefn(\ntron_sus2, Pseq([Pn(Pdefn(\ntron_sus2_0), 4)], 1));

Pdefn(\ntron_rel2_0, 0.3);
Pdefn(\ntron_rel2, Pseq([Pn(Pdefn(\ntron_rel2_0), 4)], 1));

// DRIVE
Pdefn(\ntron_drive_0, 0.0);          // 0..1
Pdefn(\ntron_drive, Pseq([Pn(Pdefn(\ntron_drive_0), 4)], 1));

Pdefn(\ntron_driveTone_0, 0.5);      // 0=dark  1=bright
Pdefn(\ntron_driveTone, Pseq([Pn(Pdefn(\ntron_driveTone_0), 4)], 1));

Pdefn(\ntron_driveLevel_0, 0.8);     // 0..1
Pdefn(\ntron_driveLevel, Pseq([Pn(Pdefn(\ntron_driveLevel_0), 4)], 1));

// DELAY
Pdefn(\ntron_delTime_0, 0.25);       // 0.001..2.0 sec
Pdefn(\ntron_delTime, Pseq([Pn(Pdefn(\ntron_delTime_0), 4)], 1));

Pdefn(\ntron_delFB_0, 0.3);          // 0..1
Pdefn(\ntron_delFB, Pseq([Pn(Pdefn(\ntron_delFB_0), 4)], 1));

Pdefn(\ntron_delMix_0, 0.2);         // 0=dry  1=wet
Pdefn(\ntron_delMix, Pseq([Pn(Pdefn(\ntron_delMix_0), 4)], 1));
)
