// Configuration
(
~cfg = (
    tempo: 100/60,
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

if(~link.notNil) { ~link.tempo = ~cfg.tempo };
)
