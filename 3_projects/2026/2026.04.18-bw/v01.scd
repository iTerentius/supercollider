
(

~v01Base = Pbind(\type, \midi, \midiout, ~mOut, \chan, 1, 
  \dur, Pseq([1/4!2,  1/2!2,  Pn(Rest(), 2.5)].flat,  inf),   
  \scale, Scale.dorian,  
  \root,  5,  
  \octave,  Pseq([3, 3], inf),   
  \stretch, 1,  
);
Pdef(\v01, Ppar([
  Pchain(
    Pbind(
    \degree,  Pslide([0,  1,  0,  2], inf,  2,  3),  
    \amp, Pseq([1,  0.8!2, 1].flat, inf),   
  ),  ~v01Base),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 16,
    \midicmd, \control, \ctlNum, 1,
    \dur, 1/16,
    // \control, Pseg([0, 0], [3], \lin, inf)
  )
]));
~lpBindB.(1, [1, 2], \v01,  80);     // bank 1, pad [1,1]
// ~phrFns[\kit] = (
//     a: {
//         Pbindef(\kit_pb),
//             \degree, Pseq([Pn(Pdefn("_degs_b")), 4)], inf), 
//             \stretch, Pseq([Pn(Pdefn(mk.("_str_1")), 4)], inf), 
//           )
//     },
//     b: {  // reset to defaults
//         Pbindef(\kit_pb),
//             \dur,    Pseq([Pn(Pdefn(mk.("_durs_a")), 4)], inf),
//             \degree, Pseq([Pn(Pdefn(mk.("_degs_a")), 4)], inf), 
//             \stretch, Pseq([Pn(Pdefn(mk.("_str_0")), 4)], inf), 
//           )
//     },
//     c: {
//         Pbindef(mk.("_pb"),
//             \dur,    Pseq([Pn(Pdefn(mk.("_durs_c")), 4)], inf),
//             \degree, Pseq([Pn(Pdefn(mk.("_degs_b")), 4)], inf),
//             \stretch, Pseq([Pn(Pdefn(mk.("_str_0")), 4)], inf))
//     },
//     d: {
//         Pbindef(mk.("_pb"),
//             \dur,    Pseq([Pn(Pdefn(mk.("_durs_d")), 4)], inf),
//             \degree, Pseq([Pn(Pdefn(mk.("_degs_b")), 4)], inf),
//             \stretch, Pseq([Pn(Pdefn(mk.("_str_0")), 4)], inf))
//     },
// );

)
Pdef(\v01).play(~link);
Pdef(\v01).clear;
~mOut.control(16, 2, 127);

