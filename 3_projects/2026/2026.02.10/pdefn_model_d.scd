(
///////////////////////////////////////////////////////////////
// MODEL D — phrase parameter banks
// _0 = sane default (use to reset). Add _1, _2 for variations.
// Wire into Pdef with:  Pn(Pdefn(\mD_param), inf)
///////////////////////////////////////////////////////////////

Pdefn(\mD_out,   ~t1.inbus.index);
Pdefn(\mD_scale, Scale.minor);

///////////////////////////////////////////////////////////////
// OCTAVE
Pdefn(\mD_oct_0, 4);              // 0..8
Pdefn(\mD_octs, Pseq([
  Pn(Pdefn(\mD_oct_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// DEGREE
Pdefn(\mD_deg_0, 0);
Pdefn(\mD_degs, Pseq([
  Pn(Pdefn(\mD_deg_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// DUR
Pdefn(\mD_dur_0, 1);
Pdefn(\mD_durs, Pseq([
  Pn(Pdefn(\mD_dur_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// STRETCH
Pdefn(\mD_str_0, 1);
Pdefn(\mD_strs, Pseq([
  Pn(Pdefn(\mD_str_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// LEGATO
Pdefn(\mD_leg_0, 0.8);            // 0..2+
Pdefn(\mD_legs, Pseq([
  Pn(Pdefn(\mD_leg_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// AMP
Pdefn(\mD_amp_0, 0.7);            // 0..1
Pdefn(\mD_amps, Pseq([
  Pn(Pdefn(\mD_amp_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// GLIDE
Pdefn(\mD_glide_0, 0.0);          // 0..10 sec  portamento
Pdefn(\mD_glides, Pseq([
  Pn(Pdefn(\mD_glide_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// OSC 1
Pdefn(\mD_osc1Wave_0, 2);         // 0=tri 1=inv-saw 2=saw 3=sq 4=wide 5=narrow
Pdefn(\mD_osc1Wave, Pseq([
  Pn(Pdefn(\mD_osc1Wave_0),  4),
],  1));

Pdefn(\mD_osc1Oct_0, 0);          // -3..+3
Pdefn(\mD_osc1Oct, Pseq([
  Pn(Pdefn(\mD_osc1Oct_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// OSC 2
Pdefn(\mD_osc2Wave_0, 2);         // 0..5
Pdefn(\mD_osc2Wave, Pseq([
  Pn(Pdefn(\mD_osc2Wave_0),  4),
],  1));

Pdefn(\mD_osc2Oct_0, 0);          // -3..+3
Pdefn(\mD_osc2Oct, Pseq([
  Pn(Pdefn(\mD_osc2Oct_0),  4),
],  1));

Pdefn(\mD_osc2Fine_0, 0.0);       // ±7 semitones  (hardware fine-tune range)
Pdefn(\mD_osc2Fine, Pseq([
  Pn(Pdefn(\mD_osc2Fine_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// OSC 3
Pdefn(\mD_osc3Wave_0, 0);         // 0=tri (LFO default)  2=saw  3=sq
Pdefn(\mD_osc3Wave, Pseq([
  Pn(Pdefn(\mD_osc3Wave_0),  4),
],  1));

Pdefn(\mD_osc3Oct_0, 0);          // -3..+3  (kbd mode only)
Pdefn(\mD_osc3Oct, Pseq([
  Pn(Pdefn(\mD_osc3Oct_0),  4),
],  1));

Pdefn(\mD_osc3Fine_0, 0.0);       // ±7 semitones  (kbd mode only)
Pdefn(\mD_osc3Fine, Pseq([
  Pn(Pdefn(\mD_osc3Fine_0),  4),
],  1));

Pdefn(\mD_osc3KbdTrack_0, 1);     // 0/1  (0=free LFO at osc3Freq)
Pdefn(\mD_osc3KbdTrack, Pseq([
  Pn(Pdefn(\mD_osc3KbdTrack_0),  4),
],  1));

Pdefn(\mD_osc3Freq_0, 1.0);       // 0.1..50 Hz  (LFO rate when kbdTrack=0)
Pdefn(\mD_osc3Freq, Pseq([
  Pn(Pdefn(\mD_osc3Freq_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// MIXER
Pdefn(\mD_osc1Lvl_0, 0.7);        // 0..1
Pdefn(\mD_osc1Lvl, Pseq([
  Pn(Pdefn(\mD_osc1Lvl_0),  4),
],  1));

Pdefn(\mD_osc2Lvl_0, 0.7);
Pdefn(\mD_osc2Lvl, Pseq([
  Pn(Pdefn(\mD_osc2Lvl_0),  4),
],  1));

Pdefn(\mD_osc3Lvl_0, 0.0);        // 0..1  (add OSC3 as audio VCO)
Pdefn(\mD_osc3Lvl, Pseq([
  Pn(Pdefn(\mD_osc3Lvl_0),  4),
],  1));

Pdefn(\mD_noiseLvl_0, 0.0);       // 0..1
Pdefn(\mD_noiseLvl, Pseq([
  Pn(Pdefn(\mD_noiseLvl_0),  4),
],  1));

Pdefn(\mD_noiseType_0, 0);         // 0=white  1=pink
Pdefn(\mD_noiseType, Pseq([
  Pn(Pdefn(\mD_noiseType_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// FILTER
Pdefn(\mD_cutoff_0, 1000);         // 20..20000 Hz
Pdefn(\mD_cutoff, Pseq([
  Pn(Pdefn(\mD_cutoff_0),  4),
],  1));

Pdefn(\mD_emphasis_0, 0.2);        // 0..1  (self-osc above ~0.88)
Pdefn(\mD_emphasis, Pseq([
  Pn(Pdefn(\mD_emphasis_0),  4),
],  1));

Pdefn(\mD_kbdAmt_0, 0.5);          // 0..1
Pdefn(\mD_kbdAmt, Pseq([
  Pn(Pdefn(\mD_kbdAmt_0),  4),
],  1));

Pdefn(\mD_contourAmt_0, 0.5);      // 0..1  (filter EG depth, up to +4 oct)
Pdefn(\mD_contourAmt, Pseq([
  Pn(Pdefn(\mD_contourAmt_0),  4),
],  1));

Pdefn(\mD_drive_0, 0.0);           // 0..1  (pre-filter saturation, max ~×9)
Pdefn(\mD_drive, Pseq([
  Pn(Pdefn(\mD_drive_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// FILTER CONTOUR (ADS)
Pdefn(\mD_fAtk_0, 0.001);          // 0.001..5 sec
Pdefn(\mD_fAtk, Pseq([
  Pn(Pdefn(\mD_fAtk_0),  4),
],  1));

Pdefn(\mD_fDcy_0, 0.3);            // 0.001..10 sec
Pdefn(\mD_fDcy, Pseq([
  Pn(Pdefn(\mD_fDcy_0),  4),
],  1));

Pdefn(\mD_fSus_0, 0.5);            // 0..1
Pdefn(\mD_fSus, Pseq([
  Pn(Pdefn(\mD_fSus_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// AMP CONTOUR (ADS)
Pdefn(\mD_aAtk_0, 0.001);          // 0.001..5 sec
Pdefn(\mD_aAtk, Pseq([
  Pn(Pdefn(\mD_aAtk_0),  4),
],  1));

Pdefn(\mD_aDcy_0, 0.3);            // 0.001..10 sec
Pdefn(\mD_aDcy, Pseq([
  Pn(Pdefn(\mD_aDcy_0),  4),
],  1));

Pdefn(\mD_aSus_0, 0.9);
Pdefn(\mD_aSus, Pseq([
  Pn(Pdefn(\mD_aSus_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// DECAY SWITCH
Pdefn(\mD_decayOn_0, 1);           // 0/1  (1=rel@decay, 0=sustain-hold 60s)
Pdefn(\mD_decayOn, Pseq([
  Pn(Pdefn(\mD_decayOn_0),  4),
],  1));

///////////////////////////////////////////////////////////////
// MOD WHEEL
Pdefn(\mD_modWheel_0, 0.0);        // 0..1  (depth of mod source)
Pdefn(\mD_modWheel, Pseq([
  Pn(Pdefn(\mD_modWheel_0),  4),
],  1));

Pdefn(\mD_modToOsc_0, 0);          // 0/1  (mod → OSC1+2 pitch ±5st)
Pdefn(\mD_modToOsc, Pseq([
  Pn(Pdefn(\mD_modToOsc_0),  4),
],  1));

Pdefn(\mD_modToFilter_0, 0);       // 0/1  (mod → filter cutoff ±2 oct)
Pdefn(\mD_modToFilter, Pseq([
  Pn(Pdefn(\mD_modToFilter_0),  4),
],  1));

Pdefn(\mD_modSource_0, 0);         // 0=OSC3  1=white noise
Pdefn(\mD_modSource, Pseq([
  Pn(Pdefn(\mD_modSource_0),  4),
],  1));

)
