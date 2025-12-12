// Key Thing
// words
(
Pdefn(\k1_deg0, Pseq([0!4, Pn(Rest(), 1)].flat,  1));
Pdefn(\k1_deg1, Pseq([0!4, Prand((1..7),  8),  \,  3].flat,  1));
Pdefn(\k1_deg2, Pseq([0!4, Pxrand((1..7),  2),  Pn(Rest(), 4)].flat,  1));

Pdefn(\k1_dur0, Pseq([1/2!2,   1/4!4,  1/2,  1/8!4, Pn(Rest(), 1)].flat,  1));
Pdefn(\k1_dur1, Pseq([1/4!4,   1/8!8,  Pn(Rest(), 2)].flat,  1));
)

// phrases
(
Pdefn(\k1_degs, Pseq([
  Pn(Pdefn(\k1_deg0), 4), 
  Pn(Pdefn(\k1_deg1), 1), 
  Pn(Pdefn(\k1_deg2), 1), 
],  inf));

Pdefn(\k1_durs, Pseq([
  Pn(Pdefn(\k0_dur1), 1), 
  Pn(Pdefn(\k1_dur1), 1), 
],  inf));
)

// voices
(
Pbindef(\k1,
  \type,  \midi,  \midiout,  ~mOut, \chan,  1,  \scale,  Scale.dorian, 
  // \octave,  Pseq(#[3, 4,  2], inf),  
  \octave,  3,  
  \amp,  0.8, 
  \degree,  Pdefn(\k1_degs),
  \dur,     Pdefn(\k1_durs),
);
)
Pbindef(\k1).play;
Pbindef(\k1).stop;
Pbindef(\k1).clear;

// Bass Thing
// words
(
// Pdefn(\b1_deg0, Pseq([
//   \E.asDegrees(Scale.dorian), \,   
//   \B.asDegrees(Scale.dorian), \,  
//   \C.asDegrees(Scale.dorian), \, 
//   \A.asDegrees(Scale.dorian), \,   
//                 // Pn(Rest(),  4), 
//             ],  1).flatten);
Pdefn(\bass1_deg1,  Pseq([0, 2,  3,  2], 1).stutter(8));
Pdefn(\bbas1_deg2,  Pseq([0, 3, 4,  2], 1).stutter(8));

Pdefn(\bass1_dur0,  Pseq([1/4,  ].flat,  1));
// Pdefn(\b1_dur0,  Pseq([1/4!7, 1/8!2].flat,  1));
Pdefn(\bass1_dur1,  Pxrand([1/8!4, 1/4!2, 1/2!2].flat,  1));

// phrases
)
(
Pdefn(\bass1_degs, Pseq([
  // Pn(Pdefn(\bass1_deg1), 4), 
  Pn(Pdefn(\bass1_deg1), 4), 
  Pn(Pdefn(\bass1_deg2), 4), 
],  inf));

Pdefn(\bass1_durs, Pseq([
  Pn(Pdefn(\bass1_dur0), 2), 
  // Pn(Pdefn(\bass1_dur1), 2), 
],  inf));
)
(
// voices

Pbindef(\bass1_m,
  \type,  \midi,  \midiout,  ~mOut, \chan,  2,  \scale,  Scale.dorian, 
  \root,  5,  
  \octave,  Prand([3!3, 4].flat,  inf),   
  \amp,  Pseq([0.8, 0.7,   0.6],  inf), 
  \degree,  Pn(Pdefn(\bass1_degs), inf),
  // \degree,  Pseq([0,  2,  4,  7], inf), 
  // \legato,  Pn(Pdefn(\bd1_durs),  inf),
  // \sustain, 1,  
  \dur,     Pn(Pdefn(\bass1_durs), inf),
  // \dur, 1/4,  
);
)
(
Pdef(\bass1, Pbindef(\bass1_m));
// ~apcAssignPad.(35, \hh1);
// ~lcxlBindPdef.(\b1_s4_p, \hh1);
)
Pdef(\bass1_m).play(~link, quant:1);
Pdef(\bass1_m).stop;
Pbindef(\bass1_m).clear;
Pdef(\bass1).clear;
// 2025-12-11 – check which proxies are empty
(
Pdef.all.do { |pd|
    if(pd.source.isNil) {
        [\Pdef, pd.key, 'EMPTY'].postln;
    } {
        [\Pdef, pd.key, 'OK'].postln;
    }
};
)
(
Pbindef.all.do { |pd|
    if(pd.source.isNil) {
        [\Pbindef, pd.key, 'EMPTY'].postln;
    } {
        [\Pbindef, pd.key, 'OK'].postln;
    }
};
)
(
Pdefn.all.do { |pd|
    if(pd.source.isNil) {
        [\Pdefn, pd.key, 'EMPTY'].postln;
    } {
        [\Pdefn, pd.key, 'OK'].postln;
    }
};
)
(
// 2025-12-11 – test bass on a plain TempoClock

// create a fresh, plain clock
~testClock = TempoClock.new(1).permanent_(true);

Pbindef(\bass1_m,
  \type,   \midi,
  \midiout, ~mOut,
  \chan,   2,
  \scale,  Scale.dorian,
  \root,   5,
  \octave, Prand([3!3, 4].flat, inf),
  \amp,    Pseq([0.8, 0.7, 0.6], inf),
  \degree, Pseq([0, 2, 4, 7], inf),
  \dur,    1/4
);

Pbindef(\bass1_m).play(~testClock, quant: 1);
)
~link.postln;
~link.class.postln;
// 2025-12-11 – other proxy dictionaries

Tdef.all.postln;
Ndef.all.postln;      // NodeProxy; it usually says "no source", but worth checking
ProxySpace.all.postln;
