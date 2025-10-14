"cc_bind_hub.scd".loadRelative;
"midi_router_cleanup.scd".loadRelative;
"lcn_param_router.locked.uid.v4.scd".loadRelative;
"lcxl_param_router.locked.uid.v9.scd".loadRelative;
// "lcxl_pn_launcher_routerhook.v1.scd".loadRelative;

// "apc_param_router.locked.uid.v2.scd".loadRelative;   // APC router
// "apc_grid_launcher.locked.uid.scd".loadRelative;  // NEW grid include

// ~apcArmLocked.();       // arm APC router
// ~apcGridFixed = (uid: 762601288, dest: 4);  // replace with your numbers

"rearm_all_locked_uid.v2.scd".loadRelative;
// "apc40_grid_rearm.locked.uid.scd".loadRelative;
"lcxl_force_rearm.v1.scd".loadRelative;

// Pdef test
// Pdef(\kick, Pbind(\instrument, \default, \dur, 0.25, \freq, 110));
// ~lcxlBindPdef.(\b0_s0_p, \kick);
//
// // Ndef test (simple drone)
// Ndef(\padbus, { SinOsc.ar(220) * EnvGen.kr(Env.asr, gate:1, doneAction:0) * -12.dbamp });
// ~lcxlBindNdef.(\b0_s1_n, \padbus);
//
// // press s1 -> Pdef plays green; press again -> amber
// // press s2 -> Ndef plays green; press again -> amber
//
// // bank switch (as before), then:
// ~lcxlPdefRefresh.(); // recompute p-row LEDs for current bank
