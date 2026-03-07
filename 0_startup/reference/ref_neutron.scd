// =============================================================================
// NEUTRON  (_synthdefs/neutron.scd)
// =============================================================================
// Semi-modular dual-VCO analog synth model (Behringer Neutron).
// Signal path: OSC1+OSC2+Sub+Noise → Filter → Drive → VCA → BBD Delay

// --- Minimal synth ---
Synth(\neutron, [\freq, 220, \out, ~t1.inbus.index]);

// --- In a Pbind ---
Pdef(\bass, Pbind(
    \instrument, \neutron,
    \out,        ~t1.inbus.index,
    \scale,      Scale.minor,
    \degree,     Pseq([0, 0, 3, 5], inf),
    \dur,        0.5,
    \amp,        0.7,
));

// =============================================================================
// ARGS — QUICK REFERENCE
// =============================================================================

// --- Pitch / gate ---
// freq       Hz           440
// gate       0/1          1       (sustain while 1)
// amp        0..1         1

// --- OSC 1 (saw + pulse) ---
// osc1Blend  0..1         0.0     (0=saw, 1=pulse)
// osc1PW     0.01..0.99   0.5     (pulse width)
// osc1Oct    int          0       (±3 octave offset)

// --- OSC 2 (saw + pulse + tri) ---
// osc2Blend  0..1         0.0     (0=saw, 0.5=pulse, 1=tri)
// osc2PW     0.01..0.99   0.5
// osc2Oct    int          0
// osc2Semi   semitones    0.0     (coarse detune)
// osc2Fine   cents        0.0     (fine detune)
// osc2Track  0/1          1       (0=free-running, useful as second LFO)
// sync       0/1          0       (hard sync OSC2 → OSC1)

// --- Oscillator mixer ---
// osc1Lvl    0..1         0.7
// osc2Lvl    0..1         0.7
// subLvl     0..1         0.0     (square, -1 oct from OSC1)
// noiseLvl   0..1         0.0

// --- LFO (audio-rate capable) ---
// lfoRate    Hz           1.0
// lfoShape   0..4         0       (0=sin 1=tri 2=saw 3=ramp 4=square)
// lfoToOsc1  -1..1        0.0     (±5% pitch mod)
// lfoToOsc2  -1..1        0.0
// lfoToPW1   -1..1        0.0     (±0.4 pulse width sweep)
// lfoToPW2   -1..1        0.0
// lfoToFilt  -1..1        0.0     (±24 semitones of cutoff)

// --- Filter ---
// cutoff     Hz           2000
// res        0..1         0.2     (self-oscillates above ~0.88)
// filterMode 0..2         0       (0=LP 1=BP 2=HP, fractional crossfade)
// keyTrack   0..1         0.0     (cutoff tracks keyboard pitch)
// env1Amt    -1..1        0.5     (ENV1 depth; negative = inverted)

// --- ENV 1 (filter) ---
// atk1  dcy1  sus1  rel1         (seconds / 0..1 level)
//  0.01  0.3   0.5   0.3

// --- ENV 2 (amp/VCA) ---
// atk2  dcy2  sus2  rel2
//  0.01  0.1   0.9   0.3

// --- Overdrive ---
// drive      0..1         0.0
// driveTone  0..1         1.0     (LP rolloff on drive; 0=dark, 1=bright)
// driveLevel 0..1         0.5

// --- BBD Delay ---
// delTime    seconds      0.25
// delFB      0..1         0.3
// delMix     0..1         0.0

// --- Patch bay CV inputs (static or mapped kr bus) ---
// cvOsc1     semitones    0.0
// cvOsc2     semitones    0.0
// cvFilt     semitones    0.0     (exponential — 12 = one octave up)
// cvPW1      -1..1        0.0
// cvPW2      -1..1        0.0
// cvAmp      0..1         1.0     (VCA open/close from patch bay)

// =============================================================================
// RECIPES
// =============================================================================

// --- Fat detuned bass ---
Synth(\neutron, [
    \out, ~t1.inbus.index, \freq, 55,
    \osc2Semi, 0.0, \osc2Fine, 7,   // slight detune
    \cutoff, 600, \res, 0.3, \env1Amt, 0.8,
    \atk1, 0.001, \dcy1, 0.4, \sus1, 0.1,
    \atk2, 0.001, \dcy2, 0.3, \sus2, 0.0,
]);

