// 2025-09-19 16:10 America-Chicago  lcxl → mixer core bridge v5
// change  ~installCCByNameRouter now ENSURES and RETURNS ~ccRouter dict with \ccMap, for compatibility with ~ccLoad
(
var spFor, ensureTargets, defaultSpec;

// fallback logger
if(~pp.isNil) { ~pp = { |label, data| label.post; " ".post; data.postln; nil } };

// ensure target table
ensureTargets = { if(~ccTargets.isNil) { ~ccTargets = IdentityDictionary.new } };
ensureTargets.();

// default spec helper
defaultSpec = { |spec|
    var sp;
    sp = spec;
    sp = sp.isNil.if({ ~ccDefaultSpec }, { sp });
    sp = sp ? ControlSpec(0,1, \lin);
    sp
};

// choose ControlSpec per control
spFor = { |control|
    var c;
    c = control.asSymbol;
    if(c == \pan) { ControlSpec(-1, 1, \lin, 0, 0) } { defaultSpec.(nil) }
};

if(~ccBindFunc.isNil) {
    ~ccBindFunc = { |name, func, spec=nil|
        var nm, sp;
        nm = name.asSymbol;
        sp = defaultSpec.(spec);
        ensureTargets.();
        ~ccTargets.put(nm, (func: func, spec: sp));
        ~pp.("ccBindFunc+", nm);
        nil
    };
};

if(~ccBindMix.isNil) {
    ~ccBindMix = { |name, chan, control=\level, spec=nil|
        var sp, ctl, ch;
        sp  = spec.isNil.if({ spFor.(control) }, { spec });
        ctl = control.asSymbol;
        ch  = chan;
        ~ccBindFunc.(name, { |val|
            switch(ctl,
                \level, { ch.tryPerform(\level_, val) },
                \pan,   { ch.tryPerform(\pan_,   val) }
            );
        }, sp);
    };
};

// return a real router dict so legacy code doing r = ~ccRouter ?? { ~install...() } works
~installCCByNameRouter = { |srcUid=nil|
    var uid, conf, revTbl;

    // ensure global router objects exist
    ~ccRouter = ~ccRouter ? IdentityDictionary.new;
    if(~ccRouter[\ccMap].isNil) { ~ccRouter[\ccMap] = IdentityDictionary.new };

    ~lcxlCC  = ~lcxlCC  ? IdentityDictionary.new;
    revTbl   = ~lcxlCC[\rev] ? IdentityDictionary.new;
    ~lcxlCC.put(\rev, revTbl);

    // optional UID filter
    conf = ~lcxlCC;
    uid  = srcUid;
    if(uid.isNil and: { conf.notNil }) { uid = conf.tryPerform(\at, \srcUid) };

    MIDIdef.free(\lcxl_cc_byname_router);
    MIDIdef.cc(\lcxl_cc_byname_router, { |val, num, chan, src|
        var k, name, tgt, spec, outVal;
        if(uid.notNil and: { src.asInteger != uid }) { ^nil };
        k    = chan.asInteger * 128 + num.asInteger;
        name = (~lcxlCC[\rev]).tryPerform(\at, k);
        if(name.isNil) { ^nil };
        tgt  = ~ccTargets.tryPerform(\at, name); if(tgt.isNil) { ^nil };
        spec = tgt[\spec] ? ControlSpec(0,1, \lin);
        outVal = spec.map(val / 127.0);
        if(tgt[\func].notNil) { tgt[\func].value(outVal) } {
            if(tgt[\ndef].notNil and: { tgt[\param].notNil }) { Ndef(tgt[\ndef]).set(tgt[\param], outVal) };
        };
    }, nil, nil, nil);

    "[ ccRouter installed ]".postln;

    // return the router dict so callers can do r[\ccMap] etc
    ~ccRouter
};

"[ lcxl→mixer core ready v5 ]".postln;
)

