"apc_boot_all.scd".loadRelative;  // NEW grid inclu
"apc_device_knobs.scd".loadRelative;  // NEW grid inclu

// // map a couple pads to patterns
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15, \out, ~t1.inbus.index));
// Pdef(\hat2,  Pbind(\instrument, \default, \degree, 7, \dur, 0.125, \amp, 0.12, \out, ~t2.inbus.index));
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
// ~apcBindParam.(\b0_d1, { |x| ("b0_d1:" ++ x).postln});            // User row: your custom
// ~apcBindParam.(\b1_d2, { |x| ("b1_d2:" ++ x).postln});            // User row: your custom
