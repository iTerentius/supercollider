// Live Coding by 박성민 using Ndefs with custom Clock and Divs


(
var maxNumBus = s.options.numControlBusChannels;
var maxDivision = 96;
var f = {
	~clock = { | bpm = 60 |
		var tick = Impulse.kr(bpm/60.0 * maxDivision);
		var count = PulseCount.kr(tick);
		Out.kr(maxNumBus-1, count);
	}.play;
	"clock re-init".postln;
};

f.();
ServerTree.removeAll;
ServerTree.add(f,s);

~tg = { | div |
	Trig1.kr( ( (In.kr(maxNumBus-1) % (maxDivision / div)).floor < 1), 0.01);
};

~tc = { | div |
	(In.kr(maxNumBus-1) / (maxDivision / div)).floor;
};

~gate = { | div, n, segs |
	Mix(segs.collect( { | c | ( ~tc.(div) % n ).floor eq: c } ) * ~tg.(div));
};
)

Ndef(\bass).fadeTime_(2).play;
(
Ndef(\bass, {
	var gate = ~tg.(4);
	var note = 55;
	Pan2.ar(SinOsc.ar(note.midicps, 0.0, EnvGen.kr(Env.perc(0.0,0.5), gate ))) * 0.5;
})
)