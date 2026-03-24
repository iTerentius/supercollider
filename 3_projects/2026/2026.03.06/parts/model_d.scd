// model_d — Minimoog Model D
// Re-eval this file to update Pdefns while preserving playback sync.
// _0 = sane default (use to reset). Add _1, _2 for variations.
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\modelD,
    Pbindef(\pbd_mD,
    // Pbind(
        \instrument,   \modelD,
        \out,          Pn(Pdefn(\mD_out),  inf),

        // --- pitch / gate ---
        \scale,        Pn(Pdefn(\mD_scale),  inf),
        \root,        0,  
        \degree,       Pn(Pdefn(\mD_degs),   inf),
        \octave,       Pn(Pdefn(\mD_octs),   inf),
        \dur,          Pn(Pdefn(\mD_durs),   inf),
        \stretch,      Pn(Pdefn(\mD_strs),   inf),
        \legato,       Pn(Pdefn(\mD_legs),   inf),
        \amp,          Pn(Pdefn(\mD_amps),   inf),
        \timeOffset,  1/2,  

        // --- glide ---
        \glide,        Pn(Pdefn(\mD_glides),  inf),

        // --- osc 1 ---
        \osc1Wave,     Pn(Pdefn(\mD_osc1Wave), inf),
        \osc1Oct,      Pn(Pdefn(\mD_osc1Oct),  inf),

        // --- osc 2 ---
        \osc2Wave,     Pn(Pdefn(\mD_osc2Wave), inf),
        \osc2Oct,      Pn(Pdefn(\mD_osc2Oct),  inf),
        \osc2Fine,     Pn(Pdefn(\mD_osc2Fine), inf),

        // --- osc 3 ---
        \osc3Wave,     Pn(Pdefn(\mD_osc3Wave),     inf),
        \osc3Oct,      Pn(Pdefn(\mD_osc3Oct),      inf),
        \osc3Fine,     Pn(Pdefn(\mD_osc3Fine),     inf),
        \osc3KbdTrack, Pn(Pdefn(\mD_osc3KbdTrack), inf),
        \osc3Freq,     Pn(Pdefn(\mD_osc3Freq),     inf),

        // --- oscillator mixer ---
        \osc1Lvl,      Pn(Pdefn(\mD_osc1Lvl),  inf),
        \osc2Lvl,      Pn(Pdefn(\mD_osc2Lvl),  inf),
        \osc3Lvl,      Pn(Pdefn(\mD_osc3Lvl),  inf),
        \noiseLvl,     Pn(Pdefn(\mD_noiseLvl), inf),
        \noiseType,    Pn(Pdefn(\mD_noiseType), inf),

        // --- filter ---
        \cutoff,       Pn(Pdefn(\mD_cutoff),      inf),
        \emphasis,     Pn(Pdefn(\mD_emphasis),     inf),
        \kbdAmt,       Pn(Pdefn(\mD_kbdAmt),      inf),
        \contourAmt,   Pn(Pdefn(\mD_contourAmt),   inf),
        \drive,        Pn(Pdefn(\mD_drive),        inf),

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
        \modWheel,     Pn(Pdefn(\mD_modWheel),    inf),
        \modToOsc,     Pn(Pdefn(\mD_modToOsc),    inf),
        \modToFilter,  Pn(Pdefn(\mD_modToFilter),  inf),
        \modSource,    Pn(Pdefn(\mD_modSource),   inf),
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\mD_out,   ~t8.inbus.index);
Pdefn(\mD_scale, Scale.minor);

// OCTAVE
Pdefn(\mD_oct_0, 5);              // 0..8
Pdefn(\mD_oct_1, Pseq([3, 4], 1));
Pdefn(\mD_octs, Pseq([
    Pn(Pdefn(\mD_oct_1), 4),
    // Pn(Pdefn(\mD_oct_1), 4),
], 1));

// DEGREE — words
Pdefn(\mD_deg_0, 0);
Pdefn(\mD_deg_1, Pslide([-3, [7, 2]], 8, 1, 0, 1));
Pdefn(\mD_deg_2, Pslide((0..-3), 1, 3, 1, 0));
Pdefn(\mD_deg_3, Pslide((-4..7), 2, 3, 1, 0));
// sentences
Pdefn(\mD_degs_a, Pseq([Pn(Pdefn(\mD_deg_0), 4)], 1));          // root pedal
Pdefn(\mD_degs_b, Pseq([Pn(Pdefn(\mD_deg_1), 1)], 1));          // slide phrase
Pdefn(\mD_degs_c, Pseq([Pn(Pdefn(\mD_deg_2), 2), Pn(Pdefn(\mD_deg_3), 2)], 1));
// story
Pdefn(\mD_degs, Pseq([Pn(Pdefn(\mD_degs_a), 1)], 1));

