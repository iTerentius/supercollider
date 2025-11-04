// Companion Code 4.2
// Working With PlayBuf

// This file explores creative sampling techniques using PlayBuf. It resides in a folder called "Companion_Code_4.2," accompanied by a subfolder of sound files named "audio." Adopting techniques detailed in Companion Code 4.1, the following function reads these sound files into arrays of buffers, and stores the arrays in an Event, contained in the interpreter variable 'b'.

s.boot;

(
~makeBuffers = { |path, event|
	var dir = PathName.new(path);
	var contents = dir.entries;

	if (contents.select({ |n| n.isFile }).size > 0)
	{
		var files, bufArray;
		files = contents.select({ |n| n.isFile });
		files = files.select({ |n|
			["aif", "aiff", "wav"].includesEqual(n.extension)
		});

		if (event[dir.folderName.asSymbol] != nil)
		{ "duplicate subfolder name ignored".warn; }
		{
			bufArray = files.collect({ |n| Buffer.read(s, n.fullPath) });
			event[dir.folderName.asSymbol] = bufArray;
		};
	};

	if (contents.select({ |n| n.isFolder }).size > 0)
	{
		var folders = contents.select({ |n| n.isFolder });
		folders.do({ |n| ~makeBuffers.(n.fullPath, event) });
	};

	event;
};

b = ~makeBuffers.("audio/".resolveRelative, ());
)

// The SynthDef in Code Example 4.15 serves as a starting point for further exploration. The files in the audio subfolder are all stereo files, so the number of channels of PlayBuf is two, and the multichannel expansion has been removed. In addition, an amplitude argument has been added, and the default value of loop has been changed to zero:

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1,
	start = 0, loop = 0, amp = 0.5, out = 0;
	var sig;
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(2, buf, rate, t_trig, start, loop, doneAction: 2);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// the "pipe" subfolder contains one sample of a small metal pipe being struck:

Synth(\playbuf, [buf: b[\pipe][0]]);

// There is a common pitfall related to reversed playback. Specifying a negative rate is just one of several required steps, so the following line of code will fail to produce sound:

Synth(\playbuf, [buf: b[\pipe][0], rate: -1]);

// There is no sound because of a combination of factors: playback starts at the 0th frame, the frame pointer attempts to move backwards, and looping is disabled. In an attempt to move backward from the 0th frame, the frame pointer realizes it is at the "end" of the buffer, so it checks its doneAction. The doneAction is 2, so the Synth is freed.

// One solution is to enable looping, causing PlayBuf to ignore its doneAction. In this case, reverse playback proceeds — and loops — with no problems. Note that this particular sound takes a few seconds to fade in, because of the long decay.

x = Synth(\playbuf, [buf: b[\pipe][0], rate: -1, loop: 1]);

x.free;

// How would we play this sample backward, once? One idea is to start the frame pointer at the last frame index, but this approach also fails.

(
x = Synth(
	\playbuf,
	[
		buf: b[\pipe][0],
		rate: -1,
		start: b[\pipe][0].numFrames - 1
	]
);
)

// A mysterious result, at first glance! No sound, no activity on the level meters, and no error message. The problem stems from the fact that PlayBuf begins at its final frame. This, in combination with the fact that looping is disabled, is PlayBuf's cue to check its doneAction. Since the doneAction is 2, the Synth is freed as soon as it is created. In this case, the most sensible solution is to start playback at the penultimate frame:

(
Synth(
	\playbuf,
	[
		buf: b[\pipe][0],
		rate: -1,
		start: b[\pipe][0].numFrames - 2
	]
);
)

