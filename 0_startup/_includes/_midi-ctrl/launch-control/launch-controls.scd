// "cc_bind_hub.scd".loadRelative;
// "midi_router_cleanup.scd".loadRelative;
// "lcn_param_router.locked.uid.v4.scd".loadRelative;
// "lcxl_param_router.locked.uid.v9.scd".loadRelative;
// "lcxl_pn_launcher_routerhook.v1.scd".loadRelative;

"apc_param_router.locked.uid.v2.scd".loadRelative;   // APC router
"apc_boot.scd".loadRelative;  // NEW grid include

// ~apcArmLocked.();       // arm APC router
// ~apcGridFixed = (uid: 762601288, dest: 4);  // replace with your numbers

// "rearm_all_locked_uid.v2.scd".loadRelative;
// "apc40_grid_rearm.locked.uid.scd".loadRelative;
// "lcxl_force_rearm.v1.scd".loadRelative;


// Pdef test
// ~lcxlBindPdef.(\b0_s0_p, \kick);

// simple sound if needed
// Pdef(\kick).play;
// Pdef(\kick).stop;
//
// MIDIClient.init;
// ~apcGridInit.(762601288, 4);
// ~apcSetPressMode.(\toggle);         // or \gate
// ~apcGL2AssignNote.(32, \kick);      // LED amber when stopped, green while playing
// ~apcAssignPad.(32, \kick);
//
// // optional CC binds
// ~apcBindCC.(7,  { |x| ("apc-fader 1: " ++ x).postln; });
// ~apcBindCC.(16, { |x| ("apc-knob 1: " ++ x).postln; });
// /* 2025-10-16 APC40 mkII LED core for grid pads — color via velocity, with Pdef follow */
// ~apcGL2AssignNote.(32, \kick);
// ~apcGridWatchStart.(0.2);
//
// ~apcDebug = true;
// MIDIdef.trace(true);
// ~apcRouterBoot.();            // it will pick ports, send Intro, arm, start watch
// ~apcArmGrid.();
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15));
// ~apcAssignPad.(32, \kick2);    // paints amber
// /* 2025-10-17 APC40 mkII — bulletproof handlers with fallback and loud debug */
// Pdef(\kick).play;
// Pdef(\kick).stop;
// /* 2025-10-17 APC40 mkII — ensure armed on assign + double-boot */
//
