// rearm_both_locked_uid.v2.scd  2025-09-26 18:46
// Re-arm both UID-locked routers and refresh their LEDs
(
~lcxlArmLocked !? { ~lcxlArmLocked.() };
~lcnArmLocked  !? { ~lcnArmLocked.() };
~lcxlParam !? { ~lcxlParam[\refreshLEDs].() };
~lcn      !? { ~lcn[\refreshLEDs].() };
"both routers re-armed and LEDs refreshed".postln;
)
