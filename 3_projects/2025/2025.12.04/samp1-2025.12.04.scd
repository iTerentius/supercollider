
~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
// BASS DRUM 1
// words
(
Pdefn(\bd1_dur0,  Pseq([1/2]))
Pdefn(\bd1_dur1,  Pseq([1/4!3, Pn(Rest(), 1/4),  1/8!2].flat,  1));
Pdefn(\bd1_dur2,  Pseq([1/8!4,  1/4, Pn(Rest(), 1.25)].flat,  1));
Pdefn(\bd1_dur3,  Pseq([1/8!8,  Rest()!2].flat,  1));

// phrases

Pdefn(\bd1_durs,  Pseq([
  // Pn(Pdefn(\bd1_dur1),  1),  
  Pn(Pdefn(\bd1_dur2),  2),  
  // Pn(Pdefn(\bd1_dur3),  2),  
],  inf));
)
// voice
(
~bd1 = ~samplesTree.at(\bass_drums).asArray;
Pbindef(\bd1_v1, 
  // \buf, Pn(Pser(~bd1, 1),  inf), 
  \buf, ~bd1.at(2), 
  \bufnum,  Pkey(\buf),
  \rate,  1,  
  \amp,  0.8, 
  \dur,  Pn(Pdefn(\bd1_durs), inf), 
);

Pdef(\bd1,
    ~pBuf.(
        Pbindef(\bd1_v1), 
    )
);
~apcAssignPad.(32, \bd1);
~lcxlBindPdef.(\b1_s1_p, \bd1);
)
Pdef(\bd1).play(~link,  quant:4);
Pdef(\bd1).stop;
Pdef(\bd1).clear;

// HH1
// words
(
Pdefn(\hh1_dur0,  Pseq([1/2,  1/4!2,  1/8, ].flat,  inf).stutter(4));
Pdefn(\hh1_dur0,  1/2);
Pdefn(\hh1_dur1,  Pseq([1/4!3, Pn(Rest(), 1/4),  1/8!2].flat,  1));
Pdefn(\hh1_dur2,  Pseq([1/8!4,  1/4, Pn(Rest(), 1.25)].flat,  1));
Pdefn(\hh1_dur3,  Pseq([1/8!8,  Rest()!2].flat,  1));

// phrases

Pdefn(\hh1_durs,  Pseq([
  Pn(Pdefn(\hh1_dur0),  1),  
],  inf));
)
// voice
(
~hh1 = ~samplesTree.at(\hats).asArray;
Pbindef(\hh1_v1, 
  // \buf, Pn(Pser(~hh1, 1),  inf), 
  \buf,     ~hh1.at(1), 
  \bufnum,  Pkey(\buf),
  \rate,  1,  
  \amp,  0.8, 
  \dur,  Pn(Pdefn(\hh1_durs), inf), 
);

Pdef(\hh1,
    ~pBuf.(
        Pbindef(\hh1_v1), 
    )
);
~apcAssignPad.(32, \hh1);
~lcxlBindPdef.(\b1_s2_p, \hh1);
)
Pdef(\hh1).play(~link,  quant:4);
Pdef(\hh1).stop;
Pdef(\hh1).clear;

(
Pdef(\kit1, Ppar([
  Pdef(\bd1),
  Pdef(\hh1), 
],  inf));
)
Pdef(\kit1).play(~link, quant:1);
Pdef(\kit1).stop;
