// Companion Code 4.3
// Working With BufRd

// This file explores creative sampling techniques using BufRd. It resides in a folder called "Companion_Code_4.3," accompanied by a subfolder of sound files named "audio." Adopting techniques detailed in Companion Code 4.1, the following function reads these sound files into arrays of buffers, and stores the arrays in an Event, contained in the interpreter variable 'b'.

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

// The SynthDef from Code Example 4.17 serves as a starting point for further exploration. The files in this companion code's audio subfolder are all stereo files, so the number of channels of BufRd is two, the multichannel expansion has been removed, and an amplitude argument has been added:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	rate = rate * BufRateScale.kr(buf);
	phs = Phasor.ar(rate: rate, start: 0, end: BufFrames.kr(buf));
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// The "drums" subfolder contains a loopable one-bar beat:

b[\drums][0].play(mul: 0.5);

// The "bass" subfolder contains two files: a one-bar bass line, and a two-bar bass line, which are both also loopable:

b[\bass][0].play(mul: 0.5);

b[\bass][1].play(mul: 0.5);

// By default, a Synth will loop through a file at its original speed:

x = Synth(\bufrd, [buf: b[\drums][0]]);

// Playback rate changes are supported:

x.set(\rate, -3.midiratio);

// Backward playback is also supported:

x.set(\rate, -1);

// Faster or slower backward playback speeds can be specified in semitones by applying the 'midiratio' method first, and then reversing the sign. This can be achieved by appending the 'neg' method:

x.set(\rate, 4.midiratio.neg); // backward, four semitones higher

x.set(\rate, -5.midiratio.neg); // backward, five semitones lower

x.free;

// Phasor is not the only option for making BufRd loop. An audio-rate LFSaw can used for the same purpose. For the original sound, the frequency of LFSaw should be the inverse of the buffer duration, and this value can be scaled by a rate argument for dynamic speed control. The output of LFSaw should range from 0 to the final frame index. LFSaw's default 'iphase' value is zero, which starts the sawtooth waveform halfway along a ramp segment, which corresponds to the middle of the buffer. An iphase value of 1 shifts the phase by a half cycle and starts playback at the beginning of the buffer.

// In this case, because LFSaw's periodic behavior is based solely on the duration of the buffer (instead of incrementing a frame count), it is incorrect to scale the rate argument by BufRateScale, so it has been removed:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	phs = LFSaw.ar(rate / BufDur.kr(buf), 1).range(0, BufFrames.kr(buf) - 1);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

// Real-time speed/pitch changes are still possible, and backward playback is supported:

x.set(\rate, 2.midiratio);

x.set(\rate, -2.midiratio.neg);

x.free;

// Sweep is yet another alternative to Phasor. The output value of Sweep starts at zero and counts upward by an "amount per second" rate, and resets to zero when triggered. It's essentially a version of Phasor that is unbounded in the positive direction, and requires an explicit trigger signal to achieve periodic behavior.

// Because Sweep is a sample-counting UGen like Phasor, it's appropriate to scale its rate by BufRateScale to compensate for potential server/buffer sample rate mismatches. The frequency of the triggering signal, like LFSaw, should be the reciprocal of the buffer duration, and Sweep's rate should be based on the server's sample rate, so that one second's worth of samples are traversed each second. To accommodate speed changes during playback, a rate argument should scale the frequency of Impulse, and also the rate of Sweep, so that these two UGens remain perfectly synchronized:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs, reset;
	reset = Impulse.ar(rate / BufDur.kr(buf));
	phs = Sweep.ar(reset, rate * SampleRate.ir * BufRateScale.kr(buf));
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

// Dynamic changes in playback speed and direction are still supported:

x.set(\rate, 2.midiratio);

x.set(\rate, -2.midiratio.neg);

x.free;

// It's not immediately clear which (if any) of these three looping techniques is the optimal choice. One may be slightly more convenient than another, depending on the situation. Mainly, these options are demonstrated to expound on the technical behavior of BufRd.

// Phasor is perhaps the UGen most clearly designed for retrieving sample values from buffers, and offers good flexibility. It has a pair of specifiable boundaries, a rate, and can be sponaneously reset to an arbitrary value. Conceptually, LFSaw is more of an oscillator than a frame index. It cannot be spontaneously reset, which limits creative options. In addition, if the output range of LFSaw changes, the steepness of its ramp shape is implicitly changed as well, which changes the playback rate of BufRd. Sweep is a decent alternative to Phasor, but its reset position is always zero, requiring additional math to make it more nimble. Because Sweep has no upper boundary, it is vulnerable to a loss of numerical precision if allowed to run for long periods of time without being reset.

