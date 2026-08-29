~midiInMap.(2, \bass8,   out: Ndef(\ins3).index, args:[\amp: 0.4]);
~midiInMap.(4, \fmSaw,   out: Ndef(\ins4).index,  args:[\amp: 0.4]);
~midiInMap.(5, \pm1,   out: Ndef(\ins4).index,  args:[\amp, 0.1]);
~midiInMap.(1, \scratch,   out: Ndef(\ins5).index);

(
~midiInMap.(6,  \pBm, out: Ndef(\ins1).index,  args:[
  // \bufnum,  ~sTree[\whoosh_impacts].values.choose,   
  \bufnum,  ~sTree[\hoarder_mono].values.choose,   
  \nSlices,  4, 
  \rate,  2,  
  \sliceDur,  1, 
  \amp, 0.4,  
]);
);
(
~midiInMap.(7,  \pBs, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree.[\bass_drums].values[0],   
]);
);
(
~midiInMap.(8,  \pBs, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree[\hats].values[7],     
]);
);
(
~midiInMap.(4,  \fm3, out: Ndef(\ins4).index);
);
(
);
// (
// ~midiInPsetStop.(7);
// ~bds = ~sTree.at(\bass_drums).asArray[0..8];
// ~midiInPset.(7, [\rate], Pbind(
//   // \buf, Pseq(~sTree[\bass_drums].values[5..10],  inf),
//   \buf, Pseq(~bds,  inf),
//   \bufnum, Pkey(\buf),  
//   // \rate,  Pwhite(-2,  2,  inf),
//   \dur, 1, 
// ));
// );
