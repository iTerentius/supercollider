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
Pdef(\bassline,
    Pbind(
        // \type,     \midi,
        // \midiout,  ~delugeOut,
        // \chan,     0,            // Deluge synth track (0-indexed)
        \instrument,  \modelD,  
        \scale,    Scale.dorian,  
        \octave,  3,  
        \degree,   Pseq([0, 1], inf), 
        \dur,      1/2, 
        \amp,      0.8,
        // \stretch, Pseq([1,  2], inf), 
        // \legato,  Pwhite(0.5, 2,   inf),  
        \out, ~t1.inbus.index,  
    )
);
// ~song[1] = { ~toggle.(\bassline) };
~song[1] = { ~oneshot.(\bassline, 2) };

// ---- arp: generative, loops until toggled off  [BEACON id=2]
Pdef(\arp,
    Pbind(
        \instrument,  \neutron, 
        // \type,     \midi,
        \midiout,  ~delugeOut,
        \chan,     1,
        \scale,  Scale.dorian,  
        \octave,  Pseq([4,  5], inf),  
        \degree,  Pslide((0..7),  inf,  2,  3), 
        \dur,      1/2, 
        \amp,      0.6,
        \vel,     Pkey(\amp), 
        \stretch, Pseq([1/4,  1,  2], inf), 
        // \legato,  Pwhite(0.5, 2,   inf),  
        \out, ~t2.inbus.index,  
    )
);
~song[2] = { ~oneshot.(\arp,  3) };

Pdef(\bd, 
  Pbind(
  
  )
)

"norns-song-template: handlers registered".postln;
);