// --- PWM pad (LFO sweeping both pulse widths in opposite directions) ---
~n = Synth(\neutron, [
    \out, ~t1.inbus.index, \freq, 220,
    \osc1Blend, 1.0, \osc2Blend, 1.0,   // both in pulse mode
    \lfoRate, 0.4, \lfoShape, 0,
    \lfoToPW1, 0.8, \lfoToPW2, -0.8,    // opposite sweep = classic PWM
    \cutoff, 3000, \res, 0.1,
    \atk2, 1.5, \sus2, 1, \rel2, 2,
]);

// --- Hard sync lead ---
Synth(\neutron, [
    \out, ~t1.inbus.index,
    \osc2Semi, 7, \sync, 1,             // sync with interval
    \cutoff, 1800, \res, 0.5, \env1Amt, 0.6,
    \atk1, 0.001, \dcy1, 0.2, \sus1, 0.3,
    \drive, 0.4,
]);

// --- Self-oscillating filter tone (no oscillators) ---
~n = Synth(\neutron, [
    \out, ~t1.inbus.index,
    \osc1Lvl, 0, \osc2Lvl, 0, \subLvl, 0, \noiseLvl, 0,
    \res, 0.95, \cutoff, 300, \env1Amt, 0,
    \atk2, 0, \sus2, 1, \rel2, 0.5,
]);
~n.set(\cutoff, 600);   // pitch the resonant tone

// --- Noise + resonance percussion ---
Synth(\neutron, [
    \out, ~t1.inbus.index,
    \osc1Lvl, 0, \osc2Lvl, 0, \noiseLvl, 1,
    \cutoff, 800, \res, 0.7, \env1Amt, 1.0,
    \atk1, 0.001, \dcy1, 0.15, \sus1, 0, \rel1, 0.1,
    \atk2, 0.001, \dcy2, 0.15, \sus2, 0, \rel2, 0.1,
]);

// =============================================================================
// PATCHING  (synth.map = patch cable)
// =============================================================================

// Utility SynthDefs (also in neutron.scd):
//   \neutronLFO   args: rate, shape (0-4), out (bus)
//   \att          args: in (bus), amt, out (bus)   — attenuator
//   \inv          args: in (bus), out (bus)         — inverter
//   \slew         args: in (bus), up, dn, out (bus) — lag/portamento
//   \sh           args: in (bus), trig (bus), out   — sample & hold

// --- Setup ---
~lfoOut = Bus.control(s, 1);
~attOut = Bus.control(s, 1);
~invOut = Bus.control(s, 1);

~lfo = Synth(\neutronLFO, [\rate, 0.5, \shape, 0, \out, ~lfoOut]);
~n   = Synth(\neutron, [\out, ~t1.inbus.index, \cutoff, 800, \res, 0.5]);

// Patch cable in:
~n.map(\cvFilt, ~lfoOut);

// Attenuated cable:
~att = Synth(\att, [\in, ~lfoOut, \amt, 0.3, \out, ~attOut]);
~n.map(\cvFilt, ~attOut);

// Opposite PWM on both OSCs (classic Neutron patch):
~inv = Synth(\inv, [\in, ~lfoOut, \out, ~invOut]);
~n.map(\cvPW1, ~lfoOut);
~n.map(\cvPW2, ~invOut);

// LFO → OSC2 pitch (vibrato on OSC2 only):
~n.map(\cvOsc2, ~lfoOut);

// Remove cable:
~n.unmap(\cvFilt);
~n.set(\cvFilt, 0);

// =============================================================================
// PDEF TEMPLATE  (all args + defaults)
// =============================================================================

