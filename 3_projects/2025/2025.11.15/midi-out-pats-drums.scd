~link.tempo = 80/60;
////////////////////////////////////////////////////////////////////
// Out-sourced MIDI to DAW
////////////////////////////////////////////////////////////////////
Pdefn(\k_01,   Pseq([   0,  \,  2,  \,  0,  \,  \,  0,  ],  inf));
Pdefn(\k_02,   Pseq([   9,  \,  0,  \,  0,  0,  9,  0,  ],  inf));
Pdefn(\k_03,   Pseq([   \,  \,  \,  \,  0,  \,  0,  0,  ],  inf));
Pdefn(\ho_01,  Pseq([   6,  \,  6,  \,  6,  \,  6,  \,  ],  inf));
Pdefn(\ho_02,  Pseq([   6,  6,  \,  6,  \,  6,  6,  \,  ],  inf));
Pdefn(\k_dur,  1/2);
Pdefn(\k_dur,  Pbjorklund2(2,  9,   inf)/4);
Pdefn(\ho_02,  Pbjorklund2(3,  8,   2));

Pdefn(\ho_01,  Pseq([   6,  \,  6,  \,  6,  \,  6,  \,  ],  inf));
(
Pdef(\h2, Pbind( 
  \type,      \midi,
  \midiout,   ~mOut,
  \chan,      0,
  \amp,       1,
  \octave,    3,
  \scale,     Scale.chromatic,   
  \degree,    6,
  \dur,       1/2,
));
)
Pdef(\h2).source.postln;
Pdef(\h2).source.isNil.postln;

Pdef(\h2).play;
Pdef(\h2).clear;
// 2025-11-25
Pbindef(\h1).source.postln;
Pbindef(\h1).source.isNil.postln;
// 2025-11-25
(
"Pbindefs:".postln;
Pbindef.all.keysValuesDo { |key, proxy|
    [key, proxy.source.isNil].postln;
};

"Pdefs:".postln;
Pdef.all.keysValuesDo { |key, proxy|
    [key, proxy.source.isNil].postln;
};

"Pdefns:".postln;
Pdefn.all.keysValuesDo { |key, proxy|
    [key, proxy.source.isNil].postln;
};
)
(
Pdef(\del_cc1, Pbind(\type, \midi, \midiout, ~mOut, \chan, 1, \midicmd, \control,
  \ctlNum, 1,
  \control, Pwhite(30,   127,   inf),   
  \dur, 0.25
));
)
Pdef(\del_cc1).play;
Pdef(\del_cc1).stop;
(
Pdef(\kit_cc1, Pbind(\type, \midi, \midiout, ~mOut, \chan, 1, \midicmd, \control,
  \ctlNum, 2,
  \control, Pwhite(30,   127,   inf),   
  \dur, 0.25
));
)
Pdef(\kit_cc1).play;
Pdef(\kit_cc1).stop;

(
Pdef(\lfo_phs_cc, Pbind(\type, \midi, \midiout, ~mOut, \chan, 1, \midicmd, \control,
  \ctlNum, 3,
  \control, Pseg(Pseq([0.0,  100],  inf), Pseq([8],  inf),  \lin),   
  \dur, 0.25
));
)
Pdef(\lfo_phs_cc).play;
Pdef(\lfo_phs_cc).stop;

~mOut.control(1,   3,  50);

(
Pdef(\kit,
    Ppar([
        // kick voice
        Pbind(
            \type, \midi, \midiout, ~mOut, \chan, 0, \octave, 3, \scale, Scale.chromatic, 
            // \degree, Psym(Pseq([\k_01, \k_02], inf)),   // alternate phrases
            \degree,   Pswitch1(
              [
                Pn(Pdefn(\k_01), inf),
                Pn(Pdefn(\k_02), inf),
                // Pn(Pdefn(\k_03),  inf), 
                // Pn(Pseq([Rest()],8), inf),   
              ],  
              Pseq([ 0!2, 1!2, /*2!2,*/  ].flat,  inf),  
            ),
            \dur, Pdefn(\k_dur)
        ),

        // hat voice
        Pbind(
            \type, \midi, \midiout, ~mOut, \chan, 0, \octave, 3, \scale, Scale.chromatic, 
            // \degree, Psym(Pseq([\ho_01, \ho_02], inf)),
            \degree,   Pswitch1(
              [
                Pn(Pdefn(\ho_01),  inf),  
                Pn(Pdefn(\ho_02),  inf)
              ],  
              Pseq([0!3,  1!1].flat,  inf),  
            ),
            \dur, Pdefn(\k_dur)/2
        )
    ])
);
)
Pdef(\kit).clear;

Pdef(\kit).play(~link, quant: 1);
~lcxlBindPdef.(\b1_s1_p,  \kit);
Pdef(\kit).stop;

(
Pdef(\bass, Pbind(
  \type,   \midi, \midiout,  ~mOut, \chan, 2,
  \scale,  Scale.minor, 
  \octave,  3,  
  \degree,  Pn(Pxrand([0,  1,   \,   \,  7, 4],  2),  inf), 
  // \sustain, 0.2,
  // \legato,   0.2, 
  \amp,  1,
  \dur, Pseq([
    Pseq([Rest()], 4),  
    Pseq([Pdefn(\k_dur)],  8)/2,
  ],  inf), 
));
)
Pdef(\bass).play(~link,  quant: 1);
Pdef(\bass).stop;
