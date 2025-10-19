// "cc_bind_hub.scd".loadRelative;
// "midi_router_cleanup.scd".loadRelative;
// "lcn_param_router.locked.uid.v4.scd".loadRelative;
// "lcxl_param_router.locked.uid.v9.scd".loadRelative;
// "lcxl_pn_launcher_routerhook.v1.scd".loadRelative;

// "apc_param_router.locked.uid.v2.scd".loadRelative;   // APC router
"apc_boot_all.scd".loadRelative;  // NEW grid inclu

// /* 3 define Pdef and bind pad */
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15));
// ~apcAssignPad.(32, \kick2);   // should be amber and stay amber
// Pdef(\hat, Pbind(\instrument, \default, \degree, 12, \dur, 0.125, \amp, 0.15));
// ~apcAssignPad.(24, \hat);   // should be amber and stay amber
//
// // temporary logger — press one scene button and note the number it prints
// // MIDIdef.free(\apc_scene_dbg);
// // MIDIdef.noteOn(\apc_scene_dbg, { |v,n,ch,src| ["[SCENE NOTE]", n, v, ch, src].postln; });
// // ~apcAssignScene.(82, 0);   // scene button controls row 0
// ~apcParamInstall.();
// map a couple pads to patterns
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15, \out, ~t1.inbus.index));
// Pdef(\hat2,  Pbind(\instrument, \default, \degree, 7, \dur, 0.25, \amp, 0.12, \out, ~t2.inbus.index));
// ~apcAssignPad.(32, \kick2);
// ~apcAssignPad.(33, \hat2);
//
// // bind faders
// ~apcBindParam.(\b0_s1_f, { |x| ~t1.level_(x) });
// ~apcBindParam.(\b0_s2_f, { |x| ~t2.level_(x) });
// ~apcBindParam.(\master_f, { |x| ~m1.level_(x) });
// /* 2025-10-19 — examples */
// /* volume faders already use \bN_sM_f and \master_f from earlier */
//
// ~apcBindParam.(\b0_s1_r1, { |x| ~t1.pan_(x.linlin(0,1,-1,1)) });     // Pan row: strip 1 pan
// ~apcBindParam.(\b1_s1_r2, { |x| ("b1_s1_r2:" ++ x).postln});                  // Sends row: send A
// ~apcBindParam.(\b0_s1_r3, { |x| ("b0_s1_r3:" ++ x).postln});            // User row: your custom
//
// ~apcBindParam.(\master_f, { |x| ~master.level_(x) });                 // Master fader
//
// ~apcForceAPCOut.();
// ~apcIntroGenericMode.();
// ~apcBindParam.(\b0_g1_d1, { |x| ("b0_g1_d1:" ++ x).postln});            // User row: your custom
// ~apcBindParam.(\b1_g1_d1, { |x| ("b1_g1_d1:" ++ x).postln});            // User row: your custom
