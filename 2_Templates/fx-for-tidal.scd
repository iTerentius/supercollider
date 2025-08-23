(
// Safe installer: waits for server + SuperDirt
s.waitForBoot {
  fork {
    while { ~dirt.isNil } { 0.2.wait };

    // Read pre-FX bus (use _.outBus for post-FX)
    ~orbDryB = ~dirt.orbits.collect(_.dryBus);

    // Your custom FX reader
    SynthDef(\orb_myfx, { |out=0, orb=0, n=0, mix=1, amp=1, sustain=2, p1=0.5, p2=0.5|
      var b    = ~orbDryB;
      var idx  = (orb != 0).if({ orb }, { n }).clip(0, b.size-1);  // allow # orb OR :n
      var src  = InFeedback.ar(Select.kr(idx, b), ~dirt.numChannels); // orbit audio
      var wet  = /* --- your processing here, using src and p1/p2 --- */ src;
      var outSig = XFade2.ar(src, wet, (mix*2 - 1)); // 0=dry, 1=wet
      var env = EnvGen.kr(Env.linen(0.001, sustain, 0.2), doneAction: 2);
      Out.ar(out, outSig * amp * env);
    }).add;

    s.sync;
    ~dirt.soundLibrary.addSynth(\orb_myfx);   // makes s "orb_myfx" available
    "[orb_myfx] ready".postln;
  };
};
)

