
(
~sBash = ~sTree[\bass_drums].values[1..6];
Pdef(\bash, ~pBuf.(
  Pbindef(\bash_pbd,  
  // \buf, Prand(~samps, inf),  
  \buf, Pseq(~sBash,  inf),     
  \bufnum,  Pkey(\buf), 
  \scale, Scale.minor,  
  // \delta,  Pkey(\dur)*2/Pxrand([4,  3,  2], inf), 
  \octave,  Pseq([4,  5], inf),   
  \degree,  Pseq([0,  1,  \,  3, \,  0], inf), 
  // \dur, Pbjorklund(5,  8,  inf)/2,  
  \dur, Pseq([1/4!2, 1/2].flat, inf),    
  \amp, 0.7,  
  \out,  ~pbd1.inbus.index, 
  )
));
~lpBind.([1,  1], \bash,  10);
~apcAssignPad.(32,  \bash);
~lpBind.([8, 1], { ~bash_t.free; ~bash_t = ~ensurePostSend.(~pbd1, ~r4,  1); });   // evaluated on press
~lpBind.([8, 2], { ~bash_t.tryPerform(\free); });   // evaluated on press

//--------------------------------------------------
~sBashat = ~sTree[\hats].values[3..7];
// ~samps = ~sTree[\snare_roll].values[0..8];
Pdef(\bashat, 
  ~pBuf.(
    Pbindef(\bashat_pbd,  
    // \buf, Prand(~samps, inf),  
    \buf, Pstep(Pseq(~sBashat,  inf), 2),     
    // \buf,  ~samps,  
    \bufnum,  Pkey(\buf), 
    // \delta,  Pkey(\dur)*2/Pxrand([  8,  4,  2], inf), 
    \dur, Pseq([1/2,  1/4!2,  1].flat,  inf), 
    \octave, Pseq([3, 5], inf),  
    \degree,  Place([0,  Pxrand([1,  2,  4],  inf)],  inf),  
    // \dur, Pbjorklund(5,  8,  inf),  
    \amp, Pwhite(0.75,  0.5,  inf),  
    \out,  ~phh1.inbus.index, 
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
      \instrument,  \slice_m, 
    // \buf, ~sRoll,  
    \buf, Pseq(~sRoll,  inf),     
    // \buf,  ~samps,  
    \bufnum,  Pkey(\buf), 
    // \delta,  Pkey(\dur)*2/Pxrand([  8,  4,  2], inf), 
    // \dur, Pseq([1/3,  1/6!2,  Pn(Rest(),  1)].flat,  inf), 
    \rate, Pseq([1,  1.neg], inf), 
    \sliceDur,  Pseq([1/4, 1/8!2,  1.5].flat, inf),  
    \spread,  1,  
    \octave, Pseq([1, 3,  7], inf),  
    \degree,  Prand([0, 2,  4],  inf),  
    \sliceIndex,  Pwhite(0, 8,  inf), 
    \dur, Pbjorklund2(3,  8,  inf)/2,  
    \amp, Pwhite(0.75,  0.4,  inf)*2,  
    \out,  ~psd1.inbus.index, 
  );
);
~lpBind.([1,  3], \roll,  30);
)
