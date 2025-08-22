(
// define a simple test synth
SynthDef(\blipTest, { |freq = 440, out = 0|
    var sig = Blip.ar(freq, 5) * Env.perc(0.01, 1).ar(doneAction:2);
    Out.ar(out, sig ! 2); // stereo
}).add;
)

// now play a few synths; recorder will start on the first
(
fork {
    3.do { |i|
        Synth(\blipTest, [\freq, 220 * (i+1)]);
        1.wait;
    };
}
)

s.notify(true)

// when the last one ends (after their envelopes finish),
// you should see "[autoRec] Recording stopped." in the post window
(
s.dumpOSC(0);

try { OSCdef(\ar_tree).free } { };
try { OSCdef(\_tmpTreePeek).free } { };

try { if(~autoRec.notNil) {
  var p = ~autoRec[\poller];
  if(p.notNil) { p.stop; ~autoRec[\poller] = nil };
}} { };

try { if(~autoRecOSC.notNil) {
  var p1 = ~autoRecOSC[\_poller] ?? ~autoRecOSC[\poller];
  if(p1.notNil) { p1.stop; ~autoRecOSC[\_poller] = nil; ~autoRecOSC[\poller] = nil };
}} { };

AppClock.clear;
SystemClock.clear;
TempoClock.default.clear;

"[autoRec] Panic clean done (no polling, no tree listeners).".postln;
)

~recStart.();
~recStop.();

~recSelfTest.();


