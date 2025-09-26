(
// cc bind hub minimal v7  param plus func sink
// updated 2025-09-25 22:42 
// sets ~ccEmit and a small API  no right parens in comments

// registry
~ccBinds = ~ccBinds ? IdentityDictionary.new;

// mapper
~cc_mapVal = { |val01, spec| var lo, hi, curve, out;
    if(spec.isNil) { ^val01 };
    if(spec.isKindOf(Symbol)) {
        if(spec == \unipolar) { ^val01 };
        if(spec == \bipolar)  { ^val01.linlin(0,1, -1, 1) };
        ^val01;
    };
    if(spec.isArray and: { spec.size >= 2 }) {
        lo = spec[0].asFloat; hi = spec[1].asFloat;
        curve = (spec.size > 2).if({ spec[2] }, { \lin });
        out = (curve == \exp)
            .if({ val01.linexp(0,1, lo.max(0.0001), hi.max(0.0001)) },
                { val01.linlin(0,1, lo, hi) });
        ^out;
    };
    ^val01;
};

// api
~ccBindParam = { |key, target, param, spec| var list, entry;
    list = ~ccBinds[key]; if(list.isNil) { list = List.new; ~ccBinds[key] = list };
    entry = (type: \param, target: target, param: param, spec: spec);
    list.add(entry);
    ("[hub] bind " ++ key.asString ++ " -> " ++ target.asString ++ ":" ++ param.asString).postln;
};

~bind = { |key, func| var list, entry;
    list = ~ccBinds[key]; if(list.isNil) { list = List.new; ~ccBinds[key] = list };
    entry = (type: \func, func: func);
    list.add(entry);
    ("[hub] bind func " ++ key.asString).postln;
};

~ccUnbind = { |key, target=nil, param=nil| var list, keep;
    list = ~ccBinds[key];
    if(list.isNil) { ^false };
    if(target.isNil and: { param.isNil }) {
        ~ccBinds.removeAt(key);
        ^true;
    };
    keep = list.reject({ |e| (e[\type] == \param) and: { e[\target] == target and: { e[\param] == param } } });
    if(keep.size == 0) { ~ccBinds.removeAt(key) } { ~ccBinds[key] = keep };
    ^true;
};

~unbind = { |key| ~ccUnbind.(key) };

// alias
~ccb = { |key, target, param, spec| ~ccBindParam.(key, target, param, spec) };

// install sink
~ccEmit = { |key, val01| var list, y;
    list = ~ccBinds[key];
    if(list.notNil) {
        list.do { |e|
            if(e[\type] == \param) {
                y = ~cc_mapVal.(val01, e[\spec]);
                e[\target].set(e[\param], y);
            } {
                e[\func].(val01);
            };
        };
    };
};

"[hub] installed emit sink param plus func".postln;
)

