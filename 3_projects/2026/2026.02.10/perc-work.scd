
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

Pdefn()
// ~samps = ~sTree[\bass_drums];
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree
(
~samps = ~sTree[\bass_drums].values[8..8];
Pdef(\bash, ~pBuf.(
  Pbind(
  // \buf, Prand(~samps, inf),  
  \buf, Pseq(~samps,  inf),     
  \bufnum,  Pkey(\buf), 
  \scale, Scale.minor,  
  // \delta,  Pkey(\dur)*2/Pxrand([4,  3,  2], inf), 
  \octave,  5,  
  \degree,  Pshuf([0,  4,  7,  \], inf), 
  \dur, Pbjorklund2(5,  8,  inf)/4,  
  \amp, 0.3,  
  \out,  ~pbd1.inbus.index, 
  )
));
~lpBind.([1,  2], \bash);
~apcAssignPad.(32,  \bash);
)
Pdef(\bash).play;
Pdef(\bash).stop;

~bash_rev = ~ensurePostSend.(~pbd1, ~r1, 1);
~bash_rev.tryPerform(\free);
~bash_rev.level_(1);
~bash_del = ~ensurePostSend.(~pbd1, ~r2,  1);
~bash_del.tryPerform(\free);

~bash_gin = ~ensurePostSend.(~pbd1, ~r3,  0.5);
~bash_gin.tryPerform(\free);
~bash_gin.level_(0.1);
~bash_t = ~ensurePostSend.(~pbd1, ~r4,  1);
~bash_t.tryPerform(\free);
~bash_t.level_(0.6);
(
~r4_fx.free;
~r4_fx = ~r4.playfx({ |in|
  var sig = LFTri.ar([220,  222], mul: SinOsc.ar([1,  2, 3])  );
  sig = sig * In.ar(~r4.inbus.index, 2);
  sig = Decimator.ar(sig, LFTri.ar(0.5).range(30, 1900), LFPulse.kr(0.5,  0.5).range(8,  16)) - sig ;
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
~samps = ~sTree[\hats].values[0..8];

Pdef(\bashat, 
  ~pBuf.(
    Pbind(
    // \buf, Prand(~samps, inf),  
    \buf, Pstep(Pseq(~samps,  inf), 2),     
    // \buf,  ~samps,  
    \bufnum,  Pkey(\buf), 
    // \delta,  Pkey(\dur)*2/Pxrand([  8,  4,  2], inf), 
    // \dur, Pseq([1/3,  1/6!2,  Pn(Rest(),  1)].flat,  inf), 
    \rate,  1.25,  
    \dur, Pbjorklund2(5,  8,  inf),  
    \amp, Pwhite(0.45,  0.2,  inf),  
    \out,  ~phh1.inbus.index, 
  );
));
~lpBind.([1,  3], \bashat);
)
Pdef(\bashat).play;
Pdef(\bashat).stop;

~bhat_del = ~ensurePostSend.(~phh1,  ~r2,  1);
~bhat_gin = ~ensurePostSend.(~phh1,  ~r4,  1);
~bhat_gin.tryPerform(\free);
~lumiPlay.(\bass8, out: ~busOf.(~t3), args: [\amp,  0.1]);
~bass8_t = ~ensurePostSend.(~t3,  ~r4,  1);
~lumiPlay.(\pBs, out: ~busOf.(~t3), args: [\bufnum, ~sTree[\bass_drums].values[4],  \amp, 0.5]);
~lumiStop.();
