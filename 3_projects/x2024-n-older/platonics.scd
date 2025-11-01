// Drum Beat Using Platonic Solids
(
// Define drum sounds (kick, snare, hi-hat, etc.)
SynthDef(\kick, { |out=0, amp=0.8|
    var env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction:2);
    var sig = SinOsc.ar(50, 0, env * amp);
    Out.ar(out, sig.dup);
}).add;

SynthDef(\snare, { |out=0, amp=0.8|
    var env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction:2);
    var noise = WhiteNoise.ar(env * amp);
    Out.ar(out, noise.dup);
}).add;

SynthDef(\hihat, { |out=0, amp=0.5|
    var env = EnvGen.kr(Env.perc(0.01, 0.1), doneAction:2);
    var noise = PinkNoise.ar(env * amp);
    Out.ar(out, noise.dup);
}).add;

// Platonic solids vertices (2D flattened representation)
var vertices = [
    [0, 1, 0], [1, 0, 0], [0, -1, 0], [-1, 0, 0], // Tetrahedron (example)
    [1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0] // Add other solids here
];

// Map vertices to rhythmic events
var rhythm = vertices.collect { |v|
    var x = v[0].abs; // Map X coordinate to time offset
    var y = v[1].abs; // Map Y coordinate to sound type
    [x, y]
};

// Schedule events
TempoClock.default.tempo = 120/60;

Task {
    loop {
        rhythm.do { |r|
            var time = r[0] % 1; // Normalize time
            var soundType = (r[1] % 3).round; // Map to kick, snare, hi-hat
            
            soundType.switch(
                0, { Synth(\kick, [\amp, 0.8]) },
                1, { Synth(\snare, [\amp, 0.6]) },
                2, { Synth(\hihat, [\amp, 0.4]) }
            );
            
            time.wait;
        };
    }
}.start;
)
