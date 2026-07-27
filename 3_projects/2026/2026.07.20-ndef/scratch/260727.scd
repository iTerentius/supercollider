( // basic
SynthDef(\sin_pulsar, { 
	var a,b,c,d,e,f;
	var overlap;

	overlap	= MouseY.kr(0,0.4);

	f = MouseX.kr(1,20);

	a = GrainSin.ar(
		numChannels: 1, 
		trigger: Impulse.ar(freq: f), 
		dur: overlap, 
		freq: 440
	); 

	a = LeakDC.ar(a);

	Out.ar(0, a * 0.1!2)
}).play;
// }).draw;
)
Synth(\sin_pulsar).play;
