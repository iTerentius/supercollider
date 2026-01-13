~link.tempo = 110/60;
Pdef(\voices).play(~link); Pdef(\perc_1_m).play(~link); Pdef(\cc_mod_1).play(~link); Pdef(\cc_mod_2).play(~link);
Pdef(\voices).stopQ(8); Pdef(\perc_1_m).stopQ(4); Pdef(\cc_mod_1).stopQ(4); Pdef(\cc_mod_2).stopQ(4);
Pdef.clear;

Pdef(\voices).play(~link);
Pdef(\voices).stopQ(8);
Pdef(\perc_1_m).play(~link);
Pdef(\perc_1_m).stopQ(4);
Pdef(\cc_mod_1).play(~link);
Pdef(\cc_mod_1).stopQ(4);
Pdef(\cc_mod_2).play(~link);
Pdef(\cc_mod_2).stopQ(4);

~mOut.control(15, 21, 127);

Pdef(\bass_1).play(~link);

(
Pdef(\cc_mod_1, Pbind(
  \type,  \midi,  \midiout, ~mOut,  \chan,  15,  \midicmd, \control, 
  \ctlNum, 20,            // Mod Wheel
  \dur, 1/16,            // High resolution (32 messages per beat)
  \control, Pseg([0, 127, 127,  0], [4, 4,  4], \sin, inf)
));

Pdef(\cc_mod_2, Pbind(
  \type,  \midi,  \midiout, ~mOut,  \chan,  15,  \midicmd, \control, 
  \ctlNum, 21,            // Mod Wheel
  \dur, 1/4,            // High resolution (32 messages per beat)
  \control, Pseg([0, 127, 0], [1, 4,], \sin, inf)
));

// Pdefn(\root_1_deg_0, Place([0, 1, [2, -1] ], 1));
Pdefn(\root_1_deg_0, Place([4, ], 1));
// Pdefn(\a000_deg_0, Pseq([\C3, \G3, \F3, \Eb3 ].flatten, 1));
Pdefn(\root_1_deg_1, Pseq([2, 1,  0, 1 ], 1));

Pdefn(\root_degs,  Pseq([
  Pn(Pdefn(\root_1_deg_0),  4), 
  Pn(Pdefn(\root_1_deg_1),  4), 
],  1));

// Define the melodic child
Pdef(\mel_1, 
  Pbindef(\mel_1_pbd, 
    \type, \midi, \midiout, ~mOut, \chan, [2,/* 1, 3*/], 
    
    \octave,  Pseq([6, ], inf),   
    // "Look Up" to the conductor for these values:
    \root, Pkey(\root), 
    \scale, Pkey(\scale),
    \legato,  1,  
    // Internal Logic
    // \degree, Pseq([4, 2,  0,  -2, 0,  1,  0   ],  1),   
    \degree,   Pser([4, 2, \,  0], Pkey(\step1)),  
    \amp, Pwhite(0.1, 0.1,  inf),
    \vel, Pkey(\amp), 
    \dur, 1/Pkey(\div),      
  )
);

Pdef(\mel_2, 
  Pbindef(\mel_2_pbd, 
    \type, \midi, \midiout, ~mOut, \chan, [3,/* 2, 1 */],
    
    \octave,  Pser([ 4!6, 5!2].flat, inf),   
    // "Look Up" to the conductor for these values:
    \root, Pkey(\root), 
    \scale, Pkey(\scale),
    
    // Internal Logic
    \degree, Pseq([0!3, 4,  2].flat, inf), 
    \amp, 0.3,
    \vel,  Pkey(\amp),  
    \dur, Pn(Pseq([1,  2, ], 1)/(Pkey(\div))).fitToBar(8),       
  )
);

// Define the bass child
Pdef(\bass_1, 
  Pbindef(\bass_1_pbd,  
    \type, \midi, \midiout, ~mOut, \chan, 1,/*  3,  2,  0*/
    // \octave,  Pseq([ 3, 4].flat, 4),     
    // \octave,  2,  
    \root, Pkey(\root),
    \scale, Pkey(\scale),
    \legato, Pkey(\div)*Pseq([0.1,1.0], inf).stutter(4),    
    // \degree, Pseq([4, 0!4, 2].flat, inf), 
    \degree,  0,  
    \octave, 3,
    // Example: Use parent's 'div' to control speed
    \amp, Pwhite(0.2, 0.6,  inf),
    \vel, Pkey(\amp),
    // \dur, Pkey(\delta), 
    \dur, Pbjorklund2(Pkey(\step1), 8,  inf)/Pkey(\div),  
  )
);

Pdef(\layers_1, Ppar([
    Pdef(\bass_1),
  ],  1), 
);

Pdef(\layers_2, Ppar([
    Pdef(\bass_1),
    Pdef(\mel_1),
  ]), 
);

Pdef(\layers_3, Ppar([
    Pdef(\bass_1),
    Pdef(\mel_1),
    Pdef(\mel_2),
  ]), 
);

Pdef(\voices, 
    Pbindef(\voices_pbd,  
        \type, \phrase, 
        \scale, Scale.minor,
        // \root, Pseq([0, 2, -2, 0], inf), // Change root every step
        \root,  Pn(Pdefn(\root_degs), inf), 
        \div,  Pseq([4], inf),        // Change subdivision every step
        \step1, Pseq([9,  7,  5,  3], inf),
        \legato,  1, 
        // \dur,  4,   //<---- Everything lasts N beats
        \dur, Pfunc { Pdefn(\kit_1_degs).source.list.size / 4}, 
        
        \instrument, Pseq([
            \layers_1,    
            \layers_2,   
            \layers_3,
            \chords,  
        ], inf),  
    )
);

Pdef(\all,  Ppar([
  Pdef(\voices),
  Pdef(\perc_1_m),
  Pdef(\cc_mod_1),  
  Pdef(\cc_mod_2),
],  inf));

// Bindings
if(~lpMini.notNil){
  ~lpBind.([1, 2], \voices, 20, ~link, 4);
  ~lpBind.([8, 1], \cc_mod_1, 45, ~link, 4);
  ~lpBind.([8, 2], \cc_mod_2, 45, ~link, 4);
  ~lpBind.([8, 8], \all, 9, ~link, 4);
  ~lpBind.([2,  8], {Pbindef(\bass_1_pbd,  \degree,  Pseq((0..7),  inf));});
  ~lpBind.([3,  8], {Pbindef(\bass_1_pbd,  \dur,  1);});
  ~lpBind.([4,  8], {Pbindef(\bass_1_pbd,  \dur, Pbjorklund2(Pkey(\step1), 8,  inf)/Pkey(\div));});
}
)