Pdef(\neutron, Pbind(
    \instrument, \neutron,
    \out,        ~t1.inbus.index,

    // --- pitch / gate ---
    \scale,      Scale.minor,
    \degree,     0,           // integer, scale degree
    \octave,     4,           // integer, 0..8
    \dur,        1,           // beats
    \legato,     0.8,         // 0..2+  (>1 = overlapping gates)
    \amp,        0.7,         // 0..1

    // --- osc 1 (CEM3340: saw + pulse) ---
    \osc1Blend,  0.0,         // 0..1      0=saw, 1=pulse
    \osc1PW,     0.5,         // 0.01..0.99  pulse width
    \osc1Oct,    0,           // -3..+3    integer octave offset

    // --- osc 2 (CEM3340: saw + pulse + tri) ---
    \osc2Blend,  0.0,         // 0..1      0=saw, 0.5=pulse, 1=tri
    \osc2PW,     0.5,         // 0.01..0.99
    \osc2Oct,    0,           // -3..+3    integer octave offset
    \osc2Semi,   0.0,         // ±24 semitones   coarse detune
    \osc2Fine,   0.0,         // ±100 cents      fine detune
    \osc2Track,  1,           // 0/1       0=free-running (second LFO)
    \sync,       0,           // 0/1       hard sync OSC2 → OSC1

    // --- oscillator mixer ---
    \osc1Lvl,    0.7,         // 0..1
    \osc2Lvl,    0.7,         // 0..1
    \subLvl,     0.0,         // 0..1      square, -1 oct from OSC1
    \noiseLvl,   0.0,         // 0..1      white noise

    // --- lfo (audio-rate capable) ---
    \lfoRate,    1.0,         // 0.01..10000 Hz  (audio-rate above ~20)
    \lfoShape,   0,           // 0..4      0=sin 1=tri 2=saw 3=ramp 4=square
    \lfoToOsc1,  0.0,         // -1..+1    ±5% pitch mod on OSC1
    \lfoToOsc2,  0.0,         // -1..+1    ±5% pitch mod on OSC2
    \lfoToPW1,   0.0,         // -1..+1    ±0.4 pulse-width sweep OSC1
    \lfoToPW2,   0.0,         // -1..+1    ±0.4 pulse-width sweep OSC2
    \lfoToFilt,  0.0,         // -1..+1    ±24 semitones of cutoff

    // --- filter (2-pole SVF) ---
    \cutoff,     2000,        // 20..20000 Hz
    \res,        0.2,         // 0..1      self-oscillates above ~0.88
    \filterMode, 0,           // 0..2      0=LP 1=BP 2=HP  (fractional crossfade)
    \keyTrack,   0.0,         // 0..1      1=cutoff tracks keyboard 1:1
    \env1Amt,    0.5,         // -1..+1    ENV1 depth (neg = inverted), ±36 semitones

    // --- env 1 (filter) ---
    \atk1,       0.01,        // 0.001..30 sec
    \dcy1,       0.3,         // 0.001..30 sec
    \sus1,       0.5,         // 0..1
    \rel1,       0.3,         // 0.001..30 sec

    // --- env 2 (amp/VCA) ---
    \atk2,       0.01,        // 0.001..30 sec
    \dcy2,       0.1,         // 0.001..30 sec
    \sus2,       0.9,         // 0..1
    \rel2,       0.3,         // 0.001..30 sec

    // --- overdrive ---
    \drive,      0.0,         // 0..1      gain up to ×21 pre-softclip
    \driveTone,  1.0,         // 0..1      LP rolloff: 0=500Hz dark, 1=12kHz bright
    \driveLevel, 0.5,         // 0..1      post-drive output level

    // --- BBD delay ---
    \delTime,    0.25,        // 0.001..2.0 sec
    \delFB,      0.3,         // 0..1      (above ~0.9 → runaway feedback)
    \delMix,     0.0,         // 0..1      0=dry only, 1=wet only

    // --- cv / patch bay (use synth.map(\cv*, bus) as patch cable) ---
    \cvOsc1,     0.0,         // semitones  exponential pitch offset OSC1
    \cvOsc2,     0.0,         // semitones  exponential pitch offset OSC2
    \cvFilt,     0.0,         // semitones  exponential cutoff offset
    \cvPW1,      0.0,         // -1..+1     direct pulse-width offset OSC1
    \cvPW2,      0.0,         // -1..+1     direct pulse-width offset OSC2
    \cvAmp,      1.0,         // 0..2       VCA gain from patch bay
));
