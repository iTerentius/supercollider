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
~fxg[\bitcrush] = { |in, rate=44100, bits=8, mix=1, mute=0, amp=1|
    var sig = in;
    var wet = Decimator.ar(sig, rate, bits);
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

// =============================================================================
// USAGE
// =============================================================================
// ddwMixerChannel insert (matches existing ~fxLib convention):
//   ~t1.playfx({ |in| ~fxg[\bitcrush].(in, 8000, 6, 0.8) });
//   // or with named args via a wrapping function if you want .set() access —
//   // same pattern as ~fxLib's own `s = chan.playfx({...}); if(args.notEmpty){s.set(*args)}`
//
// NodeProxy filter:
//   Ndef(\x)[1] = \filter -> ~fxg[\bitcrush];
//   Ndef(\x).set(\rate, 8000, \bits, 6, \mix, 0.8);
//
// Sidechain duck (two-input shape — needs its own synth, not a filter slot):
//   SynthDef(\duckIns, { |in=0, side=0, out=0 ...|
//       ReplaceOut.ar(out, ~fxg[\duck].(In.ar(in,2), In.ar(side,2), ...));
//   }).add;
)
