(
Pdefn(\kk0, ~hit.("x--x--", 0,  1));
Pdefn(\kk1, ~hit.("-xx--x------", 0,  1));
Pdefn(\kk2, ~hit.("x-x-x-x-", 0,  1));
Pdefn(\kk3, ~hit.("xxxxxxxx", 0,  1));
Pdefn(\kkA, Pseq([
  Pn(Pdefn(\kk0), 4), 
  Pn(Pdefn(\kk1), 2), 
],  1));
Pdefn(\kkB, Pseq([
  Pn(Pdefn(\kk2), 4), 
  Pn(Pdefn(\kk3), 2), 
],  1));
Pdefn(\kk,  Pseq([Pdefn(\kkA)], inf));

Pdefn(\sn0, ~hit.("----x-x-", 1,  1));
Pdefn(\sn1, ~hit.("----x-", 1,  1));
Pdefn(\snA, Pseq([
  Pn(Pdefn(\sn0), 4), 
  Pn(Pdefn(\sn1), 2), 
],  1));
Pdefn(\sn,  Pseq([Pdefn(\snA)], inf));

Pdefn(\hh0, ~hit.("x-x-x-", 2,  1));
Pdefn(\hh1, ~hit.("-x-x-x", 2,  1));
Pdefn(\hhA, Pseq([
  Pn(Pdefn(\hh0), 8), 
  Pn(Pdefn(\hh1), 2), 
], 1));
Pdefn(\hh,  Pseq([Pdefn(\hh0)], inf));

~kitBase = Pbind(\type, \midi, \midiout, ~mOut, \chan, 0, 
  \dur, 1/8,  
  \scale, Scale.chromatic,  
  \octave,  Pseq([3,  Pseq([ 3], 1)], inf),   
  \stretch, 2,  
);
Pdef(\kitm, Ppar([
  Ppar([
    Pchain(Pbind(\degree, Pdefn(\kk)),  ~kitBase),
    Pchain(Pbind(\degree, Pdefn(\sn)),  ~kitBase),
    Pchain(Pbind(\degree, Pdefn(\hh)),  ~kitBase),
  ]),
  Pbind(
      \type, \midi, \midiout, ~mOut, \chan, 15,
      \ctlNum, 1,
      \control, Pseg([0, 127], [4], \lin, inf),
      \dur, 1/16
  )
]));
~lpBindB.(1, [1, 1], \kitm,  9);     // bank 1, pad [1,1]
~lpBindBToggleFn.(1, [2, 1],
    { Pdefn(\kk, Pseq([Pdefn(\kkB)], 4)) },
    { Pdefn(\kk, Pseq([Pdefn(\kkA)], 4)) }
);
)
Pdef(\kitm).play(~link);
Pdef(\kitm).stop;
~mOut.control(16, 1, 127);
