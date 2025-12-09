
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree;
~fbufs;
(

/////////////////////////////////////////////////////////////
// BD1
/////////////////////////////////////////////////////////////
Pdefn(\bd1_bufs, ~fbufs[\bass_drums][0] );

// words

Pdefn(\bd1_durm,  1/4);
Pdefn(\bd1_dur0,
    Pseq([1/2 ! 3, Pn(Rest(), 1/2), 1/4 ! 2].flat, 1)
);

Pdefn(\bd1_dur1,
    Pseq([1/4 ! 4, 1/2, Pn(Rest(), 1.5)].flat, 1)
);

Pdefn(\bd1_dur2,
    Pseq([1/8 ! 8, Rest() ! 2].flat, 1)
);

Pdefn(\bd1_dur3,
   Pbjorklund2(5, 8,  1)
);

Pdefn(\bd1_idx,
    Pseq([1!3,  2,  ].flat, inf), 
    // 2,  
);
)
(
// phrases

Pdefn(\bd1_phr1,
    Pseq([
        Pn(Pdefn(\bd1_durm), 4), 
        // Pn(Pdefn(\bd1_dur0), 2),
        // Pn(Pdefn(\bd1_dur3), 1),
    ], inf)
);

Pdefn(\bd1_phr2,
    Pseq([
        Pn(Pdefn(\bd1_dur0), 1),
        Pn(Pdefn(\bd1_dur1), 1),
        Pn(Pdefn(\bd1_dur2), 1)
    ], inf)
);
)
(
// sentences

Pdef(\bd1,
    Pbind(
      \instrument, \pBs,
      // \buf, Pdefn(\bd1_bufs),
      \idx, Pdefn(\bd1_idx),  
      \bufnum,  Pindex(~fbufs[\bass_drums],  Pkey(\idx)),
      \rate, 1,
      \amp, 0.8,
      \dur, Pdefn(\bd1_phr1),
      \out, ~pbd1.inbus.index,  
    )
);

~apcAssignPad.(32, \bd1);
~lcxlBindPdef.(\b1_s1_p, \bd1);
)
Pdef(\bd1).play(~link,  quant:4);
Pdef(\bd1).stop;

(
/////////////////////////////////////////////////////////////
// SD1
/////////////////////////////////////////////////////////////
Pdefn(\sd1_bufs, ~fbufs[\snare_drums][0] );

// words

Pdefn(\sd1_durm,  1/2);
Pdefn(\sd1_dur0,
    // Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1)
    Pseq([Pbjorklund2(3,  16,  1), Pn(Rest(), 2)],  1)
);

Pdefn(\sd1_idx,
    Pseq([2, ], inf), 
    // 2,  
);
)
(
// phrases

Pdefn(\sd1_phr1,
    Pseq([
        // Pn(Pdefn(\sd1_durm), 4), 
        Pn(Pdefn(\sd1_dur0), 2),
        // Pn(Pdefn(\sd1_dur1), 1),
    ], inf)
);

Pdefn(\sd1_phr2,
    Pseq([
        Pn(Pdefn(\sd1_dur0), 1),
        Pn(Pdefn(\sd1_dur1), 1),
        Pn(Pdefn(\sd1_dur2), 1)
    ], inf)
);
)
(
// sentences

Pdef(\sd1,
    Pbind(
      \instrument, \pBs,
      // \buf, Pdefn(\bd1_bufs),
      \idx, Pdefn(\sd1_idx),  
      \bufnum,  Pindex(~fbufs[\snare_drums],  Pkey(\idx)),
      \rate, 1,
      \amp, 0.8,
      \dur, Pdefn(\sd1_phr1),
      \out, ~psd1.inbus.index,  
    )
);

~apcAssignPad.(33, \sd1);
~lcxlBindPdef.(\b1_s2_p, \sd1);
)
Pdef(\sd1).play(~link,  quant:4);
Pdef(\sd1).stop;

(
/////////////////////////////////////////////////////////////
// HH1
/////////////////////////////////////////////////////////////
Pdefn(\hh1_bufs, ~fbufs[\hats][0] );

// words

Pdefn(\hh1_durm,  Pseq([1/8].flat,  1);
Pdefn(\hh1_dur0,
    // Pseq([Pn(Rest(),  7/8),  1/8, Pn(Rest(),  1.25)].flat, 1)
    Pseq([Pbjorklund2(13,  16,  inf)]/2,  1)
);

Pdefn(\hh1_idx,
    Pseq([1,   ], inf), 
    // 2,  
);
)
(
// phrases

Pdefn(\hh1_phr1,
    Pseq([
        Pn(Pdefn(\hh1_durm), 4), 
        Pn(Pdefn(\hh1_dur0), 2),
        // Pn(Pdefn(\hh1_dur1), 1),
    ], inf)
);

Pdefn(\hh1_phr2,
    Pseq([
        Pn(Pdefn(\hh1_dur0), 1),
        Pn(Pdefn(\hh1_dur1), 1),
        Pn(Pdefn(\hh1_dur2), 1)
    ], inf)
);
)
(
// sentences

Pdef(\hh1,
    Pbind(
      \instrument, \pBs,
      // \buf, Pdefn(\bd1_bufs),
      \idx, Pdefn(\hh1_idx),  
      \bufnum,  Pindex(~fbufs[\hats],  Pkey(\idx)),
      \rate, 1,
      \amp, 0.8,
      \dur, Pdefn(\hh1_phr1),
      \out, ~phh1.inbus.index,  
    )
);

~apcAssignPad.(34, \hh1);
~lcxlBindPdef.(\b1_s3_p, \hh1);
)
Pdef(\sd1).play(~link,  quant:4);
Pdef(\sd1).stop;
