Ndef(\t1, {|mod=1| LFPulse.ar([110, 111]) * SinOsc.kr(mod) * 0.2 });
Ndef(\t1).set(\out, ~m36_in.(0));
Ndef(\t1).play;
Ndef(\t1).stop;

// Bank 0, Strip 3, Row-1: control a reverb "room" (0.05..0.98)
~lcxlBindParam.(\b0_s1_r1, { |x|
    Ndef(\t1).set(\mod, x.linexp(0, 1, 1, 64));
});

// Bank 1, Strip 5, Row-2: mod depth (0..0.7)
~lcxlBindParam.(\b1_s5_r2, { |x|
    Ndef(\synthA).set(\modDepth, x * 0.7);
});

