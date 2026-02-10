

TempoClock.default.tempo = 120/60;
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/Cat-Water/");

(
~sbd1 = [
  ~sTree.at(\bass_drums).asArray[1],
  ~sTree.at(\bass_drums).asArray[3],
  ~sTree.at(\bass_drums).asArray[2]
];

~ssd1 = ~sTree.at(\snare_drums).asArray[6];
~shh1 = ~sTree.at(\hats).asArray[1];

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

// ~ssd1 = ~sTree.at(\snare_drums).asArray;
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
