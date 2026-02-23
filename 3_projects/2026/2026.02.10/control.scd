"start.scd".loadRelative;
// Instruments
Pdef(\bash).play;
Pdef(\bash).stop;

~setR1.set(\room, 1.8,  \damp,  0.5,  \mix, 1.5);
~setR2.set(\maxdt,  0.7,  \dt, 1.1,  \dec, 1.1);
~bash_rev = ~ensurePostSend.(~pbd1, ~r1, 0.7);
~bash_rev.tryPerform(\free);
~bash_rev.level_(1);
~bash_del = ~ensurePostSend.(~pbd1, ~r2,  1);
~bash_del.tryPerform(\free);

~bash_gin = ~ensurePostSend.(~pbd1, ~r3,  0.5);
~bash_gin.tryPerform(\free);
~bash_gin.level_(0.1);
~bash_t = ~ensurePostSend.(~pbd1, ~r4,  1);
~bash_t.tryPerform(\free);

~bash_t.tryPerform(\free);
~bash_t.level_(0.7);

Pdef(\bashat).play;
Pdef(\bashat).stop;

~bhat_del = ~ensurePostSend.(~phh1,  ~r2,  1);
~bhat_gin = ~ensurePostSend.(~phh1,  ~r4,  1);
~bhat_gin.tryPerform(\free);

~lumi_t = ~ensurePostSend.(~t3,  ~r4,  1);
~lumiStop.();

Pdef(\roll).play;
Pdef(\roll).stop;

~roll_fx1.free;
~roll_fx1 = ~psd1.playfx(~exp1);

Pdef(\roll_fx_ctl).play;
~roll_rev = ~ensurePostSend.(~psd1, ~r1,  0.8);
~roll_rev.tryPerform(\free);
~roll_del = ~ensurePostSend.(~psd1, ~r2,  0.8);
~roll_del.tryPerform(\free);
~roll_glitch = ~ensurePostSend.(~psd1,  ~r4,  1);
~roll_glitch.tryPerform(\free);

// FX
~r3_fx.free;
~r3.level_(1);

(
~r4_fx.free;
~r4_fx = ~r4.playfx(~glitch);
)
~r4_fx_rev = ~r4.newPostSend(~r1,  1);
~r4_fx_rev.tryPerform(\free);

Pdef(\ms20).play;
Pdef(\ms20).stop;

~ms20_rev = ~ensurePostSend.(~t2,  ~r1,  1);
~ms20_rev.tryPerform(\free);
~ms20_del = ~ensurePostSend.(~t2,  ~r2,  1);
~ms20_del.tryPerform(\free);
~ms20_t = ~ensurePostSend.(~t2, ~r4,  1);
~ms20_t.tryPerform(\free);

(
 Pdef(\neutron, Pbind(                                                   
      \instrument, \neutron,
      \out,        ~t6.inbus.index,                                       
      \scale,      Scale.minor,                             
      \degree,     0,
      \dur,        1,
      \legato,     0.8,
      \amp,        0.7,

      // --- osc 1 ---
      \osc1Blend,  0.0,        // 0=saw 1=pulse
      \osc1PW,     0.5,
      \osc1Oct,    0,

      // --- osc 2 ---
      \osc2Blend,  0.0,        // 0=saw 0.5=pulse 1=tri
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
      \lfoRate,    1.0,
      \lfoShape,   0,          // 0=sin 1=tri 2=saw 3=ramp 4=square
      \lfoToOsc1,  0.0,
      \lfoToOsc2,  0.0,
      \lfoToPW1,   0.0,
      \lfoToPW2,   0.0,
      \lfoToFilt,  0.0,

      // --- filter ---
      \cutoff,     2000,
      \res,        0.2,        // self-oscillates above ~0.88
      \filterMode, 0,          // 0=LP 1=BP 2=HP
      \keyTrack,   0.0,
      \env1Amt,    0.5,        // signed -1..1

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
      \drive,      0.0,
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
Pdef(\neutron).play;
Pdef(\neutron).stop;

(
  // Self-oscillation demo (no input needed):
  ~syn = Synth(\neutron, [
      \res, 0.98, \cutoff, 400,
      \osc1Lvl, 0, \osc2Lvl, 0, \subLvl, 0, \noiseLvl, 0.02,
      \env1Amt, 0, \atk2, 0, \sus2, 1, \rel2, 0.5,  
      \out, ~t6.inbus.index,  
  ]);
)
  ~syn.set(\cutoff, 800);   // pitch the resonant tone
  