// Panning a stereo signal is not the same process as panning a monophonic signal. When working with a monophonic signal, we can use Pan2, which expects a one-channel signal and outputs a two-channel signal, adjusting the amplitudes of its two outputs according to its 'pan' value. To change the spatial imagery of a stereo signal, Balance2 should be used to temporarily split a stereo signal into individual left/right components, adjust their amplitudes based on a 'pan' value, and recombine them as a new stereo signal:

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0,
	loop = 0, pan = 0, amp = 0.5, out = 0;
	var sig;
	rate = rate * BufRateScale.kr(buf);
	sig = PlayBuf.ar(2, buf, rate, t_trig, start, loop, doneAction: 2);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth(\playbuf, [buf: b[\pipe][0], pan: -0.25]); // slightly left

Synth(\playbuf, [buf: b[\pipe][0], pan: 0.5]); // moderately right

Synth(\playbuf, [buf: b[\pipe][0], pan: -0.9]); // mostly left

// As discussed in the book, the rate argument provides a means of pitch control. Using 'midiratio,' we can specify pitch as a number of semitones:

(
Array.rand(5, -9, 7).do({ |n| // iterate over 5 random pitch values
	Synth(
		\playbuf,
		[
			buf: b[\pipe][0],
			rate: n.midiratio,
			amp: 0.4,
			pan: rrand(-0.5, 0.5),
		]
	);
});
)

// Envelopes are just as relevant in sampling as they are in synthesis. An amplitude envelope can apply additional shaping on the attack and/or release transients, and is also useful for playing short inner sections of a longer sample.

// Adding an envelope raises the question of which UGen should be responsible for self-termination via doneAction. If the envelope is intended to be shorter than the buffer duration, and is being used in one-shot fashion, then it makes sense to move the terminating doneAction from the buffer player to the envelope:

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0,
	atk = 0.001, sus = 0, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(
		Env.new([0, 1, 1, 0], [atk, sus, rel], [1, 0, -2]),
		doneAction: 2
	);
	sig = PlayBuf.ar(2, buf, rate, t_trig, start, loop);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// The default settings specify a very fast attack, a virtually instantaneous sustain portion, and a two-second release. These settings have no perceptible influence on the natural attack of the samples, but subtly shorten the release.

(
Array.rand(5, -9, 7).do({ |n|
	Synth(
		\playbuf,
		[
			buf: b[\pipe][0],
			rate: n.midiratio,
			pan: rrand(-0.5, 0.5),
			amp: 0.4,
		]
	);
});
)

// By lengthening the envelope attack time, we create a softer a attack that conceals the natural attack, introducing a gentle fade-in:

(
Array.rand(5, -9, 7).do({ |n|
	Synth(
		\playbuf,
		[
			buf: b[\pipe][0],
			rate: n.midiratio,
			atk: 0.1,
			pan: rrand(-0.5, 0.5),
			amp: 0.4,
		]
	);
});
)

// Embracing more randomness is always an option:

(
Array.rand(5, -9, 7).do({ |n|
	Synth(
		\playbuf,
		[
			buf: b[\pipe][0],
			rate: (n + rrand(-0.1, 0.1)).midiratio,
			atk: exprand(0.02, 0.75),
			rel: rrand(0.5, 2.5),
			pan: rrand(-0.5, 0.5),
			amp: exprand(0.2, 0.5),
		]
	);
});
)

// Notably, randomness can be a valuable tool for enhancing a sense of realism. When a real-world physical object is stimulated repeatedly, the excitation and resulting vibrations are slightly different each time, on account of being struck in a slightly different spot, with a slightly different angle and intensity. If no randomness is applied to this pipe sample, repeated executions quickly reveal an artificial-sounding sameness:

Synth(\playbuf, [buf: b[\pipe][0]]); // <- evaluate repeatedly

// But, introducing minor deviations in each parameter creates the subtle but appreciable suggestion of a large collection of nearly-identical samples, which tends to sound more realistic.

(
Synth(
	\playbuf, // <- evaluate repeatedly
	[
		buf: b[\pipe][0],
		rate: exprand(0.997, 1.003),
		atk: exprand(0.0001, 0.003),
		rel: exprand(3.0, 4.0),
		start: rrand(0, 199),
		pan: rrand(-0.15, 0.15),
		amp: exprand(0.5, 0.8)
	]
);
)

