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
~bd1 = ~samplesTree.at(\bass_drums).asArray[0];
Pdef(\bd1).quant = 1;
Pdef(\bd1,
    ~pBuf.(
        Pbind(
            \buf,   ~bd1,          // your Buffer object
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,   0.5,
            \amp,   1.0,
            \rate,  1,
            \pan,   0.5,
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
      \rate,  1,
      \pan,   -0.5,
      \out, ~pbd2.inbus.index 
    )
  )
).play;
)

Pdef(\bd2)[1] = \filter -> { |in| CombL.ar(in, 0.2, LFPulse.kr(0.5!2).exprange(0.01, 0.2), 3) * 0.7 };
Pdef(\bd2).set(\wet1, 0.8);
Pdef(\bd2)[1] = nil;
Pdef(\bd2).play;
Pdef(\bd2).stop;
Pdef(\bd2).clear(3);

Pdef(\bdFx, { FreeVerb2.ar(\in1.ar([0, 0]), \in2.ar([0,0]), \mix.kr(0.5), \room.kr(0.7), \damp.kr(0.5))});
Pdef(\bdFx) <<>.in1 Pdef(\bd1);
Pdef(\bdFx) <<>.in2 Pdef(\bd2);
Pdef(\bdFx).play(out:6);
Pdef(\bdFx).stop(5);

(
~hh1 = ~samplesTree.at(\hats).asArray[1];
Pdef(\hh1).quant = 1;
Pdef(\hh1, 
  ~pBuf.(
    Pbind(
      \buf,    ~hh1,
      \instrument, Pfunc { |e|
        if(e[\buf].numChannels == 2) { \pBs } { \pBm }
      },
      \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
      \dur,   0.5,
      \amp,   Pseq([0.4, 0.4, 0.7, 0.9], inf),
      \rate,  Pseq([0.5, 0.25, 0.125, 1], inf),
      \pan,   0.2,
      \startPos, 0,
      \loop, 0,
      \out, ~phh1.inbus.index
    )
  )
).play;
)
Ndef(\hh1)[1] = \filter -> { |in| FreeVerb.ar(in, 0.5, 0.5, 0.5) };


Ndef(\hh1).play(~t4.inbus);
Pdef(\hh1).play;
Ndef(\hh1).stop(3);
Ndef(\hh1).clear;


