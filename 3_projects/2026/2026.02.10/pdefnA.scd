(
"voice_pat.scd".loadRelative;
///////////////////////////////////////////////////////////////
// bd1
///////////////////////////////////////////////////////////////
Pdefn(\bd1_out,  ~pbd1.inbus.index);
Pdefn(\bd1_scale,  Scale.minor);

~sbd1 = ~sTree[\bass_drums].values;
Pdefn(\bd1_buf_0,  Pseq(~sbd1,  1));
Pdefn(\bd1_buf_1,  Pseq([
  Pseq(~sbd1[[0]], 1), 
  Pseq(~sbd1[[1, 2, 4]], 1), 
  Pseq(~sbd1[[0, 10, 12]], 1), 
],  1));
Pdefn(\bd1_bufs, Pseq([
  // Pn(Pdefn(\bd1_buf_0),  4), 
  Pn(Pdefn(\bd1_buf_1),  4), 
],  1));

Pdefn(\bd1_oct_0,  5);
Pdefn(\bd1_oct_1,  Pseq([4,  5], 1));
Pdefn(\bd1_octs, Pseq([
  Pn(Pdefn(\bd1_oct_0),  4), 
  // Pn(Pdefn(\bd1_oct_1),  4), 
],  1));

Pdefn(\bd1_amp_0,  0.7);
Pdefn(\bd1_amp_1,  Pwhite(0.5, 0.7,  1));
Pdefn(\bd1_amp_2,  Pseq([0.5!3, 0.8].flat,  1));
Pdefn(\bd1_amps, Pseq([
  Pn(Pdefn(\bd1_amp_0),  4), 
  // Pn(Pdefn(\bd1_amp_1),  4), 
  // Pn(Pdefn(\bd1_amp_2),  4), 
],  1));

Pdefn(\bd1_deg_0,  0);
Pdefn(\bd1_deg_1,  Pseq([0,  1,  \,  3, \, 0], 1));
Pdefn(\bd1_deg_2,  Pseq([0,  \,  \,  \, 14, \,  0, \,  0, \,  \,  0,  14,  \,  \,  \], 1));
Pdefn(\bd1_degs, Pseq([
  // Pn(Pdefn(\bd1_deg_0), 4),
  // Pn(Pdefn(\bd1_deg_1), 4),
  Pn(Pdefn(\bd1_deg_2), 1),
],  1));

Pdefn(\bd1_dur_0,  1);
Pdefn(\bd1_dur_1,  Pseq([1/4!2, 1/2!3,  ].flat, 1));    
Pdefn(\bd1_dur_2,  Pbjorklund(5,  8,  1)/2);  
Pdefn(\bd1_dur_3,  Pseq([1/4!2,  Rest(1/4), 1/4 ].flat,  1));
Pdefn(\bd1_dur_4,  1/2);
Pdefn(\bd1_durs, Pseq([
  Pn(Pdefn(\bd1_dur_0), 4),
  Pn(Pdefn(\bd1_dur_1), 4),
  Pn(Pdefn(\bd1_dur_2), 4),
  Pn(Pdefn(\bd1_dur_3), 4),
  Pn(Pdefn(\bd1_dur_4), 1),
],  1));

Pdefn(\bd1_str_0,  1);    
Pdefn(\bd1_str_1,  Pstep(Pseq([1!4,  2!2].flat, 1)), 4);  
Pdefn(\bd1_strs, Pseq([
  Pn(Pdefn(\bd1_str_0), 4),
  // Pn(Pdefn(\bd1_str_1), 4),
],  1));
///////////////////////////////////////////////////////////////
// hh1
///////////////////////////////////////////////////////////////
Pdefn(\hh1_out,  ~phh1.inbus.index);
Pdefn(\hh1_scale,  Scale.minor);

Pdefn(\hh1_oct_0,  5);
Pdefn(\hh1_oct_1,  Pseq([4,  5], 1));
Pdefn(\hh1_octs, Pseq([
  Pn(Pdefn(\hh1_oct_0),  4), 
  // Pn(Pdefn(\bd1_oct_1),  4), 
],  1));

Pdefn(\hh1_amp_0,  0.5);
Pdefn(\hh1_amp_1,  Pwhite(0.75, 0.5,  1));
Pdefn(\hh1_amps, Pseq([
  Pn(Pdefn(\hh1_amp_0),  4), 
  // Pn(Pdefn(\hh1_amp_1),  4), 
],  1));

~shh1 = ~sTree[\hats].values;
Pdefn(\hh1_buf_0,  Pstep(Pseq(~shh1[[1]],  1), 2));
Pdefn(\hh1_buf_1,  Pstep(Pseq(~shh1[[1, 1, 0]],  1),  4));
Pdefn(\hh1_bufs, Pseq([
  Pn(Pdefn(\hh1_buf_0),  4), 
  // Pn(Pdefn(\hh1_buf_1),  4), 
],  1));

Pdefn(\hh1_deg_0,  0);
Pdefn(\hh1_deg_1,  Pseq([-1, 0, -1,  [1, 0] ],  inf));  
Pdefn(\hh1_degs, Pseq([
  // Pn(Pdefn(\hh1_deg_0), 4),
  Pn(Pdefn(\hh1_deg_1), 4),
],  1));

Pdefn(\hh1_dur_0,  1/2);
Pdefn(\hh1_dur_1,  Pseq([1/2,  1/4!2,  1].flat,  1)); 
Pdefn(\hh1_dur_2,  Pbjorklund(3,  8,  1)/4);  
Pdefn(\hh1_dur_3,  Pseq([Pn(Rest(),  1/2),  1/2],  1)); 
Pdefn(\hh1_durs, Pseq([
  Pn(Pdefn(\hh1_dur_0), 24),
  Pn(Pdefn(\hh1_dur_1), 4),
  Pn(Pdefn(\hh1_dur_2), 2),
  Pn(Pdefn(\hh1_dur_3), 4),
  // [0], 
],  1));

Pdefn(\hh1_str_0,  1);    
Pdefn(\hh1_str_1,  Pseq([Rest(1/4),  1/4,  1/2,  1,  3].flat, 1));  
Pdefn(\hh1_str_1,  Pseq([Rest(1/4),  1/4, ].flat, 1));  
Pdefn(\hh1_strs, Pseq([
  Pn(Pdefn(\hh1_str_0), 4),
  // Pn(Pdefn(\hh1_str_1), 1),
],  1));

///////////////////////////////////////////////////////////////
// ROLL
///////////////////////////////////////////////////////////////
Pdefn(\roll_out,  ~t2.inbus.index);
Pdefn(\roll_scale,  Scale.minor);

Pdefn(\roll_oct_0,  5);
Pdefn(\roll_oct_1,  Pseq([1, 3,  7], 1));  
Pdefn(\roll_octs, Pseq([
  Pn(Pdefn(\roll_oct_0),  4), 
  Pn(Pdefn(\roll_oct_1),  4), 
],  1));

Pdefn(\roll_amp_0,  1.2);
Pdefn(\roll_amp_1,  Pwhite(0.75, 0.5,  1));
Pdefn(\roll_amps, Pseq([
  Pn(Pdefn(\roll_amp_0),  4), 
  // Pn(Pdefn(\roll_amp_1),  4), 
],  1));

~sRoll = ~sTree[\jttcot].values[0..6];
Pdefn(\roll_buf_0,  Pseq(~sRoll,  1));
Pdefn(\roll_bufs, Pseq([
  Pn(Pdefn(\roll_buf_0),  8), 
],  1));

Pdefn(\roll_nSlices_0, 8);
Pdefn(\roll_nSlices_1, Pseq([1!4, 8,  16!4].flat,  1));
Pdefn(\roll_nSlices,  Pseq([
  // Pn(Pdefn(\roll_nSlices_0),  1), 
  Pn(Pdefn(\roll_nSlices_1),  4), 
],  1));

Pdefn(\roll_rate_0, 1);
Pdefn(\roll_rate_1, Pseq([1.2,  0.8], 1));
Pdefn(\roll_rate_2, Pseg([0.4,  1.2,  0.8], [1, 4], \sin,  1));
Pdefn(\roll_rates,  Pseq([
  Pn(Pdefn(\roll_rate_0), 1), 
  Pn(Pdefn(\roll_rate_2), 4), 
],  1));

Pdefn(\roll_rev_0,  0);
Pdefn(\roll_rev_1,  Pstep(Pseq([0,  1], 1), 3));
Pdefn(\roll_rev,  Pseq([
  // Pn(Pdefn(\roll_rev_0),  1), 
  Pn(Pdefn(\roll_rev_1),  1), 
],  1));

Pdefn(\roll_sliceDur_0, 1);
Pdefn(\roll_sliceDur_1, Pseq([1/4, 1/8!2,  1.5].flat, 1));
Pdefn(\roll_sliceDurs,  Pseq([
  Pn(Pdefn(\roll_sliceDur_0), 4), 
  // Pn(Pdefn(\roll_sliceDur_1), 4), 
],  1));

Pdefn(\roll_sprd_0, 0.6);
Pdefn(\roll_sprds,  Pseq([
  Pn(Pdefn(\roll_sprd_0), 4), 
],  1));

Pdefn(\roll_sliceIdx_0, 0);
Pdefn(\roll_sliceIdx_1, Pwhite(0, 32,  1));
Pdefn(\roll_sliceIdx_2, Pseg([0,  8],  [8], 1));
Pdefn(\roll_sliceIdxs,  Pseq([
  // Pn(Pdefn(\roll_sliceIdx_0), 4), 
  Pn(Pdefn(\roll_sliceIdx_1), 4), 
  // Pn(Pdefn(\roll_sliceIdx_2), 4), 
],  1));

Pdefn(\roll_deg_0,  7);
Pdefn(\roll_deg_1,  Prand([7],  1));  
Pdefn(\roll_degs, Pseq([
  Pn(Pdefn(\roll_deg_0), 1),
  // Pn(Pdefn(\roll_deg_1), 4),
],  1));

Pdefn(\roll_dur_0,  1);
Pdefn(\roll_dur_1,  Pseq([1/3,  1/6!2,  Pn(Rest(),  1)].flat,  1)); 
Pdefn(\roll_dur_2,  Pbjorklund2(3,  8,  1)/2);  
Pdefn(\roll_durs, Pseq([
  // Pn(Pdefn(\roll_dur_0), 4),
  Pn(Pdefn(\roll_dur_2), 4),
],  1));

Pdefn(\roll_str_0,  1);    
Pdefn(\roll_str_1,  Pseq([1/4,  1/2,  1,  ], 4));  
Pdefn(\roll_strs, Pseq([
  // Pn(Pdefn(\roll_str_0), 32),
  Pn(Pdefn(\roll_str_1), 4),
],  1));

///////////////////////////////////////////////////////////////
// MS20
///////////////////////////////////////////////////////////////
Pdefn(\ms20_out,  ~t3.inbus.index);
Pdefn(\ms20_scale,  Scale.minor);

Pdefn(\ms20_oct_0,  5);
Pdefn(\ms20_oct_1,  Pstep(Pseq([3, 4,  ],  1), 7));
Pdefn(\ms20_octs, Pseq([
  // Pn(Pdefn(\ms20_oct_0),  4), 
  Pn(Pdefn(\ms20_oct_1),  4), 
],  1));

Pdefn(\ms20_amp_0,  0.7);
Pdefn(\ms20_amp_1,  Pwhite(0.5, 0.7,  1));
Pdefn(\ms20_amps, Pseq([
  Pn(Pdefn(\ms20_amp_0),  4), 
  // Pn(Pdefn(\ms20_amp_1),  4), 
],  1));

Pdefn(\ms20_deg_0,  0);
Pdefn(\ms20_deg_1,  Place([0, [2, 1, 0, -4]], 1));
Pdefn(\ms20_deg_2,  Pseq([0, 0, 3, 5,  Pn(Rest(), 8)], 1));
Pdefn(\ms20_degs, Pseq([
  // Pn(Pdefn(\ms20_deg_0),  1), 
  // Pn(Pdefn(\ms20_deg_1),  4), 
  // Pn(Pdefn(\ms20_deg_2),  4), 
  Pn(Pdefn(\bd1_durs), 4), 
],  1));

Pdefn(\ms20_dur_0,  1);
Pdefn(\ms20_dur_1, Pseq([1/4!7, ].flat, 1)); 
Pdefn(\ms20_dur_2, Pbjorklund(5,  8,  1)/4);
Pdefn(\ms20_durs, Pseq([
  // Pn(Pdefn(\ms20_dur_0),  4), 
  Pn(Pdefn(\bd1_durs), 4), 
  // Ppatlace([
  //   pn(pdefn(\ms20_dur_1),  4), 
  //   pn(pdefn(\ms20_dur_2),  4), 
  // ],  1), 
],  1));

Pdefn(\ms20_str_0,  1/2);
Pdefn(\ms20_str_1, Pseq([1,].flat, 1)); 
Pdefn(\ms20_strs, Ppatlace([
  Pn(Pdefn(\ms20_str_0),  4), 
  // Pn(Pdefn(\ms20_str_1),  4), 
  Pn(Pdefn(\bd1_strs), 4), 
],  1));

Pdefn(\ms20_leg_0,  1);
Pdefn(\ms20_leg_1,  Place([0.6, [1,  0.8, ]], 1));
Pdefn(\ms20_legs, Pseq([
  // Pn(Pdefn(\ms20_leg_0),  4), 
  Pn(Pdefn(\ms20_leg_1),  4), 
],  1));

Pdefn(\ms20_hpcut_0,  80);
Pdefn(\ms20_hpcut_1, Pseq([80], 1)); 
Pdefn(\ms20_hpcut, Pseq([
  Pn(Pdefn(\ms20_hpcut_0),  4), 
  // Pn(Pdefn(\ms20_hpcut_1),  4), 
],  1));

Pdefn(\ms20_lpcut_0,  800);
Pdefn(\ms20_lpcut_1, Pseq([800], 1)); 
Pdefn(\ms20_lpcut_2, Pseg([80,  800,  1880], [2,  4], \sin,  1)); 
Pdefn(\ms20_lpcut, Pseq([
  // Pn(Pdefn(\ms20_lpcut_0),  4), 
  // Pn(Pdefn(\ms20_lpcut_1),  4), 
  Pn(Pdefn(\ms20_lpcut_2),  4), 
],  1));

Pdefn(\ms20_lpRes_0,  0.8);
Pdefn(\ms20_lpRes_1, Pseq([0.8], 1)); 
Pdefn(\ms20_lpRes_2, Pwhite(0.4,  0.9,  1));
Pdefn(\ms20_lpRes, Pseq([
  Pn(Pdefn(\ms20_lpRes_0),  4), 
  // Pn(Pdefn(\ms20_lpRes_1),  4), 
  Pn(Pdefn(\ms20_lpRes_2),  4), 
],  1));

Pdefn(\ms20_fEamt_0,  800);
Pdefn(\ms20_fEamt_1, Pseq([800], 1)); 
Pdefn(\ms20_fEamt_2, Pwhite(80,  800,  1));
Pdefn(\ms20_fEamt_3, Pseg([100, 2000,  100],  [2, 2],  \step, 1));
Pdefn(\ms20_fEamt, Pseq([
  // Pn(Pdefn(\ms20_fEamt_0),  4), 
  // Pn(Pdefn(\ms20_fEamt_1),  4), 
  // Pn(Pdefn(\ms20_fEamt_2),  4), 
  Pn(Pdefn(\ms20_fEamt_3),  4), 
],  1));

Pdefn(\ms20_ringMod_0,  0.2);
Pdefn(\ms20_ringMod_1, Pseq([0.2], 1)); 
Pdefn(\ms20_ringMod_2, Pseg([0.2, 1.0], [1], \sin,  1)); 
Pdefn(\ms20_ringMod_3, Pwhite(0.2,  0.9,  1));
Pdefn(\ms20_ringMod, Pseq([
  // Pn(Pdefn(\ms20_ringMod_0),  4), 
  // Pn(Pdefn(\ms20_ringMod_1),  4), 
  Pn(Pdefn(\ms20_ringMod_2),  4), 
  // Pn(Pdefn(\ms20_ringMod_3),  4), 
],  1));

///////////////////////////////////////////////////////////////
// THINGA
///////////////////////////////////////////////////////////////
Pdefn(\thingA_out,  ~t4.inbus.index);
Pdefn(\thingA_scale,  Scale.minor);
Pdefn(\thingA_oct_0,  3);
Pdefn(\thingA_oct_1,  Pseq([3].flat,  1));
Pdefn(\thingA_octs, Pseq([
  Pn(Pdefn(\thingA_oct_0),  4), 
],  1));

Pdefn(\thingA_deg_0,  0);
Pdefn(\thingA_deg_1,  Pseq([Pseq([0, 1,  4,  2], 1),  Rest()*4], 1));
Pdefn(\thingA_degs, Pseq([ 
  // Pn(Pdefn(\thingA_deg_0),  4), 
  Pn(Pdefn(\thingA_deg_1),  4), 
],  1));

Pdefn(\thingA_dur_0,  4);
Pdefn(\thingA_durs, Pseq([
  Pn(Pdefn(\thingA_dur_0),  4), 
],  1));

Pdefn(\thingA_delta_0,  1);
Pdefn(\thingA_delta_1,  1/(Pkey(\dur) * 2));
Pdefn(\thingA_delta,  Pseq([
  // Pn(Pdefn(\thingA_delta_0),  4), 
  Pn(Pdefn(\thingA_delta_1),  4), 
],  1));

Pdefn(\thingA_str_0,  1/2);
Pdefn(\thingA_str_1, Pseq([1,].flat, 1)); 
Pdefn(\thingA_strs,  Ppatlace([
  Pn(Pdefn(\thingA_str_0),  4), 
  // Pn(Pdefn(\thingA_str_1),  4), 
  Pn(Pdefn(\bd1_strs), 4), 
],  1));

Pdefn(\thingA_mod1_0, 1);
Pdefn(\thingA_mod1_1, Pseg([1,  5.0,  3.5], [2, 4], \sin, 1));
Pdefn(\thingA_mod1_2, Pseq([0.1,  8.0,  2.5], 1));
Pdefn(\thingA_mod1, Pseq([
  // Pn(Pdefn(\thingA_mod1_0),  4), 
  Pn(Pdefn(\thingA_mod1_1),  4), 
  // Pn(Pdefn(\thingA_mod1_2),  4), 
],  1));

Pdefn(\thingA_mod2_0, 1);
Pdefn(\thingA_mod2_1, Pseg([5,  3.0,  0.5], [3, 4], \sin, 1));
Pdefn(\thingA_mod2_2, Pseq([0.5,  8.0,  3.5], 1));
Pdefn(\thingA_mod2, Pseq([
  // Pn(Pdefn(\thingA_mod2_0),  4), 
  Pn(Pdefn(\thingA_mod2_1),  4), 
  // Pn(Pdefn(\thingA_mod2_2),  4), 
],  1));

Pdefn(\thingA_amp_0,  1);
Pdefn(\thingA_amp_1,  Pwhite(0.5, 0.8,  1));
Pdefn(\thingA_amps,  Pseq([
  Pn(Pdefn(\thingA_amp_0),  4), 
],  1));

///////////////////////////////////////////////////////////////
// bd1 Glitch FX
///////////////////////////////////////////////////////////////
Pdefn(\bd1_glitch_amp_0, 0.8);
Pdefn(\bd1_glitch_amp_1, Pwhite(0.5, 0.9,  1));
Pdefn(\bd1_glitch_amp, Pseq([
  // Pn(Pdefn(\bd1_glitch_amp_0), 4), 
  Pn(Pdefn(\bd1_glitch_amp_1), 4), 
],  1));

Pdefn(\bd1_glitch_mod1_0,  1);
Pdefn(\bd1_glitch_mod1_1,  Pseq([1,  50],  1));
Pdefn(\bd1_glitch_mod1_2,  Pseg([1,  50,  1], [Pkey(\dur) * 8, Pkey(\dur) * 2], \sin, 1)); 
Pdefn(\bd1_glitch_mod1,  Pseq([
  Pn(Pdefn(\bd1_glitch_mod1_0),  4), 
  Pn(Pdefn(\bd1_glitch_mod1_1),  4), 
  Pn(Pdefn(\bd1_glitch_mod1_2),  4), 
],  1));

Pdefn(\bd1_glitch_mod2_0,  1);
Pdefn(\bd1_glitch_mod2_1,  Pseq([1,  50],  1));
Pdefn(\bd1_glitch_mod2_2,  Pseg([1,  50,  1], [Pkey(\dur) * 8, Pkey(\dur) * 2], \sin, 1)); 
Pdefn(\bd1_glitch_mod2,  Pseq([
  Pn(Pdefn(\bd1_glitch_mod2_0),  4), 
  Pn(Pdefn(\bd1_glitch_mod2_1),  4), 
  Pn(Pdefn(\bd1_glitch_mod2_2),  4), 
],  1));

Pdefn(\bd1_glitch_dur_0, 1);
Pdefn(\bd1_glitch_dur_1, 1/8);
Pdefn(\bd1_glitch_dur_2, Pbjorklund2(5,  8,  1)/4);
Pdefn(\bd1_glitch_durs,  Pseq([
  Pn(Pdefn(\bd1_glitch_dur_0), 4), 
  Pn(Pdefn(\bd1_glitch_dur_1), 4), 
  Pn(Pdefn(\bd1_glitch_dur_2), 4), 
],  1));

Pdefn(\bd1_glitch_str_0, 1);
Pdefn(\bd1_glitch_str_1, Pseq([1,  2,  1/4], 1));
Pdefn(\bd1_glitch_strs,  Pseq([
  Pn(Pdefn(\bd1_glitch_dur_0), 4), 
  Pn(Pdefn(\bd1_glitch_dur_1), 4), 
],  1));
)
