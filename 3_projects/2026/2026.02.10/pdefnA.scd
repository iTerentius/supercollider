(
///////////////////////////////////////////////////////////////
// BASH
///////////////////////////////////////////////////////////////
Pdefn(\bash_scale,  Scale.minor);

~sBash = ~sTree[\bass_drums].values[0..3];
Pdefn(\bash_buf_0,  Pseq(~sBash,  1));
Pdefn(\bash_buf_1,  Pstep(Pseq(~sBash,  1), 2));
Pdefn(\bash_bufs, Pseq([
  // Pn(Pdefn(\bash_buf_0),  4), 
  Pn(Pdefn(\bash_buf_1),  4), 
],  1));

Pdefn(\bash_oct_0,  5);
Pdefn(\bash_oct_1,  Pseq([4,  5], 1));
Pdefn(\bash_octs, Pseq([
  Pn(Pdefn(\bash_oct_0),  4), 
  Pn(Pdefn(\bash_oct_1),  4), 
],  1));

Pdefn(\bash_amp_0,  0.7);
Pdefn(\bash_amp_1,  Pwhite(0.5, 0.7,  1));
Pdefn(\bash_amps, Pseq([
  Pn(Pdefn(\bash_amp_0),  4), 
  Pn(Pdefn(\bash_amp_1),  4), 
],  1));

Pdefn(\bash_deg_0,  0);
Pdefn(\bash_deg_1,  Pseq([0,  1,  \,  3, \, 0], 1));
Pdefn(\bash_degs, Pseq([
  Pn(Pdefn(\bash_deg_0), 32),
  Pn(Pdefn(\bash_deg_1), 4),
],  1));

Pdefn(\bash_dur_0,  1);
Pdefn(\bash_dur_1,  Pseq([1/4!2, 1/2!3,  ].flat, 1));    
Pdefn(\bash_dur_2,  Pbjorklund(5,  8,  1)/2);  
Pdefn(\bash_durs, Pseq([
  // Pn(Pdefn(\bash_dur_0), 4),
  Pn(Pdefn(\bash_dur_1), 4),
  // Pn(Pdefn(\bash_dur_2), 4),
  // [0], 
],  1));

Pdefn(\bash_str_0,  1);    
Pdefn(\bash_str_1,  Pseq([1/4,  1/2,  1,  4], 1));  
Pdefn(\bash_strs, Pseq([
  Pn(Pdefn(\bash_str_0), 32),
  Pn(Pdefn(\bash_str_1), 4),
],  1));
///////////////////////////////////////////////////////////////
// BASHAT
///////////////////////////////////////////////////////////////
Pdefn(\bashat_scale,  Scale.minor);

Pdefn(\bashat_oct_0,  5);
Pdefn(\bashat_oct_1,  Pseq([4,  5], 1));
Pdefn(\bashat_octs, Pseq([
  Pn(Pdefn(\bashat_oct_0),  4), 
  // Pn(Pdefn(\bash_oct_1),  4), 
],  1));

Pdefn(\bashat_amp_0,  0.7);
Pdefn(\bashat_amp_1,  Pwhite(0.75, 0.5,  1));
Pdefn(\bashat_amps, Pseq([
  Pn(Pdefn(\bashat_amp_0),  4), 
  Pn(Pdefn(\bashat_amp_1),  4), 
],  1));

~sBashat = ~sTree[\hats].values[0..7];
Pdefn(\bashat_buf_0,  Pstep(Pseq(~sBashat,  1), 2));
Pdefn(\bashat_bufs, Pseq([
  Pn(Pdefn(\bashat_buf_0),  4), 
],  1));

Pdefn(\bashat_deg_0,  0);
Pdefn(\bashat_deg_1,  Place([0,  Pxrand([1,  2,  4],  1)],  1));  
Pdefn(\bashat_degs, Pseq([
  // Pn(Pdefn(\bashat_deg_0), 32),
  Pn(Pdefn(\bashat_deg_1), 4),
],  1));

Pdefn(\bashat_dur_0,  1);
Pdefn(\bashat_dur_1,  Pseq([1/2,  1/4!2,  1].flat,  1)); 
Pdefn(\bashat_dur_2,  Pbjorklund(5,  8,  1));  
Pdefn(\bashat_durs, Pseq([
  Pn(Pdefn(\bashat_dur_0), 4),
  // Pn(Pdefn(\bashat_dur_1), 4),
  // Pn(Pdefn(\bashat_dur_2), 4),
  // [0], 
],  1));

Pdefn(\bashat_str_0,  1);    
Pdefn(\bashat_str_1,  Pseq([1/4,  1/2,  1,  4], 1));  
Pdefn(\bashat_strs, Pseq([
  Pn(Pdefn(\bashat_str_0), 32),
  Pn(Pdefn(\bashat_str_1), 4),
],  1));

///////////////////////////////////////////////////////////////
// ROLL
///////////////////////////////////////////////////////////////
Pdefn(\roll_scale,  Scale.minor);

Pdefn(\roll_oct_0,  5);
Pdefn(\roll_oct_1,  Pseq([1, 3,  7], 1));  
Pdefn(\roll_octs, Pseq([
  Pn(Pdefn(\roll_oct_0),  4), 
  Pn(Pdefn(\roll_oct_1),  4), 
],  1));

Pdefn(\roll_amp_0,  0.7);
Pdefn(\roll_amp_1,  Pwhite(0.75, 0.5,  1));
Pdefn(\roll_amps, Pseq([
  Pn(Pdefn(\roll_amp_0),  4), 
  Pn(Pdefn(\roll_amp_1),  4), 
],  1));

~sRoll = ~sTree[\jttcot].values[0..6];
Pdefn(\roll_buf_0,  Pseq(~sRoll,  1));
Pdefn(\roll_bufs, Pseq([
  Pn(Pdefn(\roll_buf_0),  8), 
],  1));

Pdefn(\roll_nSlices_0, 8);
Pdefn(\roll_nSlices_1, 32);
Pdefn(\roll_nSlices,  Pseq([
  Pn(Pdefn(\roll_nSlices_0),  1), 
  // Pn(Pdefn(\roll_nSlices_1),  4), 
],  1));

Pdefn(\roll_rate_0, 1);
Pdefn(\roll_rate_1, Pseq([1,  1.neg], 1));
Pdefn(\roll_rates,  Pseq([
  Pn(Pdefn(\roll_rate_0), 1), 
  // Pn(Pdefn(\roll_rate_1), 4), 
],  1));

Pdefn(\roll_rev_0,  0);
Pdefn(\roll_rev_1,  Pseq([0,  1], 1));
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

Pdefn(\roll_sprd_0, 1);
Pdefn(\roll_sprds,  Pseq([
  Pn(Pdefn(\roll_sprd_0), 4), 
],  1));

Pdefn(\roll_sliceIdx_0, 0);
Pdefn(\roll_sliceIdx_1, Pwhite(0, 8,  1));
Pdefn(\roll_sliceIdx_2, Pseg([0,  8],  [8], 1));
Pdefn(\roll_sliceIdxs,  Pseq([
  // Pn(Pdefn(\roll_sliceIdx_0), 4), 
  Pn(Pdefn(\roll_sliceIdx_1), 4), 
],  1));

Pdefn(\roll_deg_0,  0);
Pdefn(\roll_deg_1,  Prand([0, 2,  4],  1));  
Pdefn(\roll_degs, Pseq([
  Pn(Pdefn(\roll_deg_0), 32),
  Pn(Pdefn(\roll_deg_1), 4),
],  1));

Pdefn(\roll_dur_0,  1);
Pdefn(\roll_dur_1,  Pseq([1/3,  1/6!2,  Pn(Rest(),  1)].flat,  1)); 
Pdefn(\roll_dur_2,  Pbjorklund2(3,  8,  1)/2);  
Pdefn(\roll_durs, Pseq([
  // Pn(Pdefn(\roll_dur_0), 4),
  Pn(Pdefn(\roll_dur_1), 4),
],  1));

Pdefn(\roll_str_0,  1);    
Pdefn(\roll_str_1,  Pseq([1/4,  1/2,  1,  ], 4));  
Pdefn(\roll_strs, Pseq([
  // Pn(Pdefn(\roll_str_0), 32),
  Pn(Pdefn(\roll_str_1), 4),
],  1));
)

