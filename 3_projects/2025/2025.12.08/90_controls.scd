
~bw.tempo_(90/60/4);
~link.tempo_(1.5);
~setBpm.(90);
// Bass1 -------------------------------
Pdef(\bass1).play;
Pdef(\bass1).stop;
Pdef(\bass1).clear;

Pdef(\bd1).play;
Pdef(\bd1).stop;
Pdef(\bd1).clear;

Pdef(\sd1).play;
Pdef(\sd1).stop;
Pdef(\sd1).clear;

Pdef(\hh1).play;
Pdef(\hh1).stop;
Pdef(\hh1).clear;

Pdef(\kit1).play;
Pdef(\kit1).stop;
Pdef(\kit1).clear;

(
Pdef(\bass1).stop;
Pdef(\bd1).stop;
Pdef(\sd1).stop;
Pdef(\hh1).stop;
Pdef(\kit1).stop;
)
~lcxlBindPdef.(\b1_s1_p, \kit1);
Pdef.clear;
