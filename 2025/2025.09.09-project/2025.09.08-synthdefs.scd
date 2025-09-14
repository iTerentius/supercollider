(
// 1. Define the SynthDef
SynthDef(\syn1, { |out=0, freq=440, amp=0.2, gate=1|
	var env, son;

	// Create an ADSR envelope
	env = EnvGen.ar(
		Env.adsr(0.01, 0.2, 0.5, 0.5),
		gate,
		doneAction: 2 // Automatically free the synth when done
	);

	// Create the sine oscillator and apply the envelope
	son = SinOsc.ar([freq, freq + 0.5], 0, amp) * env;

	// Output the signal to the specified bus
	Out.ar(out, son);
}).add;

)
