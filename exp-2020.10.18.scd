TempoClock.default.tempo = 1;

Ndef(\a, { Pan2.ar((SinOsc.ar(TRand.kr(1, 100, Dust2.kr(1))) * LFSaw.kr(TempoClock.default.tempo, 0, Rand(1, 3), 1)), SinOsc.kr(1)) }).play;