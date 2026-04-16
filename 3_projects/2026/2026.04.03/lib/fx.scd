// fx.scd — inline FX library + project-level FX nodes.
//
// ~fxLib : named closures. Each takes a MixerChannel, returns a Synth.
//          The closure captures the channel's inbus before playfx — the
//          standard workaround for playfx not forwarding 'in' from the bus.
//
// ~ilfx  : live node store. Free before re-creating.
//
// Usage:
//   ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1);
//   ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1, [\bits, 6, \rate, 8000]);
//   ~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;
//
// Swap by freeing the old node and deploying another from ~fxLib.
// Keys are Larbitrary — name them after the voice+effect, e.g. \v1_glitch.
(
~ilfx !? { |d| d.do { |n| n.tryPerform(\free) } };
~ilfx = ();

// ---- Library entries ----

~fxLib = ();

// Bitcrusher — reduce bit depth and/or sample rate
// Params: \bits (1–16), \rate (100–44100), \mix (0–1)
~fxLib[\bitcrush] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var sig = In.ar(bus, 2);
        var wet = Decimator.ar(sig, \rate.kr(44100), \bits.kr(8));
        XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
    });
    if(args.notEmpty) { s.set(*args) };
    s
};

// Ring modulator
// Params: \freq (20–2000), \mix (0–1)
~fxLib[\ringmod] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var sig = In.ar(bus, 2);
        var wet = sig * SinOsc.ar(\freq.kr(440));
        XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
    });
    if(args.notEmpty) { s.set(*args) };
    s
};

// Wavefolder
// Params: \gain (1–20), \mix (0–1)
~fxLib[\fold] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var sig = In.ar(bus, 2);
        var wet = (sig * \gain.kr(4)).fold2(1);
        XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(0.5)
    });
    if(args.notEmpty) { s.set(*args) };
    s
};

// Glitch — LFO-modulated decimation into original signal
// Params: \rate (0.1–10), \mix (0–1)
~fxLib[\glitch] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var sig  = In.ar(bus, 2);
        var mod  = LFTri.ar([\rate.kr(1), \rate.kr(1) * 1.01], mul: SinOsc.ar([1, 2, 3]));
        var wet  = Decimator.ar(
            sig,
            LFTri.ar(\rate.kr(1) * 0.5).range(200, 6000),
            LFPulse.kr(\rate.kr(1) * 0.5, 0.5).range(6, 14)
        ) + sig;
        XFade2.ar(sig, wet, \mix.kr(0.7).linlin(0, 1, -1, 1)) * \amp.kr(0.8)
    });
    if(args.notEmpty) { s.set(*args) };
    s
};

// Pitch shimmer — two detuned, pitch-shifted delay lines
// Params: \shift (semitones offset, e.g. 12), \time (0.01–0.5), \mix (0–1)
~fxLib[\shimmer] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var sig  = In.ar(bus, 2);
        var wet  = PitchShift.ar(sig,
            windowSize: 0.2,
            pitchRatio:  \shift.kr(12).midiratio,
            pitchDispersion: 0.01,
            timeDispersion:  \time.kr(0.1)
        );
        XFade2.ar(sig, wet, \mix.kr(0.4).linlin(0, 1, -1, 1)) * \amp.kr(1)
    });
    if(args.notEmpty) { s.set(*args) };
    s
};

// Stutter — tape-stop/freeze-style repeating buffer
// Params: \rate (0.5–4 repeats/beat), \mix (0–1)
// Note: uses TGrains, approximate stutter not quantized
~fxLib[\stutter] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var bufL  = LocalBuf(SampleRate.ir * 2, 1);
        var bufR  = LocalBuf(SampleRate.ir * 2, 1);
        var sig   = In.ar(bus, 2);
        var trig  = Impulse.kr(\rate.kr(2));
        var wet   = [
            TGrains.ar(1, trig, bufL, 1, BufDur.kr(bufL) / 2, 0.25),
            TGrains.ar(1, trig, bufR, 1, BufDur.kr(bufR) / 2, 0.25)
        ];
        RecordBuf.ar(sig[0], bufL, loop: 1);
        RecordBuf.ar(sig[1], bufR, loop: 1);
        XFade2.ar(sig, wet, \mix.kr(0.5).linlin(0, 1, -1, 1)) * \amp.kr(1)
    });
    if(args.notEmpty) { s.set(*args) };
    s
};

~fxLib[\duck] = { |chan, sideChannel, args=#[], target=nil,
  addAction=\addToTail|
      var t = target ?? { chan.effectgroup };
      var s = Synth(\duck, [
          \in,   chan.inbus.index,
          \side, sideChannel.inbus.index,
          \out,  chan.inbus.index
      ] ++ args, t, addAction);
      s
  };

  ~fxLib[\pitchGate] = { |chan, args=#[]|
    var bus = chan.inbus;
    var s = chan.playfx({ |in|
        var sig, dry, wet, localBuf, recTrig, gate, pEnv, rate, phase;
        
        // Setup Parameters
        var speed = \speed.kr(2);        // Frequency of the stutter/rhythm
        var len   = \len.kr(0.5);          // Length of the sample window (0 to 1)
        var pStart = \pStart.kr(0);       // Pitch start (semitones)
        var pEnd   = \pEnd.kr(-12);       // Pitch end (semitones)
        var width  = \width.kr(0.5);       // Gate duty cycle
        
        sig = In.ar(bus, 2);
        dry = sig;
        
        // 1. Internal Buffer (e.g., 2 seconds max)
        localBuf = LocalBuf(SampleRate.ir * 2, 2);
        
        // 2. Triggering Logic
        // We trigger a "record" and a "pitch envelope" at the same speed
        recTrig = Impulse.ar(speed);
        RecordBuf.ar(sig, localBuf, trigger: recTrig, loop: 0);
        
        // 3. Rhythmic Gate
        // Use a slight lag to prevent pops
        gate = LFPulse.ar(speed, 0, width).lag(0.01);
        
        // 4. The Pitch Glide
        // This envelope restarts every time the gate triggers
        pEnv = EnvGen.ar(
            Env([pStart, pStart, pEnd], [0.001, 1/speed], \lin),
            gate
        );
        rate = pEnv.midiratio;
        
        // 5. Playback
        // Phasor drives the reading of the captured buffer
        phase = Phasor.ar(
            trig: recTrig, 
            rate: BufRateScale.ir(localBuf) * rate, 
            start: 0, 
            end: len * SampleRate.ir
        );
        
        wet = BufRd.ar(2, localBuf, phase, interpolation: 4);
        // wet = SinOsc.ar(100);
        
        XFade2.ar(dry, wet * gate, \mix.kr(0.5).linlin(0, 1, -1, 1)) * \amp.kr(1);
    });
    
    if(args.notEmpty) { s.set(*args) };
    s
};

// ---- Project-level inline FX nodes ----
// Deploy from ~fxLib here for FX you want active on load.
// Examples:
//   ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1);
//   ~ilfx[\v2_glitch] = ~fxLib[\glitch].(~t2);
)
