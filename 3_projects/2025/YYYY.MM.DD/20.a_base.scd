
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree;
~fbufs;
(
/////////////////////////////////////////////////////////////
// A000
/////////////////////////////////////////////////////////////
Pdef(\a000_m,  Pbind(\type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  // --- SC
  // \instrument, \pBs,
  // // \buf, Pdefn(\bd1_bufs),
  // \idx, Pdefn(\a000_idx),  
  // \bufnum,  Pindex(~fbufs[\bass_drums],  Pkey(\idx)),
  // \rate, 1,
  // // \out, ~pbd1.inbus.index,  
  // \out, 2,  
  // --- Common
  \amp, Pseq([0.9,  0.7,   0.5,  0.1].mirror,  inf),
  \degree,  Pseq([0,  1,  4,  3,  \,  \,  ], inf).stutter(8), 
  \dur, Pn(Pdefn(\a000_phr), inf), 
));

Pdef(\a000,
    Pdef(\a000_m)
);
~apcAssignPad.(32, \a000);
~lcxlBindPdef.(\b1_s2_p, \a000);

/////////////////////////////////////////////////////////////
// a100
/////////////////////////////////////////////////////////////
Pdef(\a100_m,  Pbind(\type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  // --- SC
  \instrument, \pBs,
  // \buf, Pdefn(\bd1_bufs),
  \idx, Pdefn(\a100_idx),  
  \bufnum,  Pindex(~fbufs[\snare_drums],  Pkey(\idx)),
  \rate, 1,
  \out, 2,  
  // --- Common
  \amp, Pseq([0.8!7,  0.4].flat,  inf),
  \degree,  Pseq([1].flat,  inf),  
  \timingOffset,  1/4,  
  \dur, Pn(Pdefn(\a100_phr), inf),
));

Pdef(\a100,
    Pdef(\a100_m)
);
~apcAssignPad.(33, \a100);
~lcxlBindPdef.(\b1_s3_p, \a100);

/////////////////////////////////////////////////////////////
// a200
/////////////////////////////////////////////////////////////
Pdef(\a200_m,  Pbind(\type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  // --- SC
  // \instrument, \pBs,
  // \buf, Pdefn(\bd1_bufs),
  // \idx, Pdefn(\a200_idx),  
  // \bufnum,  Pindex(~fbufs[\hats],  Pkey(\idx)),
  // \rate, 1,
  // \out,  2, 
  // --- Common
  \amp, Pn(Pdefn(\a200_ampm), inf),  
  \degree,  Pseq([2!3,  [6, 2]].flat,  inf),  
  \dur, Pn(Pdefn(\a200_phr), inf), 
));

Pdef(\a200,
    Pdef(\a200_m)
);

~apcAssignPad.(34, \a200);
~lcxlBindPdef.(\b1_s4_p, \a200);

/////////////////////////////////////////////////////////////
// KIT
/////////////////////////////////////////////////////////////
Pdef(\a0, 
  Ppar([
    Pdef(\a000),
    Pdef(\a100),
    Pdef(\a200),
  ],  inf), 
);
~lcxlBindPdef.(\b2_s1_p, \a0);
)