// DUR — words
Pdefn(\mD_dur_0, 1/4);
Pdefn(\mD_dur_1, Pseq([1/4!3, Rest(0.25), 1/4,  1/2, Rest(2.25)].flat, 1));
// sentences
Pdefn(\mD_durs_a, Pseq([Pn(Pdefn(\mD_dur_0), 4), Pn(Rest(), 4)], 1));  // sparse
Pdefn(\mD_durs_b, Pseq([Pn(Pdefn(\mD_dur_1), 4)], 1));                  // syncopated
// story
Pdefn(\mD_durs, Pseq([
  Pn(Pdefn(\mD_durs_b), 1), 
  // Pn(Pdefn(\mD_durs_b), 1)
], 1));

// STRETCH
Pdefn(\mD_str_0, 1);
Pdefn(\mD_strs, Pseq([
    Pn(Pdefn(\mD_str_0), 4),
], 1));

// LEGATO
Pdefn(\mD_leg_0, 0.8);            // 0..2+
Pdefn(\mD_leg_1, Pwhite(0.6, 1.0, 1));
Pdefn(\mD_leg_2, 1.8);            // 0..2+
Pdefn(\mD_legs, Pseq([
    Pn(Pdefn(\mD_leg_2), 4),
    Pn(Pdefn(\mD_leg_1), 4),
], 1));

// AMP
Pdefn(\mD_amp_0, 0.6);            // 0..1
Pdefn(\mD_amp_1, 0.8);
Pdefn(\mD_amps, Pseq([
    // Pn(Pdefn(\mD_amp_0), 4),
    Pn(Pdefn(\mD_amp_0), 4),
], 1));

// GLIDE
Pdefn(\mD_glide_0, 0.1);          // 0..10 sec  portamento
Pdefn(\mD_glide_1, 0.5);
Pdefn(\mD_glides, Pseq([
    Pn(Pdefn(\mD_glide_0), 4),
    // Pn(Pdefn(\mD_glide_1), 4),
], 1));

// OSC 1
Pdefn(\mD_osc1Wave_0, 3);         // 0=tri 1=inv-saw 2=saw 3=sq 4=wide 5=narrow
Pdefn(\mD_osc1Wave, Pseq([Pn(Pdefn(\mD_osc1Wave_0), 4)], 1));

Pdefn(\mD_osc1Oct_0, 0);  // -3..+3
Pdefn(\mD_osc1Oct_1, Pseq((0..2), 1));  // -3..+3
Pdefn(\mD_osc1Oct, Pseq([Pn(Pdefn(\mD_osc1Oct_0), 4)], 1));

// OSC 2
Pdefn(\mD_osc2Wave_0, 2);         // 0..5
Pdefn(\mD_osc2Wave_1, Pstep(Pseq([0,  4,  3,  5],  1)), 8);         // 0..5
Pdefn(\mD_osc2Wave, Pseq([Pn(Pdefn(\mD_osc2Wave_1), 4)], 1));

Pdefn(\mD_osc2Oct_0, 1);
Pdefn(\mD_osc2Oct_1, Pseq((0..2), 1));  // -3..+3
Pdefn(\mD_osc2Oct, Pseq([
    Pn(Pdefn(\mD_osc2Oct_0), 4),
    // Pn(Pdefn(\mD_osc2Oct_1), 4),
], 1));

Pdefn(\mD_osc2Fine_0, 0.0);       // ±7 semitones
Pdefn(\mD_osc2Fine, Pseq([Pn(Pdefn(\mD_osc2Fine_0), 4)], 1));

// OSC 3
Pdefn(\mD_osc3Wave_0, 0);         // 0=tri  2=saw  3=sq
Pdefn(\mD_osc3Wave_1, Pseq((0..4), 1));
Pdefn(\mD_osc3Wave, Pseq([
    // Pn(Pdefn(\mD_osc3Wave_0), 4),
    Pn(Pdefn(\mD_osc3Wave_0), 4),
], 1));

Pdefn(\mD_osc3Oct_0, 2);          // -3..+3
Pdefn(\mD_osc3Oct, Pseq([Pn(Pdefn(\mD_osc3Oct_0), 4)], 1));

Pdefn(\mD_osc3Fine_0, 0.0);       // ±7 semitones
Pdefn(\mD_osc3Fine_1, Pseg((0..-7), [1, 8], \sin, 1));       // ±7 semitones
Pdefn(\mD_osc3Fine, Pseq([Pn(Pdefn(\mD_osc3Fine_0), 4)], 1));

Pdefn(\mD_osc3KbdTrack_0, 0);     // 0/1  (0=free LFO)
Pdefn(\mD_osc3KbdTrack_1, 1);     // 0/1  (0=free LFO)
Pdefn(\mD_osc3KbdTrack, Pseq([
  Pn(Pdefn(\mD_osc3KbdTrack_0), 1), 
  Pn(Pdefn(\mD_osc3KbdTrack_1), 1)
], 1));

Pdefn(\mD_osc3Freq_0, 2.0);       // 0.1..50 Hz  (LFO rate when kbdTrack=0)
Pdefn(\mD_osc3Freq, Pseq([Pn(Pdefn(\mD_osc3Freq_0), 4)], 1));