// We can drastically shorten the envelope's attack and release to create a drier percussive sound:

(
Array.rand(5, -9, 7).do({ |n|
	Synth(
		\playbuf,
		[
			buf: b[\pipe][0],
			rate: n.midiratio,
			atk: 0,
			rel: 0.06,
			pan: rrand(-0.5, 0.5),
			amp: 0.4,
		]
	);
});
)

// Let's now switch to a different sample (a baritone saxophone multiphonic). To hear the entire sample, we don't need to delete the envelope from the SynthDef. Instead, we can provide segment durations that transform the envelope into a simple rectangular shape whose duration is equal to the buffer duration:

(
var buf = b[\sax][0];
Synth(
	\playbuf,
	[
		buf: buf,
		atk: 0,
		sus: buf.duration,
		rel: 0,
		amp: 0.5
	]
);
)

// This sample is spectrally richer than the pipe sample, and produces different musical results with noticeably different flavors. The following example produces a cluster of eight samples, each detuned by a random amount between ± 1 semitone, with relatively long attacks and releases, and random pan positions. The starting frame for each PlayBuf is random within the first 20000 samples of the file:

(
Array.rand(8, -1.0, 1.0).do({ |n, i|
	Synth(
		\playbuf,
		[
			buf: b[\sax][0],
			rate: n.midiratio,
			start: rrand(0, 19999),
			atk: rrand(1.5, 2.0),
			sus: 0,
			rel: rrand(1.5, 2.0),
			pan: rrand(-0.5, 0.5),
			amp: 0.4,
		]
	);
});
)

// We can transpose this cluster down to create an ominous, other-worldly drone:

(
Array.rand(8, -30.0, -25.0).do({ |n, i|
	Synth(
		\playbuf,
		[
			buf: b[\sax][0],
			rate: n.midiratio,
			start: rrand(0, 19999),
			atk: rrand(2.5, 6.0),
			sus: 0,
			rel: rrand(2.5, 6.0),
			pan: rrand(-0.5, 0.5),
			amp: 0.4,
		]
	);
});
)

// It's important to maintain a sense of agreement between the rate-scaled buffer duration and the duration of the envelope. Envelope segment times will not automatically scale if the length of a PlayBuf signal is stretched or compressed by its rate parameter. If the rate value is too high, or if the envelope duration is too large, then PlayBuf may reach the end of the buffer before the envelope is complete, possibly resulting in an abrupt cut-off. You should always listen carefully to your sound and make sure it sounds correct.

// It's also important to be aware of background noise in an audio file. Though the noise floor may be sufficiently masked when only one instance of a sample is playing, a layered combination of multiple instances of a sample may cause background noise to accumulate and become significantly more audible, particularly if playback rates have been altered. This baritone saxophone sample is not an ideal example of a noise-free file — the previous Synth cluster will produce a quiet but audible hiss if your system volume is sufficiently loud. A low-pass or high-pass filter may be able to sufficiently counteract background noise in some cases. In other cases, it may be necessary to return to your library and improve the quality of your samples through waveform editing software or re-recording. In yet other cases, it may be acceptable or appropriate to embrace some amount of background noise.

// Playback need not start at the 0th frame, nor even near the start of the file. Combined with a non-zero start position, we can select a random segment from somewhere in the middle of the buffer. However, it is not a good idea to randomly select a starting frame from anywhere in the buffer. If looping is disabled, and if the randomly selected start frame is extremely close to the last frame, then there will be almost no buffer content to play, and that particular Synth will not produce much sound. One solution to this problem is to enable looping. If the buffer is uniformly filled with non-silence, then every Synth will produce some sound, though a number of Synths will "straddle" the end/beginning of the buffer. Keep in mind that these Synths will not actually loop indefinitely, just because the loop parameter equals one; this parameter only determines how PlayBuf should behave when its frame pointer reaches the end of the buffer. The envelope, which contains a terminating doneAction, determines the true end of each Synth.

