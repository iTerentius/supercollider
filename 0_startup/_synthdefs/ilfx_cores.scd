// =============================================================================
// ILFX CORES — reusable inline-FX DSP, extracted from project fx.scd ~fxLib
// =============================================================================
// NOT loaded by default. Load manually:
//   "_synthdefs/ilfx_cores.scd".loadRelative;
//
// Purely additive: this does NOT touch any project's fx.scd or ~fxLib. Those
// keep working exactly as they already do. This is a separate, standalone
// reference of the same DSP with the chan/bus/.playfx/args-set boilerplate
// stripped out, so it's usable in more than one context going forward.
//
// Each entry in ~fxg (except \duck, see below) has the shape:
//   { |in, ...namedControls| ... ; finalSignal }
// `in` is the ALREADY-READ 2-channel input — do not re-read it via In.ar.
// The function returns the fully processed (dry/wet-blended, amp-scaled)
// signal; it does not do its own In.ar/Out.ar/ReplaceOut.ar. That makes it
// usable as-is in two different contexts:
//
//   1. ddwMixerChannel .playfx (matches the existing ~fxLib convention):
//        ~t1.playfx({ |in| ~fxg[\bitcrush].(in) });
//
//   2. NodeProxy \filter -> role (see ref_ndef_mixer.scd):
//        Ndef(\x)[1] = \filter -> ~fxg[\bitcrush];
//
// Caveat carried over from the ~ginCore/pmManual discussion: verified against
// NodeProxy source that \filter -> requires exactly this in-then-return
// shape. ddwMixerChannel's .playfx is a Quark, not verified against source
// this session — the existing project fx.scd examples always re-read via a
// captured `bus` var instead of using the passed `in`, so if `in` turns out
// not to carry the right content there, fall back to:
//   ~t1.playfx({ |in| ~fxg[\bitcrush].(In.ar(~t1.inbus.index, 2)) });
(
~fxg = ();

// Bitcrusher — reduce bit depth and/or sample rate
// Params: \rate (100-44100), \bits (1-16), \mix (0-1), \mute (0/1), \amp
~fxg[\bitcrush] = { |in, brate=44100, bits=8, mix=1, mute=0, amp=1|
    var sig = in;
    var wet = Decimator.ar(sig, brate, bits);
    var effectiveMix = mix * (1 - mute);
    XFade2.ar(sig, wet, effectiveMix.linlin(0, 1, -1, 1)) * amp;
};

// Ring modulator
// Params: \freq (20-2000), \mix (0-1), \amp
~fxg[\ringmod] = { |in, freq=440, mix=1, amp=1|
    var sig = in;
    var wet = sig * SinOsc.ar(freq);
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
};

// Wavefolder
// Params: \gain (1-20), \mix (0-1), \amp
~fxg[\fold] = { |in, gain=4, mix=1, amp=0.5|
    var sig = in;
    var wet = (sig * gain).fold2(1);
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
};

// Glitch — LFO-modulated decimation into original signal
// Params: \rate (0.1-10), \mix (0-1), \amp
// Note: carried over verbatim from the original — `mod` is computed but not
// actually used in `wet` there either. Left as-is since it's proven/liked;
// flagging in case it's worth revisiting later.
~fxg[\glitch] = { |in, rate=1, mix=0.7, amp=0.8|
    var sig = in;
    var mod = LFTri.ar([rate, rate * 1.01], mul: SinOsc.ar([1, 2, 3]));
    var wet = Decimator.ar(
        sig,
        LFTri.ar(rate * 0.5).range(200, 6000),
        LFPulse.kr(rate * 0.5, 0.5).range(6, 14)
    ) + sig;
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
};

// Pitch shimmer — pitch-shifted delay
// Params: \shift (semitones, e.g. 12), \time (0.01-0.5), \mix (0-1), \amp
~fxg[\shimmer] = { |in, shift=12, time=0.1, mix=0.4, amp=1|
    var sig = in;
    var wet = PitchShift.ar(sig,
        windowSize: 0.2,
        pitchRatio: shift.midiratio,
        pitchDispersion: 0.01,
        timeDispersion: time
    );
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
};

// Stutter — rolling-buffer grain repeat
// Params: \rate (0.5-4 repeats/beat), \mix (0-1), \amp
~fxg[\stutter] = { |in, rate=2, mix=0.5, amp=1|
    var bufL = LocalBuf(SampleRate.ir * 2, 1);
    var bufR = LocalBuf(SampleRate.ir * 2, 1);
    var sig = in;
    var trig = Impulse.kr(rate);
    var wet = [
        TGrains.ar(1, trig, bufL, 1, BufDur.kr(bufL) / 2, 0.25),
        TGrains.ar(1, trig, bufR, 1, BufDur.kr(bufR) / 2, 0.25)
    ];
    RecordBuf.ar(sig[0], bufL, loop: 1);
    RecordBuf.ar(sig[1], bufR, loop: 1);
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
};

// Stereo chorus: LFO-modulated short delay, offset 90deg per channel for width
~fxg[\chorus] = { |in, rate=0.4,  depth=0.004 |
    var sig  = in;
    var lfo  = SinOsc.kr(\rate.kr(0.4), [0, 0.5pi]) * \depth.kr(0.004) + 0.005;
    var wet  = DelayC.ar(sig, 0.05, lfo);
    XFade2.ar(sig, wet, \mix.kr(0.5).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// Spectral freeze/smear (FFT) — pulled from fx_defs.scd's ~fxDefs[\spectral],
// which took { |in, bus| ... In.ar(bus,2) ... } — adapted to use `in` directly.
// Params: \chunk (FFT size), \freeze (0/1), \smear (0-1), \freezeSmear (0-1
//   crossfade between freeze/smear results), \mix (0-1), \amp
~fxg[\spectral] = { |in, chunk=2048, freeze=0, smear=0, freezeSmear=0, mix=1, amp=0.4|
    var sig = in;
    var chains, wetFreeze, wetSmear, wet;
    chains = sig.collect({ |chan| FFT(LocalBuf(chunk), chan) });
    wetFreeze = IFFT(chains.collect({ |chain| PV_Freeze(chain, freeze) }));
    wetSmear  = IFFT(chains.collect({ |chain| PV_MagSmear(chain, smear) }));
    wet = XFade2.ar(wetFreeze, wetSmear, freezeSmear * 2 - 1);
    XFade2.ar(sig, wet, mix * 2 - 1) * amp;
};

// Rhythmic pitch-gate — record/playback loop with a pitch-glide envelope,
// gated on/off, blended with a bit-crushed layer.
// Params: \speed (stutter/rhythm freq), \len (0-1 window length),
//   \pStart/\pEnd (semitones), \width (gate duty cycle), \rate/\bits (crush
//   layer), \crush (crush layer blend), \mix (0-1), \amp
~fxg[\pitchGate] = { |in, speed=2, len=0.5, pStart=0, pEnd=(-12), width=0.5,
                            rate=44100, bits=8, crush=0.5, mix=0.5, amp=1|
    var sig, dry, wet, localBuf, recTrig, gate, pEnv, pitchRate, phase;
    sig = in;
    dry = sig;

    localBuf = LocalBuf(SampleRate.ir * 2, 2);
    recTrig = Impulse.ar(speed);
    RecordBuf.ar(sig, localBuf, trigger: recTrig, loop: 0);

    gate = LFPulse.ar(speed, 0, width).lag(0.01);
    pEnv = EnvGen.ar(Env([pStart, pStart, pEnd], [0.001, 1/speed], \lin), gate);
    pitchRate = pEnv.midiratio;

    phase = Phasor.ar(
        trig: recTrig,
        rate: BufRateScale.ir(localBuf) * pitchRate,
        start: 0,
        end: len * SampleRate.ir
    );

    wet = BufRd.ar(2, localBuf, phase, interpolation: 4);
    wet = wet + (Decimator.ar(sig, rate, bits)) * crush;

    XFade2.ar(dry, wet * gate, mix.linlin(0, 1, -1, 1)) * amp;
};

// Sidechain duck — DIFFERENT SHAPE than the rest: takes two already-read
// signals (channel + sidechain), no mix crossfade, returns the ducked
// channel signal directly.
// Params: \thresh, \ratio, \attack, \release, \makeup
~fxg[\duck] = { |sig, sideSig, thresh=0.1, ratio=10, attack=0.01, release=0.1, makeup=1|
    var sideMono = Mix(sideSig);
    var env = LagUD.kr(Amplitude.kr(sideMono, 0.01, 0.1), attack, release);
    var cond = env > thresh;
    var gain = Select.kr(cond, [1, (env / thresh).reciprocal.pow(ratio)]);
    sig * gain * makeup;
};

~fxg[\biscuit] = { |
    in,
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

    var sig, dry,
        driven,
        clockImp, clockedL, clockedR,
        stepsN, crushedL, crushedR,
        sMono, scaled,
        b0v, b1v, b2v, b3v, b4v, b5v, b6v, b7v,
        p0, p1, p2, p3, p4, p5, p6, p7,
        reconstructed, bitOut,
        ws0, ws1, ws2, ws3, ws4, ws5, ws6, ws7, wsOut,
        monoFb, dline, delOut,
        pitchRatio, pitchOut,
        stepTrig, stepIdx, stepFreq, sfOut,
        fxOut,
        fLP, fBP, fHP, filtered,
        wet;

    sig = in;
    dry = sig;

    // --- DRIVE ---
    driven = (sig * drive).softclip;

    // --- BITCRUSHER (sample rate + bit depth) ---
    clockImp = Impulse.ar(clock.clip(250, 30000));
    clockedL = Latch.ar(driven[0], clockImp);
    clockedR = Latch.ar(driven[1], clockImp);
    stepsN   = 2 ** (bits.clip(1, 8) - 1);      // 1 (1-bit) to 128 (8-bit)
    crushedL = (clockedL * stepsN).round / stepsN;
    crushedR = (clockedR * stepsN).round / stepsN;

    // --- BIT MANIPULATION ---
    // Sum stereo to mono, scale to 0–255 integer range
    sMono  = (crushedL + crushedR) * 0.5;
    scaled = ((sMono + 1) * 127.5).round.clip(0, 255);

    // Extract bits 0–7 (arg b1=bit0/LSB ... arg b8=bit7/MSB)
    b0v = scaled.div(1)   % 2;
    b1v = scaled.div(2)   % 2;
    b2v = scaled.div(4)   % 2;
    b3v = scaled.div(8)   % 2;
    b4v = scaled.div(16)  % 2;
    b5v = scaled.div(32)  % 2;
    b6v = scaled.div(64)  % 2;
    b7v = scaled.div(128) % 2;

    // Apply state per bit — CRITICAL: parenthesize each product in sum
    p0 = (b0v * (b1 > 0)) + ((1 - b0v) * (b1 < 0));
    p1 = (b1v * (b2 > 0)) + ((1 - b1v) * (b2 < 0));
    p2 = (b2v * (b3 > 0)) + ((1 - b2v) * (b3 < 0));
    p3 = (b3v * (b4 > 0)) + ((1 - b3v) * (b4 < 0));
    p4 = (b4v * (b5 > 0)) + ((1 - b4v) * (b5 < 0));
    p5 = (b5v * (b6 > 0)) + ((1 - b5v) * (b6 < 0));
    p6 = (b6v * (b7 > 0)) + ((1 - b6v) * (b7 < 0));
    p7 = (b7v * (b8 > 0)) + ((1 - b7v) * (b8 < 0));

    // Reconstruct — MUST parenthesize each weighted term
    reconstructed = (p0 * 1) + (p1 * 2) + (p2 * 4) + (p3 * 8)
                  + (p4 * 16) + (p5 * 32) + (p6 * 64) + (p7 * 128);
    bitOut = (reconstructed / 127.5) - 1;

    // --- FX MODES (all operate on mono bitOut) ---

    // Mode 0: Waveshaper — 8 types, SelectX for smooth morphing
    ws0 = bitOut.fold2(1);                                               // fold distortion
    ws1 = bitOut.abs;                                                    // bat fuzz (full-wave rectify)
    ws2 = bitOut.max(0);                                                 // rectify (half-wave)
    ws3 = bitOut.neg;                                                    // bitswap (polarity reverse)
    ws4 = bitOut.fold2(0.5) * 2;                                         // alt rect (tighter fold)
    ws5 = PitchShift.ar(bitOut, 0.2, 2.pow(-7/12), 0.0, 0.01).softclip; // biscuit (−5th + crunch)
    ws6 = LFSaw.ar(ZeroCrossing.ar(bitOut));                             // synth saw (pitch-tracked)
    ws7 = LFPulse.ar(ZeroCrossing.ar(bitOut));                           // synth sq  (pitch-tracked)
    wsOut = SelectX.ar(shape.clip(0, 7), [ws0, ws1, ws2, ws3, ws4, ws5, ws6, ws7]);

    // Mode 1: 8-bit delay with feedback
    monoFb = LocalIn.ar(1);
    dline  = DelayL.ar(bitOut + (monoFb * delFB), 2.0, delTime.clip(0.001, 2.0));
    LocalOut.ar(dline);
    delOut = dline;

    // Mode 2: Pitch shifter — 8 hardware-mapped intervals
    // [-24, -19, -12, -7, -5, 0, +7, +12] semitones
    pitchRatio = Select.kr(pitchShift.clip(0, 7), [
        2.pow(-24/12), 2.pow(-19/12), 2.pow(-12/12), 2.pow(-7/12),
        2.pow(-5/12),  1.0,           2.pow(7/12),   2.0
    ]);
    pitchOut = PitchShift.ar(bitOut, 0.2, pitchRatio, 0.0, 0.01);

    // Mode 3: 4-step sequenced LP filter
    stepTrig = Impulse.kr(stepRate.clip(0.1, 40));
    stepIdx  = Stepper.kr(stepTrig, 0, 0, 3);
    stepFreq = Select.kr(stepIdx, [sf0, sf1, sf2, sf3]);
    sfOut    = RLPF.ar(bitOut, stepFreq.clip(20, 20000), filterQ.linexp(0, 1, 1.0, 0.1));

    // Select active FX mode (hard switch)
    fxOut = Select.ar(fxMode.clip(0, 3), [wsOut, delOut, pitchOut, sfOut]);

    // Widen to stereo (haas-style subtle offset)
    fxOut = [fxOut, DelayN.ar(fxOut, 0.02, 0.007)];

    // --- ANALOG OUTPUT FILTER (2-pole, 12dB/oct) ---
    fLP = RLPF.ar(fxOut, filterFreq.clip(20, 20000), filterQ.linexp(0, 1, 1.0, 0.1));
    fBP = Resonz.ar(fxOut, filterFreq.clip(20, 20000), filterQ.linexp(0, 1, 1.0, 0.1));
    fHP = RHPF.ar(fxOut, filterFreq.clip(20, 20000), filterQ.linexp(0, 1, 1.0, 0.1));
    filtered = SelectX.ar(filterType.clip(0, 2), [fLP, fBP, fHP]);

    // --- WET/DRY MIX ---
    wet = (dry * naked) + (filtered * dressed);

    // Limiter guards against runaway levels from ws6/ws7 (LFSaw/LFPulse) and bit inversion spikes
    wet = Limiter.ar(wet, 0.95, 0.01);

    wet
}

// =============================================================================
// USAGE
// =============================================================================
// IMPORTANT: each ~fxg entry's params (rate, bits, mix, ...) are PLAIN
// FUNCTION ARGUMENTS, not \name.kr(...) NamedControls. Calling
// ~fxg[\bitcrush].(in) with only `in` supplied bakes every other arg in as a
// fixed numeric CONSTANT at build time — .set() on that control will do
// NOTHING, no error, just silently no-op. To get a live-settable control,
// the OUTER function (the one actually assigned to the Ndef index / passed
// to .playfx) must declare ITS OWN matching-named args and pass them
// through explicitly — SynthDef.wrap only turns the outermost function's
// own top-level args into real controls; a nested call's args don't bubble
// up on their own. This bit a real debugging session — don't skip it.
//
// ddwMixerChannel insert (matches existing ~fxLib convention):
//   ~t1.playfx({ |in, rate=8000, bits=6, mix=0.8, mute=0, amp=1|
//       ~fxg[\bitcrush].(in, rate, bits, mix, mute, amp)
//   });
//   // now .set(\rate, ..., \bits, ...) on the returned synth actually works —
//   // same idea as ~fxLib's own `s = chan.playfx({...}); if(args.notEmpty){s.set(*args)}`
//
// NodeProxy source (fully wet return, e.g. reading a send-sum):
//   Ndef(\fxsBitcrush)[0] = { |rate=8000, bits=6, mix=0.8, mute=0, amp=1|
//       var sig = Ndef.ar(\s1_sum, 2);
//       ~fxg[\bitcrush].(sig, rate, bits, mix, mute, amp)
//   };
//   Ndef(\fxsBitcrush).set(\rate, 8000, \bits, 6, \mix, 0.8);
//
// NodeProxy \filter -> role (verified this one DOES pass its own args through
// automatically, since \filter's build code wraps the function directly —
// still list matching arg names on it for clarity, same shape either way):
//   Ndef(\x)[1] = \filter -> { |in, rate=8000, bits=6, mix=0.8, mute=0, amp=1|
//       ~fxg[\bitcrush].(in, rate, bits, mix, mute, amp)
//   };
//   Ndef(\x).set(\rate, 8000, \bits, 6, \mix, 0.8);
//   // Caveat carried over from the ndef-mixer debugging session: \filter role
//   // controls have been empirically flaky with .set() in practice even when
//   // correctly declared — if this doesn't respond either, move the control
//   // to a plain [0] source instead (see ref_ndef_mixer.scd GOTCHAS).
//
// Sidechain duck (two-input shape — needs its own synth, not a filter slot):
//   SynthDef(\duckIns, { |in=0, side=0, out=0, thresh=0.1, ratio=10, attack=0.01, release=0.1, makeup=1|
//       ReplaceOut.ar(out, ~fxg[\duck].(In.ar(in,2), In.ar(side,2), thresh, ratio, attack, release, makeup));
//   }).add;
)