// If traditional linear looping is not the goal, then the phase signal can be replaced with any audio-rate signal. A sine wave will read through the buffer sinusoidally and switch direction halfway through each of its cycles. A sensible frequency for the sine wave is half the reciprocal of the buffer duration. A phase value of 3pi/2 causes playback to start at the beginning of the buffer. The effect is similar to scrubbing a record turntable back and forth:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	rate = rate * BufRateScale.kr(buf);
	phs = SinOsc.ar(
		freq: rate * 0.5 / BufDur.kr(buf),
		phase: 3pi/2
	).range(0, BufFrames.kr(buf) - 1);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

x.set(\rate, 12.midiratio); // one octave higher & double speed

x.free;

// A linearly-interpolating noise generator will scrub through random segments at random speeds and directions. Some newly generated values will be very close to the previous value, resulting in a relatively flat ramp segment, producing a relatively slow and low-pitched sound. If consecutive random values have a large difference between them, the corresponding ramp segment will be steep, producing a fast, high-pitched sound. As the rate argument increases, values are chosen more frequently and the overall steepness of ramp segments increases. As the rate approaches zero, values are chosen less frequently, producing flatter ramp segments. At very low frequencies, the pitch of the sample may become so low that it becomes inaudible, and interpolation artifacts may emerge. Due to the random nature of this SynthDef, scaling rate by BufRateScale has no noticeable effect, so this step has been removed:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	phs = LFDNoise1.ar(rate).range(0, BufFrames.kr(buf) - 1);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

x.set(\rate, 3); // faster

x.set(\rate, 1/3); // slower

x.free;

// An exponentially-interpolating noise generator will produce continuous speed/pitch changes, due to the curvy nature of its waveform. The effect is a random-sounding record-scratching effect.

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	phs = LFDNoise3.ar(rate).range(0, BufFrames.kr(buf) - 1);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

x.set(\rate, 3); // faster

x.set(\rate, 1/3); // slower

x.free;

// A non-interpolating noise generator is a poor choice for a frame pointer. Without interpolation, the frame pointer basically "teleports" from one sample to another, producing irregular DC offset and a regular pattern of waveform discontinuities, perceived as clicks:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	phs = LFDNoise0.ar(rate).range(0, BufFrames.kr(buf) - 1);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

x.set(\rate, 9); // effectively a "clicks per second" parameter

x.free;

// If Phasor has an end value that is less than the last frame index, it will only loop through part of the buffer. Here, the default length of Phasor is a tenth of a second:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, length = 0.1, amp = 0.5, out = 0;
	var sig, phs;
	rate = rate * BufRateScale.kr(buf);
	phs = Phasor.ar(rate: rate, start: 0, end: SampleRate.ir * length);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

// Speed and direction manipulations are still supported:

x.set(\rate, 3.midiratio); // forward, three semitones higher

x.set(\rate, -4.midiratio.neg); // backward, 4 semitones lower

x.free;

// By taking the previous example and offsetting the start and end values by a slower, longer-range ramp signal, we can gradually move this looping "window" across the entire length of the buffer. The default frequency of the offset signal is 0.1, which means it will take ten seconds to move this window across the buffer. Because the default loop value of BufRd is 1, we can ignore the fact that a few of the final Phasor values will be out of range, knowing they will be automatically wrapped. The result here is a sort of slow-motion sample-chopping effect.

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, offsetRate = 0.1, length = 0.1, amp = 0.5, out = 0;
	var sig, phs, offset;
	rate = rate * BufRateScale.kr(buf);
	offset = LFSaw.ar(offsetRate, 1).range(0, BufFrames.kr(buf) - 1);
	phs = Phasor.ar(rate: rate, start: 0, end: SampleRate.ir * length);
	phs = phs + offset;
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

// We can still change the speed and/or playback direction of the looped window:

x.set(\rate, 3.midiratio);

x.set(\rate, 3.midiratio.neg);

// We can also change the speed and direction of the LFSaw controlling the start/end offset amounnt:

x.set(\offsetRate, 1/4); // one full forward cycle every four seconds

x.set(\offsetRate, -1/4); // same, but backwards

x.free;

// Many creative options for non-linear frame pointers remain unexplored, left as an open exercise to the reader. For now, we'll return to a more typical use of BufRd in order to address other practical considerations.

