(
SynthDef(\v3, {
  |out=0, amp=0.5,  freq=110, pan=0 |
  var sig, env;  
  env = EnvGen.kr(Env.perc(0.01,  2.8), doneAction:2); 
  sig = LFPulse.ar([freq, freq*1.01]) * LFSaw.ar(1 + freq);
  sig = DelayC.ar(sig.lag(0.005),  0.2,  0.2,  0.3, Decay.ar(Dust.ar(20, 0.5), 0.3, PinkNoise.ar * 0.8)) * sig; 
  sig = Pan2.ar(sig,  pan);
  Out.ar(out, sig * amp * env);
}).add;

)
