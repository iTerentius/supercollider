// Behringer Model D — SuperCollider SynthDef
// Minimoog-style 3-VCO subtractive synth with 24dB ladder filter
//
// Key differences from neutron.scd:
//   - 3 VCOs, each with 6-position waveform selector (SelectX)
//   - OSC 3 doubles as LFO (osc3KbdTrack=0 → free-running at osc3Freq Hz)
//   - 24dB Moog ladder LP filter (MoogFF), no BP/HP
//   - ADS envelopes with shared decayOn switch (no dedicated release knob)
//   - Portamento via VarLag (glide in semitone space)
//   - Mod wheel routes OSC3 or noise → OSC pitch and/or filter cutoff
//
// Waveforms (osc*Wave 0–5):
//   0: triangle        LFTri
//   1: inverse saw     LFSaw.neg   (ramp down)
//   2: sawtooth        LFSaw       (ramp up — default)
//   3: square          LFPulse pw=0.5
//   4: wide pulse      LFPulse pw=0.25
//   5: narrow pulse    LFPulse pw=0.1

(SynthDef(\modelD, {
    |freq=440, gate=1, amp=0.7, out=0,
    glide=0.0,
    osc1Wave=2, osc1Oct=0,
    osc2Wave=2, osc2Oct=0, osc2Fine=0.0,
    osc3Wave=0, osc3Oct=0, osc3Fine=0.0, osc3KbdTrack=1, osc3Freq=1.0,
    osc1Lvl=0.7, osc2Lvl=0.7, osc3Lvl=0.0, noiseLvl=0.0, noiseType=0,
    cutoff=1000, emphasis=0.2, kbdAmt=0.5, contourAmt=0.5, drive=0.0,
    fAtk=0.001, fDcy=0.3, fSus=0.5, decayOn=1,
    aAtk=0.001, aDcy=0.3, aSus=0.9,
    modWheel=0.0, modToOsc=0, modToFilter=0, modSource=0,
    cvOsc1=0.0, cvOsc2=0.0, cvOsc3=0.0, cvFilt=0.0, cvAmp=1.0 |

    var glidedFreq,
        whiteSig, pinkSig, noiseSig,
        osc3KbdFreq, osc3BaseFreq,
        osc3t0, osc3t1, osc3t2, osc3t3, osc3t4, osc3t5, osc3Sig,
        modSig, modAmt,
        osc1Freq,
        osc1t0, osc1t1, osc1t2, osc1t3, osc1t4, osc1t5, osc1Sig,
        osc2Freq,
        osc2t0, osc2t1, osc2t2, osc2t3, osc2t4, osc2t5, osc2Sig,
        mixSig, drivenSig,
        fRel, eg1, ktMult, fFreq, fGain, filtered,
        aRel, eg2,
        vcaOut, output;

    // --- Portamento (glide in semitone/MIDI space) ---
    glidedFreq = VarLag.kr(freq.cpsmidi, glide, 0).midicps;

    // --- Noise sources ---
    whiteSig = WhiteNoise.ar;
    pinkSig  = PinkNoise.ar;

    // --- OSC 3 (keyboard follower or free-running LFO) ---
    // osc3KbdTrack=1 → tracks keyboard; =0 → free at osc3Freq Hz
    // osc3Oct and osc3Fine (semitones) apply only in kbd mode
    osc3KbdFreq  = glidedFreq * (2 ** osc3Oct) * (2 ** (osc3Fine / 12)) * (2 ** (cvOsc3 / 12));
    osc3BaseFreq = ((osc3Freq * (1 - osc3KbdTrack)) + (osc3KbdFreq * osc3KbdTrack)).max(0.01);
    osc3t0 = LFTri.ar(osc3BaseFreq);
    osc3t1 = LFSaw.ar(osc3BaseFreq).neg;
    osc3t2 = LFSaw.ar(osc3BaseFreq);
    osc3t3 = LFPulse.ar(osc3BaseFreq, 0, 0.5)  * 2 - 1;
    osc3t4 = LFPulse.ar(osc3BaseFreq, 0, 0.25) * 2 - 1;
    osc3t5 = LFPulse.ar(osc3BaseFreq, 0, 0.1)  * 2 - 1;
    osc3Sig = SelectX.ar(osc3Wave.clip(0, 5), [osc3t0, osc3t1, osc3t2, osc3t3, osc3t4, osc3t5]);

    // --- Mod routing (OSC3 or noise → scaled by mod wheel) ---
    modSig = XFade2.ar(osc3Sig, whiteSig, (modSource * 2) - 1);  // 0=osc3, 1=noise
    modAmt = modSig * modWheel;

    // --- OSC 1 ---
    osc1Freq = (glidedFreq * (2 ** osc1Oct) * (2 ** (cvOsc1 / 12)) * (2 ** ((modAmt * modToOsc * 5) / 12))).max(0.01);
    osc1t0 = LFTri.ar(osc1Freq);
    osc1t1 = LFSaw.ar(osc1Freq).neg;
    osc1t2 = LFSaw.ar(osc1Freq);
    osc1t3 = LFPulse.ar(osc1Freq, 0, 0.5)  * 2 - 1;
    osc1t4 = LFPulse.ar(osc1Freq, 0, 0.25) * 2 - 1;
    osc1t5 = LFPulse.ar(osc1Freq, 0, 0.1)  * 2 - 1;
    osc1Sig = SelectX.ar(osc1Wave.clip(0, 5), [osc1t0, osc1t1, osc1t2, osc1t3, osc1t4, osc1t5]);

    // --- OSC 2 ---
    // osc2Fine in semitones (hardware range ±7st)
    osc2Freq = (glidedFreq * (2 ** osc2Oct) * (2 ** (osc2Fine / 12)) * (2 ** (cvOsc2 / 12)) * (2 ** ((modAmt * modToOsc * 5) / 12))).max(0.01);
    osc2t0 = LFTri.ar(osc2Freq);
    osc2t1 = LFSaw.ar(osc2Freq).neg;
    osc2t2 = LFSaw.ar(osc2Freq);
    osc2t3 = LFPulse.ar(osc2Freq, 0, 0.5)  * 2 - 1;
    osc2t4 = LFPulse.ar(osc2Freq, 0, 0.25) * 2 - 1;
    osc2t5 = LFPulse.ar(osc2Freq, 0, 0.1)  * 2 - 1;
    osc2Sig = SelectX.ar(osc2Wave.clip(0, 5), [osc2t0, osc2t1, osc2t2, osc2t3, osc2t4, osc2t5]);

    // --- Noise for audio path ---
    noiseSig = Select.ar(noiseType, [whiteSig, pinkSig]);

    // --- Oscillator mixer — CRITICAL: parenthesize every product ---
    mixSig = (
        (osc1Sig * osc1Lvl) + (osc2Sig * osc2Lvl) +
        (osc3Sig * osc3Lvl) + (noiseSig * noiseLvl)
    ) * 0.25;

    // --- Pre-filter drive ---
    drivenSig = (mixSig * (1 + (drive * 8))).softclip;

    // --- Filter contour envelope (ADS + decayOn switch) ---
    // decayOn=1: release=fDcy (classic Minimoog — contour fades with key held)
    // decayOn=0: release=60s  (sustain-hold mode — contour holds until key release)
    fRel = Select.kr(decayOn, [60.0, fDcy]);
    eg1  = EnvGen.kr(Env.adsr(fAtk, fDcy, fSus, fRel), gate);

    // --- MoogFF ladder filter ---
    // Keyboard tracking: CRITICAL — parenthesize the product term
    ktMult = ((glidedFreq / 440) * kbdAmt) + (1 - kbdAmt);
    fFreq  = (
        cutoff * ktMult
        * (2 ** (eg1 * contourAmt * 4))           // contour: up to +4 oct at peak
        * (2 ** ((modAmt * modToFilter * 2)))      // mod wheel: ±2 oct
        * (2 ** cvFilt)                            // CV: in octaves
    ).clip(20, 20000);
    fGain    = emphasis.linlin(0, 1, 0, 4.0);     // self-oscillates at emphasis ≥ ~0.88
    filtered = MoogFF.ar(drivenSig, fFreq, fGain);

    // --- Amp contour envelope (ADS + decayOn switch, shared) ---
    aRel   = Select.kr(decayOn, [60.0, aDcy]);
    eg2    = EnvGen.kr(Env.adsr(aAtk, aDcy, aSus, aRel), gate, doneAction: Done.freeSelf);

    // --- VCA → stereo output ---
    vcaOut = filtered * eg2 * amp * cvAmp;
    output = Pan2.ar(vcaOut * 0.7, 0);
    Out.ar(out, output);
}).add;
)
