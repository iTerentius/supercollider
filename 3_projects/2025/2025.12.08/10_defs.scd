
(
// 2025-12-08 08_20 track template defs

// Map track level names to existing MixerChannels or busses
// Edit this to point at your actual drum channel or stem

~track_bd_out_2025_12_08 = {
    var chan;
    // Example using a MixerChannel named t1
    chan = ~t1;  // replace with your drum channel object
    chan.bus.index;
}.value;

// Optional track specific SynthDef example for a non percussive instrument

SynthDef(\t2025_12_08_pad, { |out, freq = 220, amp = 0.1, atk = 0.01, rel = 0.5|
    var env, sig;
    env = EnvGen.kr(Env.linen(atk, 0.1, rel), doneAction: Done.freeSelf);
    sig = Saw.ar(freq) * env * amp;
    Out.ar(out, sig ! 2);
}).add;
)
