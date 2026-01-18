// Synth - composite output to both MIDI and SC engine
(
// Simple SC synth for layering (customize as needed)
SynthDef(\pad_synth, {
    |out=0, freq=440, amp=0.3, gate=1, attack=0.1, release=1|
    var sig, env;
    env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
    sig = LFSaw.ar(freq * [1, 1.01], 0, amp);
    sig = LPF.ar(sig, freq * 2);
    Out.ar(out, sig * env);
}).add;

SynthDef(\lead_synth, {
    |out=0, freq=440, amp=0.3, gate=1, attack=0.01, release=0.3|
    var sig, env;
    env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
    sig = Pulse.ar(freq, 0.3, amp);
    sig = RLPF.ar(sig, freq * 4, 0.3);
    Out.ar(out, sig.dup * env);
}).add;
)

// Composite pattern - sends to MIDI AND plays SC synth
(
Pdef(\synth_layer,
    Pbindef(\synth_layer_pbd,
        \type, \composite,
        \types, #[\midi, \note],

        // Shared musical data
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 4,
        \degree, Pseq([0, 2, 4, 2], inf),
        \dur, 1/2,
        \legato, 0.9,
        \amp, 0.4,

        // MIDI-specific
        \midiout, ~mOut,
        \chan, ~cfg.ch.synth ? 4,

        // SC synth-specific
        \instrument, \pad_synth,
        \attack, 0.05,
        \release, 0.5,
    )
);

// MIDI-only version (for comparison/switching)
Pdef(\synth_midi,
    Pbindef(\synth_midi_pbd,
        \type, \midi,
        \midiout, ~mOut,
        \chan, ~cfg.ch.synth ? 4,
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 4,
        \degree, Pseq([0, 2, 4, 2], inf),
        \dur, 1/2,
        \amp, 0.4,
    )
);

// SC-only version
Pdef(\synth_sc,
    Pbindef(\synth_sc_pbd,
        \type, \note,
        \instrument, \pad_synth,
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 4,
        \degree, Pseq([0, 2, 4, 2], inf),
        \dur, 1/2,
        \amp, 0.3,
        \attack, 0.05,
        \release, 0.5,
    )
);
)
