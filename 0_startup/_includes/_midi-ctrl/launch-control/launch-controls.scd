"cc_bind_hub.scd".loadRelative;
"midi_router_cleanup.scd".loadRelative;
"lcn_param_router.locked.uid.v4.scd".loadRelative;
"lcxl_param_router.locked.uid.v9.scd".loadRelative;

// "apc_param_router.locked.uid.v2.scd".loadRelative;   // APC router
// "apc_grid_launcher.locked.uid.scd".loadRelative;  // NEW grid include

// ~apcArmLocked.();       // arm APC router
// ~apcGridFixed = (uid: 762601288, dest: 4);  // replace with your numbers

"rearm_all_locked_uid.v2.scd".loadRelative;
// "apc40_grid_rearm.locked.uid.scd".loadRelative;
"lcxl_force_rearm.v1.scd".loadRelative;

// ~apcGridArmRaw.();
// ~apcGridRefresh.();

// ~apcGL2AssignNote.(32, \bd1);
// ~apcGLInit.();

// ~apcUnbindParam.(\b0_r1_s1);
//
// ~apcBindParam.(\b0_s1_r1, { |v| ["[emit]", \b0_s1_r1, v].postln });
// ~apcBindParam.(\b0_s2_r1, { |v| ["[emit]", \b0_s2_r1, v].postln });
// ~apcBindParam.(\b0_s1_f, { |v| ["[emit]", \b0_s1_f, v].postln });
// ~apcBindParam.(\apc_b0_s1_f, { |v| ["[emit]", \apc_b0_s1_f, v].postln });
// ~apcListSrc.();  // look for the line with APC40 mkII and note its uid and the dest index from your Dests print
// // example with your earlier printouts
// ~apcInit.(762601288, 4);   // srcUID, destIdx  use your actual numbers
// Pdef(\kick, Pbind(\instrument, \default, \dur, 0.25, \freq, 110));
//
// // either by coordinates  top row col 0 is note 32
// ~apcAssignRC.(0, 0, \kick);
//
// // or by exact note
// ~apcAssignNote.(32, \kick);
