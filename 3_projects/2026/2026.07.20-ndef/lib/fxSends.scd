(
Ndef(\fxsBitcrush)[0] = { |brate=44100, bits=8, mix=1, mute=0, amp=1|
    var sig = Ndef.ar(\s1_sum, 2);   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
    ~fxg[\bitcrush].(sig, brate, bits, mix, mute, amp);
};
~fxAddFX.(\fxsBitcrush);
);
