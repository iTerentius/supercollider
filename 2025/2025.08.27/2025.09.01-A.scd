~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/");

~listTopKeys.();                                   // should show [ samp, bambu, field ] in your case
~samp = ~samplesTree[\bass_drums][\SHD_808BD_03];
~samp = ~samplesTree[\field][\cat_food];
~samp = ~samplesTree[\neutron_12][\121];
~samples = ~samplesTree.at(\neutron_12);
~samples = ~samplesTree.at(\hoarder);
~samples = ~samplesTree.at(\bass_drums);
~samples.postln;
~bufnums = ~samples.collect(_.bufnum);

Ndef(\s1).play;
Ndef(\s1).fadeTime = 1;
(
Ndef(\s1, {
    var bufnums = ~bufnums;
    var which = TIRand.kr(0, bufnums.size-1, Impulse.kr(1)); // random index each second
    var bufnum = Select.kr(which, bufnums);
    PlayBuf.ar(1, bufnum, 1, loop: 1)!2 * 0.5
}).play;
)
(
Ndef(\s1, {| rate=1, amp=0.5 | 
  var rateSig = Lag.kr(rate, 0.05); 
  // Poll.kr(Impulse.kr(2), rateSig, label:"rate"); 
  PlayBuf.ar(numChannels: 1, bufnum: Prand(~samples, inf), rate: rateSig, loop: 1)!2 * amp
});
)
Ndef(\s1)[1] = \filter -> { |in, dur=1, amp=0.5 | GrainIn.ar(2, Impulse.kr(32), dur, in, 0.5) * amp * 0.2} 
Ndef(\s1)[2] = \filter -> { |in, dur=1, amp=0.5 | CombL.ar(in) } 
Ndef(\s1)[3] = \pset -> Pbind(\rate, Pwhite(0.1, 2.0, inf), \dur, Pseq([0.125, 0.25, 0.5, 1.0, 1.5], inf), \amp, 0.6);
Ndef(\s1)[1] = nil;

Ndef(\s1).set(\wet1, 1);


// doesn't drive the rate. 
(
Pdef(\p1, Pbind(
  \type, \pset,
  \id, Pfunc {Ndef(\s1).nodeID},
  \dur, Pwhite(0.5, 2.0, inf),
  \rate, Pwhite(0.5, 2.0, inf),
)).play;
)
Ndef(\s1).map(\rate, Pseq([0.5, 1.0, 2.0], inf));
Pdef(\p1).stop;
Ndef(\s1).stop;

Ndef(\s1).nodeID;
Pdef(\p1)[\id].postln;
// show what you have
~samplesTree.keys.postln;                // should include \samp
~samplesTree[\neutron_12].keys.postln;        // file keys inside samp

// 2025-09-06 09:40 America/Chicago

(
// declare vars at the top
var src, flt, pat;

// source (slot 0)
Ndef(\s1, { |amp = 0.2| Saw.ar(120) * amp });

// filter (slot 1)
Ndef(\s1)[1] = \filter -> { |in, freq = 1000, rq = 0.3|
    RLPF.ar(in, freq, rq)
};

// play first so the synths actually exist
Ndef(\s1).play;

// pattern that always fetches the **current** node id of slot 1
Pdef(\filtPat, Pbind(
    \type, \set,
    \id, Pfunc { Ndef(\s1).nodeID },   // fetch fresh node id each event
    \freq, Pseq([200, 400, 800, 1600], inf),
    \rq,   Pwhite(0.1, 0.9, inf),
    \dur,  0.5,
    \latency, s.latency                    // optional: align with server latency
)).play;
)

~samp = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
Ndef(\s1, {|rate=1| PlayBuf.ar(1, ~samp, rate, loop: 1)!2 }).play;
Ndef(\s1).map(\rate, Pseq([0.5, 1, 2], inf));