(
// evaluate repeatedly; each Synth starts at a random frame
var buf = b[\sax][0];
Synth(
	\playbuf,
	[
		buf: buf,
		start: rrand(0, buf.numFrames-1),
		loop: 1,
		amp: 0.75,
		atk: 0.002,
		rel: 0.2,
	]
);
)

// An envelope that is 0.202 seconds long corresponds to approximately 9000 samples (b[\sax][0].sampleRate * 0.202 = 8908.2 samples). Therefore, if we specify a starting frame that is half this many samples behind the final frame, we will hear an example of a Synth that includes a bit of audio from the end of the buffer, followed by a bit of audio from the beginning:

(
var buf = b[\sax][0];
Synth(
	\playbuf,
	[
		buf: buf,
		start: buf.numFrames - 4501,
		loop: 1,
		amp: 0.75,
		atk: 0.002,
		rel: 0.2,
	]
);
)

// If this straddling behavior is undesirable, we can disable looping and restrict the range of random starting frames so that they remain sufficiently behind the final frame, leaving at least one envelope's worth of samples in front of them:

(
var buf = b[\sax][0];
Synth(
	\playbuf,
	[
		buf: buf,
		start: rrand(0, buf.numFrames - (buf.numFrames * 0.202)).round,
		loop: 0,
		amp: 0.75,
		atk: 0.002,
		rel: 0.2,
	]
);
)

// Our SynthDef can be modifed to automate the process of extracting and playing short subsections of the buffer. An Impulse generator provides a repeating trigger, whose frequency is determined by an argument. Each time a trigger is generated, TIRand selects a new random starting frame ('start' has been removed from the argument declaration and declared as a variable instead), resets the envelope, and jumps the PlayBuf pointer to the new start position.

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, loop = 0, retrigHz = 0.5,
	atk = 0.001, sus = 0, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env, retrig, start;
	rate = rate * BufRateScale.kr(buf);
	retrig = Impulse.ar(retrigHz);
	start = TIRand.ar(0, BufFrames.kr(buf)-1, retrig);
	env = EnvGen.ar(
		Env.new([0, 1, 1, 0], [atk, sus, rel], [1, 0, -2]),
		retrig
	);
	sig = PlayBuf.ar(2, buf, rate, retrig, start, loop);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// By setting the frequency of the impulse generator ('retrigHz') as the reciprocal of the envelope duration, we ensure that each new envelope begins just as the previous envelope ends. This value can, however, be faster or slower. Faster values will "interrupt" each envelope with a new one, and slower values will leave gaps of silence between adjacent envelopes. Impulse can also be replaced with Dust for non-periodically generated triggers.

(
var buf = b[\sax][0];
x = Synth(
	\playbuf,
	[
		buf: buf,
		loop: 1,
		amp: 0.75,
		atk: 0.002,
		rel: 0.2,
		retrigHz: 1 / 0.202,
	]
);
)

x.free;

// Feel free to experiment with this example to create more interesting rhythmic textures. Or, if you're ready to continue, we'll back up a few steps, revert to a previous SynthDef, and return to our pipe sample:

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0,
	atk = 0.001, sus = 0, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(
		Env.new([0, 1, 1, 0], [atk, sus, rel], [1, 0, -2]),
		doneAction: 2
	);
	sig = PlayBuf.ar(2, buf, rate, t_trig, start, loop);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth(\playbuf, [buf: b[\pipe][0]]);

// Is it possible to sustain this pipe sound indefinitely? Maybe. The most important thing to realize is that not all sound files naturally lend themselves to being indefinitely sustained through artificial means. This pipe sample decays continuously, so there is no natural sustain segment for us to isolate and loop. If we restrict ourselves to only one instance of PlayBuf, one approach involves establish a repeating trigger signal, as we previously did, that endlessly cycles through a specific segment of the buffer. In the following modified SynthDef, the envelope has been changed to a gated, sustaining envelope, since our goal is to sustain the sample indefinitely:

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0, retrigHz = 1,
	gate = 1, atk = 0.001, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env, retrig;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(Env.asr(atk, 1, rel), gate, doneAction: 2);
	retrig = Impulse.ar(retrigHz);
	sig = PlayBuf.ar(2, buf, rate, retrig, start, loop);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

