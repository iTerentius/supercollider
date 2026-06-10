~stopDelugeClock.();
~startDelugeClock.();
~mOut;
~maschineOut;
~maschineOut.noteOn(1, 36, 100)
~delugeOut.noteOn(0, 36, 100)
~delugeOut.noteOff(0, 36, 100)
MIDIClient.destinations.do { |ep, i| [i, ep.device, ep.name].postln};
(
Routine({
      (24..60).do { |note|
          ~maschineOut.noteOn(1, note, 100);
          0.3.wait;
          ~maschineOut.noteOff(0, note);
      };
  }).play;
)
Pdef(\bassline).play(~link);
Pdef(\arp).play(~link);
Pdef(\kit).play(~link);
Pdef(\bassline).stop(~link);
Pdef(\arp).stop(~link);
Pdef(\kit).stop(~link);
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
Pdef(\kk,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     0,            // Deluge synth track (0-indexed)
        \scale,    Scale.dorian,  
        \octave,  5,  
        \degree,   Pseq([0, 1,  \,  0,  0], inf), 
        \dur,      1/2, 
        \amp,      0.8,
        \vel,     Pkey(\amp), 
        \stretch, Pseq([1,  1/2], inf), 
        // \legato,  Pwhite(0.5, 2,   inf),  
    )
);
// ~song[1] = { ~toggle.(\bassline) };
~song[1] = { ~toggle.(\kk, 2) };

// ---- arp: generative, loops until toggled off  [BEACON id=2]
Pdef(\sn,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     1,
        \scale,  Scale.dorian,  
        \octave,  5,  
        \degree,  0,  
        \dur,      1, 
        \amp,      0.6,
        \vel,     Pkey(\amp), 
        \stretch, Pseq([1,  2], inf), 
        // \legato,  Pwhite(0.5, 2,   inf),  
    )
);
~song[2] = { ~toggle.(\sn,  1) };

// ---- pad: sustained chords, toggled  [BEACON id=3]
Pdef(\hh,
    Pbind(
        \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     2,
        \octave, 3, 
        \scale,  Scale.dorian, 
        // \midinote, Pseq([[48, 55, 60], [46, 53, 58], [43, 50, 55]], inf),
        // \degree,  Pseq([[0!3].flat, [\],  [0, 1], [0,  2]], inf), 
        \degree,  0,  
        \dur,      1/2,
        \amp,      0.6,
        \sustain,  1.8,
        \stretch,  Pseq([1/2, 1,  2], inf), 
        // \stretch, Pseg([1/4,  1,  1/8], [2, 2], \sin, inf), 
    )
);
~song[3] = { ~toggle.(\hh) };

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
);
