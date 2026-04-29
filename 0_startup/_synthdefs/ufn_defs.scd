// ufn_defs.scd — portable UGen functions stored in ~ufn
// Load before analog_synthdefs.scd (which wraps these in SynthDef).
// FX functions (~fxDefs) are aliased into ~ufn at the end of fx_defs.scd.
//
// Usage:
//   Ndef(\x, ~ufn[\moogLead]);              // prototype in Ndef
//   Ndef(\x).set(\freq, 880, \cutoff, 1200); // live param control
//   SynthDef(\moogLead, ~ufn[\moogLead]).add // wraps with Out.ar already in analog_synthdefs.scd
//
// doneAction: \doneAction.ir(0)
//   — Pbind's default event type overrides to 2 (self-free after envelope)
//   — Ndef leaves at 0 (node stays alive, controlled by Ndef lifecycle)

(
~ufn = ();

// =============================================================================
// MOOG LEAD  (3 saw VCOs, ladder filter, filter + amp ADSR)
// =============================================================================
~ufn[\moogLead] = {
    var freq          = \freq.kr(440),        gate     = \gate.kr(1);
    var amp           = \amp.kr(0.5),          pan      = \pan.kr(0);
    var osc1Level     = \osc1Level.kr(0.7),   osc2Level = \osc2Level.kr(0.5);
    var osc3Level     = \osc3Level.kr(0.3);
    var osc2Detune    = \osc2Detune.kr(0),    osc3Detune = \osc3Detune.kr(0);
    var cutoff        = \cutoff.kr(2000),      resonance  = \resonance.kr(0.3);
    var filterEnvAmt  = \filterEnvAmt.kr(3000);
    var filterAttack  = \filterAttack.kr(0.01), filterDecay   = \filterDecay.kr(0.3);
    var filterSustain = \filterSustain.kr(0.5), filterRelease = \filterRelease.kr(0.5);
    var ampAttack     = \ampAttack.kr(0.01),    ampDecay      = \ampDecay.kr(0.3);
    var ampSustain    = \ampSustain.kr(0.7),    ampRelease    = \ampRelease.kr(0.5);
    var lfoRate       = \lfoRate.kr(5),   lfoToPitch = \lfoToPitch.kr(0);
    var lfoToFilter   = \lfoToFilter.kr(0);
    var osc1, osc2, osc3, mix, lfo, filterEnv, ampEnv, sig;

    lfo       = SinOsc.kr(lfoRate);
    osc1      = Saw.ar(freq * (1 + (lfo * lfoToPitch)));
    osc2      = Saw.ar(freq * (2 ** (osc2Detune / 12)) * (1 + (lfo * lfoToPitch)));
    osc3      = Saw.ar(freq * (2 ** (osc3Detune / 12)) * (1 + (lfo * lfoToPitch)));
    mix       = (osc1 * osc1Level) + (osc2 * osc2Level) + (osc3 * osc3Level);
    filterEnv = EnvGen.kr(Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease), gate);
    sig       = MoogFF.ar(mix,
        (cutoff + (filterEnv * filterEnvAmt) + (lfo * lfoToFilter)).clip(20, 20000),
        resonance * 4);
    ampEnv    = EnvGen.kr(Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease), gate,
        doneAction: \doneAction.ir(0));
    Pan2.ar(sig * ampEnv * amp, pan)
};

// =============================================================================
// JUNO CHORD  (pulse + PWM + sub osc, LP filter, built-in chorus)
// =============================================================================
~ufn[\junoChord] = {
    var freq          = \freq.kr(440),      gate    = \gate.kr(1);
    var amp           = \amp.kr(0.3),        pan     = \pan.kr(0);
    var pulseWidth    = \pulseWidth.kr(0.5), pwmRate = \pwmRate.kr(0.2);
    var pwmDepth      = \pwmDepth.kr(0.4),   subLevel = \subLevel.kr(0.3);
    var cutoff        = \cutoff.kr(3000),    resonance = \resonance.kr(0.2);
    var filterEnvAmt  = \filterEnvAmt.kr(2000);
    var filterAttack  = \filterAttack.kr(0.01), filterDecay   = \filterDecay.kr(0.5);
    var filterSustain = \filterSustain.kr(0.3), filterRelease = \filterRelease.kr(0.8);
    var ampAttack     = \ampAttack.kr(0.01),    ampDecay      = \ampDecay.kr(0.5);
    var ampSustain    = \ampSustain.kr(0.6),    ampRelease    = \ampRelease.kr(0.8);
    var chorusDepth   = \chorusDepth.kr(0.4);
    var pulse, sub, mix, pwmLfo, filterEnv, ampEnv, sig;

    pwmLfo    = SinOsc.kr(pwmRate, 0, pwmDepth, pulseWidth);
    pulse     = Pulse.ar(freq, pwmLfo);
    sub       = Pulse.ar(freq * 0.5, 0.5, subLevel);
    mix       = pulse + sub;
    filterEnv = EnvGen.kr(Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease), gate);
    sig       = RLPF.ar(mix,
        (cutoff + (filterEnv * filterEnvAmt)).clip(20, 20000),
        1 - (resonance * 0.9));
    ampEnv    = EnvGen.kr(Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease), gate,
        doneAction: \doneAction.ir(0));
    sig       = sig * ampEnv * amp;
    sig       = sig + DelayC.ar(sig, 0.02, SinOsc.kr(0.7, 0, chorusDepth * 0.01, 0.01));
    Pan2.ar(sig, pan)
};

