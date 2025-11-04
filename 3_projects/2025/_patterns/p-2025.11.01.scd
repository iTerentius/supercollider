
TempoClock.default.tempo = 80/60;
~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
 ~loadSamplesRecursive.("~/Music/supercollider/_samples/Cat-Water/");

~perc_rev = ~perc.newPostSend(~r1, 0.2);
~perc_rev.tryPerform(\free);
~perc_del = ~perc.newPostSend(~r2, 0.4);
~perc_del.tryPerform(\free);

(
~sbd1 = [
  ~samplesTree.at(\bass_drums).asArray[2],
  ~samplesTree.at(\bass_drums).asArray[0],
  ~samplesTree.at(\bass_drums).asArray[4]
];

~ssd1 = ~samplesTree.at(\snare_drums).asArray[6];
~shh1 = ~samplesTree.at(\hats).asArray[1];

~groove_bd1 = ~pBuf.(
   Pbind(
    \buf,    Pseq(~sbd1, inf),
    \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
    \dur,    1,
    \amp,   2.0,
    \rate,  1,
    \out,   ~pbd1.inbus.index
  )
);

~fill_bd1 = ~pBuf.(
   Pbind(
    \buf,    Prand(~sbd1, inf),
    \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
    \dur,    Pseq([0.25!2, Rest(0.25)!2].flat, inf),
    \amp,   2.0,
    \rate,  1,
    \out,   ~pbd1.inbus.index
  )
);

// ~ssd1 = ~samplesTree.at(\snare_drums).asArray;
~groove_sd1 = ~pBuf.(
  Pbind(
    \buf,    ~ssd1,
    \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
    // \dur,   Pseq([Rest(0.25), Rest(0.25), Rest(0.25), 0.25, Rest(0.25), Rest(0.25), Rest(0.25), Rest(0.25)], inf),
    \dur,   Pseq([Rest(0.75), 0.25, Rest(0.5)!2, 0.25].flat, inf),
    // \dur,   Pbjorklund2(3,8, inf, 0.125)/2,
    \amp,   Pseq([0.8, 1], inf),
    \rate,  1,
    \out,   ~psd1.inbus.index
  )
);

~fill_sd1 = ~pBuf.(
  Pbind(
    \buf,    ~ssd1,
    \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
    // \dur,   Pseq([0.5, 0.5, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125], inf),
    \dur,   Pseq([0.5!2, 0.25!4, 0.125!8].flat, inf),
    \amp,   Pseq([0.8, 1.0], inf),
    \rate,  1,
    \out,   ~psd1.inbus.index
  )
);

~groove_hh1 = ~pBuf.(
   Pbind(
    \buf,    ~shh1,
    \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
    \dur,    0.5,
    \amp,   Pseq([2, 1!3].flat, inf),
    \rate,  1,
    \out,   ~phh1.inbus.index
  )
);

~fill_hh1 = ~pBuf.(
   Pbind(
    \buf,    ~shh1,
    \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
    \dur,    Pseq([Rest(0.5), 0.5], inf),
    \amp,   Pseq([2, 1!3].flat, inf),
    \rate,  1,
    \out,   ~phh1.inbus.index
  )
);

)
(
~groove_kit1 = Ppar([~groove_bd1, ~groove_sd1, ~groove_hh1]);
~fill_kit1 = Ppar([~fill_bd1, ~fill_sd1, ~fill_hh1]);

Pdef(\kit_1, 
  Pseq([
    Pfindur(14, ~groove_kit1),
    Pfindur(2, ~fill_kit1 ),
    Pfindur(12, Ppar([Pbind(\type, \rest, \dur, 1), ~groove_bd1, ~groove_hh1], inf)),
    Pfindur(2, ~fill_kit1 ),
  ], inf);
);
~lcxlBindPdef.(\b2_s1_p, \kit_1);
)
Pdef(\kit_1).play;
Pdef(\kit_1).stop;

///////////////////////////////////////////////////////////////////////

(
~sbd1 = ~samplesTree.at(\bass_drums).asArray[2];
Pdef(\bd1,
    ~pBuf.(
        Pbind(
            \buf,    ~sbd1,
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,    1,
            \amp,   2.0,
            \rate,  1,
            \out,   ~pbd1.inbus.index
        )
    )
);
~apcAssignPad.(32, \bd1);
~lcxlBindPdef.(\b1_s1_p, \bd1);
)
Pdef(\bd1).play;
Pdef(\bd1).stop(3);
Pdef(\bd1).clear;

(
~ssd1 = ~samplesTree.at(\snare_drums).asArray[5];
Pdef(\sd1,
    ~pBuf.(
        Pbind(
            \buf,    ~ssd1,
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,   Pseq([Rest(0.25), Rest(0.25), Rest(0.25), 0.25, Rest(0.25), Rest(0.25), Rest(0.25), Rest(0.25)], inf),
            \amp,   1.5,
            \rate,  1,
            \out,   ~psd1.inbus.index
        )
    )
);
~apcAssignPad.(32, \sd1);
~lcxlBindPdef.(\b1_s2_p, \sd1);
)
Pdef(\sd1).play;
Pdef(\sd1).stop(3);
Pdef(\sd1).clear;

(
~shh1 = ~samplesTree.at(\hats).asArray[1];
Pdef(\sd1,
    ~pBuf.(
        Pbind(
            \buf,    ~shh1,
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,   Pseq([Rest(0.25), Rest(0.25), Rest(0.25), 0.25, Rest(0.25), Rest(0.25), Rest(0.25), Rest(0.25)], inf),
            \amp,   1.5,
            \rate,  1,
            \out,   ~phh1.inbus.index
        )
    )
);
~apcAssignPad.(32, \sd1);
~lcxlBindPdef.(\b1_s2_p, \sd1);
)
Pdef(\sd1).play;
Pdef(\sd1).stop(3);
Pdef(\sd1).clear;

(
Ndef(\pitchbass, {|freq=50|
  var sig;
  // var env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.1, 0.5, 1], curve: [-5, 0, -5]));
  sig = LFPulse.ar(freq)!2;
  sig * 0.1;
});
)
Ndef(\pitchbass)[1] = \pset -> Pbind(\freq, Pseq([90, 120, 440, Rest(0.5)], inf), \dur, Prand([0.25, Rest(0.5)], inf), \amp, 0.3).play;
Ndef(\pitchbass).play;
Ndef(\pitchbass).clear;
Ndef.clear;