// MIXER
Pdefn(\mD_osc1Lvl_0, 0.7);        // 0..1
Pdefn(\mD_osc1Lvl, Pseq([Pn(Pdefn(\mD_osc1Lvl_0), 4)], 1));

Pdefn(\mD_osc2Lvl_0, 0.7);
Pdefn(\mD_osc2Lvl, Pseq([Pn(Pdefn(\mD_osc2Lvl_0), 4)], 1));

Pdefn(\mD_osc3Lvl_0, 0.7);        // add OSC3 as audio VCO
Pdefn(\mD_osc3Lvl, Pseq([Pn(Pdefn(\mD_osc3Lvl_0), 4)], 1));

Pdefn(\mD_noiseLvl_0, 0.5);       // 0..1
Pdefn(\mD_noiseLvl, Pseq([Pn(Pdefn(\mD_noiseLvl_0), 4)], 1));

Pdefn(\mD_noiseType_0, j);         // 0=white  1=pink
Pdefn(\mD_noiseType, Pseq([Pn(Pdefn(\mD_noiseType_0), 4)], 1));

// FILTER
Pdefn(\mD_cutoff_0, 700);         // 20..20000 Hz
Pdefn(\mD_cutoff_1, Pseg([400, 2000, 400], [4, 8], \sin, 1));
Pdefn(\mD_cutoff, Pseq([
    Pn(Pdefn(\mD_cutoff_0), 4),
    // Pn(Pdefn(\mD_cutoff_1), 4),
], 1));

Pdefn(\mD_emphasis_0, 0.2);        // 0..1  (self-osc above ~0.88)
Pdefn(\mD_emphasis_1, Pseg([0.2, 0.8, 0.2], [4, 8], \sin, 1));
Pdefn(\mD_emphasis, Pseq([
    Pn(Pdefn(\mD_emphasis_0), 4),
    // Pn(Pdefn(\mD_emphasis_1), 4),
], 1));

Pdefn(\mD_kbdAmt_0, 0.2);          // 0..1
Pdefn(\mD_kbdAmt, Pseq([Pn(Pdefn(\mD_kbdAmt_0), 4)], 1));

Pdefn(\mD_contourAmt_0, 0.7);      // 0..1
Pdefn(\mD_contourAmt_1, Pbrown(0.1, 1.0, 0.125, 1));
Pdefn(\mD_contourAmt, Pseq([
    Pn(Pdefn(\mD_contourAmt_0), 4),
    // Pn(Pdefn(\mD_contourAmt_1), 4),
], 1));

Pdefn(\mD_drive_0, 0.5);           // 0..1  (pre-filter saturation)
Pdefn(\mD_drive, Pseq([Pn(Pdefn(\mD_drive_0), 4)], 1));

// FILTER CONTOUR (ADS)
Pdefn(\mD_fAtk_0, 0.001);          // 0.001..5 sec
Pdefn(\mD_fAtk, Pseq([Pn(Pdefn(\mD_fAtk_0), 4)], 1));

Pdefn(\mD_fDcy_0, 0.2);            // 0.001..10 sec
Pdefn(\mD_fDcy, Pseq([Pn(Pdefn(\mD_fDcy_0), 4)], 1));

Pdefn(\mD_fSus_0, 0.5);            // 0..1
Pdefn(\mD_fSus, Pseq([Pn(Pdefn(\mD_fSus_0), 4)], 1));

// AMP CONTOUR (ADS)
Pdefn(\mD_aAtk_0, 0.001);          // 0.001..5 sec
Pdefn(\mD_aAtk, Pseq([Pn(Pdefn(\mD_aAtk_0), 4)], 1));

Pdefn(\mD_aDcy_0, 0.2);            // 0.001..10 sec
Pdefn(\mD_aDcy, Pseq([Pn(Pdefn(\mD_aDcy_0), 4)], 1));

Pdefn(\mD_aSus_0, 0.8);
Pdefn(\mD_aSus, Pseq([Pn(Pdefn(\mD_aSus_0), 4)], 1));

// DECAY SWITCH
Pdefn(\mD_decayOn_0, 1);           // 0/1  (1=rel@decay, 0=sustain-hold 60s)
Pdefn(\mD_decayOn, Pseq([Pn(Pdefn(\mD_decayOn_0), 4)], 1));

// MOD WHEEL
Pdefn(\mD_modWheel_0, 0.0);        // 0..1
Pdefn(\mD_modWheel, Pseq([Pn(Pdefn(\mD_modWheel_0), 4)], 1));

Pdefn(\mD_modToOsc_0, 0);          // 0/1
Pdefn(\mD_modToOsc, Pseq([Pn(Pdefn(\mD_modToOsc_0), 4)], 1));

Pdefn(\mD_modToFilter_0, 0);       // 0/1
Pdefn(\mD_modToFilter, Pseq([Pn(Pdefn(\mD_modToFilter_0), 4)], 1));

Pdefn(\mD_modSource_0, 0);         // 0=OSC3  1=white noise
Pdefn(\mD_modSource, Pseq([Pn(Pdefn(\mD_modSource_0), 4)], 1));
)
