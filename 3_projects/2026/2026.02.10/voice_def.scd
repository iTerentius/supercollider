(
SynthDef(\thingA, {|freq=110, amp=0.1, gate=1, mod1=1, mod2=1, out=0 |
  var sig = SinOsc.ar([freq, freq+2] * mod1);
  var sigMod = VarSaw.ar([freq*0.25,  freq*0.75] * mod2);
  sig = sig * sigMod;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ), gate, doneAction:2);
	sig = sig * AmpComp.kr(freq);
  Out.ar(out, sig*0.1);
}).add;

)

(
~thingA.free;
~thingA = Synth(\thingA,  [\out,  ~t5.inbus.index]);
)
(
Pdef(\thingA, Pbind(
  \instrument,  \thingA,  
  \scale, Scale.minor,  
  \degree,  Ppatlace([
    Pseq([0, 1,  4, \,  \], inf), 
    Prand((0..7), inf),   
  ],  inf), 
  \mod1,  Pseq([0.1,  5.0,  0.5], inf),  
  \mod2,  Pseq([0.5,  3.0,  0.5], inf),  
  \amp, 0.6,  
  // \dur, Pseq([1/3!8,  1/2,  1/4!2].flat, inf),  
  \dur, 1/16,
  \out, ~t2.inbus.index,  
));
)
Pdef(\thingA).play;
Pdef(\thingA).stop;
(
Pdef(\thingA_ctl, Pbind(
  \type,   \set,  
  \id,  ~thingA,  
  \args,  #[\amp, \mod1, \mod2], 
  \dur, Pseq([1/8,  Pn(Rest(),  3)], inf),  
  // \rest,  Pseq([0,  1], inf), 
  // \amp,  Pseq([0.1, Pn(Rest(),  4)],  inf), 
  \amp, 0.2,  
  \mod1,  Pseg([0.1,  5.0,  0.5], [1, 1], \sin, inf),    
  \mod2,  Pseg([0.5,  3.0,  0.5], [4, 1], \step, inf),    


));
)
Pdef(\thingA_ctl).play;
Pdef(\thingA_ctl).stop;
~thingA.free;

// ~thingA_rev = ~ensurePostSent.(~t2, ~r1,  1);
