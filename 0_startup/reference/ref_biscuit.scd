// =============================================================================
// BISCUIT  (_synthdefs/biscuit.scd)
// =============================================================================
// OTO Machines Biscuit 8-bit FX emulation.
// Signal path: In → Drive → Bitcrusher → Bit Manipulation → FX Mode → Filter → wet/dry
//
// ~r3 is wired to \biscuit at startup (mixer-channel-16s.scd).
// Use ~setR3 or ~r3_fx.set to adjust params; send tracks via ~ensurePostSend.

// --- Minimal inline insert on a track ---
~b = Synth(\biscuit, [\in, ~t1.inbus.index, \out, ~t1.inbus.index]);
~b.set(\clock, 8000, \bits, 4);
~b.free;

// --- Using r3 as a biscuit return ---
~ensurePostSend.(~t1, ~r3, 0.3);      // send t1 → r3 at 30%
~ensurePostSend.(~t2, ~r3, 0.5);      // send t2 → r3 at 50%
~r3.level_(0.7);

// Adjust via helper (pass nil to skip)
~setR3.(clock: 8000, bits: 4);
~setR3.(filterFreq: 1200, filterQ: 0.4);
~setR3.(fxMode: 1, nil, nil, nil, nil, nil, nil, nil, nil);  // switch to delay

// Or directly on the synth
~r3_fx.set(\fxMode, 0, \shape, 1);               // waveshaper: bat fuzz
~r3_fx.set(\clock, 30000, \bits, 8);              // reset to transparent
~r3_fx.set(\naked, 1.0, \dressed, 0.0);           // dry bypass

// Remove a send
~ensurePostSend.(~t1, ~r3, 0.0);

// =============================================================================
// ARGS — QUICK REFERENCE
// =============================================================================

// --- I/O ---
// in            bus index        0       input bus
// out           bus index        0       output bus (ReplaceOut)

// --- Input stage ---
// drive         1.0..5.6         1.0     gain before softclip (+0 to +15dB)

// --- Bitcrusher ---
// clock         250..30000 Hz    30000   ADC sample rate (reduce for aliasing/ring-mod)
// bits          1..8             8       bit depth (reduce for harsh quantization)

// --- Bit manipulation (b1=LSB/bit0, b8=MSB/bit7) ---
// b1..b8        1=pass           1       1=pass, 0=mute, -1=invert per bit

// --- FX mode ---
// fxMode        0..3             0       0=waveshaper, 1=delay, 2=pitch, 3=stepfilter

// --- Waveshaper (fxMode=0) ---
// shape         0..7             0       see shapes table below; SelectX = smooth morph

// --- Delay (fxMode=1) ---
// delTime       0.001..2.0 sec   0.25
// delFB         0..1             0.3     feedback amount

// --- Pitch shifter (fxMode=2) ---
// pitchShift    0..7             5       preset index (unison=5); see intervals below

// --- Step filter (fxMode=3) ---
// stepRate      0.1..40 Hz       4.0     step advance rate
// sf0..sf3      Hz               200/400/800/1600    per-step LP cutoff

// --- Analog output filter (2-pole, 12dB/oct) ---
// filterType    0..2             0       0=LP, 1=BP, 2=HP
// filterFreq    20..20000 Hz     15000   cutoff (default = open)
// filterQ       0..1             0.1     0=flat, 1=resonant (rq 1.0→0.1)

// --- Wet/dry ---
// naked         0..1             1.0     dry level
// dressed       0..1             1.0     wet level

// Waveshaper shapes (fxMode=0, shape 0–7):
//   0: fold      bitOut.fold2(1)              smooth fold distortion
//   1: bat fuzz  bitOut.abs                   full-wave rectify (harsh DC buzz)
//   2: rectify   bitOut.max(0)                half-wave (adds DC)
//   3: bitswap   bitOut.neg                   polarity reverse
//   4: alt rect  bitOut.fold2(0.5)*2          tighter fold + boost
//   5: biscuit   PitchShift(−5th)+softclip    fifth down with crunch (signature sound)
//   6: synth saw LFSaw @ ZeroCrossing rate    pitch-tracked sawtooth
//   7: synth sq  LFPulse @ ZeroCrossing rate  pitch-tracked square

// Pitch shifter presets (fxMode=2, pitchShift 0–7):
//   0: −2 oct   1: −5th   2: −1 oct   3: −5th
//   4: −4th     5: unison (default)   6: +5th   7: +1 oct

