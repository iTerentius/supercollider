(
Pdef(\pats1, Pbind(
  \instrument, \bass8,
  \scale, Scale.minor,
  \octave, 4,
  \degree, Prand([1, -1, 5, 3, 7, Rest(2)]/2, inf),
  \dur, Prand([0.25, 0.5, 0.25, Rest(1)]/2, inf),
  \amp, 0.6,
  \root, Pshuf([10, 0, 5, 3], inf),
  \out, ~t3.inbus.index
));
~lcxlBindPdef.(\b0_s3_p, \pats1);
)
Pdef(\pats1).play;
Pdef(\pats1).stop;


ServerMeter(s);

Quarks.gui;

Pbind(\instrument, \t1002, \freq, Pseq([110, 130, 100, 50l, inf]), \dur, 0.5).play;

Pbind(\instrument, \syn1, \dur, 0.25, \degree, Pwhite(0,7,inf), \amp, 0.12, \out, ~m36_in.(2)).play;     // route your own pattern to track 3

// 2025-09-18 10:35  open a board for master, tracks, and returns
(
~m36_board.tryPerform(\free);
~m36_board = MixingBoard("m36 board", nil, [~m36_master] ++ ~m36_tracks ++ ~m36_fxchans);

// optional  watch automation curves in the GUI
~m36_tracks[0].watch(\pan);   // or .watch to watch all controls  heavier on CPU
)
~m36_tracks[1].scope;
