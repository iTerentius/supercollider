// OTO Machines Biscuit 8-bit FX — SuperCollider emulation
// Hardware: 8-bit ADC → bit manipulation → 4 FX modes → 2-pole analog filter → wet/dry
//
// Parameters:
//   in/out         — audio bus indices
//   drive          — input gain (1.0–5.6, up to +15dB), post-softclip
//   clock          — ADC sample rate 250–30000 Hz (reduce for aliasing effects)
//   bits           — bit depth 1–8 (reduce for harsh quantization)
//   b1–b8          — per-bit state: 1=pass, 0=mute, -1=invert (b1=LSB/bit0, b8=MSB/bit7)
//   fxMode         — 0=waveshaper, 1=delay, 2=pitch shifter, 3=step filter
//   shape          — waveshaper type 0–7 (SelectX for smooth morphing between types)
//   delTime/delFB  — delay time (sec) / feedback 0–1
//   pitchShift     — pitch preset index 0–7: [−2oct, −5th, −1oct, −5th, −4th, 0, +5th, +1oct]
//   stepRate       — step filter clock (Hz), sf0–sf3 = step LP cutoff frequencies
//   filterType     — 0=LP, 1=BP, 2=HP (analog output filter, 2-pole/12dB)
//   filterFreq/Q   — cutoff Hz / resonance (0=flat, 1=resonant)
//   naked/dressed  — dry / wet output levels

(SynthDef(\biscuit, { |in=0, out=0,
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

    sig = In.ar(in, 2);
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

    ReplaceOut.ar(out, wet);
}).add;
)
