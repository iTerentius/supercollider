(
Pdef(\pats1, Pbind(
  \instrument, \syn1,
  \scale, Scale.minor,
  \octave, 4,
  \degree, Pseq([1, -1, 5, 3, 7, Rest(2.5)], inf),
  // \dur, Pseq([0.25, 0.5, 0.25, Rest(0.5)], inf)*0.5,
  \dur, Pgeom(0.125, 0.25, inf ),
  \amp, 0.3,
  \root, Pshuf([10, 0, 5, 3], inf)
));
)
Pdef(\pats1).play;