(
var buf = b[\pipe][0];
x = Synth(
	\playbuf,
	[
		buf: buf,
		start: 24000,
		amp: 1,
	]
);
)

x.set(\gate, 0);

// Crude, at best! This example can hardly be considered a "sustaining" effect. Perhaps, we could spend some time hunting for a combination of an Impulse frequency and starting frame that produces a more satisfying result. But, considering the fact that this pipe sample is composed of one long decay, this is an uphill battle.

// We can get a bit closer to our goal by adding a secondary envelope ('loopEnv') that fades a looped segment in and out, and resets itself using the same triggering process from previous examples. The shape of this envelope is a sinusoidal bell curve, and its duration is the inverse of the trigger frequency. As such, it remains perfectly synchronized with the looped segment:

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0, retrigHz = 1,
	gate = 1, atk = 0.001, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env, loopEnv, retrig;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(Env.asr(atk, 1, rel), gate, doneAction: 2);
	retrig = Impulse.ar(retrigHz);
	loopEnv = EnvGen.ar(Env.sine(1 / retrigHz), retrig);
	sig = PlayBuf.ar(2, buf, rate, retrig, start, loop);
	sig = sig * loopEnv;
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

(
var buf = b[\pipe][0];
x = Synth(
	\playbuf,
	[
		buf: buf,
		start: 24000,
		amp: 1,
	]
);
)

x.set(\gate, 0);

// The hard loop points have been softened, but the result is a pulsating tone, rather than a steady sustain. To fill the gaps, we can create a second envelope that is repeatedly crossfaded with the first, so as each looped segment fades out, another fades in to take its place. This requires a second trigger signal, 180 degrees out of phase with the original, applied to a second instance of PlayBuf. The result is two bell curve envelopes that "take turns" in order to complement one another.

// The following example is a good opportunity to showcase the elegance of multichannel expansion. By specifying the phase of the Impulse generator as the array [0, 0.5], we create an array of two out-of-phase Impulse generators. The multichannel expansion propagates through EnvGen and PlayBuf: 'loopEnv' becomes an array of two alternatingly-triggered envelopes, and 'sig' becomes an array of two alternatingly-retriggered stereo signals. After the looping envelope is applied to the audio signal, we can sum these two stereo signals back together.

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0,
	gate = 1, atk = 0.001, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env, loopEnv, retrig;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(Env.asr(atk, 1, rel), gate, doneAction: 2);
	retrig = Impulse.ar(1, [0, 0.5]);
	loopEnv = EnvGen.ar(Env.sine(1),retrig);
	sig = PlayBuf.ar(2, buf, rate, retrig, start, loop);
	sig = (sig * loopEnv).sum;
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

(
var buf = b[\pipe][0];
x = Synth(
	\playbuf,
	[
		buf: buf,
		start: 24000,
		amp: 1,
	]
);
)

x.set(\gate, 0);

// For a more realistic sound, we can utilize two SynthDefs — our original, simpler instrument, and this newer looping version. The one-shot sample plays first, and as it naturally fades out, the looped sample fades in, attempting to create a seamless transition to an indefinite sustain.

