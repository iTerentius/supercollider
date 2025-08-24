// reset for mix/mute after adding new synthdefs
~fxonlyResetAll.();
// control mute  on off per orbit
~fxonlyOff.(0);   // dry ON
~fxonlyOn.(1);    // FX-only (dry muted)
~fxonlyOff.(1); 

// fade mute 
~fxonlySetFade.(0.25, 0.25);  // set fade times (s)
~fxonlyOn.(0);                 // fade to FX-only on orbit 0
~fxonlyOff.(0);                // fade back to dry
~fxonlySet.(0, 0.5);           // 50% dry (true mix)

// use in tidal
// once $ s "ctrl_gate" # oid 0 # omute 1     -- FX-only
// once $ s "ctrl_gate" # oid 0 # omute 0     -- dry
// once $ s "ctrl_gate" # oid 0 # omute 0.4   -- 60% dry (fades if set)
~startDeviceLearn.();
~startLearn.();
~finishLearn.();

~lcxl[\ledOff] = 1;
~refreshLeds.();

~onVel = 15; ~refreshLeds.();

~testLeds.();

~recStart.();
~recStop.();