// =============================================================================
// PROPHET LEAD  (dual osc + waveshape crossfade, sync, Curtis-style LP filter)
// =============================================================================
~ufn[\prophetLead] = {
    var freq          = \freq.kr(440),       gate         = \gate.kr(1);
    var amp           = \amp.kr(0.4),         pan          = \pan.kr(0);
    var osc1Shape     = \osc1Shape.kr(0),    osc2Shape    = \osc2Shape.kr(0);
    var osc2Detune    = \osc2Detune.kr(0.02), osc2Semitones = \osc2Semitones.kr(0);
    var oscMix        = \oscMix.kr(0.5),      sync         = \sync.kr(0);
    var cutoff        = \cutoff.kr(4000),     resonance    = \resonance.kr(0.4);
    var filterEnvAmt  = \filterEnvAmt.kr(3500);
    var filterAttack  = \filterAttack.kr(0.05), filterDecay   = \filterDecay.kr(0.4);
    var filterSustain = \filterSustain.kr(0.3), filterRelease = \filterRelease.kr(1.0);
    var ampAttack     = \ampAttack.kr(0.05),    ampDecay      = \ampDecay.kr(0.4);
    var ampSustain    = \ampSustain.kr(0.7),    ampRelease    = \ampRelease.kr(1.0);
    var lfoRate       = \lfoRate.kr(4),     lfoShape    = \lfoShape.kr(0);
    var lfoToOsc1     = \lfoToOsc1.kr(0),   lfoToOsc2   = \lfoToOsc2.kr(0);
    var lfoToFilter   = \lfoToFilter.kr(0), lfoToPWM    = \lfoToPWM.kr(0);
    var osc1, osc2, osc1Freq, osc2Freq, lfo, filterEnv, ampEnv, sig;

    lfo      = SelectX.kr(lfoShape, [LFTri.kr(lfoRate), LFPulse.kr(lfoRate, 0, 0.5, 2, -1)]);
    osc1Freq = freq * (1 + (lfo * lfoToOsc1));
    osc2Freq = (freq + osc2Detune) * (2 ** (osc2Semitones / 12)) * (1 + (lfo * lfoToOsc2));
    osc1     = SelectX.ar(osc1Shape, [Saw.ar(osc1Freq), LFTri.ar(osc1Freq),
        Pulse.ar(osc1Freq, (0.5 + (lfo * lfoToPWM)).clip(0.05, 0.95))]);
    osc2     = SelectX.ar(osc2Shape, [Saw.ar(osc2Freq), LFTri.ar(osc2Freq),
        Pulse.ar(osc2Freq, (0.5 + (lfo * lfoToPWM)).clip(0.05, 0.95))]);
    osc2     = SelectX.ar(sync, [osc2, SyncSaw.ar(osc1Freq, osc2Freq)]);
    sig      = XFade2.ar(osc1, osc2, (oscMix * 2) - 1);
    filterEnv = EnvGen.kr(Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease), gate);
    sig      = MoogFF.ar(sig,
        (cutoff + (filterEnv * filterEnvAmt) + (lfo * lfoToFilter)).clip(20, 20000),
        resonance * 3.5);
    ampEnv   = EnvGen.kr(Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease), gate,
        doneAction: \doneAction.ir(0));
    Pan2.ar(sig * ampEnv * amp * 0.5, pan)
};

