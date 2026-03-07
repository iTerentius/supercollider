// rearm_both_locked_uid.v2.scd  2025-09-26 18:46
// Re-arm both UID-locked routers and refresh their LEDs
// (
// ~lcxlArmLocked !? { ~lcxlArmLocked.() };
// ~lcnArmLocked  !? { ~lcnArmLocked.() };
// ~lcxlParam !? { ~lcxlParam[\refreshLEDs].() };
// ~lcn      !? { ~lcn[\refreshLEDs].() };
// ~apcEnsureMaps !? { ~apcEnsureMaps.() };
// ~apcArmLocked   !? { ~apcArmLocked.() };
// ~apcRefresh     !? { ~apcRefresh.() };
// "All midi routers re-armed and LEDs refreshed".postln;
// )
// rearm_both_locked_uid.v2.scd  2025-10-09 America Chicago
// Re-arm UID-locked routers for LCXL, LCN, and APC with per-section guards  no right parens in comments

// rearm_both_locked_uid.v2.scd  2025-10-09 America Chicago
// Re-arm both Launch Controls and APC with their own LED refresh  no right parens in comments

(
~lcxlArmLocked !? { ~lcxlArmLocked.() };
~lcnArmLocked  !? { ~lcnArmLocked.() };
~lcxlParam !? { ~lcxlParam[\refreshLEDs].() };
~lcn      !? { ~lcn[\refreshLEDs].() };

// APC last so a failure here cannot block LCXL or LCN logs you expect
~apcEnsureMaps !? { ~apcEnsureMaps.() };
~apcArmLocked   !? { ~apcArmLocked.() };
~apcRefresh     !? { ~apcRefresh.() };

"All midi routers re-armed and LEDs refreshed".postln;
)

// // apc_line_tap.scd  2025-10-09 America Chicago
// (
// var ep, srcUID, haveAPC, chTap;
//
// MIDIdef.free(\apc_tap_cc);
// MIDIdef.free(\apc_tap_on);
//
// ep = MIDIClient.sources.detect { |e|
// 	var both;
// 	both = (e.device.asString ++ " " ++ e.name.asString).toLower;
// 	both.contains("apc40") // broad match to be safe
// };
//
// srcUID = ep !? { ep.uid };
// haveAPC = srcUID.notNil;
//
// "[tap] apc src uid %  haveAPC %".format(srcUID, haveAPC).postln;
//
// // CC tap
// MIDIdef.cc(\apc_tap_cc, { |val, cc, chan, src|
// 	["[tap apc cc]", "src", src, "ch", chan, "cc", cc, "val", val].postln;
// }, nil, nil, haveAPC.if({ srcUID }, { nil })); // if no APC found, tap all
//
// // Note tap
// MIDIdef.noteOn(\apc_tap_on, { |vel, num, chan, src|
// 	["[tap apc note]", "src", src, "ch", chan, "num", num, "vel", vel].postln;
// }, nil, nil, haveAPC.if({ srcUID }, { nil }));
//
// "[tap] armed  move APC faders and press a few buttons".postln;
// )
