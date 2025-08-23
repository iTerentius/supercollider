(
SynthDef.new(\sineTest, {
	arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, offset, noise=0, ph=1, noiseHz=2;
	var sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) *amp;
	Out.ar(0, Pan2.ar(sig, pan, amp));
}).add
)

(
SynthDef.new(\simpSine, {
  arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, attack = 0.01, release = 1.0, offset = 0;
  var env, sig;
  env = EnvGen.kr(Env.circle([0.1, 0.25, 0.5], [0.15, 0.75]), 1);
  sig = Pulse.ar(freq + LFPulse.kr(2).exprange(freq, freq * env)) * env * amp;
  Out.ar(out, Pan2.ar(sig, pan, amp));
}).add
)

(
// 1) HARD MUTE — proves swapping instantly
SynthDef(\fx_mute_bus, { |inBus, outBus|
    var n = ~dirt.numChannels;
    In.ar(inBus, n);                   // read & ignore
    Out.ar(outBus, Silent.ar(n));      // pure silence
}).add;

// 2) CRUNCHY LOFI — brutal SR & bit-ish crush
SynthDef(\fx_crunch_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    var holdRate = 800;                      // lower = nastier
    var held = Latch.ar(sig, Impulse.ar(holdRate));
    var q = 12;                              // fewer steps = harsher
    var crushed = (held * q).round / q;
    Out.ar(outBus, crushed * 0.9);
}).add;

// 3) CHOP GATE — on/off at ~3 Hz
SynthDef(\fx_chop_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    var gate = LFPulse.kr(3, 0, 0.5).lag(0.01);
    Out.ar(outBus, sig * gate);
}).add;

// 4) PITCH UP OCTAVE — unmistakable
SynthDef(\fx_pitchUp_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    Out.ar(outBus, PitchShift.ar(sig, 0.2, 2.0, 0.0, 0.0));
}).add;

// 5) “TELEPHONE” BANDLIMIT — thin & nasally
SynthDef(\fx_phone_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    sig = BHiPass.ar(sig, 500, 0.8);
    sig = BLowPass.ar(sig, 2500, 0.8);
    Out.ar(outBus, sig * 1.2);
}).add;
)
s.sync;

(
// Safe installer: waits for server + SuperDirt
s.waitForBoot {
  fork {
    while { ~dirt.isNil } { 0.2.wait };

    // Read pre-FX bus (use _.outBus for post-FX)
    ~orbDryB = ~dirt.orbits.collect(_.dryBus);

    // Your custom FX reader
    SynthDef(\fx_chop_bus,{ |out=0, orb=0, n=0, mix=1, amp=1, sustain=2, p1=0.5, p2=0.5|
      var b    = ~orbDryB;
      var idx  = (orb != 0).if({ orb }, { n }).clip(0, b.size-1);  // allow # orb OR :n
      var src  = InFeedback.ar(Select.kr(idx, b), ~dirt.numChannels); // orbit audio
      var wet  = LFPulse.kr(3, 0, 0.2).lag(0.01) * src;
      var outSig = XFade2.ar(src, wet, (mix*2 - 1)); // 0=dry, 1=wet
      var env = EnvGen.kr(Env.linen(0.001, sustain, 0.2), doneAction: 2);
      Out.ar(out, outSig * amp * env);
    }).add;

    s.sync;
    ~dirt.soundLibrary.addSynth(\fx_chop_bus);   // makes s "orb_myfx" available
    "[\fx_chop_bus] ready".postln;
  };
};
)


