/*
Behringer Neutron — SuperCollider Model
=======================================

Semi-modular analog synth (2x CEM3340 VCOs, 2-pole SVF, 2x ADSR,
audio-rate LFO, overdrive, BBD delay).

FILTER NOTE:
  Uses RLPF/RHPF (per-sample IIR internally in C++) for the base filter
  response. Self-oscillation is modeled by crossfading in a SinOsc at
  fCutoff as res approaches 1 — this is what the physical filter does
  (produces a pure sine at fc when damping → 0). LocalIn/LocalOut is
  used only for the delay feedback loop.

PATCHING:
  The cv* args accept static values or mapped kr buses — equivalent
  to patch cables on the hardware. See patching examples below.

  Synth(\neutron, [...])
  ~syn.map(\cvFilt, someBus)   // patch cable
  ~syn.unmap(\cvFilt)          // remove cable
*/

(
SynthDef(\neutron, {

    // ── PITCH / GATE ─────────────────────────────────────────────────────────
    arg freq = 440, gate = 1, amp = 1, out = 0,

    // ── OSC 1 (CEM3340: saw + pulse) ─────────────────────────────────────────
    osc1Blend = 0.0,    // 0 = saw, 1 = pulse
    osc1PW    = 0.5,    // pulse width
    osc1Oct   = 0,      // octave offset (integer, ±3)

    // ── OSC 2 (CEM3340: saw + pulse + tri) ───────────────────────────────────
    osc2Blend = 0.0,    // 0 = saw, 0.5 = pulse, 1 = tri
    osc2PW    = 0.5,
    osc2Oct   = 0,
    osc2Semi  = 0.0,    // coarse detune in semitones
    osc2Fine  = 0.0,    // fine detune in cents
    osc2Track = 1,      // 1 = tracks keyboard, 0 = free-running
    sync      = 0,      // hard sync OSC2 → OSC1 (0/1)

    // ── OSCILLATOR MIXER ─────────────────────────────────────────────────────
    osc1Lvl  = 0.7,
    osc2Lvl  = 0.7,
    subLvl   = 0.0,     // square wave, -1 oct from OSC1
    noiseLvl = 0.0,

    // ── LFO (audio-rate capable up to ~10kHz) ────────────────────────────────
    lfoRate   = 1.0,
    lfoShape  = 0,      // 0=sin 1=tri 2=saw 3=ramp 4=square
    lfoToOsc1 = 0.0,    // ±1 → ±5% pitch mod
    lfoToOsc2 = 0.0,
    lfoToPW1  = 0.0,    // ±1 → ±0.4 pw sweep
    lfoToPW2  = 0.0,
    lfoToFilt = 0.0,    // ±1 → ±24 semitones of cutoff

    // ── FILTER (2-pole SVF, self-oscillating) ────────────────────────────────
    cutoff     = 2000,
    res        = 0.2,   // 0..1; self-oscillates approaching 1
    filterMode = 0,     // 0=LP 1=BP 2=HP (fractional crossfade works)
    keyTrack   = 0.0,   // 0..1 keyboard tracking
    env1Amt    = 0.5,   // ENV1 depth, signed -1..1

    // ── ENV 1 (filter) ───────────────────────────────────────────────────────
    atk1 = 0.01, dcy1 = 0.3, sus1 = 0.5, rel1 = 0.3,

    // ── ENV 2 (amp/VCA) ──────────────────────────────────────────────────────
    atk2 = 0.01, dcy2 = 0.1, sus2 = 0.9, rel2 = 0.3,

    // ── OVERDRIVE ────────────────────────────────────────────────────────────
    drive      = 0.0,   // 0..1
    driveTone  = 1.0,   // 0..1 tone LP rolloff
    driveLevel = 0.5,

    // ── BBD DELAY ────────────────────────────────────────────────────────────
    delTime = 0.25,
    delFB   = 0.3,
    delMix  = 0.0,

    // ── PATCH BAY CV INPUTS ───────────────────────────────────────────────────
    // Static values by default; use synth.map(\cv*, someBus) as patch cables.
    cvOsc1 = 0.0,   // semitones added to OSC1 pitch
    cvOsc2 = 0.0,   // semitones added to OSC2 pitch
    cvFilt = 0.0,   // semitones offset to filter cutoff (exponential)
    cvPW1  = 0.0,   // direct offset to PW1 (±0..1)
    cvPW2  = 0.0,
    cvAmp  = 1.0;   // VCA CV (open VCA from patch bay)

    // ════════════════════════════════════════════════════════════════════════
    //  SIGNAL PATH
    // ════════════════════════════════════════════════════════════════════════

    // ── DELAY FEEDBACK BUS ───────────────────────────────────────────────────
    var delFBsig = LocalIn.ar(1);

    // ── LFO ──────────────────────────────────────────────────────────────────
    var lfo = Select.ar(lfoShape.clip(0, 4), [
        SinOsc.ar(lfoRate),
        LFTri.ar(lfoRate),
        LFSaw.ar(lfoRate),
        LFSaw.ar(lfoRate).neg,                   // ramp / reverse saw
        LFPulse.ar(lfoRate, 0, 0.5) * 2 - 1     // bipolar square
    ]);

    // ── OSC 1 ────────────────────────────────────────────────────────────────
    var osc1Freq = freq * (2 ** osc1Oct)
        * (cvOsc1 / 12 + 1)
        * (lfoToOsc1 * lfo * 0.05 + 1);
    var pw1  = (osc1PW + (lfoToPW1 * lfo * 0.4) + cvPW1).clip(0.01, 0.99);
    var osc1 = XFade2.ar(
        LFSaw.ar(osc1Freq),                      // bipolar saw [-1, 1]
        LFPulse.ar(osc1Freq, 0, pw1) * 2 - 1,
        osc1Blend * 2 - 1
    );
    var sub = LFPulse.ar(osc1Freq * 0.5, 0, 0.5) * 2 - 1;  // -1 oct square

    // ── OSC 2 ────────────────────────────────────────────────────────────────
    var osc2Freq = (freq * osc2Track
        * (2 ** osc2Oct)
        * (osc2Semi / 12 + 1)
        * (osc2Fine / 1200 + 1)
        * (cvOsc2 / 12 + 1)
        * (lfoToOsc2 * lfo * 0.05 + 1)).max(0.5);
    var pw2     = (osc2PW + (lfoToPW2 * lfo * 0.4) + cvPW2).clip(0.01, 0.99);
    var osc2Saw = SelectX.ar(sync, [
        LFSaw.ar(osc2Freq),
        SyncSaw.ar(osc1Freq, osc2Freq) * 2 - 1  // hard sync approximation
    ]);
    var osc2Pul = LFPulse.ar(osc2Freq, 0, pw2) * 2 - 1;
    var osc2Tri = LFTri.ar(osc2Freq);
    // three-way blend: 0=saw → 0.5=pulse → 1=tri
    var osc2    = SelectX.ar(osc2Blend * 2, [osc2Saw, osc2Pul, osc2Tri]);

    // ── OSCILLATOR MIXER ─────────────────────────────────────────────────────
    var mixSig = (
        (osc1 * osc1Lvl) +
        (osc2 * osc2Lvl) +
        (sub  * subLvl)  +
        (WhiteNoise.ar * noiseLvl)
    ) * 0.25;

    // ── ENV 1 (filter) ───────────────────────────────────────────────────────
    var env1 = EnvGen.kr(Env.adsr(atk1, dcy1, sus1, rel1), gate);

    // ── FILTER (2-pole resonant + self-oscillation) ───────────────────────────
    //
    //   RLPF/RHPF compute feedback per-sample in C++ — no block-delay issue.
    //   Self-oscillation: above res ≈ 0.88, a SinOsc at fCutoff crossfades in.
    //   This models the physical behaviour: at zero damping, the filter rings
    //   as a pure sine at fc with no input required.
    //
    var ktMult  = freq / 440 * keyTrack + (1 - keyTrack);
    var envMult = (env1 * env1Amt * 36).midiratio;   // up to ±36 semitones
    var lfoMult = (lfoToFilt * lfo * 24).midiratio;  // ±24 semitones
    var cvMult  = cvFilt.midiratio;
    var fCutoff = (cutoff * ktMult * envMult * lfoMult * cvMult).clip(20, 20000);
    var rq      = res.linexp(0, 1, 1.0, 0.003);     // rq: open → razor-thin resonance
    var fLP     = RLPF.ar(mixSig, fCutoff, rq);
    var fHP     = RHPF.ar(mixSig, fCutoff, rq);
    var fBP     = Resonz.ar(mixSig, fCutoff, rq);
    var fRaw    = SelectX.ar(filterMode, [fLP, fBP, fHP]);
    // Self-oscillation crossfade: SinOsc blends in as res crosses 0.88 → 1.0
    var soAmt   = (res - 0.88).max(0) / 0.12;
    var filtered = (fRaw + (SinOsc.ar(fCutoff) * soAmt * 0.5)).softclip;

    // ── OVERDRIVE ────────────────────────────────────────────────────────────
    var drivenRaw  = (filtered * (1 + drive * 20)).softclip;
    var drivenTone = LPF.ar(drivenRaw, driveTone.linexp(0, 1, 500, 12000)) * driveLevel;
    var afterOD    = XFade2.ar(filtered, drivenTone, drive * 2 - 1);

    // ── ENV 2 (VCA) ──────────────────────────────────────────────────────────
    var env2   = EnvGen.kr(Env.adsr(atk2, dcy2, sus2, rel2), gate, doneAction: 2);
    var vcaOut = afterOD * env2 * amp * cvAmp;

    // ── BBD DELAY ────────────────────────────────────────────────────────────
    var dline = DelayL.ar(vcaOut + (delFBsig * delFB), 2.0, delTime.clip(0.001, 2.0));
    var final = XFade2.ar(vcaOut, dline, delMix * 2 - 1);

    // ── WRITE DELAY FEEDBACK (statements last, after all var declarations) ────
    LocalOut.ar(dline);
    Out.ar(out, Pan2.ar(final * 0.7, 0));
}).add;
)

