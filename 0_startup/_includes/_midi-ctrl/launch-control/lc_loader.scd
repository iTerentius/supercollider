
"cc_bind_hub.scd".loadRelative;
"midi_router_cleanup.scd".loadRelative;
"lcn_param_router.locked.uid.v4.scd".loadRelative;
"lcxl_param_router.locked.uid.v9.scd".loadRelative;
"lcxl_pn_launcher_routerhook.v1.scd".loadRelative;
"rearm_all_locked_uid.v2.scd".loadRelative;
"lcxl_force_rearm.v1.scd".loadRelative;


// // map a couple pads to patterns
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15, \out, ~t1.inbus.index));
// Pdef(\hat2,  Pbind(\instrument, \default, \degree, 7, \dur, 0.125, \amp, 0.12, \out, ~t2.inbus.index));
// ~lcnBindParam.(\b0_r1, {|x| ~t1.level_(x)});
// ~lcnBindParam.(\b0_r2, {|x| ~t1.pan_(x.linlin(0, 1, -1, 1))});
// ~lcnBindParam.(\b0_s1_r2, {|x| ("lcn \b0_s1_r2: ".postln)});
//
// ~lcxlBindParam.(\b0_s1_f, {|x| ~t1.level_(x)});
// ~lcxlBindParam.(\b0_s1_r3, {|x| ~t1.pan_(x.linlin(0, 1, -1, 1))});
// ~lcxlBindPdef.(\b0_s1_p, {|x| ("\b0_s1_p: " ++ x).postln;});
//
