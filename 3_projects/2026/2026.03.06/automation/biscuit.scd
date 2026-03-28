// biscuit — OTO Biscuit FX control
// Re-eval this file to update Pdefns while preserving playback sync.
// _0 = sane default (use to reset). Add _1, _2 for variations.
// ~r3_fx node is created in lib/fx.scd
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\bCtl,
    Pbindef(\pbd_biscuit, 
        \type,       \set,
        \id,         Pfunc({ ~r3fx[\biscuit].nodeID }),
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
      )
    );

    ///////////////////////////////////////////////////////////////
    // PDEFNS
    ///////////////////////////////////////////////////////////////

    // DUR — words
    Pdefn(\bsct_dur_0, 1);
    Pdefn(\bsct_dur_1, Pseq([1/4, 1, 1/2!2].flat, 1));
    // sentences
    Pdefn(\bsct_durs_a, Pseq([Pn(Pdefn(\bsct_dur_0), 4)], 1));   // slow scan
    Pdefn(\bsct_durs_a, Pseq([Pn(Pdefn(\bsct_dur_1), 4)], 1));   // variable
    // story
    Pdefn(\bsct_durs, Pseq([Pn(Pdefn(\bsct_durs_a), 1)], 1));

    // INPUT
    Pdefn(\bsct_drive_0, 1.5);          // 1.0..5.6  (+0 to +15dB)
    Pdefn(\bsct_drive_1, 1.0);
    Pdefn(\bsct_drive, Pseq([
      Pn(Pdefn(\bsct_drive_0), 4),
    ], 1));

    // BITCRUSHER
    Pdefn(\bsct_clock_0, 30000);        // 250..30000 Hz  (30000=transparent)
    Pdefn(\bsct_clock_1, Pseq([300, 30000], 1));
    Pdefn(\bsct_clock_2, Pseg([300, 3000, 30000], [1, 2], \sin, 1));
    Pdefn(\bsct_clock, Pseq([
      // Pn(Pdefn(\bsct_clock_0), 4),
      Pn(Pdefn(\bsct_clock_2), 4),
    ], 1));

    Pdefn(\bsct_bits_0, 8);             // 1..8  (8=transparent)
    Pdefn(\bsct_bits_1,  Pwhite(1,  8,  1));
    Pdefn(\bsct_bits, Pseq([Pn(Pdefn(\bsct_bits_0), 4)], 1));

    // BIT MANIPULATION  (-1=invert  0=mute  1=pass)
    Pdefn(\bsct_b1_0, 1);               // LSB / bit 0  (subtle)
    Pdefn(\bsct_b1_1, Pseq([-1, 0, 1, 0, -1], 1));
    Pdefn(\bsct_b1, Pseq([
      // Pn(Pdefn(\bsct_b1_0), 4),
      Pn(Pdefn(\bsct_b1_1), 4),
    ], 1));

    Pdefn(\bsct_b2_0, 0);
    Pdefn(\bsct_b2_1, Pseq([-1, 0, 1, 0, -1] * -1, 1));
    Pdefn(\bsct_b2, Pseq([
      Pn(Pdefn(\bsct_b2_0), 4),
      // Pn(Pdefn(\bsct_b2_1), 4),
    ], 1));

    Pdefn(\bsct_b3_0, -1);
    Pdefn(\bsct_b3, Pseq([Pn(Pdefn(\bsct_b3_0), 4)], 1));

    Pdefn(\bsct_b4_0, 1);
    Pdefn(\bsct_b4, Pseq([Pn(Pdefn(\bsct_b4_0), 4)], 1));

    Pdefn(\bsct_b5_0, 1);
    Pdefn(\bsct_b5, Pseq([Pn(Pdefn(\bsct_b5_0), 4)], 1));

    Pdefn(\bsct_b6_0, 1);
    Pdefn(\bsct_b6, Pseq([Pn(Pdefn(\bsct_b6_0), 4)], 1));

    Pdefn(\bsct_b7_0, 1);
    Pdefn(\bsct_b7, Pseq([Pn(Pdefn(\bsct_b7_0), 4)], 1));

    Pdefn(\bsct_b8_0, 1);               // MSB / bit 7  (large tonal impact)
    Pdefn(\bsct_b8, Pseq([Pn(Pdefn(\bsct_b8_0), 4)], 1));

    // FX MODE
    Pdefn(\bsct_fxMode_0, 3);           // 0=waveshaper  1=delay  2=pitch  3=step filter
    Pdefn(\bsct_fxMode_1, Pwhite(0, 4,  1));           // 0=waveshaper  1=delay  2=pitch  3=step filter
    Pdefn(\bsct_fxMode, Pseq([Pn(Pdefn(\bsct_fxMode_0), 4)], 1));

    // WAVESHAPER  (fxMode=0)
    Pdefn(\bsct_shape_0, 1);            // 0=fold  1=bat-fuzz  2=rectify  3=bitswap
    // 4=alt-rect  5=biscuit(-5th)  6=synth-saw  7=synth-sq
    Pdefn(\bsct_shape, Pseq([Pn(Pdefn(\bsct_shape_0), 4)], 1));

    // DELAY  (fxMode=1)
    Pdefn(\bsct_delTime_0, 0.25);       // 0.001..2.0 sec
    Pdefn(\bsct_delTime, Pseq([Pn(Pdefn(\bsct_delTime_0), 4)], 1));

    Pdefn(\bsct_delFB_0, 0.3);          // 0..1  (above ~0.9 → runaway)
    Pdefn(\bsct_delFB, Pseq([Pn(Pdefn(\bsct_delFB_0), 4)], 1));

    // PITCH SHIFTER  (fxMode=2)
    Pdefn(\bsct_pitchShift_0, 5);       // 0=−2oct  1=−5th  2=−1oct  3=−5th
    // 4=−4th   5=unison  6=+5th  7=+1oct
    Pdefn(\bsct_pitchShift, Pseq([Pn(Pdefn(\bsct_pitchShift_0), 4)], 1));

    // STEP FILTER  (fxMode=3)
    Pdefn(\bsct_stepRate_0, 4.0);       // 0.1..40 Hz
    Pdefn(\bsct_stepRate_1, Pseq([1, 2, 4, 8], 1));
    Pdefn(\bsct_stepRate_2, Pseq((1..8), 1));
    Pdefn(\bsct_stepRate, Pseq([
      // Pn(Pdefn(\bsct_stepRate_0), 4),
      // Pn(Pdefn(\bsct_stepRate_1), 4),
      Pn(Pdefn(\bsct_stepRate_2), 4),
    ], 1));

    Pdefn(\bsct_sf0_0, 200);            // 20..20000 Hz  step 0 LP cutoff
    Pdefn(\bsct_sf0, Pseq([Pn(Pdefn(\bsct_sf0_0), 4)], 1));

    Pdefn(\bsct_sf1_0, 400);
    Pdefn(\bsct_sf1, Pseq([Pn(Pdefn(\bsct_sf1_0), 4)], 1));

    Pdefn(\bsct_sf2_0, 800);
    Pdefn(\bsct_sf2, Pseq([Pn(Pdefn(\bsct_sf2_0), 4)], 1));

    Pdefn(\bsct_sf3_0, 1600);
    Pdefn(\bsct_sf3, Pseq([Pn(Pdefn(\bsct_sf3_0), 4)], 1));

    // ANALOG OUTPUT FILTER
    Pdefn(\bsct_filterType_0, 0);       // 0=LP  1=BP  2=HP
    Pdefn(\bsct_filterType, Pseq([Pn(Pdefn(\bsct_filterType_0), 4)], 1));

    Pdefn(\bsct_filterFreq_0, 15000);   // 20..20000 Hz  (15000=open)
    Pdefn(\bsct_filterFreq_1, Pseg([500, 1500, 500], [1, 2], \sin, 1));
    Pdefn(\bsct_filterFreq, Pseq([
      Pn(Pdefn(\bsct_filterFreq_0), 4),
      Pn(Pdefn(\bsct_filterFreq_1), 4),
    ], 1));

    Pdefn(\bsct_filterQ_0, 0.2);        // 0..1
    Pdefn(\bsct_filterQ_1, Pseg([0.0, 1.0, 0.0], [2, 4], \step, 1));
    Pdefn(\bsct_filterQ, Pseq([
      Pn(Pdefn(\bsct_filterQ_0), 4),
      // Pn(Pdefn(\bsct_filterQ_1), 4),
    ], 1));

    // WET / DRY
    Pdefn(\bsct_naked_0,   0.8);        // 0..1  dry level
    Pdefn(\bsct_naked, Pseq([Pn(Pdefn(\bsct_naked_0), 4)], 1));

    Pdefn(\bsct_dressed_0, 1.5);        // 0..2  wet level
    Pdefn(\bsct_dressed, Pseq([Pn(Pdefn(\bsct_dressed_0), 4)], 1));
  )
