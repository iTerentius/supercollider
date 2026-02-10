// Melody
(
Pdefn(\shot_1, Pseq([0], 1));

Pdef(\mel,
    Pbindef(\mel_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.mel,
        \root, Pkey(\root),
        \scale, Pkey(\scale),
        \octave, 5,
        \degree, Pseq([0, 2, 4, 1], inf),
        \amp, 0.5,
        \dur, Pseq([1/4!3,  Rest(1/4), 1/2, 1/4!2].flat, inf),
    )
);

Pdef(\wobble_1,
    Pbindef(\wobble_1_pbd,
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.one_shot,
        // \root, Pkey(\root),
        \root,  0,  
        // \scale, Pkey(\scale),
        \scale, Scale.minor,  
        \octave, 3,
        // \delta, 1/2,  
        \degree, Pseq([\, 0], inf),   
        \amp, 1,
        \dur, 4,
    )
);

Pdef(\greewl,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.one_shot,
        // \root, Pkey(\root),
        \root,  0,  
        // \scale, Pkey(\scale),
        \scale, Scale.minor,  
        \octave, Pseq([4, 5, 6, Pn(Rest(),  8)], inf),
        \delta, 1/6,  
        \degree, Place([Pn(Rest(),  4), [Pwhite(0,  7,  1)]], inf),   
        \amp, 1,
        \dur, 1,  
    )
);
)
// Pdef(\greewl).clear;
// Pdef(\wobble_1).play(~link);
