TempoClock.default.tempo = 80/60;
(
// Pdefn(\v01_deg_0, Pseq([0,  1,  \,  0,  ], 1));
Pdefn(\v01_deg_1, Pslide([0,  1,  0,  2,  ], 1,  2,  3)); 
Pdefn(\v01_deg_0, ~deg.("0010---76321--",  1,  Pkey(\dur)));
Pdefn(\v01_deg_2, ~deg.("001002-00-10-04-20-",  1,  Pkey(\dur)));
Pdefn(\v01_deg_3, Pseq([~deg.("0100",  1,  Pkey(\dur)),  Pn(Rest(),  3)], 1));

Pdefn(\v01_deg_A, Pseq([
  Pn(Pdefn(\v01_deg_3), 4), 
  Pn(Rest(),  4), 
  Pn(Pdefn(\v01_deg_0), 1), 
],  1));
Pdefn(\v01_deg_B, Pseq([
  Pn(Pdefn(\v01_deg_2), 4), 
  Pn(Pdefn(\v01_deg_1), 2), 
],  1));
Pdefn(\v01_deg,  Pseq([Pdefn(\v01_deg_A)], inf));

Pdefn(\v01_dur_0, 1/8);
Pdefn(\v01_dur_1, Pseq([1/4!2,  1/2!2].flat,  1)); 
Pdefn(\v01_dur_2, 1/8);

Pdefn(\v01_dur_A, Pseq([
  Pn(Pdefn(\v01_dur_0), 4), 
  // Pn(Pdefn(\v01_dur_1), 2), 
],  1));
Pdefn(\v01_dur_B, Pseq([
  Pn(Pdefn(\v01_dur_0), 4), 
  Pn(Pdefn(\v01_dur_2), 1), 
],  1));
Pdefn(\v01_dur,  Pseq([Pdefn(\v01_dur_A)], inf));

~v01Base = Pbind(\type, \midi, \midiout, ~mOut, \chan, 1, 
  // \dur,  Pn(Pdefn(\v01_dur),  inf), 
  \scale, Scale.minor,  
  \root,  5,  
  \octave,  Pseq([3, 3], inf),   
  \stretch, 2,  
);
Pdef(\v01, Ppar([
  Pchain(
    Pbindef(\v01_pb,  
    \dur,  Pn(Pdefn(\v01_dur),  inf), 
    \degree,  Pn(Pdefn(\v01_deg), inf), 
    \amp, Pseq([0.5!2,  0.4!1].flat, inf),   
    \legato, Pseq([1/2, 3/4].flat,  inf),  
  ),  ~v01Base),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 16,
    \midicmd, \control, \ctlNum, 21,
    \dur, 1/16,
    // \control, Pseg([0, 127, 0], [1, 2], \lin, inf)
  )
]));
~lpBindB.(1, [1, 2], \v01,  80);     // bank 1, pad [1,1]
~lpBindBToggleFn.(1, [2, 2],
    { Pdefn(\v01_deg, Pseq([Pdefn(\v01_deg_B)], 4)) },
    { Pdefn(\v01_deg, Pseq([Pdefn(\v01_deg_A)], 4)) }
);
)
Pdef(\v01).play(~link);
Pdef(\v01).clear;
~mOut.control(16, 21, 127);

