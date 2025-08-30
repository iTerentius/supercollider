// ~ccBind.(\f1, \track, \amp, ControlSpec(0,1,\lin));
// ~installCCByNameRouter.();

// ~ccDumpCCMap.();

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


// // 1) Make sure router exists, set channel (one-based)
// ~installCCByNameRouter.();
// ~setCCChannel.(9);
//
// // 2) (Optional) clear old map so you can see the new writes
// ~ccClearMap.();
//
// // 3) Start the debug learner
// ~learnFaders.();   // <— use this new one
//
// // 4) Move faders 1..8 in order (don’t touch knobs)
// //    Watch the console: it should print ✔ lines and finally ccLoad(ok: true …)
//
// // 5) Verify the map
// ~ccDumpCCMap.();   // expect f1..f8 → chan:8 cc:77..84 uid:...
//
//
