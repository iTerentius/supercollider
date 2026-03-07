(
// apcDG force wrapper  // 2025-10-23 15:48 America/Chicago
var parseKey2, validKey, old;

parseKey2 = { |key|
    var s, b, g, d;
    s = key.asString;
    b = s.findRegexp("b(\\d+)").tryPerform(\at, 1).tryPerform(\asInteger);
    g = s.findRegexp("g(\\d+)").tryPerform(\at, 1).tryPerform(\asInteger);
    d = s.findRegexp("d(\\d+)").tryPerform(\at, 1).tryPerform(\asInteger);
    if(b.isNil or: { g.isNil } or: { d.isNil }) { nil } { (bank: b, group: g, device: d) }
};

validKey = { |p|
    var conds;
    conds = [
        p[\bank].isInteger, p[\group].isInteger, p[\device].isInteger,
        p[\bank] >= 0, p[\bank] < 8, p[\group] >= 1, p[\group] <= 8,
        p[\device] >= 1, p[\device] <= 8
    ];
    conds.every { |c| c == true }
};

old = ~apcBindParam;
~apcBindParam_orig = old;

~apcBindParam = { |key, func|
    var p, tag, ok, res, handled;
    p = parseKey2.(key);
    handled = false;
    if(p.notNil) {
        ok = validKey.(p);
        if(ok) {
            tag = "\\b%_g%_d%".format(p[\bank], p[\group], p[\device]).asSymbol;
            ~apcDG[\funcs][tag] = func;
            if(~apcDG[\debug]) { ["[apcDG bind]", tag].postln };
            handled = true;
        }{
            res = old.(key, func);
            handled = res.notNil;
        };
    }{
        res = old.(key, func);
        handled = res.notNil;
    };
    handled
};

"[apcDG WRAP installed]".postln;
)

