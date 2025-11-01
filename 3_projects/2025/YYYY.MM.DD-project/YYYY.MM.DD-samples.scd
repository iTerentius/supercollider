
// Load various folders (accumulative)
~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/AKWF/AKWF_0001/");

// set individual samples
~samp = ~samplesTree[\bass_drums][\SHD_808BD_03];
~samp = ~samplesTree[\field][\cat_food];
~samp = ~samplesTree[\neutron_12][\121];

// set folder of samples (works with randomSamplePlayer)
~samples = ~samplesTree.at(\neutron_12);
~samples = ~samplesTree.at(\hoarder); //IdendityDictionary of Buffers.
~samples = ~samplesTree.at(\bass_drums);
~samples = ~samplesTree.at(\akwf_0001);
~samples.postln;

// collect for multi sample player.
~bufnums = ~samples.collect(_.bufnum);

// work with multiple samples from one folder
// Can be a synthdef too. 
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
