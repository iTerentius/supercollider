(
Pdefn(\chord_deg, PChordProgression(\chords,  "I V vi IV",  \midiNoteOffset,   48,  \arpStyle,  \chords,  inf));
)
(
Pdefn(\chord_harm,  PHarmony(
  [\minor, \major7,  \diminished], 
  [\updown, \blossomup]
));
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
  \octave,   Pseq([4,3, 4],  inf),  
  // \degree,    Pseq([0, 3,  4,  5, Pn(Rest(),  1)], inf), 
  \degree,    Pseq([0, 3,  4,  5, ], inf), 
  \ctranspose,   Pn(Pdefn(\chord_harm)), 
  \sustain,  2, 
  \dur,      1, 
);
)
Pbindef(\chord).play(~link,  quant:1);
Pbindef(\chord).stop;
