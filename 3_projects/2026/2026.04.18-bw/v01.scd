
(
Pdefn(\v01_deg_0, Pseq([0,  1,  \,  0,  \,  \], 1));
Pdefn(\v01_deg_1, Pslide([0,  1,  0,  2,  \,  \], 1,  2,  3)); 

Pdefn(\v01_deg_A, Pseq([
  Pn(Pdefn(\v01_deg_0), 4), 
  Pn(Pdefn(\v01_deg_1), 2), 
],  1));
Pdefn(\v01_deg_B, Pseq([
  Pn(Pdefn(\v01_deg_0), 4), 
  Pn(Pdefn(\v01_deg_1), 2), 
],  1));
Pdefn(\v01_deg,  Pseq([Pdefn(\v01_deg_A)], inf));

Pdefn(\v01_dur_0, 1/4);
Pdefn(\v01_dur_1, Pseq([1/4!2,  1/2!2,  Pn(Rest(), 2.5)].flat,  1)); 

Pdefn(\v01_dur_A, Pseq([
  Pn(Pdefn(\v01_dur_0), 4), 
  // Pn(Pdefn(\v01_dur_1), 2), 
],  1));
Pdefn(\v01_dur_B, Pseq([
  Pn(Pdefn(\v01_dur_0), 4), 
  Pn(Pdefn(\v01_dur_1), 2), 
],  1));
Pdefn(\v01_dur,  Pseq([Pdefn(\v01_dur_A)], inf));

~v01Base = Pbind(\type, \midi, \midiout, ~mOut, \chan, 1, 
  // \dur,  Pn(Pdefn(\v01_dur),  inf), 
  \scale, Scale.dorian,  
  \root,  5,  
  \octave,  Pseq([3, 3], inf),   
  \stretch, 1,  
);
Pdef(\v01, Ppar([
  Pchain(
    Pbindef(\v01_pb,  
    \dur,  Pn(Pdefn(\v01_dur),  inf), 
    \degree,  Pn(Pdefn(\v01_deg), inf), 
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
// ~lpBindBToggleFn.(1, [2, 1],
//     { Pdefn(\kk, Pseq([Pdefn(\kkB)], 4)) },
//     { Pdefn(\kk, Pseq([Pdefn(\kkA)], 4)) }
// );
)
Pdef(\v01).play(~link);
Pdef(\v01).clear;
~mOut.control(16, 2, 127);

