
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
  wet = GrainIn.ar(2, Impulse.kr(200), LFTri.kr(2), Mix.ar(sig), pan, ~g1envbuf); 
  wet * amp;
});
)
~r3_fx.free;
~r3.level_(1);
~t5_grain = ~t5.newPostSend(~r3, 1);
~t6_grain = ~t6.newPostSend(~r3, 1);
~t1_grain.free;
~r3_fx.set(\envbuf, ~g1envbuf);

// ~samps = ~sTree[\bass_drums];
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree
(
~samps = ~sTree[\bass_drums].values[0..3];
Pdef(\bash, ~pBuf.(
  Pbind(
  // \buf, Prand(~samps, inf),  
  \buf, Pseq(~samps,  inf),     
  \bufnum,  Pkey(\buf), 
  \delta,  Pkey(\dur)*2/Pxrand([4,  3,  2], inf), 
  \dur, Pbjorklund2(3,  8,  inf),  
  \amp, 0.3,  
  \out,  ~pbd1.inbus.index, 
  )
));
~lpBind.([1,  2], \bash);
)
Pdef(\bash).play;

~bash_rev = ~pbd1.newPostSend(~r1, 1);
~bash_rev.tryPerform(\free);
~bash_rev.level_(1);
~bash_del = ~pbd1.newPostSend(~r2,  1);

~bash_gin = ~pbd1.newPostSend(~r3,  1);
~bash_gin.level_(0.5);
~bash_t = ~pbd1.newPostSend(~r4,  1);
~bash_t.level_(1);
(
~r4_fx.free;
~r4_fx = ~r4.playfx({ |in|
  var sig = SinOsc.ar([220,  222], mul: SinOsc.ar([1,  2])  );
  sig = sig * In.ar(~r4.inbus.index, 2);
  sig = Decimator.ar(sig, LFTri.ar(0.5).range(100, 1900), LFPulse.kr(0.5,  0.5).range(8,  16)) - sin ;
  sig;
})
)
~r4_fx_rev = ~r4.newPostSend(~r1,  1);
~bash
ServerMeter(s);
~samps.asArray;

~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
(
~samps = ~sTree[\hats].values[1..4];
Pdef(\bashat, ~pBuf.(
  Pbind(
  // \buf, Prand(~samps, inf),  
  \buf, Pstep(Pseq(~samps,  inf), 2),     
  // \buf,  ~samps,  
  \bufnum,  Pkey(\buf), 
  // \delta,  Pkey(\dur)*2/Pxrand([  8,  4,  2], inf), 
  \dur, Pseq([1/3,  1/6!2,  Pn(Rest(),  3)].flat,  inf), 
  // \dur, Pbjorklund2(5,  8,  inf),  
  \amp, Pwhite(0.25,  0.2,  inf),  
  \out,  ~phh1.inbus.index, 
  );
));
~lpBind.([1,  3], \bashat);
)
Pdef(\bashat).play;

~bhat_del = ~phh1.newPostSend(~r2,  0.5);
~bhat_gin = ~phh1.newPostSend(~r4,  1);

