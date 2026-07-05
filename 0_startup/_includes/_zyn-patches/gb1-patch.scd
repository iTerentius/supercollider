// gb1-patch.scd — MVP Zynthian-chain instrument: the \gb1 granular SynthDef
// (originally from 0_startup/_synthdefs/synths_common.scd, copied here rather
// than loading that whole file — it also defines a \cello SynthDef that uses
// Decimator, a UGen class not compiled into this box's SC build; since .load
// compiles a whole file as one unit, that one missing class aborted loading
// of every SynthDef in the file, \gb1 included. Self-contained here instead).
// One fixed sample buffer. Registers its continuous params into ~zynParamTable
// (see zyn-engine-bridge.scd) and defines ~zynPatchNoteOn for MIDI note-in.
//
// Sample choice is intentionally hardcoded for MVP — knob control only makes
// sense for continuous params (amp, rate, grain density, etc.), not discrete
// sample selection.

SynthDef(\gb1, { |out=0, amp=1, ampLag=0.02, gate=1,
    freq=220, trig_rate=8, grain_dur=0.05, buf, env, rate=1, pan_rate=10, trig_enable=1|
    var trig, pos, sig, ampEnv;
    amp = Lag.kr(amp, ampLag);
    trig = Impulse.kr(trig_rate) * trig_enable;
    pos = Line.kr(0, 1, BufDur.ir(buf));
    sig = GrainBuf.ar(
        numChannels: 2,
        trigger: trig,
        dur: grain_dur,
        sndbuf: buf,
        rate: rate.midiratio,
        pos: pos,
        interp: 2,
        pan: LFNoise1.kr(pan_rate),
        envbufnum: env
    );
    ampEnv = EnvGen.kr(Env.asr(0.01, 1, 0.25), gate, doneAction: 2);
    Out.ar(out, sig * amp * ampEnv);
}).add;

~zynBuf = Buffer.read(s, "/root/Music/supercollider/_samples/Cat-Water/Cat_Water-bounce-384.wav");

// Same envelope-buffer idiom already used for \gin1/\gin1r in synths_common.scd.
~zynGrainEnv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
~zynGrainEnvBuf = Buffer.sendCollection(s, ~zynGrainEnv.discretize, 1);

~zynPatchNoteOn = { |note, vel|
    Synth(\gb1, [
        \out, 0,
        \buf, ~zynBuf,
        \env, ~zynGrainEnvBuf,
        \rate, (note - 60),   // semitone offset; gb1 applies rate.midiratio
        \amp, vel / 127,
        \gate, 1
    ]);
};

// Defaults mirror gb1's own SynthDef defaults; \rate is driven by note, not a knob.
~zynRegisterParam.(\amp,       { |v| ~zynVoice !? { |s| s.set(\amp, v) } });
~zynRegisterParam.(\trig_rate, { |v| ~zynVoice !? { |s| s.set(\trig_rate, v) } });
~zynRegisterParam.(\grain_dur, { |v| ~zynVoice !? { |s| s.set(\grain_dur, v) } });
~zynRegisterParam.(\pan_rate,  { |v| ~zynVoice !? { |s| s.set(\pan_rate, v) } });

"[gb1-patch] loaded — gb1 active as the Zynthian-chain voice.".postln;
