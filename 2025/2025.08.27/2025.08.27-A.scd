// ~ccBind.(\t1r1, \pad, \cutoff, ControlSpec(100,12000,\exp));
// ~installCCByNameRouter.();
//
// ~ccDumpCCMap.();


// Make an Ndef with slots
// Ndef(\foo)[\a] = { | freq=100 | SinOsc.ar(freq ! 2) * 0.1};
// Ndef(\foo)[\b] = { Pulse.ar(110, 0.3) * 0.1 ! 2 };
//
// // Play the whole Ndef (all slots mixed)
// Ndef(\foo).play;
//
// Ndef(\foo)[\a] = nil;
//
// Ndef(\foo).clear;
//
// Ndef(\foo).set(\freq, 400);

// (
// Ndef(\track)[\melody] = Pbind(
//     \instrument, \bass8,
//     \dur, 0.25,
//     \amp, 0.15,
//     \freq, Pseq([220, 330, 440, 550], inf)   // direct Hz, no scale involved
// );
// )

// Ndef(\track)[\drone] = { | amp = 0.5 | LFTri.ar(110) * 0.05 };


Ndef(\track)[\mel] = Pdef(\melody);


~ccBind.(\t1r1, \track, \amp, ControlSpec(0, 1, \lin));
 
Ndef(\track).set(\amp, \t1r1);

Ndef(\track).play;
Ndef(\track).stop;
Ndef(\track).clear;

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

// MIDIdef.cc(\cAmp, { |val, ccNum, chan, src|
//     if (ccNum == 13) {
//         Ndef(\track).set(\amp, val.linlin(0, 127, 0, 1)); // Map 0-127 to 100-10000 Hz
//     }
// });

( 
// --- FX send (wet only) ---
    Ndef(\instVerbSend, { |from = \track|
        var src, sendAmt, wet;
        src     = Ndef.ar(from);          // tap the instrument’s proxy bus (pre-fader)
        sendAmt = \send.kr(0.0).lag(0.1); // 0..1 send amount, lightly smoothed
        wet     = FreeVerb.ar(src * sendAmt, 0.4, 0.8, 0.2);
        wet                               // this Ndef outputs ONLY wet
    }).play;  // make the send audible
 )

Ndef(\instVerbSend).set(\from, \trackl);
Ndef(\instVerbSend).set(\send, 1);

// (
// Ndef(\instSendVerb, { |from = \track |
//     var src, sendAmt, wet, wetAmp;
//     src     = Ndef.ar(\track);            // taps the proxy bus (pre-fader)
//     sendAmt = \send.kr(0.5).lag(0.05);  // DEFAULT 0.5 so you hear it right away
//     wetAmp  = \wetAmp.kr(1.0);          // overall wet gain
//     wet     = FreeVerb.ar(src * sendAmt, 0.4, 0.8, 0.2) * wetAmp;
//     // wet                                   // wet-only output
// }).play(2);
// )
//     // Example tweaks
// Ndef(\instVerbSend).set(\send, 0.9);  // send amount
// Ndef(\track).set(\amp, 0);
//
// ( // 1) Source (no output gain here; this is the pre-fader tap)
// Ndef(\src, {
//     var sig;
//     sig = Saw.ar(110 ! 2) * EnvGen.kr(Env.asr(0.01, 1, 0.1), \gate.kr(1));
//     sig  // raw signal published on \src's proxy bus
// });
// )
// ( // 2) Instrument (dry path to main out) — applies the user "fader"
// Ndef(\inst, {
//     var dry, amp;
//     dry = Ndef.ar(\src);          // PRE-fader feed
//     amp = \amp.kr(0.15);          // this is your instrument fader
//     dry * amp
// }).play;
//  )
// // 3) FX send (wet-only) — reads the same PRE-fader feed, independent of \amp
// ( Ndef(\verbSend, {
//     var src, sendAmt, wetAmp, wet;
//     src     = Ndef.ar(\src);              // PRE-fader tap
//     sendAmt = \send.kr(0.5).lag(0.05);    // 0..1 send amount
//     wetAmp  = \wetAmp.kr(1.0);            // overall wet gain
//     wet     = FreeVerb.ar(src * sendAmt, 0.4, 0.8, 0.2) * wetAmp;
//     wet                                      // wet-only output
// }).play; 
// )
//
// // Example moves
// Ndef(\inst).set(\amp, 0.05);         // turn DRY way down...
// Ndef(\verbSend).set(\send, 0.6);     // ...FX stays present (pre-fader)
// Ndef(\verbSend).set(\wetAmp, 1.0);
//
//
//
