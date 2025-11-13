(
~g1env = Env([0, 1, 0], [0.05, 1.0], [0, -4]);
~g1envbuf = Buffer.sendCollection(s, ~g1env.discretize, 1);

Ndef(\gin1, { |in, pan=0.0, amp = 0.3, envbuf |
  var sig, env, wet;
  // use mouse x to control panning
  env = EnvGen.kr(
    Env([0, 1, 0], [1, 1], \sin, 1),
    gate,
    levelScale: amp,
    doneAction: Done.freeSelf);

  sig = In.ar(~r3.inbus.index, 2);
  // sig = in;
  wet = GrainIn.ar(2, Impulse.kr(300), LFPulse.ar(500), Mix.ar(sig), pan, ~g1envbuf) * env; 
  wet * amp;
});
)
Ndef(\gin1).clear;
(
~r3_fx.free;
~g1env = Env([0, 1, 0], [0.05, 1.0], [0, -4]);
~g1envbuf = Buffer.sendCollection(s, ~g1env.discretize, 1);
// ~r3_fx = ~r3.playfx(Ndef(\gin1));
~r3_fx = ~r3.playfx({ |in, gate = 1, pan=0.0, amp = 0.3, envbuf |
  var sig, env, wet;
  // use mouse x to control panning
  env = EnvGen.kr(
    Env([0, 1, 0], [1, 1], \sin, 1),
    gate,
    levelScale: amp,
    doneAction: Done.freeSelf);

  sig = In.ar(~r3.inbus.index, 2);
  wet = GrainIn.ar(2, Impulse.kr(200), LFTri.kr(5), Mix.ar(sig), pan, ~g1envbuf); 
  wet * amp;
});
)
~r3_fx.free;
~r3.level_(1);
~t5_grain = ~t5.newPostSend(~r3, 1);
~t6_grain = ~t6.newPostSend(~r3, 1);
~t1_grain.free;
~r3_fx.set(\envbuf, ~g1envbuf);
(
~g1env = Env([0, 1, 0], [0.05, 1.0], [0, -4]);
~g1envbuf = Buffer.sendCollection(s, ~g1env.discretize, 1);
)
(
Ndef(\st, {|freq=130, amp=0.4| LFSaw.ar([freq, freq+2], FSinOsc.ar(0.05, 3pi/2)) * amp * 0.2});
// Ndef(\st)[3] = \pset -> Pbind(\amp, Pseq([0.2, 0.2, 0.2, 0], inf), \octave, 4, \scale, Scale.minor, \t_gate, Pseq([0.25, 0.25, 0.25, Rest(1.25)],inf), \degree, Pseq([0, 2, 4, 0], inf), \dur, Pseq([0.25, 0.25, 0.25, Rest(1.25)],inf));
// Ndef(\st)[2] = \filter -> {|in, freq, t_gate=1, pan=0.0, amp=0.6, envbuf|
//   var sig, env=1, wet;
//   // use mouse x to control panning
//   env = EnvGen.kr(
//     // Env([0, 1, 0], [1, 1], \sin, 1),
//     Env.adsr(),
//     t_gate,
//     levelScale: amp,
//     doneAction: Done.freeSelf);
//
//   sig = In.ar(in);
//   wet = GrainIn.ar(2, Dust.ar(200), 1, sig, pan, ~g1envbuf) * env; 
//   wet;
// };
)
Ndef(\st)[2] = nil;
Ndef(\st).set(\wet2, 0.0);
Ndef(\st).clear;
~t6_st = ~t6.play(Ndef(\st));
~t6_st = ~t6.tryPerform(\free);
~t6_fx.free;
~t6_verb = ~t6.newPostSend(~r1, 1);
~r2.level_(1);
(
~t6_fx.free;
~g1env = Env([0, 1, 0], [0.05, 1.0], [0, -4]);
~g1envbuf = Buffer.sendCollection(s, ~g1env.discretize, 1);
~t6_fx = ~t6.playfx({ |in, gate = 1, pan=0.0, amp = 0.3, envbuf |
  var sig, env, wet;
  // use mouse x to control panning
  // env = EnvGen.kr(
  //   Env([0, 1, 0], [1, 1], \sin, 1),
  //   gate,
  //   levelScale: amp,
  //   doneAction: Done.freeSelf);

  sig = In.ar(~r3.inbus.index);
  wet = GrainIn.ar(2, Dust.kr(50), 1, sig, pan, ~g1envbuf); 
  wet
});
)

~t6_fx.free;

~test.play(~t1.inbus.index);
~test.stop;
(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\in_grain_test, { |out, gate = 1, amp = 1, envbuf|
    var pan, env;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);
    Out.ar(out,
        GrainIn.ar(2, Impulse.kr(32), 1, PinkNoise.ar * 0.05, pan, envbuf) * env)
}).add;

)

// use built-in env
x = Synth(\in_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 0);

~r1_fx = ~r1.playfx({ |in|
    var sig, wet;  // declare vars at top
    sig = In.ar(~r1.inbus.index, 2);
    wet = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.2);
    wet
});
(
// 2025-11-10 21:xx CST — GrainIn on ddwMixerChannel return, fixed

var envSig;

// make a nice grain envelope buffer (explicit size is safer)
envSig = Env([0, 1, 0], [0.5, 0.5], [8, -8]).asSignal(512);

~g1envbuf.tryPerform(\free);
~g1envbuf = Buffer.loadCollection(s, envSig);

// (Re)build the FX. Use the 'in' that playfx supplies. Keep it running (no doneAction).
~r3_fx.tryPerform(\free);
~r3_fx = ~r3.playfx({ |in, trigRate = 32, grainDur = 0.08, pan = 0.5, amp = 1|
    var mono, grains;

    // ddwMixerChannel hands you the incoming signal as 'in' (usually 2ch)
    mono = Mix(in);  // GrainIn expects mono source

    grains = GrainIn.ar(
        numChannels: 2,
        trigger: Impulse.kr(trigRate),
        dur: grainDur,
        in: mono,
        pan: pan,
        envbufnum: ~g1envbuf.bufnum
    );

    // return 2ch audio; no free-self envelope here so the FX stays alive
    grains * amp;
});
)

