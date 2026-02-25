(
///////////////////////////////////////////////////////////////
// NEUTRON — phrase parameter banks
// _0 = sane default (use to reset). Add _1, _2 for variations.
// Wire into Pdef with:  Pn(Pdefn(\ntron_param), inf)
///////////////////////////////////////////////////////////////

Pdefn(\ntron_out,   ~t6.inbus.index);
Pdefn(\ntron_scale, Scale.minor);

///////////////////////////////////////////////////////////////
// OCTAVE
Pdefn(\ntron_oct_0, 4);              // 0..8
Pdefn(\ntron_oct_1, Pseq([3, 4,  ], 1)); 
Pdefn(\ntron_octs, Pseq([
  // Pn(Pdefn(\ntron_oct_0),  4),
  Pn(Pdefn(\ntron_oct_1),  4),
],  1));

///////////////////////////////////////////////////////////////
// DEGREE
Pdefn(\ntron_deg_0, 0);
Pdefn(\ntron_deg_1, Prand((0..7),  1));
Pdefn(\ntron_degs, Pseq([
  // Pn(Pdefn(\ntron_deg_0),  4),
  Pn(Pdefn(\ntron_deg_1),  4),
],  1));

///////////////////////////////////////////////////////////////
// DUR
Pdefn(\ntron_dur_0, 1);
Pdefn(\ntron_dur_1, Pseq([1/4!2, 1/2].flat, 1));
Pdefn(\ntron_dur_2, Pbjorklund(5,  8,  1)/2);
Pdefn(\ntron_durs, Pseq([
  // Pn(Pdefn(\ntron_dur_0),  4),
  Pn(Pdefn(\ntron_dur_1),  4),
  // Pn(Pdefn(\ntron_dur_2),  4),
],  1));

///////////////////////////////////////////////////////////////
// STRETCH
Pdefn(\ntron_str_0, 1);
Pdefn(\ntron_str_1, Pseq([1!3, 2,  1/2!2].flat, 1));
Pdefn(\ntron_strs, Pseq([
  // Pn(Pdefn(\ntron_str_0),  4),
  Pn(Pdefn(\ntron_str_1),  4),
],  1));

///////////////////////////////////////////////////////////////
// LEGATO
Pdefn(\ntron_leg_0, 0.8);            // 0..2+
Pdefn(\ntron_legs, Pseq([
  Pn(Pdefn(\ntron_leg_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// AMP
Pdefn(\ntron_amp_0, 0.7);            // 0..1
Pdefn(\ntron_amps, Pseq([
  Pn(Pdefn(\ntron_amp_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// OSC 1
Pdefn(\ntron_osc1Blend_0, 0.0);      // 0=saw  1=pulse
Pdefn(\ntron_osc1Blend_1, Pstep(Pseq([0,1],  1), 1));      // 0=saw  1=pulse
Pdefn(\ntron_osc1Blend, Pseq([
  Pn(Pdefn(\ntron_osc1Blend_0),  4),
  // Pn(Pdefn(\ntron_osc1Blend_1),  4),
],  1));

Pdefn(\ntron_osc1PW_0, 0.5);         // 0.01..0.99
Pdefn(\ntron_osc1PW_1, Pseg([0.1, 0.9,  0.1], [1, 2], \sin, inf));         // 0.01..0.99
Pdefn(\ntron_osc1PW, Pseq([
  // Pn(Pdefn(\ntron_osc1PW_0),  4),
  Pn(Pdefn(\ntron_osc1PW_1),  4),
],  1));

Pdefn(\ntron_osc1Oct_0, 0);          // -3..+3
Pdefn(\ntron_osc1Oct, Pseq([
  Pn(Pdefn(\ntron_osc1Oct_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// OSC 2
Pdefn(\ntron_osc2Blend_0, 0.0);      // 0=saw  0.5=pulse  1=tri
Pdefn(\ntron_osc2Blend, Pseq([
  Pn(Pdefn(\ntron_osc2Blend_0),  4),
],  1));

Pdefn(\ntron_osc2PW_0, 0.5);         // 0.01..0.99
Pdefn(\ntron_osc2PW, Pseq([
  Pn(Pdefn(\ntron_osc2PW_0),  4),
],  1));

Pdefn(\ntron_osc2Oct_0, 0);          // -3..+3
Pdefn(\ntron_osc2Oct, Pseq([
  Pn(Pdefn(\ntron_osc2Oct_0),  4),
],  1));

Pdefn(\ntron_osc2Semi_0, 0.0);       // semitones ±24
Pdefn(\ntron_osc2Semi, Pseq([
  Pn(Pdefn(\ntron_osc2Semi_0),  4),
],  1));

Pdefn(\ntron_osc2Fine_0, 0.0);       // cents ±100
Pdefn(\ntron_osc2Fine, Pseq([
  Pn(Pdefn(\ntron_osc2Fine_0),  4),
],  1));

Pdefn(\ntron_osc2Track_0, 1);        // 0/1  (0=free LFO)
Pdefn(\ntron_osc2Track, Pseq([
  Pn(Pdefn(\ntron_osc2Track_0),  4),
],  1));

Pdefn(\ntron_sync_0, 0);             // 0/1  hard sync OSC2→OSC1
Pdefn(\ntron_sync, Pseq([
  Pn(Pdefn(\ntron_sync_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// MIXER
Pdefn(\ntron_osc1Lvl_0, 0.7);        // 0..1
Pdefn(\ntron_osc1Lvl, Pseq([
  Pn(Pdefn(\ntron_osc1Lvl_0),  4),
],  1));

Pdefn(\ntron_osc2Lvl_0, 0.7);
Pdefn(\ntron_osc2Lvl, Pseq([
  Pn(Pdefn(\ntron_osc2Lvl_0),  4),
],  1));

Pdefn(\ntron_subLvl_0, 0.0);         // 0..1  square -1 oct
Pdefn(\ntron_subLvl, Pseq([
  Pn(Pdefn(\ntron_subLvl_0),  4),
],  1));

Pdefn(\ntron_noiseLvl_0, 0.0);       // 0..1  white noise
Pdefn(\ntron_noiseLvl, Pseq([
  Pn(Pdefn(\ntron_noiseLvl_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// LFO
Pdefn(\ntron_lfoRate_0, 1.0);        // 0.01..10000 Hz (audio-rate above ~20)
Pdefn(\ntron_lfoRate, Pseq([
  Pn(Pdefn(\ntron_lfoRate_0),  4),
],  1));

Pdefn(\ntron_lfoShape_0, 0);         // 0=sin 1=tri 2=saw 3=ramp 4=square
Pdefn(\ntron_lfoShape, Pseq([
  Pn(Pdefn(\ntron_lfoShape_0),  4),
],  1));

Pdefn(\ntron_lfoToOsc1_0, 0.0);      // -1..+1  → ±5% pitch
Pdefn(\ntron_lfoToOsc1, Pseq([
  Pn(Pdefn(\ntron_lfoToOsc1_0),  4),
],  1));

Pdefn(\ntron_lfoToOsc2_0, 0.0);
Pdefn(\ntron_lfoToOsc2, Pseq([
  Pn(Pdefn(\ntron_lfoToOsc2_0),  4),
],  1));

Pdefn(\ntron_lfoToPW1_0, 0.0);       // -1..+1  → ±0.4 PW sweep
Pdefn(\ntron_lfoToPW1, Pseq([
  Pn(Pdefn(\ntron_lfoToPW1_0),  4),
],  1));

Pdefn(\ntron_lfoToPW2_0, 0.0);
Pdefn(\ntron_lfoToPW2, Pseq([
  Pn(Pdefn(\ntron_lfoToPW2_0),  4),
],  1));

Pdefn(\ntron_lfoToFilt_0, 0.0);      // -1..+1  → ±24 semitones cutoff
Pdefn(\ntron_lfoToFilt, Pseq([
  Pn(Pdefn(\ntron_lfoToFilt_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// FILTER
Pdefn(\ntron_cutoff_0, 2000);        // 20..20000 Hz
Pdefn(\ntron_cutoff_0, Pseg([500, 100,  2000],  [1, 4],  \sin, 1)); 
Pdefn(\ntron_cutoff, Pseq([
  Pn(Pdefn(\ntron_cutoff_0),  4),
  Pn(Pdefn(\ntron_cutoff_1),  4),
],  1));

Pdefn(\ntron_res_0, 0.2);            // 0..1  (self-osc above ~0.88)
Pdefn(\ntron_res, Pseq([
  Pn(Pdefn(\ntron_res_0),  4),
],  1));

Pdefn(\ntron_filterMode_0, 0);       // 0=LP  1=BP  2=HP
Pdefn(\ntron_filterMode_1, Pseq((0..2), inf));
Pdefn(\ntron_filterMode, Pseq([
  Pn(Pdefn(\ntron_filterMode_0),  4),
  Pn(Pdefn(\ntron_filterMode_1),  4),
],  1));

Pdefn(\ntron_keyTrack_0, 0.0);       // 0..1
Pdefn(\ntron_keyTrack, Pseq([
  Pn(Pdefn(\ntron_keyTrack_0),  4),
],  1));

Pdefn(\ntron_env1Amt_0, 0.5);        // -1..+1  (neg = inverted)
Pdefn(\ntron_env1Amt, Pseq([
  Pn(Pdefn(\ntron_env1Amt_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// ENV 1 (filter)
Pdefn(\ntron_atk1_0, 0.01);          // 0.001..30 sec
Pdefn(\ntron_atk1, Pseq([
  Pn(Pdefn(\ntron_atk1_0),  4),
],  1));

Pdefn(\ntron_dcy1_0, 0.3);
Pdefn(\ntron_dcy1, Pseq([
  Pn(Pdefn(\ntron_dcy1_0),  4),
],  1));

Pdefn(\ntron_sus1_0, 0.5);           // 0..1
Pdefn(\ntron_sus1, Pseq([
  Pn(Pdefn(\ntron_sus1_0),  4),
],  1));

Pdefn(\ntron_rel1_0, 0.3);
Pdefn(\ntron_rel1, Pseq([
  Pn(Pdefn(\ntron_rel1_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// ENV 2 (amp)
Pdefn(\ntron_atk2_0, 0.01);
Pdefn(\ntron_atk2, Pseq([
  Pn(Pdefn(\ntron_atk2_0),  4),
],  1));

Pdefn(\ntron_dcy2_0, 0.1);
Pdefn(\ntron_dcy2, Pseq([
  Pn(Pdefn(\ntron_dcy2_0),  4),
],  1));

Pdefn(\ntron_sus2_0, 0.9);
Pdefn(\ntron_sus2, Pseq([
  Pn(Pdefn(\ntron_sus2_0),  4),
],  1));

Pdefn(\ntron_rel2_0, 0.3);
Pdefn(\ntron_rel2, Pseq([
  Pn(Pdefn(\ntron_rel2_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// DRIVE
Pdefn(\ntron_drive_0, 0.0);          // 0..1  (gain up to ×21)
Pdefn(\ntron_drive, Pseq([
  Pn(Pdefn(\ntron_drive_0),  4),
],  1));

Pdefn(\ntron_driveTone_0, 1.0);      // 0..1  (0=dark 500Hz, 1=bright 12kHz)
Pdefn(\ntron_driveTone, Pseq([
  Pn(Pdefn(\ntron_driveTone_0),  4),
],  1));

Pdefn(\ntron_driveLevel_0, 0.5);     // 0..1
Pdefn(\ntron_driveLevel, Pseq([
  Pn(Pdefn(\ntron_driveLevel_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// DELAY
Pdefn(\ntron_delTime_0, 0.25);       // 0.001..2.0 sec
Pdefn(\ntron_delTime, Pseq([
  Pn(Pdefn(\ntron_delTime_0),  4),
],  1));

Pdefn(\ntron_delFB_0, 0.3);          // 0..1  (above ~0.9 → runaway)
Pdefn(\ntron_delFB, Pseq([
  Pn(Pdefn(\ntron_delFB_0),  4),
],  1));

Pdefn(\ntron_delMix_0, 0.0);         // 0..1  (0=dry, 1=wet)
Pdefn(\ntron_delMix, Pseq([
  Pn(Pdefn(\ntron_delMix_0),  4),
],  1));

)
