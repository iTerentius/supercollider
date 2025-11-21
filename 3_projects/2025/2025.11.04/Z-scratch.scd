
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