// The one-bar drum sample was recorded at a tempo of approximately 103 beats per minute, while the bass was recorded at a tempo of approximately 106 bpm. This discrepancy was intentional, so that we can demonstrate issues related to desynchronization. If played together using two plain instances of PlayBuf, these two samples will audibly drift out of phase:

(
x = {
	var sig;
	sig = [
		PlayBuf.ar(2, b[\drums][0], BufRateScale.kr(b[\drums][0]), loop:1),
		PlayBuf.ar(2, b[\bass][0], BufRateScale.kr(b[\bass][0]), loop:1)
	].sum;
	sig = sig * 0.5;
}.play(fadeTime: 0);
)

x.free;

// It is possible, but clumsy, to synchronize two different-sized loops with PlayBuf. BufRd lends itself to a more elegant solution. The key is to have multiple instances of BufRd relying on the same pointer signal. In our original SynthDef, a singular 'buf' argument was used to determine the buffer being played, as well as the rate and endpoint of Phasor, thus forcing BufRd playback to be governed by one specific buffer. To enable buffer synchronization, it's necessary to make a few changes to the SynthDef. We will revert to a previous version of the SynthDef and use it as a starting point:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, amp = 0.5, out = 0;
	var sig, phs;
	rate = rate * BufRateScale.kr(buf);
	phs = Phasor.ar(rate: rate, start: 0, end: BufFrames.kr(buf));
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// Since we're dealing with beat-based audio, it makes sense to think about timing in terms of tempo and beat quantity. So, we "normalize" the start and end values of Phasor between zero and some number of beats, to be determined when a Synth is created. Additionally, since we're now prioritizing tempo as a rate-determining parameter, there's no need to bother with scaling the rate argument by BufRateScale. In fact, there is no need for the rate argument at all, so it has been removed. Having an argument for playback rate and also an argument for tempo is redundant (and possibly contradictory).

