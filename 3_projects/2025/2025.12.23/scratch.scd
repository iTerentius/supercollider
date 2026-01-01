~link.tempo = 120/60;
(
Pdefn(\b000_durs, Pn(Pdefn(\a000_durs), 1));
// Pdefn(\b000_durs, Pn(Pdefn(\a000_durs), inf));

Pdefn(\b000_deg0,  Pn(Pstep(Place([8, 1, 5, [\,  4,  2,  0,  ]], 1),  2), inf));
Pdefn(\b000_chan_a, Pseq([[2]],  1));
Pdefn(\b000_chan_b, Pseq([[2,  1]],  1));
Pdefn(\b000_chans,  Pseq([
  Pn(Pdefn(\b000_chan_b), 4), 
  // Pn(Pdefn(\b000_chan_b), 4), 
],  inf));

Pdef(\b000_m, Pbind( 
  \type,  \midi,  \midiout,  ~mOut, \chan,  Pdefn(\b000_chans),  \scale,  Scale.dorian,
  // \octave,  Pn(Pstep(Pseq([4!3, 5,  ].flat, 1),  1), inf),  
  \octave,  Pseq([3!3,   4,   ].flat,  inf),  
  \root,  0, 
  \amp,     Pn(Pxrand([0.7, 0.6],   1),  inf),
  \degree,  Pn(Pstep(Place([8, [\,  4,  2,  5,  ]], inf),  1), inf),
  \legato, Pkey(\dur)*2.2,  
  \dur,     Pn(Pstep(Pdefn(\b000_durs), 1), inf),  
));

Pbindef(\b100_fill, 
  \type, \midi, \midiout, ~mOut, \chan, 3, 
  \scale, Scale.dorian,
  \octave, Pseq([4, 5], 1),    
  \root,  0,  
  \legato, Pkey(\dur),  
  \degree, Place([Prand([0, 2, \], 1), Prand([-7, -4, -2, \], 1), Pn(Rest(), 1)], inf),
  // \degree, Pn(Pdefn(\b000_deg0),  1), 
  \amp, 0.6
);

Pbindef(\b100_main, 
    \type, \midi, \midiout, ~mOut, \chan, 3, 
    \scale, Scale.dorian,
    \root,  0,  
    \octave, Prand([3, ], inf),    
    \legato, Pkey(\dur),  
    \degree, Pn(Pdefn(\b000_deg0),  inf), 
    \amp, 0.8
);


Pdef(\b100_m, Pspawn(Pbind(
    \delta, Pn(Pdefn(\a000_durs), inf),
    \method, \par, // Use PAR so the grid is the boss.
    \pattern, Pfunc { |event|
        var d = event.delta;
        var pat;
        if(d.isRest) {
            pat = Pbind(\dur, d, \type, \rest);
        } {
            if(d > 0.6) {
                Pbindef(\b100_fill,  \dur, (d % Pseq([3, 1], inf)),  1);
                pat = Pbindef(\b100_fill); 
              } {
                Pbindef(\b100_main,  \dur, d * Pseq([2, 1/3],  inf));  
                pat = Pbindef(\b100_main);
            };
            Pfindur(d, pat)
        }
    }
)));

Pdefn(\a000_deg0, Pseq([[4, 2], [0,  15,  6],  [0, 4,  15], [0, 6, 15]], 1));
Pdefn(\a000_deg1, Place([5, [0, 6],  [1,  8,  ],  [0, 5, ],  [3, 4, 0]], 1));
  
Pdefn(\a000_deg1, Place([6, [8, 6],  [0,  8,  6],  [8, 6, 13],  [13, 9, ]], 1));

Pdefn(\a000_durm0, Pseq([1/3].flat,   1));
Pdefn(\a000_dur0, Pseq([2/3], 1)); 
Pdefn(\a000_dur1, Pseq([1/3!2, 2/3!2, Pn(Rest(),  1/3)].flat,   1)); 


Pdefn(\a000_degs,  Pseq([
  Pn(Pdefn(\a000_deg_k2), 4), 
  Pn(Pdefn(\a000_deg_k0), 4), 
  Pn(Pdefn(\a000_deg_k1), 4), 
  Pn(Pdefn(\a000_deg_k0), 4), 
], 1));

Pdefn(\a000_durs,  Pseq([
  Pn(Pdefn(\a000_durm0), 4), 
  Pn(Pdefn(\a000_dur0), 4), 
  Pn(Pdefn(\a000_durm0), 4), 
  Pn(Pdefn(\a000_dur1), 4), 
], 1));

Pdefn(\a000_phr0,
    Pseq([
        Pn(Pdefn(\a000_dur0), 2), 
        Pn(Pdefn(\a000_dur1), 2),
        Pn(Pdefn(\a000_dur3), 1),
    ], 1));  

Pdefn(\a000_phr1,
    Pseq([
        Pn(Pdefn(\a000_dur0), 4), 
        Pn(Pdefn(\a000_durm), 2), 
        Pn(Pdefn(\a000_dur1), 2),
        Pn(Pdefn(\a000_dur3), 1),
    ], 1));  

Pdefn(\a000_phr2,
    Pseq([
        Pn(Pdefn(\a000_durm), 1),
        // Pn(Pdefn(\a000_dur1), 1),
        Pn(Pdefn(\a000_dur2), 1)
    ], 1));

// sentences
Pdefn(\a000_phr, Pseq([
  Pn(Pdefn(\a000_phr0), 1),   
//   Pn(Pdefn(\a000_phr1), 1),   
//   Pn(Pdefn(\a000_phr2), 1),   
],  1));

Pdefn(\a000_deg_k0, 
  Pseq([
    [0], [\],  [\], [0], [\], [\],  [\], [\],
    [\], [\],  [\], [0], [1], [\],  [\], [\],
  ], 1));  

Pdefn(\a000_deg_k1, 
  Pseq([
    [0], [\],  [\], [0], [0], [4],  [1], [10],  
    [\], [1],  [\], [\], [0], [1],  [0], [3],  
  ], 1));  

Pdefn(\a000_deg_k2, 
  Pseq([
    [0], [\],  [\], [\], [0], [\],  [\], [\],  
    [\], [\],  [\], [\], [0], [\],  [0], [\],  
  ], 1));  
  
Pdefn(\a000_deg_hh0, 
  Pseq([
    [2], [\],  [2], [\],  
    [\], [2],  [2], [3],  
  ], 
  1));  

Pdefn(\a000_deg_hh1, 
  Pseq([
    [2], [\],  [\], [\],  
    [2], [\],  [2], [3],  
  ], 
  1));  

Pdefn(\a000_deg_hh2, 
  Pseq([
    [2], [\],  [\], [\],  
    [\], [\],  [\], [\],  
  ], 
  1));  

Pdefn(\a000_hh_degs,  
Pseq([
  Pn(Pdefn(\a000_deg_hh1),  4),  
  Pn(Pdefn(\a000_deg_hh0),  4), 
  Pn(Pdefn(\a000_deg_hh2),  4), 
],  1));

Pdef(\a000_m, Ppar([
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 0,
    \scale, Scale.chromatic, \octave, 3,
    \degree, Pn(Pdefn(\a000_degs),  inf), 
    \amp,    Pn(Pseq([0.99, 0.6, 0.8, 0.7], 1), inf),  
    // \amp,  0.8, 
    \dur,    Pn(Pdefn(\a000_durs), inf), 
  ),
  Pbind(
    \type, \midi, \midiout, ~mOut, \chan, 0,
    \scale, Scale.chromatic, \octave, 3,
    \degree, Pn(Pdefn(\a000_hh_degs), inf), 
    \amp,    Pn(Pseq([0.8, 0.6, 0.8, 0.7], inf), inf),  
    \dur,    Pn(Pdefn(\a000_durm0),  inf), 
    // \dur,  1/2, 
  )
]));

