// "cc_bind_hub.scd".loadRelative;
// "midi_router_cleanup.scd".loadRelative;
// "lcn_param_router.locked.uid.v4.scd".loadRelative;
// "lcxl_param_router.locked.uid.v9.scd".loadRelative;
// "lcxl_pn_launcher_routerhook.v1.scd".loadRelative;

"apc_param_router.locked.uid.v2.scd".loadRelative;   // APC router
"apc_pad_grid_boot.scd".loadRelative;  // NEW grid inclu

/* 3 define Pdef and bind pad */
Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15));
~apcAssignPad.(32, \kick2);   // should be amber and stay amber
Pdef(\hat, Pbind(\instrument, \default, \degree, 12, \dur, 0.125, \amp, 0.15));
~apcAssignPad.(24, \hat);   // should be amber and stay amber

// temporary logger — press one scene button and note the number it prints
// MIDIdef.free(\apc_scene_dbg);
// MIDIdef.noteOn(\apc_scene_dbg, { |v,n,ch,src| ["[SCENE NOTE]", n, v, ch, src].postln; });
// ~apcAssignScene.(82, 0);   // scene button controls row 0
