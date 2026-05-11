(
// kick degs
Pdefn(\kk_d,  Pseq([0], inf));
Pdefn(\kk_00,  Pseq([0, 1,], inf));
Pdefn(\kk_02,  ~deg.("010-0---0---"));
Pdefn(\kk_08,  Pseq([
  /* Pn(~deg.("0201-"),  1),
  Pn(~deg.("0-14-2"), 1),
  Pn(~deg.("--0--"),  1),
  Pn(~deg.("----------"),  1), */
  /* Pn(~deg.("0----21---4----"), 1),  */
  /* Pn(~deg.("02-0--0-2---0-----"), 1),  */
  Pn(~deg.("0-------0-------"), 1), 
  Pn(~deg.("0-------0-------"), 1), 
  Pn(~deg.("0-------0-0---0-"), 1),
], 1));
Pdefn(\kk_deg,  Pseq([
  Pn(Pdefn(\kk_d), 4), 
  // Pn(Pdefn(\kk_d1), 1), 
],  1));
// bass degs
Pdefn(\bass_deg_d,  ~deg.("01")); 
Pdefn(\bass_deg_s1,  ~deg.("40")); 
Pdefn(\bass_deg_00, Pseq([0,  1,  2], 1));
Pdefn(\bass_deg_00a,  ~deg.("7420----")); 
Pdefn(\bass_deg,  Pseq([
  Pn(Pdefn(\bass_deg_d),  1), 
],  1));
// -- root
Pdefn(\bass_root_d, 0);
Pdefn(\bass_root_00,  Pstep(Pseq([0,  2,  4,  1], inf), 1));
Pdefn(\bass_root, Pseq([
  Pn(Pdefn(\bass_root_d), 1), 
],  1));
// -- dur
Pdefn(\bass_dur_d, 1/Pdefn(\all_div));
Pdefn(\bass_dur_00,  1/4);
Pdefn(\bass_dur, Pseq([
  Pn(Pdefn(\bass_dur_d), 1), 
],  1));
// -- stretch
Pdefn(\bass_str_d, 2);
Pdefn(\bass_str_00,  Place([1,  [2,  1,  3]],  inf));
Pdefn(\bass_str, Pseq([
  Pn(Pdefn(\bass_str_d), 1), 
],  1));
)
