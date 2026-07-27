(
~fxAddSend.(\s3);
~fxAddSend.(\s4);
~fxAddSend.(\s5);
~fxAddSend.(\s6);
Ndef(\fxsBitcrush)[0] = { |brate=44100, bits=8, mix=1, mute=0, amp=1|
    var sig = Ndef.ar(\s1_sum, 2);   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
    ~fxg[\bitcrush].(sig, brate, bits, mix, mute, amp);
};
~fxAddFX.(\fxsBitcrush);

// Biscuit
// in=0, out=0,
// drive=1.0,
// clock=30000, bits=8,
// b1=1, b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1,
// fxMode=0,
// shape=0,
// delTime=0.25, delFB=0.3,
// pitchShift=5,
// stepRate=4.0, sf0=200, sf1=400, sf2=800, sf3=1600,
// filterType=0, filterFreq=15000, filterQ=0.1,
// naked=1.0, dressed=1.0 |

Ndef(\fxsBiscuit)[0] = { |
    drive=1.0,
    clock=30000, bits=8,
    b1=1, b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1,
    fxMode=0,
    shape=0,
    delTime=0.25, delFB=0.3,
    pitchShift=5,
    stepRate=4.0, sf0=200, sf1=400, sf2=800, sf3=1600,
    filterType=0, filterFreq=15000, filterQ=0.1,
    naked=1.0, dressed=1.0 |
    var sig = Ndef.ar(\s2_sum, 2);   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
    ~fxg[\biscuit].(
      sig,
      drive,
      clock,  bits,
      b1, b2, b3, b4, b5, b6, b7, b8, 
      fxMode, 
      shape,  
      delTime,   delFB, 
      pitchShift, 
      stepRate, sf0,  sf1,  sf2,  sf3,  
      filterType, filterFreq,  filterQ, 
      naked,   dressed
    );
};
~fxAddFX.(\fxsBiscuit);

Ndef(\fxs)
);