// =============================================================================
// ACID BASS  (303-style: saw/sq osc, decay-only filter env, accent, slide)
// =============================================================================
~ufn[\acidBass] = {
    var freq      = \freq.kr(440),   gate      = \gate.kr(1);
    var amp       = \amp.kr(0.6),     pan       = \pan.kr(0);
    var waveform  = \waveform.kr(0);
    var cutoff    = \cutoff.kr(800),  resonance = \resonance.kr(0.6);
    var envMod    = \envMod.kr(0.7),  decay     = \decay.kr(0.2);
    var accent    = \accent.kr(0),    slideTime = \slideTime.kr(0.1);
    var slide     = \slide.kr(0);
    var slideFreq, osc, filterEnv, actualResonance, sig, ampEnv;

    slideFreq       = Lag.kr(freq, slide * slideTime);
    osc             = Select.ar(waveform, [Saw.ar(slideFreq), Pulse.ar(slideFreq, 0.5)]);
    filterEnv       = EnvGen.kr(Env.perc(0.001, decay, 1, -4), gate);
    filterEnv       = filterEnv * (1 + (accent * 2));
    actualResonance = (resonance + (filterEnv * 0.3)).clip(0, 0.95);
    sig             = MoogFF.ar(osc,
        (cutoff + (filterEnv * envMod * 8000)).clip(20, 20000),
        actualResonance * 4);
    ampEnv          = EnvGen.kr(Env.adsr(0.001, 0.1, 1.0, 0.05), gate,
        doneAction: \doneAction.ir(0));
    Pan2.ar(sig * ampEnv * amp * (1 + (accent * 0.5)), pan)
};

// =============================================================================
// MS-20 BASS  (dual osc + ring mod, HPF → LPF dual filter, patch matrix)
// =============================================================================
~ufn[\ms20Bass] = {
    var freq          = \freq.kr(440),    gate       = \gate.kr(1);
    var amp           = \amp.kr(0.5),      pan        = \pan.kr(0);
    var osc1Level     = \osc1Level.kr(0.7), osc2Level = \osc2Level.kr(0.5);
    var osc2Detune    = \osc2Detune.kr(7),  ringMod   = \ringMod.kr(0);
    var hpfCutoff     = \hpfCutoff.kr(100), hpfRes    = \hpfRes.kr(0.2);
    var lpfCutoff     = \lpfCutoff.kr(2000), lpfRes   = \lpfRes.kr(0.6);
    var filterEnvAmt  = \filterEnvAmt.kr(3000);
    var filterAttack  = \filterAttack.kr(0.01),  filterDecay   = \filterDecay.kr(0.5);
    var filterSustain = \filterSustain.kr(0.2),  filterRelease = \filterRelease.kr(0.5);
    var ampAttack     = \ampAttack.kr(0.01),     ampDecay      = \ampDecay.kr(0.3);
    var ampSustain    = \ampSustain.kr(0.6),     ampRelease    = \ampRelease.kr(0.3);
    var eg2ToHPF      = \eg2ToHPF.kr(0),         eg2ToLPF      = \eg2ToLPF.kr(1);
    var osc1, osc2, ring, mix, filterEnv, ampEnv, sig;

    osc1      = Saw.ar(freq);
    osc2      = Pulse.ar(freq * (2 ** (osc2Detune / 12)), 0.3);
    ring      = osc1 * osc2;
    mix       = (osc1 * osc1Level) + (osc2 * osc2Level) + (ring * ringMod);
    filterEnv = EnvGen.kr(Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease), gate);
    sig       = RHPF.ar(mix,
        (hpfCutoff + (filterEnv * filterEnvAmt * eg2ToHPF)).clip(20, 20000),
        1 - (hpfRes * 0.9));
    sig       = MoogFF.ar(sig,
        (lpfCutoff + (filterEnv * filterEnvAmt * eg2ToLPF)).clip(20, 20000),
        lpfRes * 4);
    ampEnv    = EnvGen.kr(Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease), gate,
        doneAction: \doneAction.ir(0));
    Pan2.ar(sig * ampEnv * amp, pan)
};

