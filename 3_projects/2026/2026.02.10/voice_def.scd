// Usage:
  ~lumiPlay.(\moogLead, out: ~busOf.(~t3));
  ~lumiPlay.(\ks_string, out: ~busOf.(~t4), args: [\delayTime, 0.3]);
  ~lumiStop.();   // release all notes + free MIDIdefs
  ~lumiSwap.(\ms20);  // stop current, switch to new synth

  

  Pdef(\junoChords).play;
  Pdef(\junoChords).stop;
  Pdef(\acid).play;
  Pdef(\acid).stop;
  Pdef(\ms20).play;
  Pdef(\ms20).stop;
(
// MS-20 style bass
Pdef(\ms20,
    Pbind(
        \instrument, \ms20Bass,
        \scale, Scale.minor,
        // \degree, Pseq([0, 0, 3, 5,  Pn(Rest(), 8)], inf),
        \degree, Pseq([0, 1, 0, -4,  \, \,  \,  \], inf),
        \octave, Pseq([3],  inf), 
        \dur, Pseq([1/4].flat,  inf), 
        \legato, 0.6,
        // \hpfCutoff, Pseg([0,  100, 1000], [2, 4], \sin, inf), 
        \lpfCutoff, Pseg([0,  100, 1000], [1, 4], \sin, inf), 
        \lpfRes, 0.8,
        \filterEnvAmt, Pseg([500, 2000,  100],  [2, 2],  \sin, inf), 
        \ringMod, 0.2
    )
);
)

