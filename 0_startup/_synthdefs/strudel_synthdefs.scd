(
SynthDef(\m1, {
  |out, sustain=1, note=60, pan, accelerate, speed=1, begin=0, end=1|
  var freq = 440 * 2.pow((note - 69) / 12);
  var env = EnvGen.ar(Env.linen(0.01, 0.98, 0.01, 1, -3), timeScale: sustain, doneAction: 2);
  var sound = SinOsc.ar(freq);
  Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);
(
SynthDef(\st_fm3, {
	// \vel, Pstutter(6, Pseq([ 0.2, 1, 1.2 ].scramble, inf)),
	// \f0ratio, Pseq( (3..5).scramble, inf ),
	// \f1ratio, Pseq( (1..3).scramble, inf ),
	// \f2ratio, Pseq( (3..5) / (1..3).scramble, inf ),
	// \modInd0, Pfunc{rrand(0,2.0)},
	// \modInd1, Pfunc{rrand(0,1.0)},
	// \modInd2, Pfunc{rrand(0,0.5)},
  | out, sustain=1, note=60, gate=1, vel=0.7, pan, accelerate, speed=1, begin=0, end=1, 
  amp=1, att=0.015,  rel=4.02, curve=4, f0ratio=2,  f1ratio=2,  f2ratio=4, 
  modInd0=1,  modInd1=1.4,  modInd2=2.5,  
  midEQratio=5, rq=0.5, boostAtten=32, pgain=0.1,  onepole=0.8 |

  var f,ff0,ff1,ff2,a,b,c,d,e, modInd,t, aa;
  var osc,signal;

  curve = curve.neg;
  boostAtten = boostAtten.neg;

  f = 440 * 2.pow((note - 69) / 12);  // f = f.clip(20,900);

  e = EnvGen.kr(Env.perc(
    Rand(0.8,1.2)* att,  
    rel, 
    curve: curve
  ),
  gate: gate,
  doneAction:2
) * 2;

e = e * PinkNoise.ar(1!2).range( 0.1, 1 ).lag(0.01);

ff0= f * f0ratio 
+ { Rand(-3,3) }.dup 
;
ff1= f * f1ratio 
+ { Rand(-3,3) }.dup 
;
ff2= f * f2ratio 
+ { Rand(-3,3) }.dup 
;	

b = SinOsc.ar(ff0) * f * modInd0 * e.pow(0.8);
c = SinOsc.ar(ff1) * f * modInd1 * e.pow(1.4);
d = SinOsc.ar(ff2) * f * modInd2 * e.pow(2.5);
a = SinOsc.ar(
  f 
  + LFTri.ar(e.pow(0.5) * LFNoise1.kr(0.3).range(1,5), Rand(0.0,2pi), mul: e.pow(0.2) *  f * 0.005)
  + [b,c,d].sum 
  + WhiteNoise.ar(f/8!2).lag(0.001) 
);

a = HPF.ar(a*e.pow(0.5), f);
a = MidEQ.ar(a, f*midEQratio, rq:e.pow(0.5)* rq + 0.1, db: boostAtten);

osc = a * pgain * amp;
osc = OnePole.ar(osc, onepole);
Out.ar(out, DirtPan.ar(osc, ~dirt.numChannels, pan, e));
}).add;
);
