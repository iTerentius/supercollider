(
// --- 1. Define the folder path and get file paths ---
// NOTE: Replace this path with the actual location of your sound files.
~folderPath = "~/Music/supercollider/_samples/Hoarder/hoarder/";

// Use PathName to get all files in the specified folder.
// The `files` method returns an array of PathName objects.
// Filter out hidden files by adding `select`
~filePaths = PathName(~folderPath).files.select({ |item|
    item.fileName.at(0) != $. // Exclude hidden files
});

// Post the number of files found to confirm.
~filePaths.size.postln;

// --- 2. Load the files into a Buffer array ---
// Define a temporary array to hold the buffers.
~bufferArray = Array.newClear(~filePaths.size);

// Iterate through the file paths and load each one.
// The `do` method on `~filePaths` loads each file into the buffer array.
s.waitForBoot {
    ~filePaths.do({ |path, i|
        Buffer.read(s, path.fullPath, action: { |b|
            ~bufferArray.put(i, b);
           "Loaded buffer %: %".format(i, path.fullPath).postln;
        });
    });
};

)
(
// --- 3. Define the SynthDef for playback ---
// This SynthDef will be used to play a single buffer.
SynthDef(\randomSamplePlayer, { |out=0, buf=0, amp=0.5, dur=1 , pan=0.5, rate=1.0, gate=1|
    var sig, env;
    // Use EnvGen to create a simple amplitude envelope.
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.5), gate, doneAction: 2);

    // Read the audio from the buffer using PlayBuf.
    sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, doneAction: 2);
    sig = PingPong.ar(buf, [0,1], 0.5, 0.7, 1) * sig;
    // Pan2.ar(sig * 0.5, pan);
    // Output the signal, modulated by the envelope.
    Out.ar(out, sig * amp * env);
}).add;
)

// --- 4. Create and start the playback pattern ---
(
Pdef(\pChop, 
  Pbind(
    // \type, \set,
    // Randomly select one of the buffers from our array.
    // Define the instrument to use.
    \instrument, \randomSamplePlayer,
    // \id, Pfunc {Ndef(\randomSamplePlayer).nodeID},

    // \buf, Prand(~bufferArray, inf),
    \buf, Prand(~bufferArray, inf),
    // Randomize the playback rate for some variation.
    // \rate, Pwhite(0.5, 1.5),
    // Give each note a random duration.
    // \dur, Pwhite(0.1, 2),
    // The amp is defined in the SynthDef but can be controlled here as well.
    \amp, 0.5
  )
).play;
);
~bufferArray[0].postln;
( 
Ndef(\rChop, { | buf=0, amp=0.5, rate=1.0, gate=1|
    var sig, env;
    // Ue EnvGen to create a simple amplitude envelope.
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.5), gate, doneAction: 2);

    // Read the audio from the buffer using PlayBuf.
    PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf) * rate, doneAction: 2);
  
});
 )

Ndef(\rChop).play;

Pdef(\myPattern,
    Pbind(
        \instrument, \rChop, // This tells the Pdef to play the Ndef named \myNdef
        \freq, Pseq([200, 400, 600, 800], inf), // Sequence of frequencies
        \amp, 0.2,
        \dur, 0.5 // Duration of each event
    )
);
( 
// 1. Define a granular-like Ndef
Ndef(\grain, { |freq, pan, dur|
	var grain = GrainSin.ar(freq: freq, numChannels: 2, trigger: Impulse.ar(1/dur), dur: dur, position: WhiteNoise.ar);
	Pan2.ar(grain * 0.5, pan);
}).play;
)
(// 2. Define a pattern to drive the Ndef's parameters
Pdef(\gpat,
  Pbind(
    \type, \set,
    \id, Pfunc {Ndef(\grain).nodeID},
    \freq, Pseq([300, 400, 500], inf),
    \pan, Pwhite(-1.0, 1.0, inf),
    \dur, Pseq([0.1, 0.2, 0.3], inf)
  )
).play;
)

// 2025-09-04

(
// put the synthdef into the Ndef environment
Ndef(\bass, { |freq=220, amp=0.1|
	var sig;
	sig = Saw.ar(freq, amp);
	sig = LPF.ar(sig, 2000);
	Out.ar(0, sig ! 2);
});
)

// you can play an Ndef directly, but we want to drive it with a Pbind:
(
Pdef(\bassPat,
	Pbind(
		\type, \set,              // instead of \note (plays new synths), we set params of an Ndef
		\id, Pfunc {Ndef(\bass).nodeID},               // which Ndef to target
		\freq, Pseq([220, 330, 440, 550], inf),
		\dur, 0.25,
		\amp, 0.1
	)
).play;
)
