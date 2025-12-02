(
Pdefn(\chord_harm,  PHarmony(
  [\minor, \major7,  \diminished], 
  [\updown, \blossomup]
));
)
(
Pdefn(\dorHarm,
    Pseq([
        PHarmony(\minor7),    // e.g. i
        PHarmony(\major7),    // something for IV
        PHarmony(\minor7),    // vi-ish
        PHarmony(\major7)     // etc
    ], inf)
);
)
(
Pdefn(\chord_harm, PChordProgression(chords:  "I V vi IV",  midiNoteOffset:   0,  arpStyle:  \chords, repeats:  inf));
)

(
Pbindef(\chord, 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      2,
  \root,      5, 
  \scale,     Scale.dorian,  
  \amp,       0.8,
  // \octave,    Prand([4, 3,   ], inf),
  \octave,   Prand([4,3, 4,  3],  inf),  
  // \degree,    Pseq([0, 3,  4,  5, Pn(Rest(),  1)], inf), 
  // \degree,    Pxrand([0, 2,  4,  7, ], inf), 
  \degree,   Pseq([\Em, \B,  \C,   \A,  ].chordProg,  inf).stutter(4), 
  \sustain,  1.1, 
  \dur,      1, 
);
)
(
Pdef(\chordLine,
    Pbind(
        \type,    \midi,
        \midiout, ~mOut,
        \chan,    2,
        \scale,  Scale.dorian,
        \root,  5, 
        \octave,  3,  
        \degree, Pseq([
                \E.asDegrees(Scale.dorian), Prand([0, \], 1),   
                \B.asDegrees(Scale.dorian), Prand([4, \], 1),  
                \C.asDegrees(Scale.dorian), Prand([5, \], 1), 
                \A.asDegrees(Scale.dorian), Prand([3, \], 1),   
                // Pn(Rest(),  4), 
            ],  inf).flatten,  

        \amp,     0.8,
        \dur,     1/2,
        // \sustain, 4
    )
);
)
Pdef(\chordLine).play(~link, quant:4);
Pdef(\chordLine).stop;
Pdef(\chordLine).clear;


Pbindef(\chord).play(~link,  quant:1);
Pbindef(\chord).stop;

Pbindef(\chord, \octave,  3);
Pbindef(\chordLine, \dur,  Pseq([Pn(Pseq[1/2],18), Pn(Rest(), 6)],  inf),    \sustain,  3/4);

(

)
