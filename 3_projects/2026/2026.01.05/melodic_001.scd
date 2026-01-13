~link.tempo = 110/60;

~mOut.control(15, 21, 127);


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
Pbindef(\mel_1, 
  \type, \midi, \midiout, ~mOut, \chan, [2,/* 1, 3*/], 
  \scale, Scale.minor,
  \root,  Pn(Pdefn(\root_degs), inf), 
  \div,  Pseq([4], inf),        // Change subdivision every step
  \step1, Pseq([9,  7,  5,  3], inf),
  \octave,  Pseq([6, ], inf),   
  \legato,  1,  
  // \degree, Pseq([4, 2,  0,  -2, 0,  1,  0   ],  1),   
  \degree,   Pser([4, 2, \,  0], Pkey(\step1)),  
  \amp, Pwhite(0.1, 0.1,  inf),
  \vel, Pkey(\amp), 
  \dur, 1/Pkey(\div),      
);

Pbindef(\mel_2, 
  \type, \midi, \midiout, ~mOut, \chan, [3,/* 2, 1 */],
  \scale, Scale.minor,
  \root,  Pn(Pdefn(\root_degs), inf), 
  \div,  Pseq([4, 8], inf),        // Change subdivision every step
  \step1, Pseq([9,  7,  5,  3], inf),
  \octave,  Pser([ 4!6, 5!2].flat, inf),   
  \degree, Pseq([0!3, 4,  2].flat, inf), 
  // \degree, 0, 
  \legato,  Pkey(\dur)/Pkey(\delta), 
  // \legato,   nil, 
  \amp, 0.3,
  \vel,  Pkey(\amp), 
  // \delta, Pseq([1,  2, ], inf)/(Pkey(\div)),
  \delta, 4/Pkey(\div)*2,
  \dur, Pfunc { Pdefn(\root_degs).source.list.size * 1/Pkey(\div) }, 
);

// Define the bass child
Pbindef(\bass_1,  
  \type, \midi, \midiout, ~mOut, \chan, 1,/*  3,  2,  0*/
  \scale, Scale.minor,
  \root,  Pn(Pstep(Pdefn(\root_degs), 4), inf), 
  \div,  Pseq([4], inf),        // Change subdivision every step
  \step1, Pseq([9,  7,  5,  3], inf),
  \legato, Pkey(\div)*Pseq([0.1,1.0], inf).stutter(4),    
  // \degree, Pseq([4, 0!4, 2].flat, inf), 
  \degree,  0,  
  // \octave,  Pseq([ 3, 4].flat, 4),     
  // \octave,  2,  
  \octave, 3,
  // Example: Use parent's 'div' to control speed
  \amp, Pwhite(0.2, 0.6,  inf),
  \vel, Pkey(\amp),
  \delta, Pbjorklund2(Pkey(\step1), 8,  inf)/Pkey(\div),  
  \dur, Pfunc { Pdefn(\root_degs).source.list.size }
);


// Bindings
if(~lpMini.notNil){
  ~lpBind.([1, 2], \bass_1, 20, ~link, 4);
  ~lpBind.([1, 3], \mel_1, 21, ~link, 4);
  ~lpBind.([1, 4], \mel_2, 23, ~link, 4);
  ~lpBind.([1, 5], \drone, 33, ~link, 4);
  ~lpBind.([8, 1], \cc_mod_1, 45, ~link, 4);
  ~lpBind.([8, 2], \cc_mod_2, 45, ~link, 4);
  // ~lpBind.([8, 8], \all, 9, ~link, 4);
  ~lpBind.([2,  8], {Pbindef(\bass_1,  \degree,  Pseq((0..7),  inf));});
  ~lpBind.([3,  8], {Pbindef(\bass_1,  \delta,  1/4);});
  // ~lpBind.([4,  8], {Pbindef(\bass_1,  
  //   \dur, Pfunc { Pdefn(\root_degs).source.list.size };
  // });
}
)
Pbindef(\bass_1).play(~link);
Pbindef(\bass_1).stopQ(4);
Pbindef(\mel_2).play(~link);
Pbindef(\mel_2).stopQ(4);

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
    \type, \midi, \midiout, ~mOut, \chan, 5,  
    // \root,  Pn(Pdefn(\root_degs), inf),  
    // \delta, Pseg(Pseq([1/2, 1/4], inf), Pseq([1, 1/2], inf), \step, inf),   
    // \delta, Pseq([1/4!4, 1/2, Rest(3.5), ].flat, inf),  
    // \delta, 1/6,  
    \scale, Scale.minor, 
    \octave,  Pseq([5,   ], inf),   
    \degree,  Place([0, [2, 4,  7], ], inf),  
    // \delta, Pkey(\dur) / 1,   
    // \dur, Pseq([4], inf),   
    \dur, Pn(Pseq([1/8, 1/2, 1/4!2].flat).fitToBar(4), inf),    
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
 \delta,  2,  
 \dur, 4,  
));
)
Pdef(\chords).play(~link);
Pdef(\chords).stopQ(4);

(
// Complex logic hidden: 
// "Play this rhythm. If it finishes early, wait. Reset every 4 beats."
Pbindef(\melody,
 \type, \midi, \midiout, ~mOut, \chan, 4,  
 \scale,   Scale.minor,
 \dur, Pseq([0.25, 0.25, 0.5]).fitToBar(4), // <--- CLEAN!
 \degree, Pseq([0, 1, 2], inf) + Pdefn(\root_degs), 
);
)
Pbindef(\melody).play(~link);
