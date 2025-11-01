~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/AKWF/AKWF_0001/");

~listTopKeys.();                                   // should show [ samp, bambu, field ] in your case
~samp = ~samplesTree[\bass_drums][\SHD_808BD_03];
~samp = ~samplesTree[\field][\cat_food];
~samp = ~samplesTree[\neutron_12][\121];
~samples = ~samplesTree.at(\neutron_12);
~samples = ~samplesTree.at(\hoarder); //IdendityDictionary of Buffers.
~samples = ~samplesTree.at(\bass_drums);
~samples = ~samplesTree.at(\akwf_0001);
~samples.postln;
~bufnums = ~samples.collect(_.bufnum);

~ccBindParam.(\b0_f1, \s1, \amp, ControlSpec(0, 0.5, \lin, 0, 0));
~ccBindParam.(\b0_t1_r1, \s1, \rate, ControlSpec(0.5, 2.0, \lin, 0, 0));
~ccBindParam.(\b0_t1_r2, \s1, \dur, ControlSpec(0.125, 2.0, \lin, 0, 0));
~ccBindParam.(\b0_t1_r3, \s1, \grains, ControlSpec(8, 256, \lin, 0, 0));


Ndef(\s1).play;
Ndef(\s1).fadeTime = 1;
Ndef(\s1)[0] = { |amp=0.5 rate=1, dur=1|
(
    var buffers = ~samples.values; // get array of Buffer objects
    var which = TIRand.kr(0, buffers.size-1, Impulse.kr(1)); // random index each second
    var buf = Select.kr(which, buffers); // select Buffer object
    var isMono = (buf.numChannels == 1);
    var rateSig = Lag.kr(rate, 0.05);
    var sig;
  // Poll.kr(Impulse.kr(10), rateSig, label:"rate");
    sig = PlayBuf.ar(2, buf, rateSig, loop: 1);
    sig = (isMono).if({sig!2},{sig});
    // sig * amp;
    Out.ar(~sendBus, sig);
    Silent.ar(2)
}
)

Ndef(\s1)[1] = \filter -> { |in, dur=1, amp=0.5, grains=32 | GrainIn.ar(2, LFPulse.kr(grains), dur, in, 0.5) *(grains /100)/amp } 
Ndef(\s1)[2] = \filter -> { |in, dur=1, amp=0.5 | CombL.ar(in) } 
Ndef(\s1)[3] = \pset -> Pbind(\rate, Pwhite(0.5, 2.0, inf), \dur, Pseq([0.125, 0.25, 0.5, 1.0, 1.5], inf), \amp, 0.1);
Ndef(\s1)[1] = nil;

Ndef(\s1).set(\wet1, 0.3);


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

