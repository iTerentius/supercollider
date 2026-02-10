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
        one_shot: 5,  
        greewl: 6,  
        cc: 15
    ),
    cc: (
        mod1: 20, 
        mod3: 22, 
        mod4: 23, 
    )
);

if(~link.notNil) { ~link.tempo = ~cfg.tempo };
)