// =============================================================================
// PATTERN CONTROL  (via \type \set targeting ~r3_fx.nodeID)
// =============================================================================

// --- Automate clock + bits over time ---
Pdef(\bCrush, Pbind(
    \type,  \set,
    \id,    ~r3_fx.nodeID,
    \args,  #[\clock, \bits],
    \clock, Pseq([30000, 16000, 8000, 4000, 2000, 1000], inf),
    \bits,  Pseq([8,     7,     6,    5,    4,    3],    inf),
    \dur,   Pseq([4,     2,     2,    2,    2,    4],    inf)
)).play(~link);

// --- Filter sweep ---
Pdef(\bFilt, Pbind(
    \type,       \set,
    \id,         ~r3_fx.nodeID,
    \args,       #[\filterFreq, \filterQ],
    \filterFreq, Pwhite(200, 8000, inf),
    \filterQ,    Pwhite(0.0, 0.6, inf),
    \dur,        Pseq([2, 4, 2, 4], inf)
)).play(~link);

// --- Cycle waveshaper shapes ---
Pdef(\bShape, Pbind(
    \type,   \set,
    \id,     ~r3_fx.nodeID,
    \args,   #[\fxMode, \shape],
    \fxMode, 0,
    \shape,  Pseq([0, 1, 2, 5, 6, 7], inf),
    \dur,    4
)).play(~link);

// --- Step filter: program the 4 cutoffs each bar ---
Pdef(\bStep, Pbind(
    \type,    \set,
    \id,      ~r3_fx.nodeID,
    \args,    #[\fxMode, \stepRate, \sf0, \sf1, \sf2, \sf3],
    \fxMode,  3,
    \stepRate, 4,
    \sf0,     Prand([100, 200, 400], inf),
    \sf1,     Prand([600, 1200, 2400], inf),
    \sf2,     Prand([400, 800, 1600], inf),
    \sf3,     Prand([3000, 6000, 200], inf),
    \dur,     Pseq([2, 4, 2], inf)
)).play(~link);

// --- Delay feedback swell ---
Pdef(\bDel, Pbind(
    \type,    \set,
    \id,      ~r3_fx.nodeID,
    \args,    #[\fxMode, \delTime, \delFB],
    \fxMode,  1,
    \delTime, Pseq([0.5, 0.25, 0.375, 0.125], inf),
    \delFB,   Pwhite(0.3, 0.8, inf),
    \dur,     Pseq([4, 2, 2, 4], inf)
)).play(~link);

// =============================================================================
// RECIPES
// =============================================================================

// --- Subtle vinyl crunch ---
~setR3.(drive: 1.5, clock: 22000, bits: 7, filterFreq: 12000);

// --- Lo-fi telephone ---
~setR3.(clock: 8000, bits: 6, filterType: 0, filterFreq: 3200, filterQ: 0.15);

// --- Harsh digital destruction ---
~r3_fx.set(\clock, 2000, \bits, 3, \fxMode, 0, \shape, 1, \drive, 2.0);

// --- Rhythmic gate (step filter, 4-on-floor feel) ---
~r3_fx.set(\fxMode, 3, \stepRate, 4, \sf0, 80, \sf1, 4000, \sf2, 80, \sf3, 4000);

// --- Pitched down grit (signature Biscuit sound) ---
~r3_fx.set(\fxMode, 0, \shape, 5, \bits, 6, \clock, 12000);

// --- Pitch octave down ---
~r3_fx.set(\fxMode, 2, \pitchShift, 2);   // -1 oct
~r3_fx.set(\fxMode, 2, \pitchShift, 0);   // -2 oct

// --- Bit surgery (mute/invert individual bits) ---
~r3_fx.set(\b8, 0);      // mute MSB  — large tonal/volume change
~r3_fx.set(\b7, 0);      // mute bit6 — moderate change
~r3_fx.set(\b1, -1);     // invert LSB — subtle high-freq buzz
~r3_fx.set(\b8, 1, \b7, 1, \b1, 1);   // restore all

// --- Delay slapback (8-bit mono) ---
~r3_fx.set(\fxMode, 1, \delTime, 0.12, \delFB, 0.2);

// --- Delay runaway feedback (be ready to kill) ---
~r3_fx.set(\fxMode, 1, \delTime, 0.375, \delFB, 0.85);

