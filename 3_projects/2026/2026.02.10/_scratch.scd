
(
 Pdef(\neutron, Pbind(                                                   
      \instrument, \neutron,
      \out,        ~t6.inbus.index,                                       
      \scale,      Scale.minor,                             
      \octave,     Pseq([3, 4,  ], inf), 
      \degree,     Prand((0..7),  inf),
      \dur,        Pseq([1/4!2, 1/2].flat, inf), 
      \stretch,    Pseq([1!3, 2,  1/2].flat, inf), 
      \legato,     0.8,
      \amp,        0.7,

      // --- osc 1 ---
      \osc1Blend,  Pstep(Pseq([0,1],  inf), 4),          // 0=saw 1=pulse
      \osc1PW,     Pseg([0.1, 0.9,  0.1], [1, 2], \sin, inf), 
      \osc1Oct,    0,

      // --- osc 2 ---
      \osc2Blend,  0.5,        // 0=saw 0.5=pulse 1=tri
      \osc2PW,     0.5,
      \osc2Oct,    0,
      \osc2Semi,   0.0,
      \osc2Fine,   0.0,
      \osc2Track,  1,          // 0=free-running
      \sync,       0,

      // --- mixer ---
      \osc1Lvl,    0.7,
      \osc2Lvl,    0.7,
      \subLvl,     0.0,
      \noiseLvl,   0.0,

      // --- lfo ---
      \lfoRate,    0.5,
      \lfoShape,   1,          // 0=sin 1=tri 2=saw 3=ramp 4=square
      \lfoToOsc1,  0.0,
      \lfoToOsc2,  1.0,
      \lfoToPW1,   0.0,
      \lfoToPW2,   1.0,
      \lfoToFilt,  0.0,

      // --- filter ---
      \cutoff,     Pseg([500, 100,  2000],  [1, 4],  \sin, inf), 
      \res,        0.2,        // self-oscillates above ~0.88
      \filterMode, Pseq((0..2), inf),          // 0=LP 1=BP 2=HP
      \keyTrack,   0.0,
      \env1Amt,    -1.0,        // signed -1..1

      // --- env 1 (filter) ---
      \atk1,       0.01,
      \dcy1,       0.3,
      \sus1,       0.5,
      \rel1,       0.3,

      // --- env 2 (amp) ---
      \atk2,       0.01,
      \dcy2,       0.1,
      \sus2,       0.9,
      \rel2,       0.3,

      // --- drive ---
      \drive,      0.2,
      \driveTone,  1.0,
      \driveLevel, 0.5,

      // --- delay ---
      \delTime,    0.25,
      \delFB,      0.3,
      \delMix,     0.0,

      // --- cv / patch bay ---
      \cvOsc1,     0.0,
      \cvOsc2,     0.0,
      \cvFilt,     0.0,
      \cvPW1,      0.0,
      \cvPW2,      0.0,
      \cvAmp,      1.0,
  ));
)
  ~lpBind.([1,  6], \neutron,  60);
  ~apcAssignPad.(36,  \neutron,  \cyan);
