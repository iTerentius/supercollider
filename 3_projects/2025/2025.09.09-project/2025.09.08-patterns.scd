(
Pdef(\pats1, Pbind(
  \instrument, \bass8,
  \scale, Scale.minor,
  \octave, 4,
  \degree, Prand([1, -1, 5, 3, 7, Rest(2)], inf),
  \dur, Prand([0.25, 0.5, 0.25, Rest(1)], inf),
  \amp, 0.4,
  \root, Pshuf([10, 0, 5, 3], inf),
  \out, ~t4.inbus.index
));
~lcxlBindPdef.(\b1_s4_p, \pats1);
~apcAssignPad.(25, \pats1);
)
Pdef(\pats1).play;
Pdef(\pats1).stop;


ServerMeter(s);

Quarks.gui;

