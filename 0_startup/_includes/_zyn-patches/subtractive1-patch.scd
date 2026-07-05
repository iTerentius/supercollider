// subtractive1-patch.scd — MVP Zynthian-chain instrument #2, replacing gb1
// (a GrainBuf/sample-based voice that turned out to be unreliable/inaudible
// even at heavily boosted gain — root cause not yet isolated, set aside for
// now). This is a plain oscillator + filter + envelope synth: no buffers, no
// grain triggering, nothing that can silently misbehave — meant to nail down
// whether the touchscreen-to-audible-sound pipeline itself is solid before
// returning to anything more complex.
//
// SynthDef is defined unconditionally at load time (safe to redefine on
// every SC boot); the actual ~zynPatchNoteOn/~zynRegisterParam setup only
// runs when this patch is selected, via ~zynPatches[\subtractive1] (see
// zyn-engine-bridge.scd's ~zynLoadPatch) — NOT at load time anymore, now
// that more than one patch can be loaded and switched between.

SynthDef(\scBasic, { |out=0, freq=440, amp=0.3, gate=1,
    cutoff=2000, res=0.3, attack=0.01, release=0.3|
    var sig, env;
    env = EnvGen.kr(Env.adsr(attack, 0.1, 0.7, release), gate, doneAction: 2);
    sig = (Saw.ar(freq) * 0.5) + (Pulse.ar(freq, 0.3) * 0.5);
    sig = RLPF.ar(sig, cutoff, res);
    sig = sig * amp * env ! 2;
    Out.ar(out, sig);
}).add;

~zynPatches[\subtractive1] = {
    // Reads ~zynCurrentParams (updated by ~zynRegisterParam on every knob/OSC
    // change) rather than the SynthDef's own hardcoded defaults — a synth only
    // exists between note-on and note-off, so a freshly created one has to be
    // told the last-set knob values itself; it doesn't inherit them from
    // whatever the previous (now-freed) synth had.
    ~zynPatchNoteOn = { |note, vel|
        Synth(\scBasic, [
            \out, 0,
            \freq, note.midicps,
            \amp, (vel / 127) * ~zynCurrentParams[\amp],
            \cutoff, ~zynCurrentParams[\cutoff],
            \res, ~zynCurrentParams[\res],
            \attack, ~zynCurrentParams[\attack],
            \release, ~zynCurrentParams[\release],
            \gate, 1
        ]);
    };

    // \amp here is a gain multiplier on top of MIDI velocity (default 1.0 =
    // velocity-only, matching prior behavior); every other param is applied
    // directly. Defaults mirror both the SynthDef's own defaults and zynconfig.yml.
    ~zynRegisterParam.(\amp,     { |v| ~zynVoice !? { |s| s.set(\amp, (~zynLastVel ? 127) / 127 * v) } }, 1.0);
    ~zynRegisterParam.(\cutoff,  { |v| ~zynVoice !? { |s| s.set(\cutoff, v) } }, 2000);
    ~zynRegisterParam.(\res,     { |v| ~zynVoice !? { |s| s.set(\res, v) } }, 0.3);
    ~zynRegisterParam.(\attack,  { |v| ~zynVoice !? { |s| s.set(\attack, v) } }, 0.01);
    ~zynRegisterParam.(\release, { |v| ~zynVoice !? { |s| s.set(\release, v) } }, 0.3);
};

"[subtractive1-patch] loaded — scBasic SynthDef ready, registered as \\subtractive1.".postln;
