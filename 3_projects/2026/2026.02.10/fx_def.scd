
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
  wet = GrainIn.ar(2, Impulse.kr(200), LFTri.kr(2), Mix.ar(sig), pan, ~g1envbuf); 
  wet * amp;
});

// FX Functions
~glitch = { |in|
  var sig = LFTri.ar([220,  222], mul: SinOsc.ar([1,  2, 3])  );
  sig = sig * In.ar(~r4.inbus.index, 2);
  sig = Decimator.ar(sig, LFTri.ar(0.5).range(30, 1900), LFPulse.kr(0.5,  0.5).range(8,  16)) + sig ;
  sig;
};

~exp1 = {|in|
  var mod1 = \mod1.kr(1);
  var amp = \amp.kr(0.5);
  var dur = \dur.kr(1);
  var sig = In.ar(~psd1.inbus.index,  2);
  var r = mod1 / dur;
  // var wet = VarSaw.ar(LFTri.ar(sig * mod1), 0.5,  LFPulse.kr(dur));
  var wet = SinOsc.ar(sig / r * LFSaw.ar(r),  LFTri.ar(mod1,  width:r)) ;
  sig * wet * amp * 8;
};

Pdef(\roll_fx_ctl,  Pbindef(\roll_fx_ctl_pbd, 
  \type,  \set, 
  \id,   Pfunc({~roll_fx1.nodeID }),  
  \args, #[\mod1, \amp, \dur],  
  \amp, 0.9,  
  // \mod1,  Pseq([1, 50], inf), 
  // \delta, 1/32, 
  \mod1,  Pseg([1,  50,  1], [Pkey(\dur) * 8, Pkey(\dur) * 2], \sin, inf), 
  // \dur, Pbjorklund2(5,  8,  inf)/4, 
  \dur, 1/8, 
));
)
