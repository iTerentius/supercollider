~lcxlSC.learnFaders.();  // move the 8 faders left→right
~lcxlSC.learnTop.();     // top knobs
~lcxlSC.learnMid.();     // middle knobs
~lcxlSC.learnBot.();     // bottom knobs

~lcxlSC.postln;  // should print an Event with your functions

~lcxlSC.status.();

(
// 8 voices ch0..ch7
8.do { |i|
    var nm = ("ch"++i).asSymbol;
    Ndef(nm, { |freq=110, level=0.2, cutoff=1000, rq=0.2, mix=0.0|
        var f   = freq * (i+1);
        var dry = Saw.ar(f!2) * 0.2;
        var wet = RLPF.ar(dry, cutoff.max(40), rq.clip(0.05,0.99));
        XFade2.ar(dry, wet, (mix*2-1)) * level
    }).play;
};
)



