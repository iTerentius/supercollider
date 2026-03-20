// sd1 — Snare Drum
// Re-eval this file to reset voice to defaults (story overrides live in arrangement.scd).
(
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\sd1, ~pBuf.(
    // Pbindef(\pbd_sd1, 
    Pbind(
        \buf,     Pn(Pdefn(\sd1_bufs),  inf),
        \bufnum,  Pkey(\buf),
        \scale,   Pn(Pdefn(\sd1_scale), inf),
        \octave,  Pn(Pdefn(\sd1_octs),  inf),
        \stretch, Pn(Pdefn(\sd1_strs),  inf),
        \degree,  Pn(Pdefn(\sd1_degs),  inf),
        \dur,     Pn(Pdefn(\sd1_durs),  inf),
        \amp,     Pn(Pdefn(\sd1_amps),  inf),
        \out,     Pn(Pdefn(\sd1_out),   inf),
    )
));

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\sd1_out,   ~t2.inbus.index);
Pdefn(\sd1_scale, Scale.minor);

// BUFS — words
~ssd1 = ~sTree[\snare_drums].values;
Pdefn(\sd1_buf_0, Pseq(~ssd1, 1));
Pdefn(\sd1_buf_1, Pseq(~ssd1[[5]], 1));
// sentences
Pdefn(\sd1_bufs_a, Pseq([Pn(Pdefn(\sd1_buf_1), 4)], 1));      // single hit
Pdefn(\sd1_bufs_b, Pseq([Pn(Pdefn(\sd1_buf_0), 4)], 1));      // all samples
Pdefn(\sd1_bufs_c, Pseq([Pn(Pdefn(\sd1_buf_1), 2), Pn(Pdefn(\sd1_buf_0), 2)], 1));
// story
Pdefn(\sd1_bufs, Pseq([Pn(Pdefn(\sd1_bufs_a), 1)], 1));

// OCTS — words
Pdefn(\sd1_oct_0, 5);
Pdefn(\sd1_oct_1, Pseq([4, 5], 1));
// story
Pdefn(\sd1_octs, Pseq([Pn(Pdefn(\sd1_oct_0), 4)], 1));

// AMPS — words
Pdefn(\sd1_amp_0, 0.3);
Pdefn(\sd1_amp_1, Pwhite(0.5, 0.7, 1));
Pdefn(\sd1_amp_2, Pseq([0.5!3, 0.8].flat, 1));
// story
Pdefn(\sd1_amps, Pseq([Pn(Pdefn(\sd1_amp_0), 4)], 1));

// DEGS — words
Pdefn(\sd1_deg_0, 0);
Pdefn(\sd1_deg_1, Pseq([0, 1, \, 3, \, 0], 1));
Pdefn(\sd1_deg_2, Pseq([0, \, \, \, 14, \, 0, \, 0, \, \, 0, 14, \, \, \], 1));
// sentences
Pdefn(\sd1_degs_a, Pseq([Pn(Pdefn(\sd1_deg_0), 4)], 1));
Pdefn(\sd1_degs_b, Pseq([Pn(Pdefn(\sd1_deg_1), 4)], 1));
Pdefn(\sd1_degs_c, Pseq([Pn(Pdefn(\sd1_deg_2), 4)], 1));
// story
Pdefn(\sd1_degs, Pseq([Pn(Pdefn(\sd1_degs_c), 1)], 1));

// DURS — words
Pdefn(\sd1_dur_0, 2);
Pdefn(\sd1_dur_1, Pseq([1/4!2, 1/2!3].flat, 1));
Pdefn(\sd1_dur_2, Pbjorklund(5, 8, 1)/2);
Pdefn(\sd1_dur_3, Pseq([1/4!2, Rest(1/4), 1/4].flat, 1));
Pdefn(\sd1_dur_4, 1/2);
// sentences
Pdefn(\sd1_durs_a, Pseq([Pn(Pdefn(\sd1_dur_0), 4)], 1));         // straight half notes
Pdefn(\sd1_durs_b, Pseq([Pn(Pdefn(\sd1_dur_0), 2), Pn(Pdefn(\sd1_dur_3), 2)], 1));
Pdefn(\sd1_durs_c, Pseq([Pn(Pdefn(\sd1_dur_2), 4)], 1));         // euclidean
// story
Pdefn(\sd1_durs, Pseq([
  Pn(Pdefn(\sd1_durs_a), 1),  
  Pn(Pdefn(\sd1_durs_b), 1),  
], 1));

// STRS — words
Pdefn(\sd1_str_0, 1);
Pdefn(\sd1_str_1, Pstep(Pseq([1!4, 2!2].flat, 1), 4));
// story
Pdefn(\sd1_strs, Pseq([Pn(Pdefn(\sd1_str_0), 4)], 1));


// ~bd1_ilfx_1.free;
// ~bd1_ilfx_1 = ~pbd1.playfx({|in|
//   var sig = In.ar(~pbd1.inbus,  2);
//   var hpfreq = \hpfreq.kr(400);
//   var hprq = \hprq.kr(1.0);
//   var lpfreq = \lpfreq.kr(800);
//   var lprq = \lprq.kr(1.0);
//   var lpsig = LPF.ar(sig, lpfreq, lprq);
//   var hpsig = HPF.ar(sig, hpfreq, hprq); 
//   var wet = lpsig + hpsig; 
//   wet; 
// });
// ~bd1_ilfx_1.set(\lpfreq,  1000,  \rq, 2.0,  \hpfreq,  500,  \hprq,  2.0);
)

