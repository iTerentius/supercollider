 ~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/");
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/");
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/AKWF/AKWF_0001/");
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/Cat-Water/");

 ~samp = ~samplesTree[\bass_drums][\SHD_808BD_03];
 ~samp = ~samplesTree[\field][\cat_food];
 ~samp = ~samplesTree[\neutron_12][\121];
 ~samples = ~samplesTree.at(\neutron_12);
 ~samples = ~samplesTree.at(\hoarder);
 ~samples = ~samplesTree.at(\bass_drums);
 ~samples = ~samplesTree.at(\cat_water);
 ~samples = ~samplesTree.at(\akwf_0001);
 ~samples.postln; 

TempoClock.default.tempo = 60/60; // 90 bpm
(
// ~samples = ~samplesTree.at(\hoarder);
~samples = ~samplesTree.at(\neutron_12);
Ndef(\i2).quant = 1;
Ndef(\i2)[0] = { |amp=1, rate=1, dur=1|
  var buffers = ~samples.values; // get array of Buffer objects
  var which = TIRand.kr(0, buffers.size-1, Impulse.kr(1)); // random index each second
  var buf = Select.kr(which, buffers); // select Buffer object
  var isMono = (buf.numChannels == 1);
  var rateSig = Lag.kr(rate, 0.05);
  var sig;
  sig = PlayBuf.ar(2, buf, rateSig, loop: 1);
  sig = (isMono).if({sig!2},{sig});
  sig * amp;
  // Silent.ar(2)
};
)
Ndef(\i2).play(out:2);
Ndef(\i2).stop(3);
Ndef(\i2).clear(3);

~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
(
~bd1 = ~samplesTree.at(\bass_drums).asArray;
Pdef(\bd1).quant = 1;
Pdef(\bd1,
    ~pBuf.(
        Pbind(
            \buf,   Prand(~bd1, inf),          // your Buffer object
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,    Pbjorklund2(3, 8)/4,
            \amp,   2.0,
            \rate,  1,
            \out,   ~pbd1.inbus.index
        )
    )
);
~apcAssignPad.(32, \bd1);
)
Pdef(\bd1).play;
Pdef(\bd1).stop(3);
Pdef(\bd1).clear;

ServerMeter(s);

Ndef.clear;

(
~bd2 = ~samplesTree.at(\bass_drums).asArray[4];
Pdef(\bd2).quant = 1;
Pdef(\bd2,
  ~pBuf.(
    Pbind(
      \buf,    ~bd2,
      \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
      \dur,   Prand([0.25, 0.5, Rest(0.25)], inf),
      \amp,   1.0,
      \rate,  Prand([1, 2, 3], inf),
      \out, ~pbd2.inbus.index 
    )
  )
);
~apcAssignPad.(33, \bd2);
)
Pdef(\bd2).play;
Pdef(\bd2).stop;
Pdef(\bd2).clear(3);



// Ndef(\bd2)[1] = \filter -> { |in| CombL.ar(in, 0.2, LFPulse.kr(0.5!2).exprange(0.01, 0.2), 3) * 0.7 };
// Ndef(\bd2).set(\wet1, 0.8);
// Ndef(\bd2)[1] = nil;
//
// Ndef(\bdFx, { FreeVerb2.ar(\in1.ar([0, 0]), \in2.ar([0,0]), \mix.kr(0.5), \room.kr(0.7), \damp.kr(0.5))});
// Ndef(\bdFx) <<>.in1 Ndef(\bd1);
// Ndef(\bdFx) <<>.in2 Ndef(\bd2);
// Ndef(\bdFx).play(out:6);
// Ndef(\bdFx).stop(5);

