
// cc bind short alias  updated 2025-09-24 America Chicago
(
~ccb = { |key, target, param, spec| var f;
    f = ~ccBindParam;
    if(f.isNil) { f = ~cc_bind_register };
    if(f.isNil) { f = ~ccBind_register };
    if(f.isNil) {
        "[ccb] no cc bind hub function found".warn;
    }{
        f.(key, target, param, spec);
    };
};
"[ccb] ready. use ~ccb.(key, target, param, spec)".postln;

