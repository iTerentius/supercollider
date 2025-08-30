Ndef(\track).play;

Ndef(\track)[\mel] = Pdef(\melody);

(
Pdef(\melody, Pbind(
        \instrument, \bass8,
        \dur, 0.25,
        \legato, 0.9,
        \amp, 0.02,
        \scale, Scale.minor,
        \degree, Pseq([0, 2, 4,  8], inf),
        \octave, 5
    ));
)