// =============================================================================
// FULL DEFAULTS TEMPLATE  (all args, defaults, and ranges)
// =============================================================================
// \type \set Pdef — use as a starting point or reset snapshot.
// Change \id to target a different synth node.
// Change individual values to pattern streams for timed automation.

Pdef(\bCtl, Pbind(
    \type,       \set,
    \id,         ~r3_fx.nodeID,
    \args,       #[\drive, \clock, \bits,
                   \b1, \b2, \b3, \b4, \b5, \b6, \b7, \b8,
                   \fxMode, \shape,
                   \delTime, \delFB,
                   \pitchShift,
                   \stepRate, \sf0, \sf1, \sf2, \sf3,
                   \filterType, \filterFreq, \filterQ,
                   \naked, \dressed],

    // --- input ---
    \drive,      1.0,    // 1.0..5.6    input gain (+0 to +15dB), post-softclip

    // --- bitcrusher ---
    \clock,      30000,  // 250..30000 Hz   ADC sample rate (30000 = transparent)
    \bits,       8,      // 1..8            bit depth (8 = transparent)

    // --- bit manipulation (b1=LSB/bit0 ... b8=MSB/bit7) ---
    \b1,         1,      // -1/0/1   -1=invert, 0=mute, 1=pass  (LSB, subtle)
    \b2,         1,      // -1/0/1
    \b3,         1,      // -1/0/1
    \b4,         1,      // -1/0/1
    \b5,         1,      // -1/0/1
    \b6,         1,      // -1/0/1
    \b7,         1,      // -1/0/1
    \b8,         1,      // -1/0/1   (MSB, large tonal impact)

    // --- fx mode ---
    \fxMode,     0,      // 0..3    0=waveshaper, 1=delay, 2=pitch, 3=step filter

    // --- waveshaper (fxMode=0) ---
    \shape,      0,      // 0..7    SelectX crossfades between shapes
                         //   0=fold  1=bat-fuzz  2=rectify  3=bitswap
                         //   4=alt-rect  5=biscuit(-5th)  6=synth-saw  7=synth-sq

    // --- delay (fxMode=1) ---
    \delTime,    0.25,   // 0.001..2.0 sec
    \delFB,      0.3,    // 0..1   (above ~0.9 → runaway feedback)

    // --- pitch shifter (fxMode=2) ---
    \pitchShift, 5,      // 0..7   preset index
                         //   0=−2oct  1=−5th  2=−1oct  3=−5th
                         //   4=−4th   5=unison  6=+5th  7=+1oct

    // --- step filter (fxMode=3) ---
    \stepRate,   4.0,    // 0.1..40 Hz   step advance clock
    \sf0,        200,    // 20..20000 Hz  step 0 LP cutoff
    \sf1,        400,    // 20..20000 Hz  step 1 LP cutoff
    \sf2,        800,    // 20..20000 Hz  step 2 LP cutoff
    \sf3,        1600,   // 20..20000 Hz  step 3 LP cutoff

    // --- analog output filter (2-pole, 12dB/oct) ---
    \filterType, 0,      // 0..2    0=LP, 1=BP, 2=HP  (SelectX crossfades)
    \filterFreq, 15000,  // 20..20000 Hz   cutoff (15000 = open/transparent)
    \filterQ,    0.1,    // 0..1    0=flat (rq=1.0), 1=resonant (rq=0.1)

    // --- wet/dry ---
    \naked,      1.0,    // 0..1   dry level
    \dressed,    1.0,    // 0..1   wet level

    \dur,        1,      // beats between events (set to inf for one-shot)
)).play(~link);

// =============================================================================
// CLEANUP
// =============================================================================

// Stop pattern modulation
Pdef(\bCrush).stop; Pdef(\bFilt).stop; Pdef(\bShape).stop;
Pdef(\bStep).stop;  Pdef(\bDel).stop;

// Reset to transparent settings
~r3_fx.set(\clock, 30000, \bits, 8, \fxMode, 0, \shape, 0,
    \filterFreq, 15000, \filterQ, 0.1, \drive, 1.0);

// Remove sends
~ensurePostSend.(~t1, ~r3, 0.0);
~ensurePostSend.(~t2, ~r3, 0.0);

// Free the biscuit insert (r3 goes silent / passes nothing without a playfx)
~r3_fx.free;
~r3.effectgroup.freeAll;
