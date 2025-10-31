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
// Pdef stays the same
//
//
//
////
//Pdef(\kick2, Pbind(\dur, 0.25, \degree, 0, \amp, 0.15));
//~apcAssignPad.(32, \kick2);                  // default kind is \p
//
//// Ndef path, typed bind
//Ndef(\droneA, { LFTri.ar(70).dup * 0.08 });
//~apcAssignPad.(24, \droneA, "n");            // Ndef type
//Ndef(\droneA).play;
//Ndef(\droneA).stop;
//
//(
///* 2025-10-31 10:47 — minimal Ndef toggler: uses isPlaying only */
//~dbgNdefToggle3 !? { ~dbgNdefToggle3 = nil };
//~dbgNdefToggle3 = { |key|
//    var k, p, was;
//    k = key.asSymbol;
//    p = Ndef(k);
//    was = p.isPlaying;
//    ["[DBG3 BEFORE]", k, \isPlaying, was].postln;
//    if(was) { p.pause } { p.play };
//    AppClock.sched(0.05, {
//        ["[DBG3 AFTER]", k, \isPlaying, p.isPlaying].postln; nil
//    });
//};
//
//)
//Ndef(\droneA, { LFTri.ar(70).dup * 0.08 });
//~dbgNdefToggle3.(\droneA);   // expect AFTER true and sound
//~dbgNdefToggle3.(\droneA);   // expect AFTER true but paused silence
//~dbgNdefToggle3.(\droneA);   // expect AFTER true resume and sound
//(
///* 2025-10-31 — free grid handlers only */
//[\apc40_grid_any_on, \apc40_grid_any_off].do { |nm| MIDIdef.free(nm) };
//~apcNoteOnFunc  !? { ~apcNoteOnFunc.free;  ~apcNoteOnFunc  = nil };
//~apcNoteOffFunc !? { ~apcNoteOffFunc.free; ~apcNoteOffFunc = nil };
//"[DBG3] grid handlers freed".postln;
//)
//
//(
///* 2025-10-31 — direct note→Ndef toggles for isolation */
//MIDIdef.free(\dbg3_n24_on); MIDIdef.free(\dbg3_n24_off);
//MIDIdef.free(\dbg3_n25_on); MIDIdef.free(\dbg3_n25_off);
//
//MIDIdef.noteOn(\dbg3_n24_on, { |vel, num, chan, src|
//    ["[DBG3 24 on]", \vel, vel, \chan, chan].postln;
//    if(vel > 0) { ~dbgNdefToggle3.(\droneA) };
//}, 24);
//
//MIDIdef.noteOff(\dbg3_n24_off, { |vel, num, chan, src|
//    ["[DBG3 24 off]", \vel, vel, \chan, chan].postln;
//}, 24);
//
//MIDIdef.noteOn(\dbg3_n25_on, { |vel, num, chan, src|
//    ["[DBG3 25 on]", \vel, vel, \chan, chan].postln;
//    if(vel > 0) { ~dbgNdefToggle3.(\droneA) };
//}, 25);
//
//MIDIdef.noteOff(\dbg3_n25_off, { |vel, num, chan, src|
//    ["[DBG3 25 off]", \vel, vel, \chan, chan].postln;
//}, 25);
//
//"[DBG3] direct 24 and 25 armed".postln;
//
//)
///* quick direct route test */
//Ndef(\droneA, { LFTri.ar(70).dup * 0.08 }).play(out: 0);  // try out 0/1 explicitly
//// stop afterwards
//Ndef(\droneA).stop;
//
///* if you use a mixer bus, make sure Ndef goes there */
//~m1 !? { Ndef(\droneA).play(out: ~m1.inbus) };  // adjust mixer var as in your setup
