// Configuration
(
~cfg = (
    tempo: 120/60,
    ch: (
        kit: 0,
        bass: 1,
        mel: 2,
        pad: 3,
        synth: 4,  // composite: MIDI + SC
        cc: 15
    ),
    cc: (
        mod1: 20
    )
);

~link.tempo = ~cfg.tempo;
)
