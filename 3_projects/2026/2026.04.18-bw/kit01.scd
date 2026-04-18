
(
Pdefn(\kk0, ~hit.("x--x--", 0));
Pdefn(\kk1, ~hit.("-xx--x------", 0));
Pdefn(\kkA, Pseq([
  Pn(Pdefn(\kk0), 4), 
  Pn(Pdefn(\kk1), 2), 
],  1));
Pdefn(\kk,  Pseq([Pdefn(\kk0)], 4));

Pdefn(\sn0, ~hit.("----x-x-", 1));
Pdefn(\sn1, ~hit.("----x-", 1));
Pdefn(\snA, Pseq([
  Pn(Pdefn(\sn0), 4), 
  Pn(Pdefn(\sn1), 2), 
],  1));
Pdefn(\sn,  Pseq([Pdefn(\snA)], 4));

Pdefn(\hh0, ~hit.("x-x-x-", 2));
Pdefn(\hh1, ~hit.("-x-x-x", 2));
Pdefn(\hhA, Pseq([
  Pn(Pdefn(\hh0), 8), 
  Pn(Pdefn(\hh1), 2), 
], 1));
Pdefn(\hh,  Pseq([Pdefn(\hh0)], 1));

~kitBase = Pbind(\type, \midi, \midiout, ~mOut, \chan, 0, 
  \dur, 1/4,  
  \scale, Scale.chromatic,  
  \octave,  Pseq([3,  Pseq([ 3], 1)], inf),   
  \stretch, 1,  
);
Pdef(\kitm, Ppar([
  Ppar([
    Pchain(Pbind(\degree, Pdefn(\kk)),  ~kitBase),
    Pchain(Pbind(\degree, Pdefn(\sn)),  ~kitBase),
    Pchain(Pbind(\degree, Pdefn(\hh)),  ~kitBase),
  ]),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 16,
    \midicmd, \control, \ctlNum, 1,
    \dur, 1/16,
    // \control, Pseg([0, 0], [3], \lin, inf)
  )
]));
~lpBindB.(1, [1, 1], \kitm,  9);     // bank 1, pad [1,1]
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
Pdef(\kitm).play(~link);
Pdef(\kitm).clear;
~mOut.control(16, 1, 127);

