(
Pdef(\pats1, Pbind(
  \instrument, \syn1,
  \scale, Scale.minor,
  \octave, 4,
  \degree, Pseq([1, -1, 5, 3, 7, Rest(2)], inf),
  \dur, Pseq([0.25, 0.5, 0.25, Rest(1)], inf),
  \amp, 0.3,
  \root, Pshuf([10, 0, 5, 3], inf),
  \out, ~m36_in.(0)
));
)
Pdef(\pats1).play;

~m36_tracks[0].level_(1.7);

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
