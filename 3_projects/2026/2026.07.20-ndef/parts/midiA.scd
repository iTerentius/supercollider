~midiInMap.(2, \bass8,   out: Ndef(\ins3).index, args:[\amp: 0.4]);
~midiInMap.(4, \fmSaw,   out: Ndef(\ins4).index,  args:[\amp: 0.4]);
~midiInMap.(5, \pm1,   out: Ndef(\ins4).index,  args:[\amp, 0.1]);
~midiInMap.(1, \scratch,   out: Ndef(\ins5).index);

(
~midiInMap.(6,  \pBm, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree[\whoosh_impacts].values.choose,   
  \nSlices,  4, 
  \rate,  2,  
  \sliceDur,  1, 
  \amp, 0.4,  
]);
);
(
~midiInMap.(7,  \pBs, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree[\bass_drums].values.choose,   
]);
);
(
~midiInMap.(8,  \pBs, out: Ndef(\ins1).index,  args:[
  \bufnum,  ~sTree[\hats].values.choose,     
]);
);
(
~midiInPsetStop.(7);
// ~midiInPset.(7, [\bufnum],   Pbind(
//   \bufnum,   Pseq(~sTree[\bass_drums].values[0..3],  inf),  
//   \dur, 2,  
// ));
);