/*
═══════════════════════════════════════════════════════════════════════════════
  PATCHING — utility synths + patch cable idiom
═══════════════════════════════════════════════════════════════════════════════

  synth.map(\cvFilt, someBus)   → patch cable IN
  synth.unmap(\cvFilt)          → remove cable
  synth.set(\cvFilt, 0)         → reset to default


  // ── Utility module SynthDefs ─────────────────────────────────────────────

  SynthDef(\att,  { |in=0, amt=0.5, out| Out.kr(out, In.kr(in) * amt) }).add;
  SynthDef(\inv,  { |in=0, out|          Out.kr(out, In.kr(in).neg) }).add;
  SynthDef(\slew, { |in=0, up=0.05, dn=0.05, out|
      Out.kr(out, VarLag.kr(In.kr(in), up, dn)) }).add;
  SynthDef(\sh,   { |in=0, trig=0, out|
      Out.kr(out, Latch.kr(In.kr(in), In.kr(trig))) }).add;
  SynthDef(\neutronLFO, { |rate=1, shape=0, out|
      var lfo = Select.ar(shape.clip(0,4), [
          SinOsc.ar(rate), LFTri.ar(rate), LFSaw.ar(rate),
          LFSaw.ar(rate).neg, LFPulse.ar(rate,0,0.5)*2-1 ]);
      Out.kr(out, A2K.kr(lfo)) }).add;


  // ── Example patches ──────────────────────────────────────────────────────

  ~lfoOut = Bus.control(s, 1);
  ~attOut = Bus.control(s, 1);
  ~invOut = Bus.control(s, 1);

  ~lfo = Synth(\neutronLFO, [\rate, 0.5, \shape, 0, \out, ~lfoOut]);
  ~syn = Synth(\neutron, [\cutoff, 800, \res, 0.7]);

  // LFO → filter cutoff
  ~syn.map(\cvFilt, ~lfoOut);

  // LFO → attenuator → filter (attenuated cable)
  ~att = Synth(\att, [\in, ~lfoOut, \amt, 0.3, \out, ~attOut]);
  ~syn.map(\cvFilt, ~attOut);

  // Classic PWM: LFO → PW1, INVERT → PW2 (opposite sweep on both OSCs)
  ~inv = Synth(\inv, [\in, ~lfoOut, \out, ~invOut]);
  ~syn.map(\cvPW1, ~lfoOut);
  ~syn.map(\cvPW2, ~invOut);

  // Self-oscillation demo — sweep the resonant tone with the filter:
  ~syn = Synth(\neutron, [\res, 0.99, \osc1Lvl, 0, \osc2Lvl, 0,
      \subLvl, 0, \noiseLvl, 0.1, \cutoff, 300]);
  ~syn.map(\cvFilt, ~lfoOut);   // LFO sweeps the self-oscillation pitch
*/
