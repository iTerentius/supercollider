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
~ndefToTrack.(\i2, 0, 2);
Ndef(\i2).play;
Ndef(\i2).stop(3);
Ndef(\i2).clear(3);

~m36_openMeters.();
~m36_closeMeters.();

~m36_debugDump.();
~m36_setMeterSources.();   // auto uses ~m36_tracks, ~m36_master, and ~m36_returns if present
~m36_openMeters_basic.();
~m36_openMeters.();
Window("qt test 2025-09-22", Rect(200,200,220,120)).front;
// 2025-09-21 debug channel discovery
(
var chans;
chans = ~m36_collectChannels.();
"discovered: ".post; chans.size.postln;
chans.do { |ch, i|
    var nm, bi, nc; // declare vars at top
    nm = ch.tryPerform(\key) ?? { "ch" ++ i };
    bi = ch.inbus.index;
    nc = ch.inbus.numChannels ? 2;
    ("  " ++ i ++ "  " ++ nm ++ "  inbus " ++ bi ++ "  chans " ++ nc).postln;
};
)

TempoClock.default.tempo = 60/60; // 90 bpm

( ~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/"); )
(
~bd1 = ~samplesTree.at(\bass_drums).asArray[0];
Pdef(\bd1).quant = 1;
Pdef(\bd1, Pbind(
    \buf,    ~bd1,
    \instrument, Pfunc { |e|
        if(e[\buf].numChannels == 2) { \pBs } { \pBm }
    },
    \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
    \dur,   0.5,
    \amp,   1.0,
    \rate,  1,
    \pan,   0.5,
    \out,   ~m36_in.(1) 
));
)
Pdef(\bd1).play;
Pdef(\bd1).stop(3);
Pdef(\bd1).clear;

~m36_tracks[1].level_(2.05);
~m36_master.level_(0);

ServerMeter(s);
// 2025-09-21 force new taper at runtime
~lcxlMix[\cfg].put(\faderBottom_dB, -80);  // deeper off
~lcxlMix[\cfg].put(\faderTop_dB, 12);       // top = +6 dB (or try 12 later)

Ndef.clear;

(
~bd2 = ~samplesTree.at(\bass_drums).asArray[4];
Pdef(\bd2).quant = 1;
Pdef(\bd2, Pbind(
    \buf,    ~bd2,
    \instrument, Pfunc { |e|
        if(e[\buf].numChannels == 2) { \pBs } { \pBm }
    },
    \bufnum, Pkey(\buf),   // SC will pass the Buffer’s bufnum
    \dur,   Prand([0.25, 0.5, Rest(0.25)], inf),
    \amp,   1.0,
    \rate,  1,
    \pan,   -0.5,
    \out, ~m36_in.(0) 
));
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
Pdef(\hh1, Pbind(
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
));
)
Pdef(\hh1)[1] = \filter -> { |in| FreeVerb.ar(in, 0.5, 0.5, 0.5) };


Pdef(\hh1).play;
Pdef(\hh1).stop(3);
Pdef(\hh1).clear;

// tracks on row 1, then master + 8 returns on row 2
~m36_openMeters_inline.( ~m36_tracks ++ [ ~m36_master ] ++ ( ~m36_returns ? [] ), 9, 30, 110, 12, 6, 80, 80 );
// 2025-09-22 show all 18 using the already-built source list
~m36_openMeters_inline.( ~m36_meterSources, 9, 30, 110, 12, 6, 80, 80 );

// or, if you prefer to pass the vars explicitly in your setup
~m36_openMeters_inline.( ~m36_tracks ++ [ ~m36_master ] ++ ( ~m36_fxchans ? [] ), 9, 30, 110, 12, 6, 80, 80 );s.boot;

// 3 groups and fader synth, just this one line
~srcMc = MixerChannel(\src, s, s, 2, level: 1);

// no need to write group and bus by hand
~srcMc.play((instrument: \syn1, sustain: 1));
~t1 = ~m36_tracks[0];
~m36_tracks[0].play((instrument: \syn1, sustain: 1));

// ringmod fx insert - group bus etc also automatic
// (but I have to use a different arg name)
// playfx does ReplaceOut for you!
(
~ringmod = ~m36_tracks[0].playfx { |outbus|
	var sig = In.ar(outbus, 2);
	sig * SinOsc.ar(90);
};
)

~srcMc.play((instrument: \default, sustain: 1));


// reverb send
// we know in advance what fx insert is needed!
// so we can write it at init time, save a step
(
~rvbMc = MixerChannel(\rvb, s, 2, 2, level: 1,
	completionFunc: { |chan|
		~rvb = chan.playfx { |outbus|
			var sig = In.ar(outbus, 2);
			FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.2);
      // PingPong.ar(sig, [sig[0], sig[1]], 0.5);
		}
	}
);

~m36_tracks[0].newPostSend(~rvbMc, 0.9);  // one liner to make the send
)

(
~t1 = ~m36_tracks[0].play(
	Pbind(
		\instrument, \default,
		\degree, Pwhite(-7, 7, inf),
		\dur, Pwhite(1, 3, inf) * 0.25,
		\legato, 0.4,
		\amp, 0.2
	)
);
)

~t1.stop;

~srcMc.free; ~rvbMc.free;

