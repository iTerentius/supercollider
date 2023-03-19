(
SynthDef(\trigTest2, { |out, trig=0, freq=440|
    Out.ar(out, SinOsc.ar(freq+[0,1], 0, Decay2.kr(trig, 0.005, 1.0)));
    }, [0, \tr, 4]        // lag the freq (lagtime: 4s), \tr creates a TrigControl for trig
).add;
);

(
SynthDef(\test, {
    | out, sustain=1, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset, noise=0 |
    var env    = Line.ar(1, 0, sustain, doneAction: Done.freeSelf);
	var osc    = SinOsc.ar(freq) * LFNoise0.kr(noise);
    var output = osc * env;
    OffsetOut.ar(out, Pan2.ar(in: output, pos: pan));
}).add;
);

// (
// var busses = ~dirt.orbits.collect { |x| x.dryBus };

// SynthDef(\readorb, { |out, amp = 1, n = 0, obus = 0 | // number
// 	var bus, sound;
// 	bus = Select.kr(n, busses);
// 	sound = InFeedback.ar(bus, ~dirt.numChannels);
// 	//sound = CombL.ar(sound, 0.2, 0.03, 1);
// 	Out.ar(out,
// 		sound * (amp * 2.5);
// 	)
// }).add;
// );

(
SynthDef(\t1002, {
	arg out = 0, amp = 0.2, gate = 1, pan = 0, freq = 200, ph = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc, 1);
	sig = SinOsc.ar(freq + LFPulse.ar(freq: 2, phase: ph, mul: 1, add: 0 )) * env * ph;
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;
);

/*
// in tidal, e.g.:
d1 $ sound "can bd hh*5 bd" # pan "0" # up "{1 2 3 4}/4"
d2 $ sound "readorb:0 blip"
  # pan "1" # orbit "1"hoarder
  # delay "1" # delaytime "0.15" # delayfeedback "0.5"
  # bandf "{90 200 1450 9000}/3" # bandq "10"
d1 $ sound "can*2" # pan "0" # up "{1 2 3 4}/4"
*/

(

SynthDef(\bass8, {
	arg out = 0, amp = 0.1, gate = 1, pan = 0, freq = 200;
	var sig;
	var osc = Array.newClear(6);
	var env = Array.newClear(6);

	env[0] = EnvGen.kr(Env([0,1,0.051,0],[0.001,0.01,0.8], [4,-8]), 1);
	env[1] = EnvGen.kr(Env([0,1,0.051,0],[0.005,0.5,1.5], [0,-8], releaseNode:2), 1);
	env[2] = EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.2], [0,0,-4], releaseNode:2), gate);
	env[3] = EnvGen.kr(Env([0,1,0],[0.002,2.8], [0,-4]), 1);
	env[4] = EnvGen.kr(Env([0,1,1,0],[0.001,0.1,0.8], [4,0,-4], releaseNode:2), gate);
	env[5] = EnvGen.kr(Env([0,1,0],[0.001,3.0], [0,-4]), 1);

	freq = (freq / 4) * ((0..1)/1 - 0.5 * 0.0007 + 1);

	osc[0] = SinOsc.ar(freq * 11 + 0) * env[0];
	osc[1] = SinOsc.ar(freq * 6 * ( osc[0] * 2.5 + 1 )) * env[1];
	osc[2] = SinOsc.ar(freq * 2 * 1 + 0) * env[2];
	osc[3] = SinOsc.ar(freq * 1 * ( osc[2] * 2.5 + 1 ) + 0) * env[3];
	osc[4] = SinOsc.ar(freq * 1 * ( osc[1] * 2.5 + 1 ) * (osc[3] * 2.5 + 1)) * env[4];
	osc[5] = SinOsc.ar(freq * 2) * env[5];

	sig = osc * DC.ar([0.0, 0.0, 0.0,  0.0, 0.5, 0.5]);
	sig = sig * 0.5;
	sig = sig.flop.sum;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ), gate, doneAction:2);
	sig = sig * AmpComp.kr(freq);
	sig = sig.sum;
	Out.ar(out, Pan2.ar(sig, pan, amp));

}).add;

);