// Configuration - MIDI channels, CC numbers, tempo
(
~cfg = (
    tempo: 110/60,

    // MIDI channels
    ch: (
        kit: 0,
        bass: 1,
        mel1: 2,
        mel2: 3,
        chords: 4,
        drone: 5,
        cc: 15
    ),

    // CC numbers
    cc: (
        mod1: 20,
        mod2: 21
    )
);

// Apply tempo
~link.tempo = ~cfg.tempo;
)
