// rearm_both_locked_uid.scd  2025-09-26 18:13
// Helper to re-arm both locked routers after startup with UID filters
(
~lcxlArmLocked !? { ~lcxlArmLocked.() };
~lcnArmLocked  !? { ~lcnArmLocked.() };
"both routers locked and armed via UID".postln;
)
