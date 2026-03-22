// score_debug.scd — run each step independently to find where score.scd fails.
// Eval this whole file (Cmd+A, Cmd+Enter), or line-by-line.
// Each step prints OK or FAIL with the error message.
(
var step = { |n, path|
    try {
        path.loadRelative;
        ("Step " ++ n ++ " OK: " ++ path).postln;
    } { |err|
        ("STEP " ++ n ++ " FAILED: " ++ path).postln;
        err.messageString.postln;
        err.errorString.postln;
    };
};

step.(1,  "lib/samples.scd");
step.(2,  "lib/config.scd");
step.(3,  "lib/fx.scd");
step.(4,  "parts/thingA.scd");
step.(5,  "parts/bd1.scd");
step.(6,  "parts/sd1.scd");
step.(7,  "parts/hh1.scd");
step.(8,  "parts/roll.scd");
step.(9,  "parts/ms20.scd");
step.(10, "parts/neutron.scd");
step.(11, "parts/model_d.scd");
step.(12, "automation/biscuit.scd");
step.(13, "lib/bindings.scd");
step.(14, "arrangement.scd");
)
