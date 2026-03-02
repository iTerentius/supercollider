(
SynthDef(\thingA, {|freq=110, amp=0.1, gate=1, mod1=1, mod2=1, out=0 |
  var sig = SinOsc.ar([freq, freq+2] * mod1);
  var sigMod = VarSaw.ar([freq*0.25,  freq*0.75] * LFPulse.ar(mod2/ mod1.sqrt), mod2);
  sig = sig * sigMod;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ), gate, doneAction:2);
	sig = sig * AmpComp.kr(freq);
  Out.ar(out, sig*0.1);
}).add;
)
// (
// ~thingA.free;
// ~thingA = Synth(\thingA,  [\out,  ~t5.inbus.index]);
// )
// (
// Pdef(\thingA, Pbind(
//   \instrument,  \thingA,  
//   \scale, Scale.minor,  
//   \octave,  Pseq([3], inf),   
//   \degree, Pseq([Pseq([0, 1,  4,  2], 1),  Rest()*4], inf), 
//   // \mod1,  Pseq([0.1,  8.0,  2.5], inf),  
//   // \mod2,  Pseq([0.5,  8.0,  3.5], inf),  
//   \mod1,  Pseg([1,  5.0,  3.5], [2, 4], \sin, inf),    
//   \mod2,  Pseg([5,  3.0,  0.5], [3, 4], \sin, inf),    
//   // \amp, 0.6,  
//   // \dur, Pseq([1/3!8,  1/2,  1/4!2].flat, inf),  
//   // \sustain, Pkey(\dur)/2,  
//   \delta, 1/(Pkey(\dur) * 2),  
//   \stretch,  Pseq([1/2/* ,  */1,  2], inf), 
//   \dur, 4,
//   \out, ~t2.inbus.index,  
// ));
// )
// Pdef(\thingA).play;
// Pdef(\thingA).stop;
// (
// Pdef(\thingA_ctl, Pbind(
//   \type,   \set,  
//   \id,  ~thingA,  
//   \args,  #[\amp, \mod1, \mod2], 
//   \dur, Pseq([1/8,  Pn(Rest(),  3)], inf),  
//   // \rest,  Pseq([0,  1], inf), 
//   // \amp,  Pseq([0.1, Pn(Rest(),  4)],  inf), 
//   \amp, 0.2,  
//   \mod1,  Pseg([0.1,  5.0,  0.5], [1, 1], \sin, inf),    
//   \mod2,  Pseg([0.5,  3.0,  0.5], [4, 1], \step, inf),    
//
//
// ));
// )
// Pdef(\thingA_ctl).play;
// Pdef(\thingA_ctl).stop;
// ~thingA.free;

// ~thingA_rev = ~ensurePostSent.(~t2, ~r1,  1);

// (
// Pdefn(\deg_def, 0);
// Pdefn(\deg_clutch,  Pclutch(Pxrand((0..7),  1), Pseq([0!3,  1].flat,  1))); 
// Pdefn(\deg_dup,  Pdup(Pwhite(1,  4, 1),  Pxrand((0..7),  1))); 
// Pdefn(\deg_sub,  Psubdivide(8,  Pxrand((0..7),  inf))); 
// // Pdefn(\deg_sync,  Psync(Pseq([0,  2,  4], 1), 1,  8), 1);
// Pdefn(\deg_seg, Pseg(Pseq([0, 2,  4,  7],  inf), [8, 16]/4,  \sin));
// Pdefn(\degs,  Pseq([
//   Pn(Pdefn(\deg_def),  4),  
//   Pn(Pdefn(\deg_clutch),  4),
//   Pn(Pdefn(\deg_dup),  4),
//   Pn(Pdefn(\deg_sub),  4),
//   Pn(Pdefn(\deg_seg),  4),
// ],  1));
//
// Pdefn(\dur_def, 1/2);
// Pdefn(\dur_clutch,  Pclutch(Prand([1/8,  1/4,  1/2], inf), Pseq([0!3,  1].flat,  inf)));  
// Pdefn(\dur_dup, Pdup(Pseq([8, 8, 2, 4,  2], 1), Pseq([1/16, 1/8, Rest(), 1/4,  1/2],  inf)));
// Pdefn(\durs,  Pseq([
//   Pn(Pdefn(\dur_def),  4),
//   Pn(Pdefn(\dur_clutch),  4),
//   Pn(Pdefn(\dur_dup),  4),
// ],  1));
//
// Pdef(\filter_pats,  Pbind(
//   \instrument,  \modelD,  
//   \out,  ~t3.inbus.index, 
//   \octave,  4,  
//   \degree, Pn(Pdefn(\degs), inf), 
//   \dur, Pn(Pdefn(\durs),  inf),
// ));
// )
//
// Pdef(\filter_pats).play;
// Pdef(\filter_pats).stop;
//
// Pbindf
