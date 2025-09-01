
// exact key workflow you prefer
~setDefaultOut.(0);
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~storm = ~samplesTree[\Storm][\Storm_05_11_2022_01];

Ndef(\chopper).fadeTime = 0.02;
Ndef(\chopper).source   = \chop;

Ndef(\chopper).set(
    \out, 0,
    \buf, ~storm,
    \chop, 8,
    \slice, 0,
    \start, 0.0,
    \stop, 1.0,
    \rate, 1.0,
    \amp, 0.35,
    \pan, 0.0,
    \useInternal, 1,
    \trate, 4,
    \atk, 0.005,
    \rel, 0.08
);

Ndef(\chopper).play;

~printTree.();

// ensure loader has run and buffer is ready
~setDefaultOut.(0);
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~stormBuf = ~samplesTree[\Storm][\Storm_05_11_2022_01];
~catFood = ~samplesTree[\Field][\cat_food];
( 
Pdef(\stormChop,
    Pbind(
        \instrument, \chop_play,
        \out, 0,
        \buf, ~catFood.bufnum,
        \chop, 32,
        \slice, Pseq([0,1,2,3,4,5,6,7], inf),
        \start, 0.0,
        \stop, 1.0,
        \rate, 1.0,
        \amp, 0.35,
        \pan, 0.0,
        \useInternal, 0,      // pattern drives the gate
        \dur, 0.25,           // event length in beats
        \legato, 0.9,         // scales sustain  tweak with rel for tails
        \atk, 0.005,
        \rel, 0.06
    )
).play;
 )

// stop and wipe any old pattern under that name
Pdef(\stormChop).stop;
Pdef(\stormChop).clear;

// also clear proxies and server nodes to be extra sure
Ndef.clearAll;
CmdPeriod.run;
s.freeAll;

~setDefaultOut.(0);
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~storm = ~samplesTree[\Storm][\Storm_05_11_2022_01];
// exact key buffer
~setDefaultOut.(0);
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~storm = ~samplesTree[\Storm][\Storm_05_11_2022_01];

( 
// new pattern name and new instrument
Pdef(\stormChop_pb3,
    Pbind(
        \instrument, \chop_pb3,
        \out, 0,
        \buf, ~storm.bufnum,          // bufnum for SynthDef
        \chop, 8,
        \slice, Pseq((0..7), inf),
        \start, 0.0,
        \stop, 1.0,
        \rate, 1.0,
        \amp, 0.35,
        \pan, 0.0,
        \useInternal, 0,              // pattern mode  uses gate ASR
        \atk, 0.005,
        \rel, 0.06,
        \dur, 0.25,                   // pattern duration
        \legato, 0.9                  // sustain fraction for ASR
    )
).play;
 )
