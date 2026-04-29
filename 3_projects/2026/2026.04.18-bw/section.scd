(
~link.tempo = 80/60;
// "kit01.scd".loadRelative;
// "v01.scd".loadRelative;

Pdef(\score, Ppar([
  Pseq([
    Psection([\kitm], 8, {~mOut.control(16, 80, 127)},  sync: true),  
    Psection([\kitm, \v01], 16, {~mOut.control(16, 80, 127)}, sync: true),
    Psection([\v01], 8, {~mOut.control(16, 80, 0)},  sync: true),
    Psection([\kitm, \v01], 8, 
    // { 
    //   Pdefn(\kk, Pseq([Pdefn(\kkB)], 4));
    //   Pdefn(\v01_deg, Pseq([Pdefn(\v01_deg_B)], 4));
    // },
    sync: true),

    Psection([\kitm, \v01], 16, 
    { 
      Pdefn(\kk, Pseq([Pdefn(\kkA)], 4));
      Pdefn(\v01_deg, Pseq([Pdefn(\v01_deg_A)], 4));
    },
    sync: true),

    Psection([\kitm, \v01], 16, 
    { 
      Pdefn(\kk, Pseq([Pdefn(\kkB)], 4));
      Pdefn(\v01_deg, Pseq([Pdefn(\v01_deg_B)], 4));
    },
    sync: true),

  ], inf),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 16,
    \midicmd, \control, \ctlNum, 21,
    \dur, 1/16,
    \control, 1,  
  )

])
);
~lpBindB.(1, [8, 8], \score,  80);     // bank 1, pad [1,1]
)
Pdef(\score).play(~link);
Pdef(\score).stopQ(4);
