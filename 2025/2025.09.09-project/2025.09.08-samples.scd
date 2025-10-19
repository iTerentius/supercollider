( ~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/"); )
( ~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/"); )
( ~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/"); )
( ~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/"); )
( ~loadSamplesRecursive.("~/Music/supercollider/_samples/AKWF/AKWF_0001/"); )
( ~loadSamplesRecursive.("~/Music/supercollider/_samples/Cat-Water/"); )

( ~samp = ~samplesTree[\bass_drums][\SHD_808BD_03]; )
( ~samp = ~samplesTree[\field][\cat_food]; )
( ~samp = ~samplesTree[\neutron_12][\121]; )
( ~samples = ~samplesTree.at(\neutron_12); )
( ~samples = ~samplesTree.at(\hoarder); )
( ~samples = ~samplesTree.at(\bass_drums); )
( ~samples = ~samplesTree.at(\cat_water); )
( ~samples = ~samplesTree.at(\akwf_0001); )
 ~samples.postln; 

(
~samples = ~samplesTree.at(\hoarder);
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
});
)
Ndef(\i2).play;
Ndef(\i2).stop(3);
Ndef(\i2).clear(3);

TempoClock.default.tempo = 60/60; // 90 bpm

(
~perc = MixerChannel.new(\perc, s, 2, 2, outbus: ~t2);

~pbd1 = MixerChannel.new(\pbd1, s, 2, 2, outbus: ~perc);
~lcxlBindParam.(\b4_s1_f, {|x| ~pbd1.level_(x)});
~lcxlBindParam.(\b4_s1_r3, {|x| ~pbd1.pan_(x.linlin(0, 1, -1, 1))});

~pbd2 = MixerChannel.new(\pbd2, s, 2, 2, outbus: ~perc);
~lcxlBindParam.(\b4_s2_f, {|x| ~pbd2.level_(x)});
~lcxlBindParam.(\b4_s2_r3, {|x| ~pbd2.pan_(x.linlin(0, 1, -1, 1))});

~phh1 = MixerChannel.new(\phh1, s, 2, 2, outbus: ~perc);
~lcxlBindParam.(\b4_s3_f, {|x| ~phh1.level_(x)});
~lcxlBindParam.(\b4_s3_r3, {|x| ~phh1.pan_(x.linlin(0, 1, -1, 1))});
)


( ~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/"); )
(
~bd1 = ~samplesTree.at(\bass_drums).asArray;
Pdef(\bd1).quant = 1;
Pdef(\bd1,
    ~pBuf.(
        Pbind(
            \buf,   Prand(~bd1, inf),          // your Buffer object
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,    Pbjorklund2(3, 8)/4,
            \amp,   3.0,
            \rate,  1,
            \out,   ~pbd1.inbus.index
        )
    )
).play;
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
~lcxlBindPdef.(\b0_s2_p, \bd2);
)

Pdef(\bd2)[1] = \filter -> { |in| CombL.ar(in, 0.2, LFPulse.kr(0.5!2).exprange(0.01, 0.2), 3) * 0.7 };
Pdef(\bd2).set(\wet1, 0.8);
Pdef(\bd2)[1] = nil;
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
).play;
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
(
// ~sample = ~samplesTree.at(\neutron_12).asArray[rrand(0, 6)];
// ~sample = ~samplesTree.at(\hoarder).asArray[rrand(0, 20)];
~sample = ~samplesTree.at(\cat_water).asArray;
// ~sample = ~samplesTree.at(\storm);
~slices = 22;
Pdef(\yesorno, Pbind(
    \instrument, \slice_s,
    \bufnum, Pseq(~sample, inf),
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
Ndef(\slicePan, {SinOsc.kr(5)});
Ndef(\slicePan).fadeTime_(3);
)

Pdef(\yesorno).stop;
Pdef.clear;

~yesorno_reverb = ~t5.newPostSend(~r1, 1.0);
~yesorno_reverb.free;

~yesorno_delay = ~t5.newPostSend(~r2, 1.0);
~yesorno_delay.free;

~perc_reverb = ~perc.newPostSend(~r1, 0.5);
~perc_s_4.free;
~r1.level_(1);
~r2.level_(1);

~r2_fx.set(\mdt, 3,\dlt, 3, \dct, 3);
~perc_reverb.level_(1);

(
~t5_fx = ~t5.playfx{ | outbus, bot=30, wet=0.5|
  var sig = In.ar(outbus, 2);
  sig * Pulse.ar(bot) * wet;
};
)
~t5_fx.free;

Ndef(\mod_bot).fadeTime = 3;
Ndef(\mod_bot, {LFSaw.ar(0.5).range(20, 200)});
~t5_fx.set(\bot, Ndef(\mod_bot));
~t5_fx.set(\wet, 1.0);

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
