(
SynthDef(\sKik, ~ufn[\808][\kik]).add;
SynthDef(\sHh, ~ufn[\808][\hh]).add;
)
(
Ndef.dictFor(s).clock = ~link;
Ndef.dictFor(s).quant = 1;
Ndef.dictFor(s).fadeTime = 3;
)
// Example:
Ndef(\pad, { SinOsc.ar([100, 441]) * 0.2 });
Ndef(\pad).fadeTime = 2;

Ndef(\pad).play;
Ndef(\pad).stop;
Ndef(\pad).clear;

};

Ndef(\ins3)[0] = {|amp = 1| Ndef.ar(\v1) * amp};
)
Ndef(\v1).map(\bits, { Ndef.kr(\lfo).range(4,  12) });
Ndef(\v1).map(\freeze, Ndef(\freezeLFO));
Ndef(\v1).set(\smear, 0);
Ndef(\v1).set(\freezeSmear, 0);
Ndef(\v1).map(\wet4,  Ndef(\freezeLFO));
Ndef(\v1).map(\amp,  { 1.5 * Ndef(\freezeLFO) });
Ndef(\v1)[2] = nil;
Ndef(\v1).free;
Ndef(\v1).clear;

Tdef(\tempo).play;
Tdef(\tempo).stop;

Ndef(\freezeLFO, { LFPulse.kr(1) }).play;
~sTree[\bass_drums];

