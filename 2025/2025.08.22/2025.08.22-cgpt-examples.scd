
// sources
Ndef(\kick, { Decay2.ar(Impulse.ar(2), 0.005, 0.2) * SinOsc.ar(45) * 0.8 ! 2 }).quant_(1).play(out:6);
Ndef(\pad,  { Saw.ar([100,101]) * 0.15 }).play;

// ducking stage
Ndef(\duck, {
    var pad  = Ndef.ar(\pad);
    var amp  = Amplitude.kr(Mix(Ndef.ar(\kick)), 0.01, 0.1).lag(0.03);
    var gain = (1 - (amp * 1.6)).clip(0.2, 1); // floor at -14 dB
    pad * gain
}).play;

// one trigger per *beat* (TempoClock.default is driven by Tidal cps)
Ndef(\beat, { Impulse.kr(TempoClock.default.tempo) }).quant_(1);

// 4-on-the-floor kick: fire on every beat
Ndef(\kick).quant = 1;

(
Ndef(\kick, {
    var trig = Ndef.kr(\beat);          // 1 trig per beat
    var env  = Decay2.kr(trig, 0.001, 0.12);
    // simple punchy synth kick
    var sweep = EnvGen.kr(Env([1, 0], [0.06], curve: -8), trig);
    var sig   = SinOsc.ar(48 + 120*sweep) * env * 0.9
              + BPF.ar(WhiteNoise.ar(0.15), 1200, 0.5) * env * 0.25;
    (sig ! 2) * 0.7
}).play(quant: 1);

)

// if you want quarter‑notes explicitly (same as above):
// Ndef(\kick, { ... trig = Ndef.kr(\beat) ... });

// if you want 8ths or 16ths instead:
Ndef(\beat8,  { Impulse.kr(TempoClock.default.tempo * 2) }).quant_(1);
Ndef(\beat16, { Impulse.kr(TempoClock.default.tempo * 4) }).quant_(1);
// then use trig = Ndef.kr(\beat8) or \beat16 in the kick if desired

