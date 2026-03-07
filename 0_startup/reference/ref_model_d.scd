// =============================================================================
// MODEL D  (_synthdefs/model_d.scd)
// =============================================================================
// Behringer Model D / Minimoog-style 3-VCO, 24dB ladder filter subtractive synth.
// Signal path: 3x VCO + noise → mixer → pre-filter drive → MoogFF → VCA

// --- Minimal synth ---
Synth(\modelD, [\out, ~t1.inbus.index]);

// --- In a Pbind ---
Pdef(\bass, Pbind(
    \instrument, \modelD,
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
// freq        Hz           440
// gate        0/1          1        (sustain while 1)
// amp         0..1         0.7
// glide       seconds      0.0      (portamento time, semitone space)

// --- OSC 1 ---
// osc1Wave    0..5         2        (see waveform table below)
// osc1Oct     integer      0        (octave offset, e.g. -1, 0, +1, +2)

// --- OSC 2 ---
// osc2Wave    0..5         2
// osc2Oct     integer      0
// osc2Fine    semitones    0.0      (range ±7st, hardware fine-tune)

// --- OSC 3 (keyboard follower or free LFO) ---
// osc3Wave    0..5         0        (triangle is good for LFO)
// osc3Oct     integer      0        (only used when osc3KbdTrack=1)
// osc3Fine    semitones    0.0      (only used when osc3KbdTrack=1)
// osc3KbdTrack 0/1         1        (1=follows keyboard, 0=free LFO)
// osc3Freq    Hz           1.0      (LFO rate when osc3KbdTrack=0)

// --- Oscillator mixer ---
// osc1Lvl     0..1         0.7
// osc2Lvl     0..1         0.7
// osc3Lvl     0..1         0.0      (add OSC3 as audio VCO)
// noiseLvl    0..1         0.0
// noiseType   0/1          0        (0=white, 1=pink)

// --- Filter (MoogFF, 24dB/oct LP only) ---
// cutoff      Hz           1000
// emphasis    0..1         0.2      (resonance; self-oscillates above ~0.88)
// kbdAmt      0..1         0.5      (keyboard tracking: 0=none, 1=full)
// contourAmt  0..1         0.5      (filter EG depth, up to +4 oct at peak)
// drive       0..1         0.0      (pre-filter saturation, max ~x9)

// --- Filter contour (ADS) ---
// fAtk        seconds      0.001
// fDcy        seconds      0.3
// fSus        0..1         0.5

// --- Amp contour (ADS) ---
// aAtk        seconds      0.001
// aDcy        seconds      0.3
// aSus        0..1         0.9

// --- Shared decay switch ---
// decayOn     0/1          1
//   1 → release = decay time (contour fades after key held)
//   0 → release = 60s (sustain-hold; contour dies only on key release)

// --- Mod wheel routing ---
// modWheel    0..1         0.0      (depth of mod source)
// modToOsc    0/1          0        (mod → OSC1+2 pitch, ±5 semitones)
// modToFilter 0/1          0        (mod → filter cutoff, ±2 octaves)
// modSource   0/1          0        (0=OSC3, 1=white noise)

// --- CV / patch bay (all in semitones, cvFilt in octaves) ---
// cvOsc1      semitones    0.0      (pitch offset, exponential)
// cvOsc2      semitones    0.0
// cvOsc3      semitones    0.0
// cvFilt      octaves      0.0      (cutoff offset, exponential)
// cvAmp       0..1         1.0      (VCA gain from patch bay)

// Waveforms (osc*Wave 0–5):
//   0: triangle       LFTri            (good for LFO on OSC3)
//   1: inverse saw    LFSaw.neg        (ramp down)
//   2: sawtooth       LFSaw            (ramp up — classic Moog default)
//   3: square         LFPulse pw=0.5
//   4: wide pulse     LFPulse pw=0.25
//   5: narrow pulse   LFPulse pw=0.1

// =============================================================================
// RECIPES
// =============================================================================

// --- Fat detuned bass ---
Synth(\modelD, [
    \out, ~t1.inbus.index, \freq, 55,
    \osc2Fine, 5.0,                       // +5st detune
    \cutoff, 500, \emphasis, 0.3, \contourAmt, 0.8,
    \fAtk, 0.001, \fDcy, 0.4, \fSus, 0.0,
    \aAtk, 0.001, \aDcy, 0.3, \aSus, 0.0,
]);

// --- Lush pad (OSC3 as LFO, mod wheel for vibrato + filter wobble) ---
~n = Synth(\modelD, [
    \out, ~t1.inbus.index, \freq, 220,
    \osc1Wave, 0, \osc2Wave, 2, \osc2Oct, 1, \osc2Fine, 2.0,
    \osc3KbdTrack, 0, \osc3Freq, 2.5, \osc3Wave, 0,   // 2.5 Hz triangle LFO
    \modWheel, 0.5, \modToOsc, 1, \modToFilter, 1,     // mod to pitch + filter
    \cutoff, 1500, \emphasis, 0.25, \contourAmt, 0.4,
    \aAtk, 1.2, \aSus, 1.0, \aRel, 2.0,
]);
~n.set(\modWheel, 0.8);   // swell mod wheel

// --- Classic Minimoog lead (sawtooth, filter sweep) ---
Synth(\modelD, [
    \out, ~t1.inbus.index,
    \osc2Fine, 3.0, \cutoff, 800, \emphasis, 0.5,
    \contourAmt, 0.9, \fAtk, 0.005, \fDcy, 0.3, \fSus, 0.2,
    \aAtk, 0.005, \aDcy, 0.2, \aSus, 0.8,
    \drive, 0.3,
]);

// --- Self-oscillating filter tone (no oscillators) ---
~n = Synth(\modelD, [
    \out, ~t1.inbus.index,
    \osc1Lvl, 0, \osc2Lvl, 0, \noiseLvl, 0,
    \emphasis, 0.95, \cutoff, 300,
    \contourAmt, 0, \kbdAmt, 1.0,
    \aAtk, 0, \aSus, 1,
]);
~n.set(\cutoff, 600);    // pitch the resonant tone

// --- Percussion with noise burst ---
Synth(\modelD, [
    \out, ~t1.inbus.index,
    \osc1Lvl, 0, \osc2Lvl, 0, \noiseLvl, 0.8, \noiseType, 0,
    \cutoff, 1200, \emphasis, 0.6, \contourAmt, 1.0,
    \fAtk, 0.001, \fDcy, 0.12, \fSus, 0,
    \aAtk, 0.001, \aDcy, 0.15, \aSus, 0,
    \drive, 0.4,
]);

// --- OSC3 as audio VCO (fifth interval, hard chord) ---
Synth(\modelD, [
    \out, ~t1.inbus.index, \freq, 110,
    \osc3KbdTrack, 1, \osc3Wave, 2, \osc3Oct, 0, \osc3Fine, 7.0,  // +7st = 5th
    \osc1Lvl, 0.6, \osc2Lvl, 0.6, \osc3Lvl, 0.5,
    \cutoff, 2000, \emphasis, 0.2, \contourAmt, 0.3,
]);

// --- Glide (portamento) lead ---
Pdef(\glide, Pbind(
    \instrument, \modelD,
    \out,        ~t1.inbus.index,
    \glide,      0.08,           // 80ms portamento
    \scale,      Scale.minor,
    \degree,     Pseq([0, 3, 5, 7, 5, 3, 0, -2], inf),
    \dur,        0.25,
    \legato,     1.5,            // overlapping gates = glide triggers
    \cutoff,     1200, \emphasis, 0.4, \contourAmt, 0.7,
    \fAtk,       0.01, \fDcy, 0.3, \fSus, 0.5,
)).play(~link);

// --- Mod wheel automation (LFO → pitch vibrato) ---
Pdef(\vibrato, Pbind(
    \type,      \set,
    \id,        ~n.nodeID,
    \args,      #[\modWheel],
    \modWheel,  Pseg([0, 0.6, 0], [0.5, 1.5], \sin, inf),
    \dur,       0.05
)).play;

// =============================================================================
// PATCHING  (map CV buses to args)
// =============================================================================

// --- LFO from a Bus → OSC pitch ---
~lfoOut = Bus.control(s, 1);
~lfo    = Synth(\neutronLFO, [\rate, 3.0, \shape, 0, \out, ~lfoOut]);
~n      = Synth(\modelD, [\out, ~t1.inbus.index]);
~n.map(\cvOsc1, ~lfoOut);    // patch LFO → OSC1 pitch (in semitones)
~n.map(\cvOsc2, ~lfoOut);    // same LFO → OSC2 pitch (both detune together)

// --- Remove patch ---
~n.unmap(\cvOsc1);
~n.set(\cvOsc1, 0);

// =============================================================================
// PDEF TEMPLATE  (all args + defaults)
// =============================================================================

Pdef(\modelD, Pbind(
    \instrument,   \modelD,
    \out,          ~t1.inbus.index,

    // --- pitch / gate ---
    \scale,        Scale.minor,
    \degree,       0,            // integer, scale degree
    \octave,       4,            // integer, 0..8
    \dur,          1,            // beats
    \legato,       0.8,          // 0..2+   (>1 = overlapping gates)
    \amp,          0.7,          // 0..1

    // --- glide ---
    \glide,        0.0,          // 0..10 sec  portamento time (semitone space)

    // --- osc 1 ---
    \osc1Wave,     2,            // 0..5   0=tri 1=inv-saw 2=saw 3=sq 4=wide 5=narrow
    \osc1Oct,      0,            // -3..+3  integer octave offset

    // --- osc 2 ---
    \osc2Wave,     2,            // 0..5
    \osc2Oct,      0,            // -3..+3
    \osc2Fine,     0.0,          // ±7 semitones   hardware fine-tune range

    // --- osc 3 (keyboard follower or free LFO) ---
    \osc3Wave,     0,            // 0..5   triangle (0) recommended for LFO
    \osc3Oct,      0,            // -3..+3  kbd mode only
    \osc3Fine,     0.0,          // ±7 semitones   kbd mode only
    \osc3KbdTrack, 1,            // 0/1    0=free LFO at osc3Freq, 1=follows keyboard
    \osc3Freq,     1.0,          // 0.1..50 Hz   LFO rate when osc3KbdTrack=0

    // --- oscillator mixer ---
    \osc1Lvl,      0.7,          // 0..1
    \osc2Lvl,      0.7,          // 0..1
    \osc3Lvl,      0.0,          // 0..1   add OSC3 as audio VCO
    \noiseLvl,     0.0,          // 0..1
    \noiseType,    0,            // 0/1    0=white, 1=pink

    // --- filter (MoogFF 24dB/oct LP only) ---
    \cutoff,       1000,         // 20..20000 Hz
    \emphasis,     0.2,          // 0..1   resonance; self-oscillates above ~0.88
    \kbdAmt,       0.5,          // 0..1   keyboard tracking (1=full 1:1 at 440Hz)
    \contourAmt,   0.5,          // 0..1   filter EG depth, up to +4 oct at peak
    \drive,        0.0,          // 0..1   pre-filter saturation (max ~×9)

    // --- filter contour (ADS) ---
    \fAtk,         0.001,        // 0.001..5 sec
    \fDcy,         0.3,          // 0.001..10 sec
    \fSus,         0.5,          // 0..1

    // --- amp contour (ADS) ---
    \aAtk,         0.001,        // 0.001..5 sec
    \aDcy,         0.3,          // 0.001..10 sec
    \aSus,         0.9,          // 0..1

    // --- decay switch (shared by both envelopes) ---
    \decayOn,      1,            // 0/1   1=release@decaytime  0=sustain-hold (60s rel)

    // --- mod wheel ---
    \modWheel,     0.0,          // 0..1   scales mod depth
    \modToOsc,     0,            // 0/1   1=mod → OSC1+2 pitch (±5 semitones max)
    \modToFilter,  0,            // 0/1   1=mod → filter cutoff (±2 octaves max)
    \modSource,    0,            // 0/1   0=OSC3, 1=white noise

    // --- cv / patch bay (use synth.map(\cv*, bus) as patch cable) ---
    \cvOsc1,       0.0,          // semitones  exponential pitch offset OSC1
    \cvOsc2,       0.0,          // semitones  exponential pitch offset OSC2
    \cvOsc3,       0.0,          // semitones  exponential pitch offset OSC3 (kbd mode)
    \cvFilt,       0.0,          // octaves    exponential cutoff offset
    \cvAmp,        1.0,          // 0..2       VCA gain from patch bay
));