Pdef(\a100_m, Pbind(
  \type,  \midi,  \midiout,  ~mOut, \chan,  5,  \scale,  Scale.dorian,
  \root,   0,  
  \octave,  Pn(Pstep(Pseq([3,4], inf),  Pseq([1/2,  1], inf), 1), inf),   
  \amp,     Pn(Pstep(Place([9.0, [0.7,  0.5]], inf), 2), inf),
  \degree,  Pn(Pstep(Place([0, [4,  2,  ]], inf),  4),  inf),  
  \dur,     Pn(Pstep(Pdefn(\b000_durs), Pseq([7,  4, 1/2], inf)), inf),  
));

Pdef(\a000, Pdef(\a000_m));
Pdef(\a100, Pdef(\a100_m));
Pdef(\b000, Pdef(\b000_m));
Pdef(\b100, Pdef(\b100_m));
~apcAssignPad.(35, \b000);
~lcxlBindPdef.(\b1_s1_p, \a000);
~lcxlBindPdef.(\b1_s5_p, \b000);
~lcxlBindPdef.(\b1_s6_p, \b100);
// ~lcxlBindPdef.(\b1_s7_p, \a100);
// Pdef(\m000, Pdef(\m000_m));
)

~link.tempo = 110/60;
~link.tempo * 60;
Pdef(\a000).play(~link);
Pdef(\a000).stopQ(4);
Pdef(\a100).play(~link);
Pdef(\a100).stopQ(4);
Pdef(\b000).play(~link);
Pdef(\b000).stopQ(4);
Pdef(\b100).play(~link);
Pdef(\b100).stopQ(4);
(
Pdefn(\b000_chans,  Pseq([
  Pn(Pdefn(\b000_chan_a), 4), 
  // Pn(Pdefn(\b000_chan_b), 4), 
],  inf));
)
(
Pdefn(\b000_chans,  Pseq([
  Pn(Pdefn(\b000_chan_b), 4), 
  // Pn(Pdefn(\b000_chan_b), 4), 
],  inf));
)
~link.tempo(110/60)
(1/6 * 3 + 1/3 * 2 + 2/3)

    // Play overlapping major scales, up and down
(
Pdef.defaultQuant = 5;
Pdef(\b100).play(~link); Pdef(\a000).play(~link); Pdef(\b000).play(~link);
)
Pdef(\b100).stopQ(5); Pdef(\a000).stopQ(5); Pdef(\b000).stopQ(5);
// RUN THIS ONCE
LanguageConfig.addIncludePath("/Users/isaaclinder/Music/sc_system/Extensions");
LanguageConfig.includePaths.postln;
MIDIFunc.trace(false);
