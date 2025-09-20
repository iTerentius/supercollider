
// cc-bind bootstrap  2025-09-20 America/Chicago
(
var haveAdd, haveRm, table, addFn, rmFn;
haveAdd = currentEnvironment.at(\ccBindFuncAdd).notNil;
haveRm  = currentEnvironment.at(\ccBindFuncRm).notNil;
if(haveAdd.not or: haveRm.not, {
    table = IdentityDictionary.new;
    addFn = { |key, fn|
        var f;
        f = fn;
        table[key] = f;
        ("[cc-bind] add " ++ key).postln;
    };
    rmFn = { |key|
        var had;
        had = table.removeAt(key).notNil;
        ("[cc-bind] rm " ++ key ++ (had.if({""},{" (not found)"}))).postln;
    };
    currentEnvironment.put(\ccBindFuncAdd, addFn);
    currentEnvironment.put(\ccBindFuncRm,  rmFn);

    // optional: tiny tracer so you can see calls flowing through
    currentEnvironment.put(\ccBindTrace, { |key, val|
        var fn;
        fn = table[key];
        if(fn.notNil) { fn.value(val) } { ("[cc-bind] no fn for " ++ key).postln };
    });

    "[cc-bind] bootstrap registry installed".postln;
}) {
    "[cc-bind] registry already present".postln;
};
)