// =============================================================================
// SH-101 LEAD  (pulse + sub osc, LFO with delay, Roland-style LP filter)
// =============================================================================
~ufn[\sh101Lead] = {
    var freq       = \freq.kr(440),   gate         = \gate.kr(1);
    var amp        = \amp.kr(0.5),     pan          = \pan.kr(0);
    var pwm        = \pwm.kr(0.5),     subOscLevel  = \subOscLevel.kr(0.4);
    var cutoff     = \cutoff.kr(2500), resonance    = \resonance.kr(0.5);
    var envMod     = \envMod.kr(0.6);
    var attack     = \attack.kr(0.01), decay        = \decay.kr(0.3);
    var sustain    = \sustain.kr(0.6), release      = \release.kr(0.4);
    var lfoRate    = \lfoRate.kr(5),   lfoDelay     = \lfoDelay.kr(0.2);
    var lfoToPitch = \lfoToPitch.kr(0), lfoToFilter = \lfoToFilter.kr(0);
    var lfoToPWM   = \lfoToPWM.kr(0);
    var osc, sub, mix, pwmMod, lfo, lfoEnv, filterEnv, ampEnv, sig;

    lfoEnv    = EnvGen.kr(Env([0, 0, 1], [lfoDelay, 0.5]));
    lfo       = LFTri.kr(lfoRate) * lfoEnv;
    pwmMod    = (pwm + (lfo * lfoToPWM)).clip(0.05, 0.95);
    osc       = Pulse.ar(freq * (1 + (lfo * lfoToPitch)), pwmMod);
    sub       = Pulse.ar(freq * 0.25, 0.5, subOscLevel);
    mix       = osc + sub;
    filterEnv = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate);
    sig       = MoogFF.ar(mix,
        (cutoff + (filterEnv * envMod * 5000) + (lfo * lfoToFilter)).clip(20, 20000),
        resonance * 3.8);
    ampEnv    = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate,
        doneAction: \doneAction.ir(0));
    Pan2.ar(sig * ampEnv * amp, pan)
};

~ufn[\thickPad] = {
    |
    out = 0, freq = 440, amp = 0.5, 
    gate = 1, attack = 2, release = 3, 
    cutoff = 1200, rq = 0.6, detune = 0.005,
    pan = 0
    |
    var sig, env, filterEnv, lfo;

    // 1. Envelopes
    // Main amplitude envelope (ASR)
    env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
    
    // Filter envelope: opens up the cutoff over the attack time
    filterEnv = EnvGen.kr(Env.adsr(attack * 1.5, 1, 1, release), gate);

    // 2. Oscillators
    // We create 8 detuned voices for a thick sound
    sig = Splay.ar(
        Array.fill(8, { |i|
            LFPulse.ar(
                freq * LFNoise1.kr(0.5).range(1 - detune, 1 + detune) * (1 + (i * 0.001))
            )
        })
    );

    // 3. Modulation & Filtering
    lfo = SinOsc.kr(0.1).range(0.8, 1.2); // Subtle movement
    sig = MoogFF.ar(
        sig, 
        (cutoff * filterEnv * lfo).clip(20, 20000), 
        gain: rq * 2
    );

    // 4. Stereo Width & Output
    sig = Balance2.ar(sig[0], sig[1], pan, amp * env);
    
    Out.ar(out, sig);
};

// =============================================================================
// RANDOM STUFF
// =============================================================================
~ufn[\duck] = { |in=0, side=0, out=0, thresh=0.1, ratio=10, attack=0.01, release=0.1, makeup=1|
    var sig, sideSig, sideMono, env, cond, gain;

    sig      = In.ar(in, 2);    // stereo signal to be ducked
    sideSig  = In.ar(side, 2);  // stereo sidechain signal
    sideMono = Mix(sideSig);    // collapse to mono for envelope tracking

    // envelope follower with smoothing
    env = LagUD.kr(
        Amplitude.kr(sideMono, 0.01, 0.1),
        attack,
        release
    );

    // cond is a control rate signal, 0 when below threshold, >0 when above
    cond = env > thresh;

    // Select.kr chooses index 0 or 1 based on cond (0 or 1)
    gain = Select.kr(
        cond,  // when 0 -> first element, when 1 -> second
        [
            1,                                      // below threshold
            (env / thresh).reciprocal.pow(ratio)   // above threshold
        ]
    );

    ReplaceOut.ar(out, sig * gain * makeup);
};

~ufn[\harpy1] = { 
  | out, freq=110, gate=1, freqmod=1, amp=0.2,  conv=1|
	var sig, lf,  env;
  env = EnvGen.ar(Env.asr( 0.01, 0.7, 1.0), gate: gate, doneAction: 2 ); 
  sig = SinOsc.ar([freq, freq+2], env*0.1,  freqmod) * LFPulse.ar(freq/2, LFPulse.ar([freqmod-1, freqmod])) * 0.7;
  // sig = LFPulse.ar([freq, freq+2], env,  freqmod) * SinOsc.ar(freq/2, LFPulse.ar([freqmod-1, freqmod])) * 0.7;
  // sig = sig * Convolution.ar(~t3.inbus.index, ~t1.inbus.index, 2048, 0.8);
  sig = sig * env;
	Out.ar(out, sig * amp);
};

