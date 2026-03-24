
(
~outs = ~r5_ilfx_1;
// ~outs = [~m1_ilfx_1,  ~r5_ilfx_1];
Pdef(\freeze, Pbind(
  \type,  \set,  
  \id,    Pn(Pdefn(\freeze_outs), inf),    
  \args,  #[\freeze, \mix, \amp,  \chunk],  
  \amp,   Pn(Pdefn(\freeze_amp),  inf), 
  \mix,   Pn(Pdefn(\freeze_mix),  inf), 
  \dur,   Pn(Pdefn(\freeze_durs), inf),
  \chunk, Pn(Pdefn(\freeze_chunk), inf), 
  \freeze,Pn(Pdefn(\freeze_freeze), inf), 
));

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////

// DUR — words
Pdefn(\freeze_dur_0, 1);
Pdefn(\freeze_dur_1, Pseg([1/2,   1, 1/4], [2, 4], \sin,  1));
Pdefn(\freeze_dur_2, Pseq([1/4, 1/2,  1,  2], 1));
Pdefn(\freeze_dur_3, Pbjorklund(3,  8,  1));
// sentences
Pdefn(\freeze_durs_a, Pseq([Pn(Pdefn(\freeze_dur_1), 4)], 1));   // slow scan
Pdefn(\freeze_durs_b, Pseq([
  Pn(Pdefn(\freeze_dur_1), 4),  
  Pn(Pdefn(\freeze_dur_2), 4),  
  Pn(Pdefn(\freeze_dur_3), 4),  
], 1));   // variable
// story
Pdefn(\freeze_durs, Pseq([Pn(Pdefn(\freeze_durs_a), 1)], 1));

// OUTS
Pdefn(\freeze_outs_0,  ~r5_ilfx_1);
Pdefn(\freeze_outs_1,  ~m1_ilfx_1);
Pdefn(\freeze_outs_2,  [~r5_ilfx_1,  ~m1_ilfx_1]);
// sentences
Pdefn(\freeze_outs_a, Pseq([Pn(Pdefn(\freeze_outs_0), 4)],  1));
// story
Pdefn(\freeze_outs, Pseq([Pn(Pdefn(\freeze_outs_a), 1)],  1));

// AMP
Pdefn(\freeze_amp_0,  0.1);
// sentences
Pdefn(\freeze_amp_a, Pseq([Pn(Pdefn(\freeze_amp_0), 4)],  1));
// story
Pdefn(\freeze_amp, Pseq([Pn(Pdefn(\freeze_amp_a), 1)],  1));

// MIX 
Pdefn(\freeze_mix_0,  1);
// sentences
Pdefn(\freeze_mix_a, Pseq([Pn(Pdefn(\freeze_mix_0), 4)],  1));
// story
Pdefn(\freeze_mix, Pseq([Pn(Pdefn(\freeze_mix_a), 1)],  1));

// CHUNK
Pdefn(\freeze_chunk_0,  2048);
Pdefn(\freeze_chunk_1,  Pseq([512,  1024, 2048, 4096],  inf));
// sentences
Pdefn(\freeze_chunk_a, Pseq([Pn(Pdefn(\freeze_chunk_0), 4)],  1));
// story
Pdefn(\freeze_chunk, Pseq([Pn(Pdefn(\freeze_chunk_a), 1)],  1));

// FREEZE
Pdefn(\freeze_freeze_0,  0);
Pdefn(\freeze_freeze_1,  Pwhite(0,  1,  1));
// sentences
Pdefn(\freeze_freeze_a, Pseq([Pn(Pdefn(\freeze_freeze_1), 4)],  1));
// story
Pdefn(\freeze_freeze, Pseq([Pn(Pdefn(\freeze_freeze_a), 1)],  1));

)
