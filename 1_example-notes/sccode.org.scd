(
// the arg direct will control the proportion of direct to processed signal
SynthDef("tutorial-DecayPink", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of PinkNoise. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(1, 0.25), 0.01, 0.2, PinkNoise.ar);
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-DecaySin", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of a modulating sine wave. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(0.3, 0.25), 0.3, 1, SinOsc.ar(SinOsc.kr(0.2, 0, 110, 440)));
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("tutorial-Reverb", { arg outBus = 0, inBus;
    var input;
    input = In.ar(inBus, 1);

    // a low-rent reverb
    // aNumber.do will evaluate its function argument a corresponding number of times
    // {}.dup(n) will evaluate the function n times, and return an Array of the results
    // The default for n is 2, so this makes a stereo reverb
    16.do({ input = AllpassC.ar(input, 0.04, { Rand(0.001,0.04) }.dup, 3)});

    Out.ar(outBus, input);
}).add;

b = Bus.audio(s,1); // this will be our effects bus
)

(
x = Synth.new("tutorial-Reverb", [\inBus, b]);
y = Synth.before(x, "tutorial-DecayPink", [\effectBus, b]);
z = Synth.before(x, "tutorial-DecaySin", [\effectBus, b, \outBus, 1]);
)

// Change the balance of wet to dry
y.set(\direct, 1); // only direct PinkNoise
z.set(\direct, 1); // only direct Sine wave
y.set(\direct, 0); // only reverberated PinkNoise
z.set(\direct, 0); // only reverberated Sine wave
x.free; y.free; z.free; b.free;




(
// make two control rate busses and set their values to 880 and 884.
b = Bus.control(s, 1); b.set(110);
c = Bus.control(s, 1); c.set(884);
// and make a synth with two frequency arguments
x = SynthDef("tutorial-map", { arg freq1 = 440, freq2 = 440;
    Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
}).play(s);
)
// Now map freq1 and freq2 to read from the two busses
x.map(\freq1, b, \freq2, c);

// Now make a Synth to write to the one of the busses
y = {Out.kr(b, SinOsc.kr(1, 0, 50, 880))}.play(addAction: \addToHead);

// free y, and b holds its last value
y.free;

// use Bus-get to see what the value is. Watch the post window
b.get({ arg val; val.postln; f = val; });

// set the freq2, this 'unmaps' it from c
x.set(\freq2, f / 2);

// freq2 is no longer mapped, so setting c to a different value has no effect
c.set(200);

x.free; b.free; c.free;