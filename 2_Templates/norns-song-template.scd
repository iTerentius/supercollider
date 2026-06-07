(
// norns-song-template.scd
// Load this after norns-router.scd (which defines ~song, ~delugeOut,
// ~play, ~stop, ~toggle, ~oneshot).
// Only define Pdefs and register ~song handlers here — nothing else.
//
// Keys in ~song match the integer ID set on each BEACON cell in arcologies (1-99).
// The number is the only contract between Norns and SC — name your Pdefs however
// you like on the SC side.

// ---- bassline: loops until toggled off  [BEACON id=1]
Pdef(\bassline,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     0,            // Deluge synth track (0-indexed)
        \midinote, Pseq([36, 36, 43, 36, 36, 48, 46, 43], inf),
        \dur,      Pseq([0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5], inf),
        \amp,      0.8,
        \sustain,  0.1,
    )
);
~song[1] = { ~toggle.(\bassline) };

// ---- arp: generative, loops until toggled off  [BEACON id=2]
Pdef(\arp,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     1,
        \midinote, Prand([60, 63, 65, 67, 70, 72], inf),
        \dur,      Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
        \amp,      Pwhite(0.5, 0.9),
        \sustain,  0.08,
    )
);
~song[2] = { ~toggle.(\arp) };

// ---- pad: sustained chords, toggled  [BEACON id=3]
Pdef(\pad,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     2,
        \midinote, Pseq([[48, 55, 60], [46, 53, 58], [43, 50, 55]], inf),
        \dur,      2,
        \amp,      0.6,
        \sustain,  1.8,
    )
);
~song[3] = { ~toggle.(\pad) };

// ---- fill: one-shot, plays for 2 bars then stops automatically  [BEACON id=4]
Pdef(\fill,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     3,
        \midinote, Pseq([60, 63, 65, 67, 65, 63, 60, 58, 55, 53, 50, 48, 50, 53, 55, 58], 1),
        \dur,      0.5,
        \amp,      0.85,
        \sustain,  0.12,
    )
);
~song[4] = { ~oneshot.(\fill, 2) };

// ---- chaos: weighted generative  [BEACON id=5]
Pdef(\chaos,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     4,
        \midinote, Pwrand(
            [36, 43, 48, 55, 60, 67, 72, 79],
            [0.2, 0.2, 0.2, 0.15, 0.1, 0.08, 0.05, 0.02].normalizeSum,
            inf
        ),
        \dur,      Pwrand([0.25, 0.5, 1.0], [0.5, 0.35, 0.15], inf),
        \amp,      Pwhite(0.4, 1.0),
        \sustain,  Pkey(\dur) * 0.5,
    )
);
~song[5] = { ~toggle.(\chaos) };

"norns-song-template: handlers registered".postln;
)
