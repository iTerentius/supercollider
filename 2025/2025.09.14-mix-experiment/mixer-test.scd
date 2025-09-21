Ndef(\t1, {|mod=1| LFPulse.ar([110/mod, 111]) * SinOsc.kr(mod) * 0.5 });
Ndef(\t1).set(\out, ~m36_in.(0));
Ndef(\t1).play;
Ndef(\t1).stop;
Ndef(\t1).clear;

// Bank 0, Strip 3, Row-1: control a reverb "room" (0.05..0.98)
~lcxlBindParam.(\b0_s1_r1, { |x|
    Ndef(\t1).set(\mod, x.linexp(0, 1, 1, 64));
});

// Bank 1, Strip 5, Row-2: mod depth (0..0.7)
~lcxlBindParam.(\b1_s5_r2, { |x|
    Ndef(\synthA).set(\modDepth, x * 0.7);
});
~lcnBindParam.(\b0_s1_r1, { |x| Ndef(\t1).set(\mod, x.linexp(0, 1, 1, 64)) });
~lcnBindParam.(\b1_s4_r2, { |x| Ndef(\synthA).set(\modDepth, x*0.7) });

// pick default device for 2-arg ~ccb
~ccdev.(\lcx);  // or \lc

// bind using default
~ccb.(\b0_s1_r1, { |x| Ndef(\t1).set(\mod, x.linexp(0,1, 1,64)) });

// bind explicitly to Launch Control (non-XL)
~ccb.(\lc,  \b0_s1_r1, { |x| Ndef(\t1).set(\mod, x.linexp(0,1, 1,64)) });

// unbind
~ccu.(\b0_s1_r1);        // default device
~ccu.(\lc, \b0_s1_r1);   // explicit device

// list binds
~ccshow.();        // both devices
~ccshow.(\lcx);    // LCXL only

{SinOsc.ar([100, 102]) * 0.5}.play(out: ~m36_in.(1));

~m36_tracks[1].play({ SinOsc.ar([100, 101]) * 0.5});