(
SynthDef(\playbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0,
	atk = 0.001, sus = 0, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(
		Env.new([0, 1, 1, 0], [atk, sus, rel], [1, 0, -2]),
		doneAction: 2
	);
	sig = PlayBuf.ar(2, buf, rate, t_trig, start, loop);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\loopbuf, {
	arg buf = 0, rate = 1, t_trig = 1, start = 0, loop = 0,
	gate = 1, atk = 0.001, rel = 2, pan = 0, amp = 0.5, out = 0;
	var sig, env, loopEnv, retrig;
	rate = rate * BufRateScale.kr(buf);
	env = EnvGen.ar(Env.asr(atk, 1, rel), gate, doneAction: 2);
	retrig = Impulse.ar(1, [0, 0.5]);
	loopEnv = EnvGen.ar(Env.sine(1),retrig);
	sig = PlayBuf.ar(2, buf, rate, retrig, start, loop);
	sig = (sig * loopEnv).sum;
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

(
var buf = b[\pipe][0];
x = []; // an array to hold sustaining synths

Synth(
	\playbuf,
	[
		buf: buf,
		start: 0,
		amp: 0.75,
		atk: 0,
		rel: 4
	]
);
x = Synth(
	\loopbuf,
	[
		buf: buf,
		start: 24000,
		amp: 1,
		atk: 3,
	]
);
)

x.set(\gate, 0, \rel, 5);

// The result isn't flawless — the pulsation of the looped envelope is still subtly audible — but the result is pleasant enough to listen to. If we wanted to create several simultaneous sustained pipes with different pitches, it would be prudent to define some sort of function that modularizes the Synth-creating code:

(
~playloop = {
	|buf = 0, rate = 1, start = 24000, amp = 0.2, array|
	Synth(
		\playbuf,
		[
			buf: buf,
			start: 0,
			amp: amp,
			rate: rate,
			atk: 0,
			rel: 4
		]
	);
	array = array.add(
		Synth(
			\loopbuf,
			[
				buf: buf,
				start: start,
				rate: rate,
				amp: amp,
				atk: 3,
			]
		);
	);

	array;
};
)

// The input argument named 'array' is passed into the function on evaluation, and new Synths are added to it, thus making it easy to accumulate several Synths and store them in the same place. We first evaluate the function, providing a buffer, a rate, a starting frame, an amplitude, and an initially empty collection. The '~playloop' function above returns the modified array containing a new Synth, so we can capture the result in order to retain access to it:

(
~sus = [];
~sus = ~playloop.(b[\pipe][0], 0.midiratio, 24000, 0.5, ~sus);
)

// We can then add more notes and capture the sustaining Synths in that same collection:

~sus = ~playloop.(b[\pipe][0], -2.midiratio, 24000, 0.5, ~sus);

~sus = ~playloop.(b[\pipe][0], -5.midiratio, 24000, 0.5, ~sus);

~sus = ~playloop.(b[\pipe][0], -7.midiratio, 24000, 0.5, ~sus);

~sus = ~playloop.(b[\pipe][0], 3.midiratio, 24000, 0.5, ~sus);

~sus = ~playloop.(b[\pipe][0], 4.midiratio, 24000, 0.5, ~sus);

// When finished, we can release all the Synths in the ~sus array, and reset ~sus to a neutral, empty state:

(
~sus.do({ |synth| synth.set(\gate, 0, \rel, 5) });
~sus = [];
)

// We can use this same function to attempt to sustain the saxophone sample, which may be a better candidate. The starting frame value of 92000 was determined through trial-and-error:


~sus = ~playloop.(b[\sax][0], 0.midiratio, 92000, 0.3, ~sus);

~sus = ~playloop.(b[\sax][0], -6.midiratio, 92000, 0.3, ~sus);

~sus = ~playloop.(b[\sax][0], -13.midiratio, 92000, 0.3, ~sus);

(
~sus.do({ |synth| synth.set(\gate, 0, \rel, 5) });
~sus = [];
)

// Admittedly, this is quite a bit of work to produce a sustain effect that is only somewhat convincing. As discussed, not all samples are natural candidates for indefinite sustain. Other samples, e.g. bowed strings, woodwinds, electric motors, etc., may be more viable.

// All things considered, this application of PlayBuf is essentially a version of granular synthesis, discussed later in chapter 4, which is a more fluid and flexible technique of arbitrarily deconstructing and reconstructing a sample.