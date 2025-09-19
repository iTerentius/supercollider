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
~samples = ~samplesTree.at(\cat_water);
Ndef(\i2).quant = 1;
Ndef(\i2)[0] = { |amp=0.5 rate=1, dur=1|
  var buffers = ~samples.values; // get array of Buffer objects
  var which = TIRand.kr(0, buffers.size-1, Impulse.kr(1)); // random index each second
  var buf = Select.kr(which, buffers); // select Buffer object
  var isMono = (buf.numChannels == 1);
  var rateSig = Lag.kr(rate, 0.05);
  var sig;
  sig = PlayBuf.ar(2, buf, rateSig, loop: 1);
  sig = (isMono).if({sig!2},{sig});
  sig * amp * 0.3;
  // Silent.ar(2)
}).play(vol: 0, quant: 1);
)
Ndef(\i2).stop(3);
Ndef(\i2).clear(3);

TempoClock.default.tempo = 60/60; // 90 bpm

( ~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/"); )
Ndef(\bd1).play(quant: 1, out: ~m36_in.(3));
(
~bd1 = ~samplesTree.at(\bass_drums).asArray[0];
Ndef(\bd1).quant = 1;
Ndef(\bd1)[0] = Pbind(
    \buf,    ~bd1,
    \instrument, Pfunc { |e|
        if(e[\buf].numChannels == 2) { \pBs } { \pBm }
    },
    \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
    \dur,   0.5,
    \amp,   0.4,
    \rate,  1,
    \pan,   0.5,
    \out,   ~m36_in.(2) 
);
)
Ndef(\bd1).play;
Ndef(\bd1).stop;

~m36_tracks[2].level_(0.25);
~m36_master.level_(0.24);

ServerMeter(s);

Ndef.clear;

(
~bd2 = ~samplesTree.at(\bass_drums).asArray[4];
Ndef(\bd2).quant = 1;
Ndef(\bd2)[0] = Pbind(
    \buf,    ~bd2,
    \instrument, Pfunc { |e|
        if(e[\buf].numChannels == 2) { \pBs } { \pBm }
    },
    \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
    \dur,   Prand([0.25, 0.5, Rest(0.25)], inf),
    \amp,   0.4,
    \rate,  1,
    \pan,   -0.5,
    \out, ~m36_in.(1) 
);
)

Ndef(\bd2)[1] = \filter -> { |in| CombL.ar(in, 0.2, LFPulse.kr(0.5!2).exprange(0.01, 0.2), 3) * 0.7 };
Ndef(\bd2).set(\wet1, 0.8);
Ndef(\bd2)[1] = nil;
Ndef(\bd2).play;
Ndef(\bd2).stop;
Ndef(\bd2).clear(3);

Ndef(\bdFx, { FreeVerb2.ar(\in1.ar([0, 0]), \in2.ar([0,0]), \mix.kr(0.5), \room.kr(0.7), \damp.kr(0.5))});
Ndef(\bdFx) <<>.in1 Ndef(\bd1);
Ndef(\bdFx) <<>.in2 Ndef(\bd2);
Ndef(\bdFx).play(out:6);
Ndef(\bdFx).stop(5);

(
~hh1 = ~samplesTree.at(\hats).asArray[1];
Ndef(\hh1).quant = 1;
Ndef(\hh1)[0] = Pbind(
    \buf,    ~hh1,
    \instrument, Pfunc { |e|
        if(e[\buf].numChannels == 2) { \pBs } { \pBm }
    },
    \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
    \dur,   1.0,
    \amp,   Pseq([0.4, 0.4, 0.7, 0.9], inf),
    \rate,  Pseq([0.5, 0.25, 0.125, 1], inf),
    \pan,   0.2,
    \startPos, 0,
    \loop, 0,
    \out, ~m36_in.(3) 
);
)
Ndef(\hh1)[1] = \filter -> { |in| FreeVerb.ar(in, 0.5, 0.5, 0.5) };


Ndef(\hh1).play;
Ndef(\hh1).stop(3);
Ndef(\hh1).clear;


