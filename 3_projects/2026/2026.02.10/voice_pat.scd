
(
~sBash = ~sTree[\bass_drums].values[0..3];
Pdef(\bash, ~pBuf.(
  Pbind(  
  \buf,     Pn(Pdefn(\bash_bufs), inf), 
  \bufnum,  Pkey(\buf), 
  \scale,   Pn(Pdefn(\bash_scale), inf), 
  \octave,  Pn(Pdefn(\bash_octs), inf), 
  \stretch, Pn(Pdefn(\bash_strs), inf), 
  \degree,  Pn(Pdefn(\bash_degs), inf),  
  \dur,     Pn(Pdefn(\bash_durs), inf), 
  \amp,     Pn(Pdefn(\bash_amp),  inf),  
  \out,     ~pbd1.inbus.index, 
  )
));
~lpBind.([1,  1], \bash,  10);
~apcAssignPad.(32,  \bash);
~lpBind.([8, 1], { ~bash_t.free; ~bash_t = ~ensurePostSend.(~pbd1, ~r4,  1); });   // evaluated on press
~lpBind.([8, 2], { ~bash_t.tryPerform(\free); });   // evaluated on press

//--------------------------------------------------
~sBashat = ~sTree[\hats].values[7..7];
// ~samps = ~sTree[\snare_roll].values[0..8];
Pdef(\bashat, 
  ~pBuf.(
    Pbind(
    \buf,     Pn(Pdefn(\bashat_bufs), inf), 
    \bufnum,  Pkey(\buf), 
    \dur,     Pn(Pdefn(\bashat_durs), inf), 
    \octave,  Pn(Pdefn(\bashat_octs), inf), 
    \degree,  Pn(Pdefn(\bashat_degs), inf), 
    \stretch, Pn(Pdefn(\bashat_strs), inf), 
    \dur,     Pn(Pdefn(\bashat_durs), inf), 
    \amp,     Pn(Pdefn(\bashat_amps), inf), 
    \out,     ~phh1.inbus.index, 
  );
));
~lpBind.([1,  2], \bashat,  20);

//--------------------------------------------------
// ~sRoll = ~sTree[\drumloops].values[3..3];
~sRoll = ~sTree[\jttcot].values[0..6];
Pdef(\roll, 
  // ~pBuf.(
    // Pbindef(\roll_pbd,  
    Pbind(
    \instrument,\slice_m, 
    \buf,       Pn(Pdefn(\roll_bufs), inf), 
    \bufnum,    Pkey(\buf), 
    \nSlices,   Pn(Pdefn(\roll_nSlices),  inf), 
    \rate,      Pn(Pdefn(\roll_rates), inf), 
    \rev,       Pn(Pdefn(\roll_rev),  inf),  
    \sliceDur,  Pn(Pdefn(\roll_sliceDurs), inf),  
    \stretch,   Pn(Pdefn(\roll_strs), inf), 
    \spread,    Pn(Pdefn(\roll_sprds), inf),  
    \octave,    Pn(Pdefn(\roll_octs), inf), 
    \degree,    Pn(Pdefn(\roll_degs), inf), 
    \sliceIndex,Pn(Pdefn(\roll_sliceIdxs), inf), 
    \dur,       Pn(Pdefn(\roll_durs), inf), 
    \amp,       Pn(Pdefn(\roll_amps), inf), 
    \out,       ~psd1.inbus.index, 
  );
);
~lpBind.([1,  3], \roll,  30);

//--------------------------------------------------
// MS-20 style bass
Pdef(\ms20,
    Pbind(
        \instrument,   \ms20Bass,
        \scale,        Pn(Pdefn(\ms20_scale), inf), 
        \degree,       Pn(Pdefn(\ms20_degs), inf), 
        \octave,       Pn(Pdefn(\ms20_octs), inf), 
        \amp,          Pn(Pdefn(\ms20_amps), inf),  
        \dur,          Pn(Pdefn(\ms20_durs), inf), 
        \stretch,      Pn(Pdefn(\ms20_strs), inf), 
        \legato,       Pn(Pdefn(\ms20_legs), inf),
        \hpfCutoff,    Pn(Pdefn(\ms20_hpcut), inf), 
        \lpfCutoff,    Pn(Pdefn(\ms20_lpcut), inf),  
        \lpfRes,       Pn(Pdefn(\ms20_lpRes), inf), 
        \filterEnvAmt, Pn(Pdefn(\ms20_fEamt), inf), 
        \ringMod,      Pn(Pdefn(\ms20_ringMod), inf),  
        \out,          ~t2.inbus.index, 
    );
);
~lpBind.([1,  4], \ms20,  40);

//--------------------------------------------------
// thingA 
Pdef(\thingA, Pbind(
  \instrument,  \thingA,  
  \scale,       Pn(Pdefn(\thingA_scale),  inf), 
  \octave,      Pn(Pdefn(\thingA_octs),  inf), 
  \degree,      Pn(Pdefn(\thingA_degs),  inf), 
  \mod1,        Pn(Pdefn(\thingA_mod1), inf), 
  \mod2,        Pn(Pdefn(\thingA_mod2), inf), 
  \amp,         Pn(Pdefn(\thingA_amps), inf),  
  \delta,       Pn(Pdefn(\thingA_delta),  inf), 
  \stretch,     Pn(Pdefn(\thingA_strs), inf), 
  \dur,         Pn(Pdefn(\thingA_durs), inf),
  \out,         ~t2.inbus.index,  
));
~lpBind.([1,  5], \thingA,  50);
//--------------------------------------------------
// BASH Glitch FX
Pdef(\roll_fx_ctl,  Pbindef(\roll_fx_ctl_pbd, 
  \type,    \set, 
  \id,      Pfunc({~roll_fx1.nodeID }),  
  \args,    #[\mod1, \amp, \dur],  
  \amp,     Pn(Pdefn(\bash_glitch_amp), inf),  
  \mod1,    Pn(Pdefn(\bash_glitch_mod1), inf), 
  \mod2,    Pn(Pdefn(\bash_glitch_mod2), inf), 
  \dur,     Pn(Pdefn(\bash_glitch_durs),  inf), 
  \stretch, Pn(Pdefn(\bash_glitch_strs),  inf), 
));
)
