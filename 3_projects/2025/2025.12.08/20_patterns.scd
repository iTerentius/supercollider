
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree;
~fbufs;
(
//
// /////////////////////////////////////////////////////////////
// // BD1
// /////////////////////////////////////////////////////////////
// // Pdefn(\bd1_bufs, ~fbufs[\bass_drums][0] );
//
// // words
//
// Pdefn(\bd1_durm,  1/4);
// Pdefn(\bd1_dur0,
//     Pseq([1/2 ! 3, Pn(Rest(), 1/2), 1/4 ! 2].flat, 1)
// );
//
// Pdefn(\bd1_dur1,
//     Pseq([1/4 ! 4, 1/2, Pn(Rest(), 1.5)].flat, 1)
// );
//
// Pdefn(\bd1_dur2,
//     Pseq([1/8 ! 8, Rest() ! 2].flat, 1)
// );
//
// Pdefn(\bd1_dur3,
//    Pbjorklund2(5, 8,  1)
// );
//
// Pdefn(\bd1_idx,
//     Pseq([1!3,  2,  ].flat, inf), 
//     // 2,  
// );
//
//
// // phrases
//
// Pdefn(\bd1_phr1,
//     Pseq([
//         Pn(Pdefn(\bd1_durm), 4), 
//         Pn(Pdefn(\bd1_dur0), 2),
//         Pn(Pdefn(\bd1_dur3), 1),
//     ], 1)
// );
//
// Pdefn(\bd1_phr2,
//     Pseq([
//         Pn(Pdefn(\bd1_dur0), 1),
//         Pn(Pdefn(\bd1_dur1), 1),
//         Pn(Pdefn(\bd1_dur2), 1)
//     ], 1)
// );
//
// Pdefn(\bd1_phr, Pseq([Pdefn(\bd1_phr1), Pdefn(\bd1_phr2)],  inf));
//


Pbindef(\bd1_m,  \type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  \amp, 0.8,
  \dur, Pdefn(\bd1_phr),
);


Pbindef(\bd1_s,
  \instrument, \pBs,
  // \buf, Pdefn(\bd1_bufs),
  \idx, Pdefn(\bd1_idx),  
  \bufnum,  Pindex(~fbufs[\bass_drums],  Pkey(\idx)),
  \rate, 1,
  // \amp, 0.8,
  \amp,  Pseq([0.9, 0.7, 0.6],  inf), 
  \dur, Pdefn(\bd1_phr),
  \out, ~pbd1.inbus.index,  
);


// sentences

Pdef(\bd1,
    Pbindef(\bd1_m)
);

// ~apcAssignPad.(32, \bd1);
// ~lcxlBindPdef.(\b1_s1_p, \bd1);

// Pdef(\bd1).play(~link,  quant:4);
// Pdef(\bd1).stop;


/////////////////////////////////////////////////////////////
// SD1
/////////////////////////////////////////////////////////////
// // Pdefn(\sd1_bufs, ~fbufs[\snare_drums][0] );
//
// // words
//
// // Pdefn(\sd1_durm,  Ptpar([1/4,  Pseq([1/2],  1) ]));
// Pdefn(\sd1_durm,  Pseq([1/2],  1) );
// Pdefn(\sd1_dur0,
//     // Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1)
//     Pseq([Pbjorklund2(3,  16,  1)/4],  1),  
// );
//
// Pdefn(\sd1_idxt,
//     Pseq([2, ], inf), 
//     // 2,  
// );
//
//
// // phrases
//
// Pdefn(\sd1_phr1,
//     Pseq([
//         Pn(Pdefn(\sd1_durm), 1), 
//         Pn(Pdefn(\sd1_dur0), 2),
//         // Pn(Pdefn(\sd1_dur1), 1),
//     ], inf)
// );
//
// Pdefn(\sd1_phr2,
//     Pseq([
//         Pn(Pdefn(\sd1_dur0), 1),
//         Pn(Pdefn(\sd1_dur1), 1),
//         Pn(Pdefn(\sd1_dur2), 1)
//     ], inf)
// );

Pbindef(\sd1_m,  \type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  \amp, Pseq([0.8!7,  0.4].flat,  inf),
  \degree,  Pseq([1!7,  5].flat,  inf),  
  \timingOffset,  1/4,  
  \dur, Pdefn(\sd1_phr1),
);

// Pbindef(\sd1_s,
//   \instrument, \pBs,
//   // \buf, Pdefn(\bd1_bufs),
//   \idx, Pdefn(\sd1_idx),  
//   \bufnum,  Pindex(~fbufs[\snare_drums],  Pkey(\idx)),
//   \rate, 1,
//   \amp, 0.8,
//   \dur, Pdefn(\sd1_phr1),
//   \out, ~psd1.inbus.index,  
// );

Pdef(\sd1,
    Pbindef(\sd1_m)
);
// ~apcAssignPad.(33, \sd1);
// ~lcxlBindPdef.(\b1_s2_p, \sd1);

// Pdef(\sd1).play(~link,  quant:4);
// Pdef(\sd1).stop;


/////////////////////////////////////////////////////////////
// HH1
/////////////////////////////////////////////////////////////
// // Pdefn(\hh1_bufs, ~fbufs[\hats][0] );
//
// // words
//
// // Pdefn(\hh1_durm,  Ptpar([1/8,  Pseq([1/8].flat,  1)));
// Pdefn(\hh1_durm,  Pseq([1/8].flat,  1));
// Pdefn(\hh1_dur0,
//     // Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1)
//     Pseq([Pbjorklund2(13,  16,  inf)]/4,  1)
// );
//
// Pdefn(\hh1_ampm,   Pseq([0.5!7, 0.9].flat, inf));
//
// Pdefn(\hh1_idx,
//     Pseq([1,   ], inf), 
//     // 2,  
// );
//
//
// // phrases
// Pdefn(\hh1_phr1,
//     Pseq([
//         Pn(Pdefn(\hh1_durm), 4), 
//         Pn(Pdefn(\hh1_dur0), 2),
//         // Pn(Pdefn(\hh1_dur1), 1),
//     ], inf)
// );
//
// Pdefn(\hh1_phr2,
//     Pseq([
//         Pn(Pdefn(\hh1_dur0), 1),
//         Pn(Pdefn(\hh1_dur1), 1),
//         Pn(Pdefn(\hh1_dur2), 1)
//     ], inf)
// );

Pbindef(\hh1_m,  \type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  \amp, Pdefn(\hh1_ampm),
  \degree,  Pseq([6!3,  2].flat,  inf),  
  \dur, Pdefn(\hh1_phr1),
);

// Pbindef(\hh1_s,
//   \instrument, \pBs,
//   // \buf, Pdefn(\bd1_bufs),
//   \idx, Pdefn(\hh1_idx),  
//   \bufnum,  Pindex(~fbufs[\hats],  Pkey(\idx)),
//   \rate, 1,
//   \amp, Pdefn(\hh1_ampm),
//   \dur, Pdefn(\hh1_phr1),
//   \out, ~phh1.inbus.index,  
// );

Pdef(\hh1,
    Pbindef(\hh1_m)
);

// ~apcAssignPad.(34, \hh1);
// ~lcxlBindPdef.(\b1_s3_p, \hh1);

// Pdef(\hh1).play(~link,  quant:4);
// Pdef(\hh1).stop;
)
