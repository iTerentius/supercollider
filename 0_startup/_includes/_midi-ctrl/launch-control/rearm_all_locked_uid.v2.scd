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
~lcxlPdefArm.();        // re-arm our dedicated listener
~lcxlPdefRefresh.();    // repaint the p-row for the current bank
~lcn      !? { ~lcn[\refreshLEDs].() };


// APC last so a failure here cannot block LCXL or LCN logs you expect
~apcEnsureMaps !? { ~apcEnsureMaps.() };
~apcArmLocked   !? { ~apcArmLocked.() };
~apcRefresh     !? { ~apcRefresh.() };

"All midi routers re-armed and LEDs refreshed".postln;

)
