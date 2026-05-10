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
Pdefn(\bass_d,  ~deg.("01")); 
Pdefn(\bass_s1,  ~deg.("40--")); 
Pdefn(\bass_deg,  Pseq([
  Pn(Pdefn(\bass_d),  1), 
],  1));
// -- root
Pdefn(\bass_root_d, 0);
Pdefn(\bass_root_00,  Pstep(Pseq([0,  2,  4,  1], inf), 1));
Pdefn(\bass_root, Pseq([
  Pn(Pdefn(\bass_root_d), 1), 
],  1));
)