~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/"); 
(
~hh1 = ~samplesTree.at(\hats).asArray[1];
Pdef(\hh1).quant = 1;
Pdef(\hh1, 
  ~pBuf.(
    Pbind(
      \buf,    ~hh1,
      \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
      \dur,   0.25,
      \amp,   Pseq([0.4, 0.4, 0.7, 0.9], inf),
      \rate,  Prand([0.5, 0.25, 0.125, 1], inf),
      \pan,   0.2,
      \startPos, 0,
      \loop, 0,
      \out, ~phh1.inbus.index
    )
  )
);
~apcAssignPad.(34, \hh1);
)
Pdef(\hh1).play;
Pdef(\hh1).clear;
s.scope;
FreqScope.new(s);
// Ndef(\hh1).play(~t4.inbus);
// Pdef(\hh1).play;
// Ndef(\hh1).stop(3);
// Pdef(\hh1).clear;

~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/"); 
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/");
(
// ~yesorno_samp = ~samplesTree.at(\neutron_12).asArray;
// ~sample = ~samplesTree.at(\hoarder).asArray[rrand(0, 20)];
~yesorno_samp = ~samplesTree.at(\hoarder).asArray;
// ~sample = ~samplesTree.at(\cat_water).asArray;
// ~sample = ~samplesTree.at(\storm);
~slices = 32;
Pdef(\yesorno, Pbind(
    \instrument, \slice_s,
    \bufnum, Prand(~yesorno_samp, inf),
    \nSlices, ~slices,
    \spread, 0.75,
    \rev, Prand([1, 0], inf),
    \sliceIndex, Prand((0..~slices-1), inf),
    \pan, Ndef(\slicePan),
    \dur, 0.125,
    \amp, Pwhite(0.5, 1.5, inf),
    \rate, 0.9,
    \out, ~t5.inbus.index
));
~lcxlBindPdef.(\b0_s5_p, \yesorno);
~apcAssignPad.(24, \yesorno);
Ndef(\slicePan, {SinOsc.kr(5)});
Ndef(\slicePan).fadeTime_(3);
)
~apcBindPdef.(7, \yesorno);

Pdef(\yesorno).play;
Pdef(\yesorno).stop;
Pdef.clear;

~yesorno_reverb = ~t5.newPostSend(~r1, 1.0);
~yesorno_reverb.free;

~yesorno_delay = ~t5.newPostSend(~r2, 1.0);
~yesorno_delay.free;

~perc_reverb = ~perc.newPostSend(~r1, 0.5);
~perc_reverb.free;
~r1.level_(0.2);
~r2.level_(0.5);

~r2_fx.set(\mdt, 1,\dlt, 1, \dct, 1);
~perc_reverb.level_(0.5);

(
~t5_fx = ~t5.playfx{ | outbus, bot=30, wet=0.5|
  var sig = In.ar(outbus, 2);
  sig * Pulse.ar(bot) * wet;
};
)
~t5_fx.free;

Ndef(\mod_bot).fadeTime = 3;
Ndef(\mod_bot, {SinOsc.ar(0.5).range(20, 100)});
~t5_fx.set(\bot, Ndef(\mod_bot));
~t5_fx.set(\wet, 1.4);

(
~r4.playfx(\slice_s, [
    \bufSecs, 2,     // length of rolling buffer in seconds
    \nSlices, 64,     // number of slices across that window
    \mix, 1,         // 0 dry  1 wet
    \spread, 0.5,    // alternating pan offset
    \rate, 0.5,        // playback rate per slice
    \rev, 0,         // 0 forward  1 reverse
    \pan, 0,
    \amp, 1
]);
)

~perc_slice = ~t1.newPostSend(~r4, 1.0);
~perc_slice.free;
~r4.level_(1.0);
~perc_slice.level_(1);
~r1.set(\room, 0.1);
~slice_idx.set(0);
~slice_rev.set(0);      // 0 or 1
~slice_sp.set(0.5);     // spread amount
~slice_rate.set(0.5);
~slice_mix.set(1);
~slice_pan.set(0);

(
// don’t pass sends; just pass channels you actually want stems for
~stopStems = ~stemDiskStart.(
  [~m1, ~t1, ~t2, ~t3, ~phh1],   // track stems (dry)
  [~r1, ~r2],            // return stem (this is the reverb bus)
  "songC"           // file base name
);
)
// when you want to stop, on a musical offset
~stopStems.(1);

Pdef.clear;
