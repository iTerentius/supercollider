

// --- Sources ---------------------------------------------------------------

(
Ndef(\i1, { |freq = 110, amp = 0.15|
    var sig;
    sig = SinOsc.ar(Pulse.kr(32) * freq) ! 2 * amp;
    sig
}).play(vol: 0);
)

(
Ndef(\i2, { |amp = 0.28|
    var sig;
    sig = Saw.ar(LFPulse.ar(1) * 112 ! 2) * amp;
    LPF.ar(sig, 1000)
}).play(vol: 0);
)

// --- Shared send mixer -----------------------------------------------------

(
Ndef(\sends, { |a_to_fx = 0.3, b_to_fx = 0.1|
    var a, b, sendMix;
    a = Ndef.ar(\a, 2) * a_to_fx;
    b = Ndef.ar(\b, 2) * b_to_fx;
    sendMix = a + b;
    sendMix
});
)

// --- FX return -------------------------------------------------------------

(
Ndef(\fx1, { |mix = 0.7, room = 0.6, damp = 0.3, amp = 0.8|
    var src, wet;
    src = Ndef.ar(\sends, 2);
    wet = FreeVerb2.ar(src[0], src[1], room, damp, 0.5);
    XFade2.ar(src, wet, (mix * 2 - 1)) * amp
});
)

// --- Master mix to hardware outs ------------------------------------------
// add more sends and FX above as needed. add additional 'wetN' args below etc.
(
Ndef(\master, { |dry = 1, wet1 = 1, amp = 0.9|
    var a, b, drySum, wetSum, outSig;
    a = Ndef.ar(\a, 2);
    b = Ndef.ar(\b, 2);
    drySum = (a + b) * dry;
    fx1 = Ndef.ar(\fx, 2) * wet1;
    outSig = (drySum + fx1) * amp;
    outSig
}).play(out: 0);
)

// --- Handy live controls ---------------------------------------------------
// Start with audible defaults
Ndef(\sends).set(\a_to_fx, 0.3, \b_to_fx, 0.1);
Ndef(\fx).set(\mix, 0.7, \room, 0.6, \damp, 0.3, \amp, 0.8);
Ndef(\master).set(\dry, 1, \wet, 1, \amp, 0.9);

// Quick tweaks during performance ideas
Ndef(\a).set(\freq, 55);
Ndef(\sends).set(\a_to_fx, 0.5, \b_to_fx, 0.5);
Ndef(\fx).set(\mix, 0.0);
Ndef(\master).set(\amp, 0.7);

Ndef(\fx).set(\mix, 1.0);
Ndef(\master).set(\wet, 0.75, \dry, 0.25);