~ufn[\dk] = {
    arg out = 0, gate = 1, amp = 0.3, freq=110, 
        freq0 = 220, freq1 = 440, freq2 = 660,
        lfoRate = 0.3, lfoDepth = 0.15,
        attackTime = 0.01, releaseTime = 2.0;

    var lfo, freqs, amps, rings, sig, env;

    freq0 = freq;
    freq1 = freq0 *1.2;
    freq2 = freq1 *1.5;
    // Slow LFO modulating the partials
    lfo = LFPulse.kr(lfoRate);

    // Frequencies: base + LFO-warped harmonics
    freqs = [
        freq0 * (1 + (lfo * lfoDepth)),
        freq1 * (1 + (lfo.neg * lfoDepth * 0.7)),
        freq2 * (1 + (lfo * lfoDepth * 0.5))
    ];

    // Amplitudes: slowly breathe
    amps = [
        0.5 + (lfo * 0.1),
        0.3 + (lfo.neg * 0.05),
        0.2
    ];

    // Ring times: fixed is fine here
    rings = [2.0, 1.5, 0.8];

    // DynKlang takes flat Arrays, not the backtick `[] syntax
    sig = DynKlang.ar(`[freqs, amps, rings]);
    // sig = 
    env = EnvGen.kr(Env.asr(attackTime, 1.0, releaseTime), gate, doneAction: 2);

    Out.ar(out, (sig * env * amp).dup);
};


// =============================================================================
// 808 Synth Kit
// =============================================================================
~ufn[\808] = ();
~ufn[\808][\kik] = {
    arg out=0, pan=0, amp=0.5, 
        freq=50,        // Root frequency
        att=0.001,      // Attack time
        rel=0.8,        // Decay/Release time
        pitchMod=4,     // How high the pitch sweep starts (multiplier)
        pitchRel=0.1,   // How fast the pitch drops
        clickAmp=0.2,   // Volume of the initial click
        dist=1.5;       // Subtle saturation/distortion

    var env, pitchEnv, sig, click;
    env = EnvGen.ar(Env.perc(att, rel), doneAction: 2);
    pitchEnv = EnvGen.ar(Env.perc(0.001, pitchRel)) * (freq * pitchMod) + freq;
    click = BPF.ar(WhiteNoise.ar(1), 2000, 0.5) * EnvGen.ar(Env.perc(0.001, 0.01)) * clickAmp;
    sig = SinOsc.ar(pitchEnv, 0.5pi); // Phase shift to 0.5pi starts the sine at its peak
    sig = sig + click;
    sig = (sig * dist).tanh; 
    
    sig = Pan2.ar(sig * env * amp, pan);
    Out.ar(out, sig);
};

~ufn[\808][\sn] = {
    arg out=0, pan=0, amp=0.4,
        att=0.001, rel=0.15, 
        snapRel=0.2,    // Length of the "snare" noise
        toneFreq=180,   // Base frequency of the drum head
        snappy=0.5;     // Mix between tone and noise

    var env, tone, noise, sig;

    // Amplitude Envelopes
    env = EnvGen.ar(Env.perc(att, rel), doneAction: 2);
    
    // 1. Tone: Two sines tuned apart to simulate drum head resonance
    tone = SinOsc.ar(toneFreq) + SinOsc.ar(toneFreq * 1.5);
    tone = tone * EnvGen.ar(Env.perc(att, rel * 0.5));

    // 2. Snappy: The noise component
    noise = WhiteNoise.ar;
    noise = HPF.ar(noise, 1000); // Remove low end from noise
    noise = BPF.ar(noise, 2000, 0.5);
    noise = noise * EnvGen.ar(Env.perc(att, snapRel)) * snappy;

    sig = tone + noise;
    sig = sig.softclip; // Glue it together
    
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
};

~ufn[\808][\hh] = {
    arg out=0, pan=0, amp=0.3,
        att=0.001, rel=0.05,
        freq=3000,      // Filter cutoff
        res=0.1,        // Filter resonance
        gate=1;

    var env, sig, osclist;

    env = EnvGen.ar(Env.perc(att, rel), doneAction: 2);

    // 6 Square waves at specific ratios for that metallic "clang"
    osclist = [2, 3, 4.1, 5.4, 6.7, 8.2] * 200; 
    sig = Mix.fill(osclist.size, { arg i;
        Pulse.ar(osclist[i], 0.5);
    });

    // High pass filter is the key to the hat sound
    sig = HPF.ar(sig, freq);
    sig = BPF.ar(sig, freq * 2, 0.5); 
    
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
};

"ufn_defs loaded. ~ufn keys: %".format(~ufn.keys).postln;
)
