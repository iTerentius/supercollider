s.waitForBoot {
    "Server booted. Playing sound...".postln;
    { SinOsc.ar(440, 0, 0.2) ! 2 }.play;
    2.wait;
    "Sound done.".postln;
    0.exit;
};
