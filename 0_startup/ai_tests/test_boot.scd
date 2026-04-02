s.waitForBoot {
    "Server booted successfully".postln;
    0.exit;
};
{ 10.wait; "Server boot timed out".postln; 0.exit; }.fork;
