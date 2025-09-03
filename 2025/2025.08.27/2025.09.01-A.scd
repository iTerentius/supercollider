~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

// exact keys
~storm = ~samplesTree[\Storm][\Storm_05_11_2022_01];

// decide instrument name based on channel count in language
~chopInstr = (~storm.numChannels == 1).if(\chop_pb_m, \chop_pb_s);
~chopInstr.postln;  // should print chop_pb_s for your Storm file

( 
Synth(~chopInstr, [
    \out, 0,
    \buf, ~storm.bufnum,  // bufnum for SynthDef
    \chop, 8, \slice, 0, \start, 0.0, \stop, 1.0,
    \rate, 1.0, \amp, 0.35, \pan, 0.0,
    \useInternal, 0, \gate, 1, \atk, 0.005, \rel, 0.06
]);
 )


Pdef(\stormChop_clean).stop.clear;
( 
Pdef(\stormChop_clean,
    Pbind(
        \type, \note,
        \instrument, Pfunc { ~chopInstr },    // mono or stereo chosen here
        \out, 0,
        \buf, ~storm.bufnum,
        \chop, 8,
        \slice, Pseq((0..7), inf),
        \start, 0.0,
        \stop, 1.0,
        \rate, 1.0,
        \amp, 0.35,
        \pan, 0.0,
        \useInternal, 0,                     // pattern controls gate
        \atk, 0.005,
        \rel, 0.06,
        \dur, 0.25,
        \legato, 0.9
    )
).play;   // trace first to confirm instrument and buf values 
)

// show what you have
~samplesTree.keys.postln;                // should include \storm
~samplesTree[\storm].keys.postln;        // file keys inside storm

// quick exact access with the lowercase folder
~storm = ~samplesTree[\storm][\Storm_05_11_2022_01];
~playBuf.(~storm, amp: 0.6);

~listTopKeys.();                                   // should show [ storm, bambu, field ] in your case
~storm = ~asBuf.(\storm, \Storm_05_11_2022_01);    // Buffer(...)
~playBuf.(~storm, amp: 0.6);                       // plays on out 0 1
~chopSample.(~storm, amp: 0.5);                    // calls your \chop_pb_s since it's stereo

// 1 load
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

// 2 confirm top keys
~listTopKeys.();   // should print [ storm, bambu, field ] in your case

// 3 resolve a Buffer and play
~storm = ~asBuf.(\storm, \Storm_05_11_2022_01);
~playBuf.(~storm, amp: 0.6);
~chopSample.(~storm, amp: 0.5);

