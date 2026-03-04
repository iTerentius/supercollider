(
"fx_buscuit-pat.scd".loadRelative;
///////////////////////////////////////////////////////////////
// OTO BISCUIT — phrase parameter banks
// _0 = sane default (use to reset). Add _1, _2 for variations.
// Wire into Pdef with:  Pn(Pdefn(\bsct_param), inf)
///////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////
// DUR
Pdefn(\bsct_dur_0, 1);
Pdefn(\bsct_dur_1, Pseq([1/4, 1,  1/2!2].flat, 1));
Pdefn(\bsct_durs, Pseq([
  // Pn(Pdefn(\bsct_dur_0),  4),
  Pn(Pdefn(\bsct_dur_1),  4),
],  1));

///////////////////////////////////////////////////////////////
// INPUT
Pdefn(\bsct_drive_0, 1.0);          // 1.0..5.6  (+0 to +15dB)
Pdefn(\bsct_drive_1, 1.0);          // 1.0..5.6  (+0 to +15dB)
Pdefn(\bsct_drive, Pseq([
  Pn(Pdefn(\bsct_drive_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// BITCRUSHER
Pdefn(\bsct_clock_0, 30000);        // 250..30000 Hz  (30000 = transparent)
Pdefn(\bsct_clock_1, Pseq([300, 3000, 30000], 1));        // 250..30000 Hz  (30000 = transparent)
Pdefn(\bsct_clock, Pseq([
  // Pn(Pdefn(\bsct_clock_0),  4),
  Pn(Pdefn(\bsct_clock_1),  4),
],  1));

Pdefn(\bsct_bits_0, 4);             // 1..8  (8 = transparent)
Pdefn(\bsct_bits, Pseq([
  Pn(Pdefn(\bsct_bits_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// BIT MANIPULATION  (-1=invert  0=mute  1=pass)
Pdefn(\bsct_b1_0, 1);               // LSB / bit 0  (subtle)
Pdefn(\bsct_b1_0, Pseq([-1, 0, 1],  1));               // LSB / bit 0  (subtle)
Pdefn(\bsct_b1, Pseq([
  // Pn(Pdefn(\bsct_b1_0),  4),
  Pn(Pdefn(\bsct_b1_1),  4),
],  1));

Pdefn(\bsct_b2_0, 1);
Pdefn(\bsct_b2, Pseq([
  Pn(Pdefn(\bsct_b2_0),  4),
],  1));

Pdefn(\bsct_b3_0, 1);
Pdefn(\bsct_b3, Pseq([
  Pn(Pdefn(\bsct_b3_0),  4),
],  1));

Pdefn(\bsct_b4_0, 1);
Pdefn(\bsct_b4, Pseq([
  Pn(Pdefn(\bsct_b4_0),  4),
],  1));

Pdefn(\bsct_b5_0, 1);
Pdefn(\bsct_b5, Pseq([
  Pn(Pdefn(\bsct_b5_0),  4),
],  1));

Pdefn(\bsct_b6_0, 1);
Pdefn(\bsct_b6, Pseq([
  Pn(Pdefn(\bsct_b6_0),  4),
],  1));

Pdefn(\bsct_b7_0, 1);
Pdefn(\bsct_b7, Pseq([
  Pn(Pdefn(\bsct_b7_0),  4),
],  1));

Pdefn(\bsct_b8_0, 1);               // MSB / bit 7  (large tonal impact)
Pdefn(\bsct_b8, Pseq([
  Pn(Pdefn(\bsct_b8_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// FX MODE
Pdefn(\bsct_fxMode_0, 0);           // 0=waveshaper  1=delay  2=pitch  3=step filter
Pdefn(\bsct_fxMode, Pseq([
  Pn(Pdefn(\bsct_fxMode_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// WAVESHAPER  (fxMode=0)
Pdefn(\bsct_shape_0, 0);            // 0=fold  1=bat-fuzz  2=rectify  3=bitswap
                                     // 4=alt-rect  5=biscuit(-5th)  6=synth-saw  7=synth-sq
Pdefn(\bsct_shape, Pseq([
  Pn(Pdefn(\bsct_shape_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// DELAY  (fxMode=1)
Pdefn(\bsct_delTime_0, 0.25);       // 0.001..2.0 sec
Pdefn(\bsct_delTime, Pseq([
  Pn(Pdefn(\bsct_delTime_0),  4),
],  1));

Pdefn(\bsct_delFB_0, 0.3);          // 0..1  (above ~0.9 → runaway)
Pdefn(\bsct_delFB, Pseq([
  Pn(Pdefn(\bsct_delFB_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// PITCH SHIFTER  (fxMode=2)
Pdefn(\bsct_pitchShift_0, 5);       // 0=−2oct  1=−5th  2=−1oct  3=−5th
                                     // 4=−4th   5=unison  6=+5th  7=+1oct
Pdefn(\bsct_pitchShift, Pseq([
  Pn(Pdefn(\bsct_pitchShift_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// STEP FILTER  (fxMode=3)
Pdefn(\bsct_stepRate_0, 4.0);       // 0.1..40 Hz
Pdefn(\bsct_stepRate, Pseq([
  Pn(Pdefn(\bsct_stepRate_0),  4),
],  1));

Pdefn(\bsct_sf0_0, 200);            // 20..20000 Hz  step 0 LP cutoff
Pdefn(\bsct_sf0, Pseq([
  Pn(Pdefn(\bsct_sf0_0),  4),
],  1));

Pdefn(\bsct_sf1_0, 400);
Pdefn(\bsct_sf1, Pseq([
  Pn(Pdefn(\bsct_sf1_0),  4),
],  1));

Pdefn(\bsct_sf2_0, 800);
Pdefn(\bsct_sf2, Pseq([
  Pn(Pdefn(\bsct_sf2_0),  4),
],  1));

Pdefn(\bsct_sf3_0, 1600);
Pdefn(\bsct_sf3, Pseq([
  Pn(Pdefn(\bsct_sf3_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// ANALOG OUTPUT FILTER
Pdefn(\bsct_filterType_0, 0);       // 0=LP  1=BP  2=HP
Pdefn(\bsct_filterType, Pseq([
  Pn(Pdefn(\bsct_filterType_0),  4),
],  1));

Pdefn(\bsct_filterFreq_0, 15000);   // 20..20000 Hz  (15000 = open)
Pdefn(\bsct_filterFreq, Pseq([
  Pn(Pdefn(\bsct_filterFreq_0),  4),
],  1));

Pdefn(\bsct_filterQ_0, 0.1);        // 0..1
Pdefn(\bsct_filterQ, Pseq([
  Pn(Pdefn(\bsct_filterQ_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// WET / DRY
Pdefn(\bsct_naked_0,   1.0);        // 0..1  dry level
Pdefn(\bsct_naked, Pseq([
  Pn(Pdefn(\bsct_naked_0),  4),
],  1));

Pdefn(\bsct_dressed_0, 1.0);        // 0..1  wet level
Pdefn(\bsct_dressed, Pseq([
  Pn(Pdefn(\bsct_dressed_0),  4),
],  1));

)
