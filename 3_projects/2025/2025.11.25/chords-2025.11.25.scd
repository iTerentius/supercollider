(
Pdefn(\chord_harm,  PHarmony(
  [\minor, \major,  \diminished], 
  // [\updown, \blossomup]
  \up
),  inf);
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
  \chan,      3,
  \root,      5, 
  \scale,     Scale.dorian,  
  \amp,       Pwhite(0.1, 0.3,  inf),
  \octave,    3,
  // \octave,   Prand([4,3, 4,  3],  inf),  
  // \degree,    Pseq([0, 3,  4,  5, Pn(Rest(),  1)], inf), 
  \degree,    Pxrand([0, 3,  6,  1, ], inf), 
  // \degree,   Pseq([\E, \B,  \C,   \A,  ].chordProg,  inf), 
  \ctranspose,   Pn(Pdefn(\harm), inf),  
  \strum,  0.12,  
  \sustain,  17, 
  \dur,      16, 
);
)
Pbindef(\chord).play(~link,  quant:1);
Pbindef(\chord).stop;
Pbindef(\chord).clear;

(
Pdef(\chordLine,
    Pbind(
        \type,    \midi,
        \midiout, ~mOut,
        \chan,    3,
        \scale,  Scale.dorian,
        \root,  5, 
        \octave,  4,  
        // \degree, Pseq([
        //         \Em7.asDegrees(Scale.dorian), \,   
        //         \B7.asDegrees(Scale.dorian), \,  
        //         \C.asDegrees(Scale.dorian), \, 
        //         \A.asDegrees(Scale.dorian), \,   
        //         // Pn(Rest(),  4), 
        //     ],  inf).flatten.stutter(8),  
        \degree,  Pn(Pdefn(\harm),  inf),  
        // \degree,  Pseq([0,  3,  7,  \],  inf).stutter(1), 
        \amp,     0.8,
        \dur,     2,
        // \sustain, 8.1,  
    )
);
)
Pdef(\chordLine).play(~link, quant:4);
Pdef(\chordLine).stop;
Pdef(\chordLine).clear;


Pbindef(\chord).play(~link,  quant:1);
Pbindef(\chord).clear;

Pbindef(\chord, \octave,  3);
Pbindef(\chordLine, \dur,  Pseq([1/8,  1/4,  1/8, 1/2],  inf));

(
Pdefn(\harm, Pseq([
    PHarmony(\minor7), 
    // Rest(),      // i7
    PHarmony(\dominant7),
    // Rest(),        // V7
    PHarmony(\major7),
    // Rest(),       // bVImaj7
    PHarmony(\major),        // IV
    // Pn(Rest(),  4), 
],   1));
)

// Simple chord progression
(
Pbindef(\test,  
  // \instrument,   \bass8,  
  \octave,  5,  
  \scale,  Scale.dorian,  
	\degree, Pseq([0], inf),
  \ctranspose, Pn(Pdefn(\harm), inf),  
  // \degree,   Pdefn(\chord_harm),  
    \dur, 1 
).play;
)
Pbindef(\test).clear;

// Complex arpeggiation
(
Pbind(
    \ctranspose, PHarmony(
        [\major, \minor7, \diminished],
        [\blossomup, \updown, \random]
    ),
    \dur, 0.125
).play;
)

// Combining with other patterns
(
Pbind(
    \degree,  Pseq([0,  4,  7], inf), 
    \octave,  4,  
    \ctranspose, Pseq([

        // Major chord
        PHarmony(\major),

        // Major 9
        PHarmony(\major9),

        // Major 9 with chord operations
        PHarmony(Harmony(\major9).withDouble(\root, octaves: -1).withInversion(\first))
    ], inf),
    \dur, 0.5
).play;
)
Harmony.all
(
TempoClock.default.tempo = 84/60;

p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Pseq(#[rest, 4, 3, 4, 2, 4, 1, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2, 4,
        -3, 4, -1.9, 4, -0.9, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2], 1),
    \dur, 0.25
).play;
)

(
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Place([#[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2],
        (4 ! 16) ++ \rest], 17),
    \dur, 0.25
).play;
)

(
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Ppatlace([Pseq(#[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2], 1),
        Pn(4, 16)], inf),
    \dur, 0.25
).play;
)
(
p = Pbind(
    \degree, Pseries(7, Pwhite(1, 3, inf) * Prand(#[-1, 1], inf), inf).fold(0, 14)
        + Prand(#[[0, -2, -4], [0, -3, -5], [0, -2, -5], [0, -1, -4]], inf),
    \dur, Pwrand(#[1, 0.5], #[0.8, 0.2], inf)
).play;
)

p.stop;
~samp = ~samplesTree.at(\_mono).asArray[0];
~samp.bufnum;
~samplesTree[\_mono][0];
b;
// b = Buffer.read(s, "/Users/isaaclinder/Music/supercollider/_samples/_mono/hoarder_mono/04-6-rats.wav");
b = Buffer.read(s, "/Users/isaaclinder/Music/supercollider/_samples/_mono/are-you-guys-hungry.wav");
~loadSamplesRecursive.("~/Music/supercollider/_samples/_mono/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/_mono/hoarder_mono/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Codeine_Drum_Kit/DrumLoops/");
~samp= ~samplesTree[\_mono][\Ya_Ya_125bpm_Vox];
~samp= ~samplesTree[\jttcot][\04];
~samp= ~samplesTree.at(\jttcot).asArray;
~samp= ~samplesTree.at(\hoarder_mono).asArray[20];
~samp= ~samplesTree[\drumloops][\DrumLoop_DeepSea_93BPM];
~samp= ~samplesTree[\drumloops][\DrumLoop_Sprite1_120BPM];
(
SynthDef(\stretchedFragments, { |out, bufnum, start, time = 1, stretch = 1, amp = 1, attack = 0.01, decay = 0.05|
    var sig = PlayBuf.ar(1, bufnum, rate: stretch.reciprocal, startPos: start), eg;
    sig = PitchShift.ar(sig, pitchRatio: stretch);
    eg = EnvGen.kr(Env.linen(attack, time, decay), sig.abs > 0, doneAction: Done.freeSelf);
    Out.ar(out, (sig * eg) ! 2)
}).add; // note add! Without this, arguments won't work
)

(
// TempoClock.default.tempo = 1;

~samp= ~samplesTree[\jttcot][\00];
Pbindef(\st,  
    \instrument, \stretchedFragments,
    \bufnum, ~samp,   
    \start, Pwhite(0, (~samp.numFrames * 0.7).asInteger, inf),
    \delta, Pexprand(0.2, 2.5, inf),
    \time, Pkey(\delta),
    \stretch, Pexprand(1.0, 2.0, inf),
    \amp, 0.5,
    \attack, 0.1,
    \decay, 0.2
);
)
Pbindef(\st).play(~link,   quant:4);
Pbindef(\st).stop;
Pbindef(\st).clear;
