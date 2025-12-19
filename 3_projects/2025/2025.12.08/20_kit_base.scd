
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree;
~fbufs;
(
/////////////////////////////////////////////////////////////
// BD1
/////////////////////////////////////////////////////////////
Pdef(\bd1_m,  Pbind(\type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  \amp, 0.8,
  \dur, Pn(Pdefn(\bd1_phr), inf), 
));

Pdef(\bd1_s, Pbind(
  \instrument, \pBs,
  // \buf, Pdefn(\bd1_bufs),
  \idx, Pdefn(\bd1_idx),  
  \bufnum,  Pindex(~fbufs[\bass_drums],  Pkey(\idx)),
  \rate, 1,
  // \amp, 0.8,
  \amp,  Pseq([0.9, 0.7, 0.6],  inf), 
  \dur, Pn(Pdefn(\bd1_phr), inf), 
  \out, ~pbd1.inbus.index,  
));

Pdef(\bd1,
    Pdef(\bd1_m)
);
~apcAssignPad.(32, \bd1);
~lcxlBindPdef.(\b1_s2_p, \bd1);

/////////////////////////////////////////////////////////////
// SD1
/////////////////////////////////////////////////////////////
Pdef(\sd1_m,  Pbind(\type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  \amp, Pseq([0.8!7,  0.4].flat,  inf),
  \degree,  Pseq([1].flat,  inf),  
  \timingOffset,  1/4,  
  \dur, Pn(Pdefn(\sd1_phr), inf),
));

Pdef(\sd1_s, Pbind(
  \instrument, \pBs,
  // \buf, Pdefn(\bd1_bufs),
  \idx, Pdefn(\sd1_idx),  
  \bufnum,  Pindex(~fbufs[\snare_drums],  Pkey(\idx)),
  \rate, 1,
  \amp, 0.8,
  \dur, Pn(Pdefn(\sd1_phr), inf),  
  \out, ~psd1.inbus.index,  
));

Pdef(\sd1,
    Pdef(\sd1_m)
);
~apcAssignPad.(33, \sd1);
~lcxlBindPdef.(\b1_s3_p, \sd1);

/////////////////////////////////////////////////////////////
// HH1
/////////////////////////////////////////////////////////////
Pdef(\hh1_m,  Pbind(\type,  \midi, \midiout, ~mOut,  \chan,  0,  \scale, Scale.chromatic,  \octave,  3,  
  \amp, Pn(Pdefn(\hh1_ampm), inf),  
  \degree,  Pseq([6!3,  2].flat,  inf),  
  \dur, Pn(Pdefn(\hh1_phr), inf), 
));

Pdef(\hh1_s, Pbind(
  \instrument, \pBs,
  // \buf, Pdefn(\bd1_bufs),
  \idx, Pdefn(\hh1_idx),  
  \bufnum,  Pindex(~fbufs[\hats],  Pkey(\idx)),
  \rate, 1,
  \amp, Pn(Pdefn(\hh1_ampm), inf),  
  \dur, Pdefn(\hh1_phr1),
  \out, ~phh1.inbus.index,  
));

Pdef(\hh1,
    Pdef(\hh1_m)
);

~apcAssignPad.(34, \hh1);
~lcxlBindPdef.(\b1_s4_p, \hh1);

/////////////////////////////////////////////////////////////
// KIT
/////////////////////////////////////////////////////////////
Pdef(\kit1, 
  Ppar([
    Pdef(\bd1),
    Pdef(\sd1),
    Pdef(\hh1),
  ],  inf), 
);
~lcxlBindPdef.(\b1_s1_p, \kit1);
)
