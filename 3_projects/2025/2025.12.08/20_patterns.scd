
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~sTree;
~fbufs;
(

/////////////////////////////////////////////////////////////
// BD1
/////////////////////////////////////////////////////////////
Pdefn(\bd1_bufs,
    Pn(
        Pseq(
            ~fbufs[\bass_drums],
            4
        ),
        inf
    )
);

// words

Pdefn(\bd1_dur0,
    Pseq([1/4 ! 3, Pn(Rest(), 1/4), 1/8 ! 2].flat, 1)
);

Pdefn(\bd1_dur1,
    Pseq([1/8 ! 4, 1/4, Pn(Rest(), 1.25)].flat, 1)
);

Pdefn(\bd1_dur2,
    Pseq([1/8 ! 8, Rest() ! 2].flat, 1)
);

Pdefn(\bd1_idx,
    Pseq([0,  5, ], inf), 
    // 2,  
);
)
(
// phrases

Pdefn(\bd1_phr1,
    Pseq([
        Pn(Pdefn(\bd1_dur0), 1),
        Pn(Pdefn(\bd1_dur1), 1)
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
  ~pBuf.(
    Pbind(
      // \instrument, \slice_s,
      \buf, Pdefn(\bd1_bufs),
      \idx, Pdefn(\bd1_idx),  
      \bufnum,  Pindex(~fbufs[\bass_drums],  Pkey(\idx)),
      \rate, 1,
      \amp, 0.8,
      \dur, Pdefn(\bd1_phr1),
      \out, ~pbd1.inbus.index,  
    )
  )
);

~apcAssignPad.(32, \bd1);
~lcxlBindPdef.(\b1_s1_p, \bd1);
)
Pdef(\bd1).play(~link,  quant:4);
Pdef(\bd1).stop;
~fbufs[\bass_drums][1]
~m1.level = 4.0;
