(
Pdef(\pats1, Pbind(
  \instrument, \syn1,
  \scale, Scale.minor,
  \octave, 4,
  \degree, Prand([1, -1, 5, 3, 7, Rest(2)]/2, inf),
  \dur, Prand([0.25, 0.5, 0.25, Rest(1)]/2, inf),
  \amp, 0.6,
  \root, Pshuf([10, 0, 5, 3], inf),
  \out, ~t1.inbus.index
)).play;
)
Pdef(\pats1).play;
Pdef(\pats1).stop;
Pdef(\pats1).clear;

ServerMeter(s);

Quarks.gui;

Pbind(\instrument, \t1002, \freq, Pseq([110, 130, 100, 50l, inf]), \dur, 0.5).play;

Pbind(\instrument, \syn1, \dur, 0.25, \degree, Pwhite(0,7,inf), \amp, 0.12, \out, ~t1.inbus.index).play;     // route your own pattern to track 3