Pdef(\voices).play(~link); Pdef(\perc_1_m).play(~link); Pdef(\cc_mod_1).play(~link); Pdef(\cc_mod_2).play(~link);
Pdef(\voices).stopQ(8); Pdef(\perc_1_m).stopQ(4); Pdef(\cc_mod_1).stopQ(4); Pdef(\cc_mod_2).stopQ(4);
Pdef.clear;
\E4.asDegree.postln;
Pdef(\voices).play(~link);
Pdef(\voices).stopQ(8);

Pdef(\perc_1_m).play(~link);
Pdef(\perc_1_m).stopQ(4);

Pdef(\cc_mod_1).play(~link);
Pdef(\cc_mod_1).stopQ(4);
Pdef(\cc_mod_2).play(~link);
Pdef(\cc_mod_2).stopQ(4);
~mOut.control(15, 21, 127);

~link.tempo = 110/60;

(
Pdef(\tempoUp,  Pbind(
  \tempo, Pseg((880..110)/60, 1),
  \dur, (1/16),    
));
)
Pdef(\tempoUp).play(~link);


(
Pdef(\drone,   Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 4,  
    \root,  Pn(Pdefn(\root_degs), inf),  
    // \delta, Pseg(Pseq([1/2, 1/4], inf), Pseq([1, 1/2], inf), \step, inf),   
    // \delta, Pseq([1/4!4, 1/2, Rest(3.5), ].flat, inf),  
    \delta, 1/6,  
    \scale, Scale.minor, 
    \octave,  Pseq([6, 5,   ], inf),   
    \degree,  Place([0, [2, 4,  7]], inf),  
    \dur, Pseq([2,  4], inf),   
));
)
Pdef(\drone).play(~link);
Pdef(\drone).stop;

(
Pdefn(\harms,  PHarmony(
  [\minor, \minor,  \major, \major],  
  // \blossomup, 
));
Pdef(\chords, Pbind(
 \scale,   Scale.minor,
 // \delta,  1,  
 // \root,  Pn(Pdefn(\root_degs), inf), 
 \degree, Pn(Pdefn(\root_degs), inf), 
 \type, \midi, \midiout, ~mOut, \chan, 4,  
 \ctranspose,  Pn(Pdefn(\harms), inf),
 \dur, 4,  
));
)
Pdef(\chords).play(~link);
Pdef(\chords).stopQ(4);
