// FX — function defs + static FX nodes
(
~glitch = { |in|
    var sig = LFTri.ar([220, 222], mul: SinOsc.ar([1, 2, 3]));
    sig = sig * In.ar(~r4.inbus.index, 2);
    sig = Decimator.ar(sig, LFTri.ar(0.5).range(30, 1900), LFPulse.kr(0.5, 0.5).range(8, 16)) + sig;
    sig;
};

~freeze = {|in|
    var sig, chains, wet, mix, freeze, chunk, amp;
    sig = In.ar(~r5.inbus, 2);
    mix = \mix.kr(1);
    amp = \amp.kr(0.4);
    chunk = \chunk.kr(2048);
    freeze = \freeze.kr(0);
    chains = sig.collect({ |chan| FFT(LocalBuf(chunk), chan) });
    chains = chains.collect({ |chain| PV_Freeze(chain, freeze) });
    wet = IFFT(chains);
    XFade2.ar(sig, wet, mix * 2 - 1);
};

~exp1 = { |in|
    var mod1 = \mod1.kr(1);
    var amp  = \amp.kr(0.5);
    var dur  = \dur.kr(1);
    var sig  = In.ar(~t2.inbus.index, 2);
    var r    = mod1 / dur;
    var wet  = SinOsc.ar(sig / r * LFSaw.ar(r), LFTri.ar(mod1, width: r));
    sig * wet * amp * 3;
};

~r5_ilfx_1.free;
~r5_ilfx_1 = ~r5.playfx(~freeze);

// ~m1_ilfx_1.free;
// ~m1_ilfx_1 = ~m1.playfx({|in|
//     var sig, chains, wet, mix, freeze, chunk, amp;
//     sig = In.ar(~m1.inbus, 2);
//     mix = \mix.kr(1);
//     amp = \amp.kr(0.4);
//     chunk = \chunk.kr(2048);
//     freeze = \freeze.kr(0);
//     chains = sig.collect({ |chan| FFT(LocalBuf(chunk), chan) });
//     chains = chains.collect({ |chain| PV_Freeze(chain, freeze) });
//     wet = IFFT(chains);
//     XFade2.ar(sig, wet, mix * 2 - 1);
// });


// ~r3_fx is created and aliased by ~fxSetup[\r3_biscuit] in fx_defs.scd (via config.scd).
// Do NOT create a second \biscuit synth here — that was the old pre-fxSetup approach.
)
