/*
Classic Analog Synth SynthDef Patterns
======================================

These SynthDefs reproduce common analog synth architectures and can serve
as design patterns for your own instruments. Each includes typical modulation
routing and parameter ranges found in classic hardware.
*/

(
// ============================================================================
// MINIMOOG-STYLE - 3 Oscillator Monophonic Lead
// ============================================================================
SynthDef(\moogLead, {
    |out=0, gate=1, freq=440, amp=0.5, pan=0,
    // Oscillator mix
    osc1Level=0.7, osc2Level=0.5, osc3Level=0.3,
    osc2Detune=0, osc3Detune=0,  // in semitones
    // Filter
    cutoff=2000, resonance=0.3, filterEnvAmt=3000,
    // Envelopes
    filterAttack=0.01, filterDecay=0.3, filterSustain=0.5, filterRelease=0.5,
    ampAttack=0.01, ampDecay=0.3, ampSustain=0.7, ampRelease=0.5,
    // Modulation
    lfoRate=5, lfoToPitch=0, lfoToFilter=0|
    
    var osc1, osc2, osc3, mix, lfo;
    var filterEnv, ampEnv, sig;
    
    // LFO
    lfo = SinOsc.kr(lfoRate);
    
    // Three saw oscillators (classic Moog)
    osc1 = Saw.ar(freq * (1 + (lfo * lfoToPitch)));
    osc2 = Saw.ar(freq * (2 ** (osc2Detune/12)) * (1 + (lfo * lfoToPitch)));
    osc3 = Saw.ar(freq * (2 ** (osc3Detune/12)) * (1 + (lfo * lfoToPitch)));
    
    // Mix oscillators
    mix = (osc1 * osc1Level) + (osc2 * osc2Level) + (osc3 * osc3Level);
    
    // Classic Moog ladder filter envelope
    filterEnv = EnvGen.kr(
        Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease),
        gate
    );
    
    // Moog ladder filter
    sig = MoogFF.ar(
        mix,
        (cutoff + (filterEnv * filterEnvAmt) + (lfo * lfoToFilter)).clip(20, 20000),
        resonance * 4  // MoogFF resonance range 0-4
    );
    
    // Amp envelope
    ampEnv = EnvGen.kr(
        Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease),
        gate,
        doneAction: 2
    );
    
    sig = sig * ampEnv * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// ============================================================================
// JUNO-106 STYLE - PWM Poly Synth
// ============================================================================
SynthDef(\junoChord, {
    |out=0, gate=1, freq=440, amp=0.3, pan=0,
    // Oscillator
    pulseWidth=0.5, pwmRate=0.2, pwmDepth=0.4,
    subLevel=0.3,
    // Filter (Juno has a simple HP->LP configuration)
    cutoff=3000, resonance=0.2, filterEnvAmt=2000,
    // Envelopes
    filterAttack=0.01, filterDecay=0.5, filterSustain=0.3, filterRelease=0.8,
    ampAttack=0.01, ampDecay=0.5, ampSustain=0.6, ampRelease=0.8,
    // Chorus (Juno's signature sound)
    chorusDepth=0.4|
    
    var pulse, sub, mix;
    var pwmLfo, filterEnv, ampEnv, sig;
    
    // PWM modulation
    pwmLfo = SinOsc.kr(pwmRate, 0, pwmDepth, pulseWidth);
    
    // Pulse wave with PWM
    pulse = Pulse.ar(freq, pwmLfo);
    
    // Sub oscillator (square wave one octave down)
    sub = Pulse.ar(freq * 0.5, 0.5, subLevel);
    
    mix = pulse + sub;
    
    // Filter envelope
    filterEnv = EnvGen.kr(
        Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease),
        gate
    );
    
    // Simple lowpass filter (Juno style)
    sig = RLPF.ar(
        mix,
        (cutoff + (filterEnv * filterEnvAmt)).clip(20, 20000),
        1 - (resonance * 0.9)  // inverse Q for RLPF
    );
    
    // Amp envelope
    ampEnv = EnvGen.kr(
        Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease),
        gate,
        doneAction: 2
    );
    
    sig = sig * ampEnv * amp;
    
    // Simple chorus effect (Juno's signature)
    sig = sig + DelayC.ar(
        sig,
        0.02,
        SinOsc.kr(0.7, 0, chorusDepth * 0.01, 0.01)
    );
    
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// ============================================================================
// PROPHET-5 STYLE - Dual Oscillator with Cross-Mod
// ============================================================================
SynthDef(\prophetLead, {
    |out=0, gate=1, freq=440, amp=0.4, pan=0,
    // Oscillators
    osc1Shape=0,  // 0=saw, 0.5=triangle, 1=pulse
    osc2Shape=0,
    osc2Detune=0.02,  // in Hz for beating
    osc2Semitones=0,
    oscMix=0.5,  // 0=osc1 only, 1=osc2 only
    sync=0,  // oscillator sync amount
    // Filter (Curtis chip style)
    cutoff=4000, resonance=0.4, filterEnvAmt=3500,
    filterAttack=0.05, filterDecay=0.4, filterSustain=0.3, filterRelease=1.0,
    // Amp
    ampAttack=0.05, ampDecay=0.4, ampSustain=0.7, ampRelease=1.0,
    // Modulation
    lfoRate=4, lfoShape=0,  // 0=tri, 1=square
    lfoToOsc1=0, lfoToOsc2=0, lfoToFilter=0, lfoToPWM=0|
    
    var osc1, osc2, osc1Freq, osc2Freq;
    var lfo, filterEnv, ampEnv, sig;
    
    // LFO with shape morphing
    lfo = SelectX.kr(lfoShape, [
        LFTri.kr(lfoRate),
        LFPulse.kr(lfoRate, 0, 0.5, 2, -1)
    ]);
    
    // Oscillator frequencies with LFO modulation
    osc1Freq = freq * (1 + (lfo * lfoToOsc1));
    osc2Freq = (freq + osc2Detune) * (2 ** (osc2Semitones/12)) * (1 + (lfo * lfoToOsc2));
    
    // Oscillator 1 with waveshape morphing
    osc1 = SelectX.ar(osc1Shape, [
        Saw.ar(osc1Freq),
        LFTri.ar(osc1Freq),
        Pulse.ar(osc1Freq, 0.5 + (lfo * lfoToPWM))
    ]);
    
    // Oscillator 2 with optional hard sync to osc1
    osc2 = SelectX.ar(osc2Shape, [
        Saw.ar(osc2Freq),
        LFTri.ar(osc2Freq),
        Pulse.ar(osc2Freq, 0.5 + (lfo * lfoToPWM))
    ]);
    
    // Optional sync
    osc2 = SelectX.ar(sync, [
        osc2,
        SyncSaw.ar(osc1Freq, osc2Freq)
    ]);
    
    // Mix oscillators
    sig = XFade2.ar(osc1, osc2, oscMix * 2 - 1);
    
    // Filter envelope
    filterEnv = EnvGen.kr(
        Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease),
        gate
    );
    
    // Curtis-style filter (using MoogFF as approximation)
    sig = MoogFF.ar(
        sig,
        (cutoff + (filterEnv * filterEnvAmt) + (lfo * lfoToFilter)).clip(20, 20000),
        resonance * 3.5
    );
    
    // Amp envelope
    ampEnv = EnvGen.kr(
        Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease),
        gate,
        doneAction: 2
    );
    
    sig = sig * ampEnv * amp * 0.5;  // Scale down for headroom
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// ============================================================================
// TB-303 STYLE - Acid Bass
// ============================================================================
SynthDef(\acidBass, {
    |out=0, gate=1, freq=440, amp=0.6, pan=0,
    // Oscillator
    waveform=0,  // 0=saw, 1=square
    // Filter (the heart of 303)
    cutoff=800, resonance=0.6, envMod=0.7,
    // Envelope (303 has unique decay-only filter envelope)
    decay=0.2,
    // Accent
    accent=0,  // 0-1, accented notes have more envelope mod
    // Slide
    slideTime=0.1, slide=0|  // slide between notes
    
    var osc, sig, filterEnv, ampEnv;
    var slideFreq, actualResonance;
    
    // Frequency slide (portamento)
    slideFreq = Lag.kr(freq, slide * slideTime);
    
    // Oscillator - saw or square
    osc = Select.ar(waveform, [
        Saw.ar(slideFreq),
        Pulse.ar(slideFreq, 0.5)
    ]);
    
    // 303's distinctive decay-only envelope with accent
    filterEnv = EnvGen.kr(
        Env.perc(0.001, decay, 1, -4),  // -4 curve is important for 303 character
        gate
    );
    
    // Accent increases envelope depth
    filterEnv = filterEnv * (1 + (accent * 2));
    
    // Resonance increases with envelope (303 characteristic)
    actualResonance = resonance + (filterEnv * 0.3);
    
    // Classic diode ladder filter simulation
    sig = MoogFF.ar(
        osc,
        (cutoff + (filterEnv * envMod * 8000)).clip(20, 20000),
        actualResonance.clip(0, 0.95) * 4
    );
    
    // Simple amp envelope
    ampEnv = EnvGen.kr(
        Env.adsr(0.001, 0.1, 1.0, 0.05),
        gate,
        doneAction: 2
    );
    
    sig = sig * ampEnv * amp * (1 + (accent * 0.5));
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// ============================================================================
// MS-20 STYLE - Dual Filter with Patch Matrix
// ============================================================================
SynthDef(\ms20Bass, {
    |out=0, gate=1, freq=440, amp=0.5, pan=0,
    // Oscillators
    osc1Level=0.7, osc2Level=0.5,
    osc2Detune=7,  // semitones
    ringMod=0,  // ring modulation amount
    // Dual filters (MS-20's signature)
    hpfCutoff=100, hpfRes=0.2,
    lpfCutoff=2000, lpfRes=0.6,
    filterEnvAmt=3000,
    // Envelopes
    filterAttack=0.01, filterDecay=0.5, filterSustain=0.2, filterRelease=0.5,
    ampAttack=0.01, ampDecay=0.3, ampSustain=0.6, ampRelease=0.3,
    // Patch matrix modulation
    eg2ToHPF=0, eg2ToLPF=1|  // envelope can route to either/both filters
    
    var osc1, osc2, mix, ring;
    var filterEnv, ampEnv, sig;
    
    // Two VCOs
    osc1 = Saw.ar(freq);
    osc2 = Pulse.ar(freq * (2 ** (osc2Detune/12)), 0.3);
    
    // Ring modulation
    ring = osc1 * osc2;
    
    // Mix with ring mod
    mix = (osc1 * osc1Level) + (osc2 * osc2Level) + (ring * ringMod);
    
    // Filter envelope
    filterEnv = EnvGen.kr(
        Env.adsr(filterAttack, filterDecay, filterSustain, filterRelease),
        gate
    );
    
    // HPF then LPF (MS-20 configuration)
    sig = RHPF.ar(
        mix,
        (hpfCutoff + (filterEnv * filterEnvAmt * eg2ToHPF)).clip(20, 20000),
        1 - (hpfRes * 0.9)
    );
    
    sig = MoogFF.ar(
        sig,
        (lpfCutoff + (filterEnv * filterEnvAmt * eg2ToLPF)).clip(20, 20000),
        lpfRes * 4
    );
    
    // Amp envelope
    ampEnv = EnvGen.kr(
        Env.adsr(ampAttack, ampDecay, ampSustain, ampRelease),
        gate,
        doneAction: 2
    );
    
    sig = sig * ampEnv * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// ============================================================================
// SH-101 STYLE - Sub-Oscillator Lead
// ============================================================================
SynthDef(\sh101Lead, {
    |out=0, gate=1, freq=440, amp=0.5, pan=0,
    // Oscillator
    pwm=0.5, subOscLevel=0.4,
    // Filter
    cutoff=2500, resonance=0.5, envMod=0.6,
    // Envelopes (101 has simple ADSR)
    attack=0.01, decay=0.3, sustain=0.6, release=0.4,
    // LFO
    lfoRate=5, lfoDelay=0.2, lfoToPitch=0, lfoToFilter=0, lfoToPWM=0|
    
    var osc, sub, mix, pwmMod;
    var lfo, lfoEnv, filterEnv, ampEnv, sig;
    
    // LFO with delay
    lfoEnv = EnvGen.kr(Env([0, 0, 1], [lfoDelay, 0.5]));
    lfo = LFTri.kr(lfoRate) * lfoEnv;
    
    // PWM
    pwmMod = pwm + (lfo * lfoToPWM);
    
    // Main oscillator (pulse with PWM)
    osc = Pulse.ar(freq * (1 + (lfo * lfoToPitch)), pwmMod.clip(0.05, 0.95));
    
    // Sub oscillator (square, -2 octaves)
    sub = Pulse.ar(freq * 0.25, 0.5, subOscLevel);
    
    mix = osc + sub;
    
    // Filter envelope
    filterEnv = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate);
    
    // Roland IR3109 filter (approximated with MoogFF)
    sig = MoogFF.ar(
        mix,
        (cutoff + (filterEnv * envMod * 5000) + (lfo * lfoToFilter)).clip(20, 20000),
        resonance * 3.8
    );
    
    // Amp envelope
    ampEnv = EnvGen.kr(
        Env.adsr(attack, decay, sustain, release),
        gate,
        doneAction: 2
    );
    
    sig = sig * ampEnv * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

)

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

// (
// // Moog-style lead line
// Pdef(\moogSeq,
//     Pbind(
//         \instrument, \moogLead,
//         \scale, Scale.minor,
//         \degree, Pseq([0, 3, 5, 7, 5, 3, 2, 0], inf),
//         \octave, 5,
//         \dur, 0.25,
//         \legato, 0.9,
//         \cutoff, 1200,
//         \resonance, 0.6,
//         \filterEnvAmt, 2500,
//         \lfoRate, 6,
//         \lfoToPitch, 0.005,
//         \osc2Detune, 0.05,
//         \osc3Detune, -0.07
//     )
// );
// )
//
// (
// // Juno-style chords
// Pdef(\junoChords,
//     Pbind(
//         \instrument, \junoChord,
//         \scale, Scale.major,
//         \degree, Pseq([
//             [0, 2, 4],
//             [2, 4, 6],
//             [4, 6, 8],
//             [0, 2, 4]
//         ], inf),
//         \octave, 4,
//         \dur, 2,
//         \legato, 0.95,
//         \cutoff, 2000,
//         \chorusDepth, 0.6,
//         \pwmRate, 0.25,
//         \pwmDepth, 0.5
//     )
// );
// )
//
// (
// // 303-style acid bass
// Pdef(\acid,
//     Pbind(
//         \instrument, \acidBass,
//         \scale, Scale.minor,
//         \degree, Prand([0, 3, 5, 7, 10, 12], inf),
//         \octave, Prand([3, 4], inf),
//         \dur, 0.125,
//         \legato, Pwrand([0.1, 1.5], [0.7, 0.3], inf),  // short vs. slide
//         \slide, Pwrand([0, 1], [0.7, 0.3], inf),
//         \cutoff, Pwhite(400, 1200),
//         \resonance, 0.7,
//         \envMod, 0.8,
//         \decay, Pwhite(0.1, 0.4),
//         \accent, Pwrand([0, 1], [0.7, 0.3], inf),
//         \waveform, 0  // saw wave
//     )
// );
// )
//
// (
// // MS-20 style bass
// Pdef(\ms20,
//     Pbind(
//         \instrument, \ms20Bass,
//         \scale, Scale.minor,
//         \degree, Pseq([0, 0, 3, 5], inf),
//         \octave, 3,
//         \dur, 0.5,
//         \legato, 0.6,
//         \hpfCutoff, 80,
//         \lpfCutoff, 800,
//         \lpfRes, 0.8,
//         \filterEnvAmt, 2000,
//         \ringMod, 0.2
//     )
// );
// )
//
// "Classic Analog SynthDefs loaded! Try the examples above.".postln;
