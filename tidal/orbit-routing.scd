(
var busses = ~dirt.orbits.collect { |x| x.dryBus };

SynthDef(\readorb, { |out, amp = 1, n = 0, obus = 0 | // number
	var bus, sound;

	bus = Select.kr(n, busses);
	sound = InFeedback.ar(bus, ~dirt.numChannels);
	//sound = CombL.ar(sound, 0.2, 0.03, 1);
	Out.ar(out,
		sound * (amp * 2.5);
	)
}).add;
);

/*
// in tidal, e.g.:
d1 $ sound "can bd hh*5 bd" # pan "0" # up "{1 2 3 4}/4"
d2 $ sound "readorb:0 blip"
  # pan "1" # orbit "1"
  # delay "1" # delaytime "0.15" # delayfeedback "0.5"
  # bandf "{90 200 1450 9000}/3" # bandq "10"
d1 $ sound "can*2" # pan "0" # up "{1 2 3 4}/4"
*/

(
SynthDef(\bass, { | out = 0, freq = 110, mul =  1, modfreq = 1, pmindex = 1, sustain = 1, speed = 1, begin = 0, end = 1, pan, accelerate, offset, clamp = 1 |
	var sig, env, line, vol;
	line = Line.ar(begin,end,sustain/speed,doneAction: Done.freeSelf);
	env = Env.pairs([[0.5, 0.9, 0.25, 0.9, 2], [0.1, 0.5, 0.6, 0.8, 1]], \exp, doneAction: Done.freeSelf);
	vol = IEnvGen.ar(env, line);
	sig = LFSaw.ar((SinOsc.ar(freq) * LFPulse.kr(Rand(1,4)).range(60, 220))!2, modfreq: modfreq, pmindex: pmindex, mul: vol).dup;
	Out.ar(out, sig * mul);
}).add;
)