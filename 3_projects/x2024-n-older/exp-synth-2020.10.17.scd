Ndef(\a).play;
Ndef(\a, { |freq = 110 | var env; env = EnvGen.kr(Env.perc(0.5, 0.6)); SinOsc.ar(freq)!2 * env});

Pdef(\ap, Pbind(\freq, Pseq([110, 220, 330, 800], inf), \dur, 2));

Ndef(\a)[1] = \xset -> Pdef(\ap);

Ndef(\a).asCompileString;

\a.asCompileString;

TempoClock.default.tempo = 40/60;