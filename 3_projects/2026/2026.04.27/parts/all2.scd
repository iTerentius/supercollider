/* all2.scd
   Eval [0] once at load.
   Eval voice blocks individually to update a voice mid-performance.
   Eval [structure] once; it reads Pbindefs by name — never needs re-eval.
*/

/* [0] global spine — re-eval to reset cut streams or change division */
(
~odd = 0;
~mkCut = { 
  /* Pseq([16,  2,  4]+odd, inf).asStream  */
  Pseq([16]+~odd, inf).asStream;
};
/* var ~mkCut = { Pstep(Pseq([9, 7, 9, 7], inf), Pseq([3, 4, 8, 4], inf)/4).asStream }; */
~kickCut = ~mkCut.(); ~snCut = ~mkCut.(); ~hhCut = ~mkCut.(); ~bassCut = ~mkCut.();
/* shared stream for intentional drift: ~all_cut = ~mkCut.(); */
~allMul  = (kick: 4, sn: 1, hh: 1, bass: 3);
Pdefn(\all_div,   Pstep(Pseq([4+~odd], inf), 1));
Pdefn(\all_scale, Scale.dorian);
/* Pdefn(\kick_str,  Pseq([4, 2, 1!8].flat, inf)); */
/* Pdefn(\kick_str,  Pseq([8, 4, 2!8].flat, inf)); */
Pdefn(\kick_str,  1/2);
Pdefn(\bass_str,  2);
);

/* [kick] */
(
Pbindef(\all_kick,
  \instrument, \kik808,
  \scale,   Pn(Pdefn(\all_scale), inf),
  \octave,  Pseq([3, 3], inf),
  \dur,     1/Pdefn(\all_div),
  \stretch, Pdefn(\kick_str),
  \dist,  0.4,  
  \clickAmp, 0.5, 
  \pitchMod,  0.0,  
  \pitchRel,  0.0,  
  \rel,  Pseq([0.5!3, 1].flat,   inf),   
  // \rel, 0.5,  
  \subAmp,  0.3,  
  \amp,     0.9,
  \out,     ~pbd1.inbus.index,
  \degree,  Pseq([
    /* Pn(~deg.("0201-"),  1),
    Pn(~deg.("0-14-2"), 1),
    Pn(~deg.("--0--"),  1),
    Pn(~deg.("----------"),  1), */
    /* Pn(~deg.("0----21---4----"), 1),  */
    /* Pn(~deg.("02-0--0-2---0-----"), 1),  */
    Pn(~deg.("0-------0-------"), 1), 
    Pn(~deg.("0-------0-------"), 1), 
    Pn(~deg.("0-------0-0---0-"), 1),
  ], inf),
);
);

/* [snare] */
(
Pbindef(\all_sn,
  \instrument, \sn808,
  \scale,   Pn(Pdefn(\all_scale), inf),
  \octave,  Pseq([2, 2], inf),
  \dur,     1/Pdefn(\all_div),
  \stretch, Pseq([1], inf),
  \amp,     0.3,
  \snappy,  Pwhite(0.2, 1.0, inf),
  \snapRel, 4,
  \tonFreq, Pkey(\degree).midicps,
  \out,     ~psd1.inbus.index,
  \degree,  Pseq([
    Pn(~deg.("--------0-------"), 1),
    Pn(~deg.("------------4---"),   1),
  ], inf),
);
);

/* [hh] */
(
Pbindef(\all_hh,
  \instrument, Pseq([\hh808!4,  \harpy1].flat, inf),
  \scale,   Scale.dorian,
  \octave,  9,
  \degree,  ~deg.("4747"),
  \legato,  0.005,
  \pan,     0,
  \dur,     1/Pdefn(\all_div),
  \rel,     Pseq([0.1!4, 0.4].flat),
  \stretch, 2,
  \amp,     0.4,
  \out,     ~phh1.inbus.index,
);
);

/* [bass] */
(
Pbindef(\all_bass,
  \instrument, \bass8,
  \scale,   Scale.dorian,
  \octave,  Pseq([4,  4], inf),
  /* \root,    Pstep(Pseq([0,  2,  4,  1], inf), 1),   */
  \root,   0, 
  \dur,     1/Pdefn(\all_div),
  \stretch, Pdefn(\bass_str), 
  \legato,  Pseg([0.3, 0.9, 1.2], [2, 4], \sin,  inf), 
  \amp,     0.15,
  \pan,     0,
  \out,     ~t6.inbus.index,
  \degree,  Pseq([
    /* Pn(~deg.("0-74-2--"), 1), */
    /* Pn(~deg.("4-0--001"), 1), */
    /* Pn(~deg.("02-0--0-2---0-----"), 1),  */
    /* Pn(~deg.("04-23-0-----7241-0"), 1),  */
    /* Pn(~deg.("0404--3212--------"), 1),   */
    Pn(~deg.("01"), 1),  
  ], inf),
);
);

/* [structure] — eval once; reads Pbindefs by name at stream time */
(
Pdef(\all,
  Ppar([
    Pn(Plazy({ Pfindur(~kickCut.next * ~allMul[\kick], Pbindef(\all_kick)) }), inf),
    Pn(Plazy({ Pfindur(~snCut.next   * ~allMul[\sn],   Pbindef(\all_sn))   }), inf),
    Pn(Plazy({ Pfindur(~hhCut.next   * ~allMul[\hh],   Pbindef(\all_hh))   }), inf),
    Pn(Plazy({ Pfindur(~bassCut.next * ~allMul[\bass], Pbindef(\all_bass)) }), inf),
  ])
);
);

/* snippets — eval any of these as one-liners during performance */

/* change cut multiplier per voice: */
/* ~allMul[\kick] = 4; */

/* reset all cuts in phase (same sequence, independent streams): */
/* { var ~mkCut = { Pseq([3, 5, 3, 9].mirror, inf).asStream }; ~kickCut = ~mkCut.(); ~hhCut = ~mkCut.(); ~bassCut = ~mkCut.(); }; */

/* switch to shared stream for intentional drift: */
/* ~all_cut = Pseq([3, 5, 3, 9].mirror, inf).asStream; */
/* then update [structure] to use ~all_cut.next for all voices */

/* update one key on a running voice without restarting it: */
/* Pbindef(\all_kick, \amp, 0.8); */

/* swap kick degrees: */
/* Pbindef(\all_kick, \degree, Pseq([Pn(~deg.("040-1"),1), Pn(~deg.("--224-0---"),1)], inf)); */

/* swap bass to Pslide: */
/* Pbindef(\all_bass, \degree, Pn(Pslide((0..7), Pseq([8, 3, 5], inf), 3, 1), 1)); */
