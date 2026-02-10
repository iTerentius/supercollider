// CC Automation
(
Pdef(\cc_mod_1,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.cc,
        \midicmd, \control,
        \ctlNum, ~cfg.cc.mod1,
        \dur, 1/16,
        \control, Pseg([0, 127, 0], [4, 4], \sin, inf)
    )
);

Pdef(\cc_mod_2,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.cc,
        \ctlNum, ~cfg.cc.mod1,
        \dur, 1/3,
        \delta, 1,  
        \note, Pseq([0,  127], inf), 
    )
);

Pdef(\cc_mod_3,
    Pbind(
        \type, \midi, \midiout, ~mOut, \chan, ~cfg.ch.cc,
        \ctlNum, ~cfg.cc.mod3,
        \dur, Pseq([8,  16],  inf), 
        \note, Pseq([0,  127], inf).fitToBar(8), 
        // \delta, 2,  
    )
);

Pdef(\lfoRM,
    Pbind(
        \type, \midi,
        \midicmd, \control,
        \midiout, ~mOut,  
        \chan, ~cfg.ch.cc, // MIDI channel
        
        // CC number - you'll need to MIDI learn this in Bitwig
        \ctlNum, ~cfg.cc.mod4, // arbitrary CC number, map this to your LFO Rate parameter
        
        // The actual modulation value (0-127)
        \control, Pseq([
            // Fast wobble section
            // Pseq([127], 16), // high rate value
            
            // Slowdown section
            // Pseries(70, -8, 16), // gradually decrease from 127 to 0 over 16 steps
            
            // Slow section
            // Pseq([0], 8), // very slow/stopped
            Pexprand(70, 10, inf).round(1)
            // Pwhite(20,  70, inf)
            // Snap back to fast
            // Pseq([127], 16),
        ], inf),
      //   \control, Pseq([
      //     127, 127, 127, 127, // fast
      //     100, 100, 100, 100, // medium
      //     70, 70, 70, 70,     // slower
      //     40, 40, 40, 40,     // very slow
      //     0, 0, 0, 0,         // stopped
      //     127,                // snap back
      // ], inf),
      //   
        \dur, 1/4, // send CC every 1/8 note
    )
);
)

