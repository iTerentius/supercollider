
~link.tempo_(80/60);
~link.tempo;
~setBpm.(90);

Pdef(\b000).play;
Pdef(\b000).stop;
Pdef(\b000).clear;

Pdef(\c000).play(out:2);
Pdef(\c000).stop;
Pdef(\c000).clear;

Pdef(\c100).play(out:2);
Pdef(\c100).stop;
Pdef(\c100).clear;

Pdef(\a000).play;
Pdef(\a000).stop;
Pdef(\a000).clear;

Pdef(\a100).play;
Pdef(\a100).stop;
Pdef(\a100).clear;

Pdef(\a200).play;
Pdef(\a200).stop;
Pdef(\a200).clear;

Pdef(\a0).play;
Pdef(\a0).stop;
Pdef(\a0).clear;

(
Pdef(\b000).stop;
Pdef(\c000).stop;
Pdef(\a000).stop;
Pdef(\a100).stop;
Pdef(\a200).stop;
Pdef(\a0).stop;
)
~lcxlBindPdef.(\b1_s1_p, \a0);
Pdef.clear;
Pdefn.clear;
