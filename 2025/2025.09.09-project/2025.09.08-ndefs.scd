

// --- Sources ---------------------------------------------------------------

Ndef(\all).proxyspace.quant = 1;
Ndef(\all).proxyspace.fadeTime = 1;
Ndef(\test, )
(
Ndef(\i1, { |freq = 110, amp = 0.15|
    var sig;
    sig = SinOsc.ar(Pulse.kr(32!2) * freq) * amp * 0.6;
    sig
}).play(out: 4, vol: 1);
)
Ndef(\i1)[1] = \filter -> {|in| Gate.ar(in, LFPulse.kr(0.5))};
Ndef(\11).set(\wet1, 1);

(
Ndef(\i3, { |amp = 0.28, freq = 90, dur = 1|
    var sig;
    sig = SinOsc.ar(LFPulse.ar(dur) * freq ! 2) * amp;
    LPF.ar(sig, 1000)
});
Ndef(\i3)[1] = \pset -> Pbind(\freq, Pseq([90, 120, 440, Rest(0.5)], inf), \dur, Prand([0.25, Rest(0.5)], inf), \amp, 0.3);
)
~lcxlBindPdef.(\b0_s7_p, \i3);
Ndef(\i3).stop;
Ndef(\i3)[2] = \filter -> {|in, rate=32, dur=0.5 | Gate.ar(in, LFPulse.kr(rate*dur))};
Ndef(\i3).set(\wet2, 1);
Ndef(\13)[1] = nil;

// --- Shared send mixer -----------------------------------------------------

(
Ndef(\sends1, { |a_to_fx = 0.5, b_to_fx = 0.5, c_to_fx = 0.5 |
    var a, b, c, sendMix;
    a = Ndef.ar(\i1, 2) * a_to_fx;
    b = Ndef.ar(\i2, 2) * b_to_fx;
    c = Ndef.ar(\i3, 2) * c_to_fx;
    sendMix = a + b + c;
    sendMix
});
)

(
Ndef(\sends2, { |a_to_fx = 0.5, b_to_fx = 0.5, c_to_fx = 0.5 |
    var a, b, c, sendMix;
    a = Ndef.ar(\i1, 2) * a_to_fx;
    b = Ndef.ar(\i2, 2) * b_to_fx;
    c = Ndef.ar(\i3, 2) * c_to_fx;
    sendMix = a + b + c;
    sendMix
});
)

// --- FX return -------------------------------------------------------------

(
Ndef(\fx1, { |mix = 0.7, room = 0.6, damp = 0.3, amp = 0.8|
    var src1, src2, srcMix, wet;
    src1 = Ndef.ar(\sends1, 2);
    src2 = Ndef.ar(\sends2, 2);
    srcMix = src1 + src2;
    // wet = CombC.ar(0.5, 0.5, 0.3, 1.0);
    wet = Disintegrator.ar(srcMix, 0.5).distort;
    // wet = FreeVerb2.ar(src[0], src[1], room, damp, 0.5);
    XFade2.ar(srcMix, wet, (mix * 2 - 1)) * amp
});
)
(
Ndef(\fx2, { |mix = 0.7, room = 0.6, damp = 0.3, amp = 0.8|
    var src1, src2, srcMix, wet;
    src1 = Ndef.ar(\sends1, 2);
    src2 = Ndef.ar(\sends2, 2);
    srcMix = src1 + src2;
    wet = FreeVerb.ar(srcMix, 1, room, damp, 0.5);
    XFade2.ar(srcMix, wet, (mix * 2 - 1)) * amp
});
)

// --- Master mix to hardware outs ------------------------------------------
// add more sends1 and FX above as needed. add additional 'wetN' args below etc.
(
Ndef(\master, { |dry = 1, wet1 = 1, wet2 = 1, wet3 = 1, amp = 0.9|
    var a, b, c, drySum, fx1, fx2, fx3, fxSum, outSig;
    a = Ndef.ar(\i1, 2);
    b = Ndef.ar(\i2, 2);
    c = Ndef.ar(\i3, 2);
    drySum = (a + b + c) * dry;
    fx1 = Ndef.ar(\fx1, 2) * wet1;
    fx2 = Ndef.ar(\fx2, 2) * wet2;
    fx3 = Ndef.ar(\fx3, 2) * wet3;
    fxSum = fx1 + fx2 + fx3;
    outSig = (drySum + fxSum) * amp;
    outSig
}).play(out: 0);
)

// --- Handy live controls ---------------------------------------------------
// Start with audible defaults
Ndef(\sends1).set(\a_to_fx, 0.3, \b_to_fx, 0.1);
Ndef(\fx).set(\mix, 0.7, \room, 0.6, \damp, 0.3, \amp, 0.8);
Ndef(\master).set(\dry, 1, \wet, 1, \amp, 0.9);

// Quick tweaks during performance ideas
Ndef(\a).set(\freq, 55);
Ndef(\sends1).set(\a_to_fx, 0.5, \b_to_fx, 0.5);
Ndef(\fx).set(\mix, 0.0);
Ndef(\master).set(\amp, 0.7);

Ndef(\fx1).set(\mix, 1.0);
Ndef(\master).set(\wet, 0.75, \dry, 0.25);
