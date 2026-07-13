// bass8-patch.scd — dedicated bass instrument for the "SB" (SuperCollider
// Bass) Zynthian chain, running in its own sclang/scsynth process (see
// startup.scd's SC_ZYN_INSTANCE == "bass" branch) so it can sound
// simultaneously with the slicer/subtractive1 chain in the main "SC" process
// instead of sharing one ~zynActivePatch with them.
//
// SynthDef copied from the shared _synthdefs/synths_common.scd \bass8 rather
// than loading that file directly — same reasoning as every other zyn-patch
// (see ref_zynthian_sc_engine.scd's "shared synthdefs" gotcha: a single
// missing UGen class anywhere in a shared file silently aborts every
// SynthDef in it, not just the one that needs it).
//
// Gate-based sustained voice (like subtractive1), not one-shot (like
// slicer): \bass8 already has a `gate` arg feeding an EnvGen with
// doneAction: 2, so it behaves like a normal held note.

SynthDef(\bass8, {
	arg out = 0, amp = 0.1, gate = 1, pan = 0, freq = 200;
	var sig;
	var osc = Array.newClear(6);
	var env = Array.newClear(6);

	env[0] = EnvGen.kr(Env([0,1,0.051,0],[0.001,0.01,0.8], [4,-8]), 1);
	env[1] = EnvGen.kr(Env([0,1,0.051,0],[0.005,0.5,1.5], [0,-8], releaseNode:2), 1);
	env[2] = EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.2], [0,0,-4], releaseNode:2), gate);
	env[3] = EnvGen.kr(Env([0,1,0],[0.002,2.8], [0,-4]), 1);
	env[4] = EnvGen.kr(Env([0,1,1,0],[0.001,0.1,0.8], [4,0,-4], releaseNode:2), gate);
	env[5] = EnvGen.kr(Env([0,1,0],[0.001,3.0], [0,-4]), 1);

	freq = (freq / 4) * ((0..1)/1 - 0.5 * 0.0007 + 1);

	osc[0] = SinOsc.ar(freq * 11 + 0) * env[0];
	osc[1] = SinOsc.ar(freq * 6 * ( osc[0] * 2.5 + 1 )) * env[1];
	osc[2] = SinOsc.ar(freq * 2 * 1 + 0) * env[2];
	osc[3] = SinOsc.ar(freq * 1 * ( osc[2] * 2.5 + 1 ) + 0) * env[3];
	osc[4] = SinOsc.ar(freq * 1 * ( osc[1] * 2.5 + 1 ) * (osc[3] * 2.5 + 1)) * env[4];
	osc[5] = SinOsc.ar(freq * 2) * env[5];

	sig = osc * DC.ar([0.0, 0.0, 0.0,  0.0, 0.5, 0.5]);
	sig = sig * 0.5;
	sig = sig.flop.sum;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ), gate, doneAction:2);
	sig = sig * AmpComp.kr(freq);
	sig = sig.sum;
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~zynPatches[\bass8] = {
    // Reads ~zynCurrentParams (updated by ~zynRegisterParam on every knob/OSC
    // change) rather than the SynthDef's own hardcoded defaults — same
    // reasoning as subtractive1-patch.scd: a freshly created Synth doesn't
    // inherit whatever the previous (now-freed) one had its knobs set to.
    ~zynPatchNoteOn = { |note, vel|
        Synth(\bass8, [
            \out, 0,
            \freq, note.midicps,
            \amp, (vel / 127) * ~zynCurrentParams[\amp],
            \pan, ~zynCurrentParams[\pan],
            \gate, 1
        ]).register(true);
    };

    // amp/pan are \bass8's only true "knob" args beyond freq/gate (which
    // come from MIDI note-on itself) — applied to every currently-held voice
    // (~zynSetAllVoices, zyn-engine-bridge.scd), not just whichever note was
    // struck last.
    ~zynRegisterParam.(\amp, { |v| ~zynSetAllVoices.(\amp, (~zynLastVel ? 127) / 127 * v) }, 0.1);
    ~zynRegisterParam.(\pan, { |v| ~zynSetAllVoices.(\pan, v) }, 0.0);
};

"[bass8-patch] loaded — bass8 SynthDef ready, registered as \\bass8.".postln;
