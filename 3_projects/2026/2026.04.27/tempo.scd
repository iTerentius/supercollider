
(
Tdef(\tempo, {
  var bpms = [50,  100, 200].scramble;
  var durs = [4,  8,  16].scramble;
  loop {
    bpms.do { |bpm, i|
      ~link.tempo = bpm / 60;
      durs[i].wait;  // wait 4 beats
    };
  };
};)
)
Tdef(\tempo).play;
Tdef(\tempo).stop;

~link.tempo = 60/60;