(
SynthDef(\bufrd, {
	arg buf = 0, nbeats = 4, amp = 0.5, out = 0;
	var sig, phs;
	phs = Phasor.ar(rate: 1, start: 0, end: nbeats);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// Now, the main question is: how do we express Phasor's rate parameter?

// We want Phasor to move from zero to some number of beats over the duration of a buffer, so Phasor's increment value should be equal to the number of beats per sample. The SampleDur UGen outputs the number of seconds per sample (usually a very tiny number), so we can multiply this value by the number of beats in one second, which is equal to bpm / 60. Therefore, in this case, the appropriate rate for Phasor is SampleDur.ir * (bpm / 60):

(
SynthDef(\bufrd, {
	arg buf = 0, nbeats = 4, bpm = 104, amp = 0.5, out = 0;
	var sig, phs;
	phs = Phasor.ar(rate: SampleDur.ir * (bpm / 60), start: 0, end: nbeats);
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// Finally, because BufRd expects its pointer to be a value in frames (not beats), we need to scale the Phasor signal from beats to frames. The range-mapping method 'linlin' can be used here:

(
SynthDef(\bufrd, {
	arg buf = 0, nbeats = 4, bpm = 104, amp = 0.5, out = 0;
	var sig, phs;
	phs = Phasor.ar(rate: SampleDur.ir * (bpm / 60), start: 0, end: nbeats);
	phs = phs.linlin(0, nbeats, 0, BufFrames.kr(buf));
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// We can now play these two Synths simultaneously, using the default values of 4 beats per sample and 104 bpm, and they will remain perfectly synchronized:

(
x = [
	Synth(\bufrd, [buf: b[\drums][0]]),
	Synth(\bufrd, [buf: b[\bass][0]])
];
)

// Tempo changes can now be easily executed:

x.do({ |synth| synth.set(\bpm, 118) });

x.do({ |synth| synth.set(\bpm, 90) });

x.do({ |synth| synth.free });

// The design of this SynthDef allows us to begin playing with our third sample, a two-bar (eight-beat) bass sample:

(
x = [
	Synth(\bufrd, [buf: b[\drums][0], nbeats: 4]),
	Synth(\bufrd, [buf: b[\bass][1], nbeats: 8])
];
)

// We can even swap one sample for another in real-time. The swap will happen as soon as code is evaluated, but playback will remain synchronized and there may be a momentary click as the buffer swap occurs:

x[1].set(\buf, b[\bass][0], \nbeats, 4); // swap to 1-bar sample

x[1].set(\buf, b[\bass][1], \nbeats, 8); // swap to 2-bar sample

// "Wrong" values for 'nbeats' are allowed. Doubling or halving the normal value will cause the sample to loop twice as fast or twice as slow. We can, for example, drop the drums to half-tempo by pretending it is composed of eight bars:

x[0].set(\nbeats, 8);

// Similarly, we can double the speed of the bass line by pretending it only has two beats:

x[1].set(\buf, b[\bass][0], \nbeats, 2);

x.do({ |synth| synth.free });

// Two final questions are worth addressing: Can we change our SynthDef so that a precise number of loops are played? And, similarly, is there a way for us to loop a buffer indefinitely, but send a message to the Synth at an arbitrary point in the future that causes it to free itself when the current loop cycle is complete?

// The answer to both questions is yes, and both problems are handled with the addition of an envelope. If the number of desired loops is known in advance, a terminating envelope can be applied, and the duration can be specified when a Synth is created. Here, the duration of the envelope's sustain is calculated as the number of beats, times the number of seconds per beat, times the number of loops. A courtesy release is included, to prevent a click as the sound ends. The duration of the release is subtracted from the sustain so that the total envelope duration is preicely equal to the duration of the desired number of loops.

(
SynthDef(\bufrd, {
	arg buf = 0, nbeats = 4, bpm = 104, numLoops = 1, rel = 0.01, amp = 0.5, out = 0;
	var sig, phs, env, sus;
	phs = Phasor.ar(rate: SampleDur.ir * (bpm / 60), start: 0, end: nbeats);
	phs = phs.linlin(0, nbeats, 0, BufFrames.kr(buf));
	sig = BufRd.ar(2, buf, phs);
	sus = (nbeats * (60 / bpm) * numLoops) - rel;
	env = Env([1, 1, 0], [sus, rel], [0, 0]).ar(2);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

Synth(\bufrd, [buf: b[\drums][0], \numLoops, 3]); // ends after 3 loops

// We might want to loop a file for a yet-undetermined amount of time, but ensure that it stops at the end of a loop cycle, regardless of when a stopping message is sent. This can be done by comparing the live value of Phasor against a threshold value near the end of its cycle. In the example below, the comparison signal is named 'trig,' and the threshold is a value in frames that represents 0.01 seconds before the final frame of the buffer. If Phasor is beyond (i.e. greater than) this threshold, trig changes from false to true, represented on the server as a change from 0 to 1, which constitutes a trigger.

// Before we complete the SynthDef, we can test our trigger by using a sine tone to sonify it. This is a clever debugging strategy that helps ensure a trigger signal is behaving correctly. In the following code, you will hear a short 2kHz tone one hundredth of a second before the end of each loop:

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, nbeats = 4, bpm = 104, amp = 0.5, out = 0;
	var sig, phs, env, trig;
	rate = rate * BufRateScale.kr(buf);
	phs = Phasor.ar(rate: SampleDur.ir * (bpm / 60), start: 0, end: nbeats);
	phs = phs.linlin(0, nbeats, 0, BufFrames.kr(buf));
	trig = phs > (BufFrames.kr(buf) - (SampleRate.ir * 0.01));
	sig = BufRd.ar(2, buf, phs);
	sig = sig * amp;

	// add a 2kHz tone to the output signal each time a trigger is generated
	sig = sig + SinOsc.ar(2000, mul: Env.perc(0.001, 0.1).ar(gate: trig) * 0.5 ! 2);

	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

x.free;

// Once we confirm that our trigger works properly, we can use the comparison value to trigger a short terminating envelope. Before it is supplied to the envelope, we multiply the trigger by a new argument named 'end.' If end equals zero, the trigger is also zero, so it is effectively "muted" and ignored. If end equals one, the trigger passes through to the envelope, and the sound will end.

(
SynthDef(\bufrd, {
	arg buf = 0, rate = 1, nbeats = 4, bpm = 104, end = 0, amp = 0.5, out = 0;
	var sig, phs, env, trig;
	rate = rate * BufRateScale.kr(buf);
	phs = Phasor.ar(rate: SampleDur.ir * (bpm / 60), start: 0, end: nbeats);
	phs = phs.linlin(0, nbeats, 0, BufFrames.kr(buf));
	trig = phs > (BufFrames.kr(buf) - (SampleRate.ir * 0.01));
	trig = trig * end; // ignored if end = 0, passed if end = 1
	sig = BufRd.ar(2, buf, phs);
	env = Env([1, 0], [0.01], [-1]).ar(2, trig);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth(\bufrd, [buf: b[\drums][0]]);

x.set(\end, 1); // evaluate, and playback will stop at the end of the current loop