(
~loadSamps.("~/Music/supercollider/_samples/Ghosthack/");
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
// ~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
)
(
Ndef(\kit)[0] =  Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\impacts].values[0..8], inf),   
  \amp,  0.4, 
  \dur,   4,
  \stretch, Pseq([1/4!3,   2.25].flat,   inf), 
);
Ndef(\kit)[1] = Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\hats].values(1,  3), inf),   
  \degree,  Pseq([0], inf),
  \amp,  0.4, 
  \dur,   Pseq([1/2].flat, inf), 
  // \stretch, Pseg([1,   1/5],[8],  \sin,   inf), 
);
Ndef(\kit)[3] =  Pbind(
  \instrument,  \pBs,  
  // \rate,  Pseq([1,  2,  4], inf), 
  \bufnum,  Pseq(~sTree[\bass_drums].values[0..4], inf),   
  \amp,  0.9, 
  \dur,   1/2,
  \stretch, Pseq([1/4!3,   3.25].flat,   inf), 
);
// Ndef(\kit)[2] = \filter ->  {|in| ~fxg[\bitcrush].(in)};
Ndef(\kit)[7] = \filter -> {|in, delayTime=0.25, size=0.2, damp=0.1,  diff=0.5,  feedback=0.9, modDepth=0.5, modFreq=2.0 | Greyhole.ar(in, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
Ndef(\ins2)[0] = { |amp=1| Ndef.ar(\kit, 2) * amp };
~apcBindParam.(\b0_ds1_k1, { |x| Ndef(\kit).set(\wet7,  x)});
~apcBindParam.(\b0_ds1_k2, { |x| Ndef(\kit).set(\wet2,  x)});
)
Ndef(\lfo, {LFPulse.ar(1.5) + SinOsc.ar(1)});

Ndef(\kit).set(\size,  0.8, \damp,  0.1,  \diff,  0.5,  \modDepth,  0.5);
Ndef(\kit).map(\modFreq,  { 1/ Ndef(\lfo,  1).max(0.1) });
Ndef(\kit).map(\size,  Ndef(\lfo));
Ndef(\kit).map(\diff,  Ndef(\lfo));

// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
Ndef(\kit).set(\rate, 1); 
Ndef(\kit).set(\delayTime, 0.25);
Ndef(\kit)[2] = nil;
Ndef(\kit).set(\wet2, 0.8);
Ndef(\kit).set(\wet7, 0.0);
Ndef(\kit).set(\bits,  6,  \mix, 1);
(
Ndef(\fxsBitcrush)[0] = { |brate=44100, bits=6, mix=1, mute=0, amp=1|
    var sig = Ndef.ar(\s1_sum, 2);   // .ar, not Ndef(\s1_sum, 2) — that form sets its source to a literal scalar
    ~fxg[\bitcrush].(sig, brate, bits, mix, mute, amp);
};
Ndef(\fxsBitcrush)[1] = \pset -> Pbind(\dur,  1/16, \brate,  Pseg([1000, 10000], [32], \lin, inf));
~fxAddFX.(\fxsBitcrush);
)
Ndef(\fxsBitcrush).set(\brate, 1400, \bits, 8, \mix, 1);
~fxSetSend.(\ins1,  \s1,  0.5);
~fxSetSend.(\ins2,  \s1,  1.0);
~fxSetSend.(\ins3,  \s1,  0.9);
Ndef(\brate,   { SinOsc.ar(1) });

Ndef(\kit).free;
Ndef(\kit).clear;
Ndef.all.clear;

Ndef(\kit,  { SinOsc.ar([110,  111]) * 0.2 });
(
Pdef(\kit, Pbind(
  \instrument, ~ufn[\808][\kik],
  \octave, 2,
  \degree, 3,
  \dur, 1/2,
)).play;
)
Pdef(\kit).stop;
(
Ndef(\kit)[0] = Pbind(
  \instrument, \sKik,
  \octave, 2,
  \degree, 3,
  \rel, Pseq([0.5!3, 1.5].flat,inf),
  \dur, 1,
  \stretch, Pseq([1, 1/3], inf),
);
Ndef(\kit)[1] = Pbind(
  \instrument, \sHh,
  \octave, 2,
  \degree, 3,
  // \rel, Pseq([0.5!3, 1.5].flat,inf),
  \dur, 1/2,
  \stretch, Pseq([1, 1/3], inf),
);
)
Ndef(\kit).clear;
(
Ndef(\as, { | freq=410 ,  index=0.42, distance=1.00,  amp=0.2 |
	var theta, beta, num, denom, son, env;
	
	// Two phasors which will ramp from zero to 2pi
	theta = Phasor.ar(0, freq, 0, 2pi);
	beta  = Phasor.ar(0, freq * distance, 0, 2pi);
	
	num = sin(theta) - (index * sin(theta - beta));
	denom = 1 + index.squared - (2 * index * cos(beta));
	
	son = num / denom;
	
	Pan2.ar(son * amp);
	
});
Ndef(\as)[1] = \pset -> Pbind(
  \dur,  8, 
  // \index,  Pwhite(0.42, 0.9,  inf), 
  \distance,  Pseq((5..10), inf),  
  \octave, Pstep(Pseq((-2..1), inf),4),   
  \degree,  Pseq([0, 4,  2,  1], inf),  
  \stretch,  Pseg([1/2, 2,   1/2], [4,  2],  \sin, inf), 
);
)
Ndef(\ins1,  {|amp=0.75| Ndef(\as) * amp});
Ndef(\as).free;
Ndef(\as).map(\index, {Ndef.kr(\lfo).range(0.3, 0.9)});
Ndef.all.free;

(
Ndef(\pm1)[0] = Pbind(
  \instrument, \pm1,
  \octave,  3,  
  \dur, 1,  
  // \index, Pseq((1..5),  inf), 
  \index, 5,
  \ratio1, 2, 
  \degree,   Pseq([0, 2,  0,  4,], inf), 
  \stretch, Pseq([1/3!3, 3].flat, inf),
);
Ndef(\ratio,   { SinOsc.kr(0.5) * 2pi });
Ndef(\ins4, {|amp=0.75| Ndef(\pm1) * amp });
)
Ndef(\pm1).map(\ratio, Ndef.ar(\ratio));
Ndef(\pm1).set(\ratio, 3);
Ndef(\ratio,   { LFPulse.ar(1) });
Ndef(\pm1).play;
Ndef(\pm1).clear;
Ndef(\pm1).stop;

FreqScope.new;
(
Ndef(\pmBell, {| vel=0.8 |

	var f,ff0,ff1,ff2,a,b,c,d,e, modInd,aa;
	var osc,signal;
	f = \freq.kr(100).lag(0.01);

	e = EnvGen.kr(Env.perc(
		\att.kr(0.015) * Rand(0.9,1.1),
		\rel.kr(1.02), 
		curve: \curve.kr(-4)
	),
		gate: Impulse.kr(0.5),
	) * vel;


	ff0= f * \f0ratio.kr(2 * e.pow(0.8));
	ff1= f * \f1ratio.kr(2 * e.pow(1.2));
	


	b = SinOsc.ar(ff1) * f * \modInd1.kr(1) * e;
	c = SinOsc.ar(ff0) * f * \modInd0.kr(1) * e;
	a = SinOsc.ar(f + [b,c].sum 
	);

	a = HPF.ar(a*e, f * 0.5);



	osc = a * \pgain.kr(1);

});
Ndef(\pmBell)[1] = \filter -> { |in, trigRate = 40, grainDur = 0.08, pan = 0.0, amp = 0.3, envbufnum = 0|
    var mono, wet;
    mono = (in[0] + in[1]) * 0.5;
    wet = GrainIn.ar(
        numChannels: 2, trigger: Dust.kr(trigRate), dur: grainDur,
        in: mono, pan: pan, envbufnum: envbufnum
    ) * amp;
    wet   // just return it — no In.ar/Out.ar/ReplaceOut.ar needed, NodeProxy handles both
};
Ndef(\pmBell)[5] = \pset -> Pbind(
  \octave,  4,  
  \degree,  Pseq((0..7).scramble,  inf),  
  \dur, 1/4,  
  \stretch, Pseq([1/3!3,  1].flat,  inf), 
  \f0ratio,  Pwhite(1,  4,  inf), 
  \f1ratio,  Pwhite(2,  5,  inf), 
)
)

Ndef(\pmBell).set(\trigRate, 20);
Ndef(\pmBell).set(\wet1, 0.0);
Ndef(\pmBell).play;
Ndef(\pmBell).clear;
Ndef(\pmBell).stop;
Ndef(\pmBell).set(\t_trig, 0); // retriggers the perc envelope every time


( 
Ndef(\fm1)[0] = Pbind(
	\instrument, \fm3,
	\dur, Pseq( 2.pow((-4..1).scramble), inf ),
	\legato, Pfunc({rrand(0.01,1)}),
	\degree, Pseq([0,2,5,6,8,11].scramble, inf),
	\octave, Pstutter(3, Pseq([3,4,5], inf) ),
	\vel, Pstutter(6, Pseq([ 0.2, 1, 1.2 ].scramble, inf)),
	\f0ratio, Pseq( (3..5).scramble, inf ),
	\f1ratio, Pseq( (1..3).scramble, inf ),
	\f2ratio, Pseq( (3..5) / (1..3).scramble, inf ),
	\modInd0, Pfunc{rrand(0,2.0)},
	\modInd1, Pfunc{rrand(0,1.0)},
	\modInd2, Pfunc{rrand(0,0.5)},
); 
)

(
Ndef(\pedestrian).fadeTime = 16;
Ndef(\pedestrian)[0] = { | freq=220,   amp=0.2 |
	var sig;
  sig = SinOsc.ar([freq, freq * 1.1], 0, 0.2) * LFPulse.ar([5,  5.1]);
  sig * amp; 
};
Ndef(\pedestrian)[1] = \pset -> Pbind(
  \amp, 0.5,  
  // \octave,  Pseq([4,  5,  6], inf), 
  \degree,  Pslide((0..7).scramble, inf,  3,  4),  
  \dur, 1/8
);
Ndef(\ins1)[0] = {|amp=0.8| Ndef(\pedestrian) * amp };
)
Ndef(\pedestrian).play;
Ndef(\pedestrian).free;
Ndef(\pedestrian).stop;
