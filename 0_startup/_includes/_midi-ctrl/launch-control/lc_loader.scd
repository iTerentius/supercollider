
// "cc_bind_hub.scd".loadRelative;
// "midi_router_cleanup.scd".loadRelative;
// "lcn_param_router.locked.uid.v4.scd".loadRelative;
// "lcxl_param_router.locked.uid.v9.scd".loadRelative;
// "rearm_all_locked_uid.v2.scd".loadRelative;
// "lcxl_force_rearm.v1.scd".loadRelative;
"lc-lcxl-router-revamp.scd".loadRelative;
// "lcxl-banked-param-router.scd".loadRelative;


// // map a couple pads to patterns
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15, \out, ~t1.inbus.index));
// Pdef(\hat2,  Pbind(\instrument, \default, \degree, 7, \dur, 0.125, \amp, 0.12, \out, ~t2.inbus.index));
//
// ~lcn[\b1_s1_r2] = { |val| ("LC strip 1, row2: %\n".format(val)).post };
// ~lcxlParam[\b3_s5_r3] = { |val| ("LCXL b3s5r3: %\n".format(val)).post };
// ~lcxlParam[\b1_s1_f] = { |val| ("LCXL b1_s1_f: %\n".format(val)).post };
// ~lcxlBindPdef.(\b1_s3_p, \kick2);  // maps bank 0, button 3 to Pdef(\drums)
// (
// MIDIFunc.cc({ |val, num, chan, src|
//     ["CHECKING", "CC Num (num):", num, "Midi Channel (chan):", chan].postln;
// });
// MIDIFunc.noteOn({ |val, num, chan, src|
//     ["CHECKING", "noteOn Num (num):", num, "Midi Channel (chan):", chan].postln;
// });
// )

