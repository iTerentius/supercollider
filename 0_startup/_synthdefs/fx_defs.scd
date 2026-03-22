(
~fxDefs    = ();
~fxSetup   = ();
~fxTeardown = ();
~lcn = ~lcn ?? { () };  // LC binding dict — init if not already set by a controller

~fxDefs[\combDelay] = { |in, bus|
    var sig = In.ar(bus, 2);
    var wet = CombL.ar(sig,
        maxdelaytime: \maxdt.kr(0.4),
        delaytime:    \dt.kr(0.25),
        decaytime:    \dec.kr(0.6)
    );
    XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

~fxDefs[\freeVerb] = { |in, bus|
    var sig = In.ar(bus, 2);
    var wet = FreeVerb2.ar(sig[0], sig[1],
        mix:  1.0,
        room: \room.kr(0.5),
        damp: \damp.kr(0.5)
    );
    XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

~fxDefs[\greyhole] = { |in, bus|
    var sig = In.ar(bus, 2);
    var wet = Greyhole.ar(sig,
        \delayTime.kr(2.0),
        \damp.kr(0.0),
        \size.kr(3.0),
        \diff.kr(0.707),
        \feedback.kr(0.1),
        \modDepth.kr(0.1),
        \modFreq.kr(2.0)
    );
    XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// Stereo chorus: LFO-modulated short delay, offset 90deg per channel for width
~fxDefs[\chorus] = { |in, bus|
    var sig  = In.ar(bus, 2);
    var lfo  = SinOsc.kr(\rate.kr(0.4), [0, 0.5pi]) * \depth.kr(0.004) + 0.005;
    var wet  = DelayC.ar(sig, 0.05, lfo);
    XFade2.ar(sig, wet, \mix.kr(0.5).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// ---- r1: greyhole (default) / freeVerb (swap) ----
// TOSC layout: r1=delayTime, r2=feedback, xy1(x=size, y=damp), f=modDepth
// diff and modFreq: LC/APC only (TOSC has no remaining controls)
~fxSetup[\r1_greyhole] = { |page=nil, slot=nil|
    ~r1fx[\greyhole].tryPerform(\free);
    ~r1fx[\greyhole] = nil; ~r1fx[\setGreyhole] = nil;
    ~r1fx[\greyhole] = ~r1.playfx({ |in| ~fxDefs[\greyhole].(in, ~r1.inbus.index) });

    ~r1fx[\setGreyhole] = { |delayTime, damp, size, diff, feedback, modDepth, modFreq|
        delayTime.notNil.if { ~r1fx[\greyhole].set(\delayTime, delayTime) };
        damp.notNil.if      { ~r1fx[\greyhole].set(\damp,      damp) };
        size.notNil.if      { ~r1fx[\greyhole].set(\size,      size) };
        diff.notNil.if      { ~r1fx[\greyhole].set(\diff,      diff) };
        feedback.notNil.if  { ~r1fx[\greyhole].set(\feedback,  feedback) };
        modDepth.notNil.if  { ~r1fx[\greyhole].set(\modDepth,  modDepth) };
        modFreq.notNil.if   { ~r1fx[\greyhole].set(\modFreq,   modFreq) };
    };

    ~lcn[\b1_s1_r1] = { |x| ~r1fx[\greyhole].set(\delayTime, x.linexp(0, 127, 0.1,  5.0)) };
    ~lcn[\b1_s2_r1] = { |x| ~r1fx[\greyhole].set(\damp,      x.linlin(0, 127, 0.0,   1.0)) };
    ~lcn[\b1_s3_r1] = { |x| ~r1fx[\greyhole].set(\size,      x.linlin(0, 127, 0.1,  5.0)) };
    ~lcn[\b1_s4_r1] = { |x| ~r1fx[\greyhole].set(\diff,      x.linlin(0, 127, 0.1,  0.99)) };
    ~lcn[\b1_s5_r1] = { |x| ~r1fx[\greyhole].set(\feedback,  x.linlin(0, 127, 0.1,  0.95)) };
    ~lcn[\b1_s1_r2] = { |x| ~r1fx[\greyhole].set(\modDepth,  x.linlin(0, 127, 0.0,   1.0)) };
    ~lcn[\b1_s2_r2] = { |x| ~r1fx[\greyhole].set(\modFreq,   x.linexp(0, 127, 0.5, 100.0)) };

    // APC40 device knobs — main bank 1, sub-bank 1 (b0_ds1_k1..8), x = 0-1
    ~apcBindParam.(\b0_ds1_k1, { |x| ~r1fx[\greyhole].set(\delayTime, x.linexp(0.001, 1, 0.1,  5.0)) });
    ~apcBindParam.(\b0_ds1_k2, { |x| ~r1fx[\greyhole].set(\damp,      x.linlin(0, 1, 0.0,   1.0)) });
    ~apcBindParam.(\b0_ds1_k3, { |x| ~r1fx[\greyhole].set(\size,      x.linlin(0, 1, 0.1,   5.0)) });
    ~apcBindParam.(\b0_ds1_k4, { |x| ~r1fx[\greyhole].set(\diff,      x.linlin(0, 1, 0.01,  0.99)) });
    ~apcBindParam.(\b0_ds1_k5, { |x| ~r1fx[\greyhole].set(\feedback,  x.linlin(0, 1, 0.01,  0.95)) });
    ~apcBindParam.(\b0_ds1_k6, { |x| ~r1fx[\greyhole].set(\modDepth,  x.linlin(0, 1, 0.0,   1.0)) });
    ~apcBindParam.(\b0_ds1_k7, { |x| ~r1fx[\greyhole].set(\modFreq,   x.linexp(0.001, 1, 0.5, 100.0)) });
    ~apcBindParam.(\b0_ds1_k8, { |x| ~r1fx[\greyhole].set(\mix,       x.linlin(0, 1, 0.0,   1.0)) });

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "greyhole");
        ~toscFXBind.(page, slot, \r1, { |v| ~r1fx[\greyhole].set(\delayTime, v.linexp(0, 1, 0.1, 5.0)) },  "time");
        ~toscFXBind.(page, slot, \r2, { |v| ~r1fx[\greyhole].set(\feedback,  v.linlin(0, 1, 0.1, 0.95)) }, "fdbk");
        ~toscFXBind.(page, slot, \r3, { |v| ~r1fx[\greyhole].set(\diff,  v.linlin(0, 1, 0.1, 0.99)) }, "diff");
        ~toscFXBindXY.(page, slot, 1,
            { |v| ~r1fx[\greyhole].set(\size, v.linlin(0, 1, 0.1, 5.0)) },
            { |v| ~r1fx[\greyhole].set(\damp, v.linlin(0, 1, 0.0, 1.0)) },
            "sz|dmp"
        );
        ~toscFXBindXY.(page, slot, 2,
            { |v| ~r1fx[\greyhole].set(\modDepth, v.linlin(0, 1, 0.01, 1.0)) },
            { |v| ~r1fx[\greyhole].set(\modFreq, v.linexp(0, 1, 0.5, 100.0)) },
            "modDepth|modFreq"
        );
        ~toscFXBind.(page, slot, \f, { |v| ~r1fx[\greyhole].set(\mix, v) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 2.0.explin(0.1, 5.0, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.1.linlin(0.1, 0.95, 0, 1));
        ~toscFXSync.(page, slot, \r3, 0.707.linlin(0.1, 0.99, 0, 1));
        ~toscFXSyncXY.(page, slot, 1, 3.0.linlin(0.1, 5.0, 0, 1), 0.0);
        ~toscFXSyncXY.(page, slot, 2, 0.1.linlin(0.01, 1.0, 0, 1), 2.0.explin(0.5, 100.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\r1_greyhole] = { |page=nil, slot=nil|
    ~r1fx[\greyhole].free;
    ~r1fx[\greyhole]    = nil;
    ~r1fx[\setGreyhole] = nil;
    [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1, \b1_s4_r1, \b1_s5_r1, \b1_s1_r2].do { |k| ~lcn[k] = nil };
    if(~apcParamBindings.notNil) {
        [\b0_ds1_k1, \b0_ds1_k2, \b0_ds1_k3, \b0_ds1_k4,
         \b0_ds1_k5, \b0_ds1_k6, \b0_ds1_k7, \b0_ds1_k8].do { |k| ~apcParamBindings[k] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \r3, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
        ~oscParam[(base ++ "/xy1/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy1/y").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy3/y").asSymbol] = nil;
    };
};

// TOSC layout: r1=mix, r2=room, f=damp
~fxSetup[\r1_freeVerb] = { |page=nil, slot=nil|
    ~r1fx[\freeVerb].tryPerform(\free);
    ~r1fx[\freeVerb] = nil; ~r1fx[\setFreeVerb] = nil;
    ~r1fx[\freeVerb] = ~r1.playfx({ |in| ~fxDefs[\freeVerb].(in, ~r1.inbus.index) });

    ~r1fx[\setFreeVerb] = { |mix, room, damp|
        mix.notNil.if  { ~r1fx[\freeVerb].set(\mix,  mix)  };
        room.notNil.if { ~r1fx[\freeVerb].set(\room, room) };
        damp.notNil.if { ~r1fx[\freeVerb].set(\damp, damp) };
    };

    ~lcn[\b1_s1_r1] = { |x| ~r1fx[\freeVerb].set(\room, x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s2_r1] = { |x| ~r1fx[\freeVerb].set(\damp, x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s3_r1] = { |x| ~r1fx[\freeVerb].set(\mix,  x.linlin(0, 127, 0.0, 1.0)) };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "freeVerb");
        ~toscFXBind.(page, slot, \r1, { |v| ~r1fx[\freeVerb].set(\room, v.linlin(0, 1, 0.0, 1.0)) }, "room");
        ~toscFXBind.(page, slot, \r2, { |v| ~r1fx[\freeVerb].set(\damp, v.linlin(0, 1, 0.0, 1.0)) }, "damp");
        ~toscFXBind.(page, slot, \f,  { |v| ~r1fx[\freeVerb].set(\mix,  v.linlin(0, 1, 0.0, 1.0)) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.5.linlin(0.0, 1.0, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.5.linlin(0.0, 1.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\r1_freeVerb] = { |page=nil, slot=nil|
    ~r1fx[\freeVerb].free;
    ~r1fx[\freeVerb]    = nil;
    ~r1fx[\setFreeVerb] = nil;
    [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1].do { |k| ~lcn[k] = nil };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \r3, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// ---- r2: combDelay → chorus (series) ----
// TOSC layout: r1=time, r2=decay  (maxdt: LC only)
~fxSetup[\r2_combDelay] = { |page=nil, slot=nil|
    ~r2fx[\combDelay].tryPerform(\free);
    ~r2fx[\combDelay] = nil; ~r2fx[\setCombDelay] = nil;
    ~r2fx[\combDelay] = ~r2.playfx({ |in| ~fxDefs[\combDelay].(in, ~r2.inbus.index) });

    ~r2fx[\setCombDelay] = { |dt, dec, maxdt|
        dt.notNil.if    { ~r2fx[\combDelay].set(\dt,    dt)    };
        maxdt.notNil.if { ~r2fx[\combDelay].set(\maxdt, maxdt) };
        dec.notNil.if   { ~r2fx[\combDelay].set(\dec,   dec)   };
    };

    ~lcn[\b1_s1_r2] = { |x| ~r2fx[\combDelay].set(\dt,    x.linlin(0, 127, 0.01, 0.4)) };
    ~lcn[\b1_s2_r2] = { |x| ~r2fx[\combDelay].set(\dec,   x.linlin(0, 127, 0.1,  4.0)) };
    ~lcn[\b1_s3_r2] = { |x| ~r2fx[\combDelay].set(\maxdt, x.linlin(0, 127, 0.01, 0.5)) };
    // APC40 device knobs — main bank 1, sub-bank 2 (b0_ds2_k1..4), x = 0-1
    ~apcBindParam.(\b0_ds2_k1, { |x| ~r2fx[\combDelay].set(\dt,    x.linlin(0, 1, 0.01, 0.4)) });
    ~apcBindParam.(\b0_ds2_k2, { |x| ~r2fx[\combDelay].set(\dec,   x.linlin(0, 1, 0.1,  4.0)) });
    ~apcBindParam.(\b0_ds2_k3, { |x| ~r2fx[\combDelay].set(\maxdt, x.linlin(0, 1, 0.01, 0.5)) });
    ~apcBindParam.(\b0_ds2_k4, { |x| ~r2fx[\combDelay].set(\mix,   x.linlin(0, 1, 0.0,  1.0)) });

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "comb");
        ~toscFXBind.(page, slot, \r1, { |v| ~r2fx[\combDelay].set(\dt,  v.linlin(0, 1, 0.01, 0.4)) }, "time");
        ~toscFXBind.(page, slot, \r2, { |v| ~r2fx[\combDelay].set(\dec, v.linlin(0, 1, 0.1,  4.0)) }, "decay");
        ~toscFXBind.(page, slot, \f, { |v| ~r2fx[\combDelay].set(\mix, v) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.25.linlin(0.01, 0.4, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.6.linlin(0.1, 4.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\r2_combDelay] = { |page=nil, slot=nil|
    ~r2fx[\combDelay].free;
    ~r2fx[\combDelay]    = nil;
    ~r2fx[\setCombDelay] = nil;
    [\b1_s1_r2, \b1_s2_r2, \b1_s3_r2].do { |k| ~lcn[k] = nil };
    if(~apcParamBindings.notNil) {
        [\b0_ds2_k1, \b0_ds2_k2, \b0_ds2_k3, \b0_ds2_k4].do { |k| ~apcParamBindings[k] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2,  \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// TOSC layout: r1=rate, r2=depth, f=mix
~fxSetup[\r4_chorus] = { |page=nil, slot=nil|
    ~r4fx[\chorus].tryPerform(\free);
    ~r4fx[\chorus] = nil; ~r4fx[\setChorus] = nil;
    ~r4fx[\chorus] = ~r4.playfx({ |in| ~fxDefs[\chorus].(in, ~r4.inbus.index) });

    ~r4fx[\setChorus] = { |rate, depth, mix|
        rate.notNil.if  { ~r4fx[\chorus].set(\rate,  rate)  };
        depth.notNil.if { ~r4fx[\chorus].set(\depth, depth) };
        mix.notNil.if   { ~r4fx[\chorus].set(\mix,   mix)   };
    };

    ~lcn[\b2_s1_r2] = { |x| ~r4fx[\chorus].set(\rate,  x.linlin(0, 127, 0.05, 5.0)) };
    ~lcn[\b2_s2_r2] = { |x| ~r4fx[\chorus].set(\depth, x.linlin(0, 127, 0.0, 0.015)) };
    ~lcn[\b2_s3_r2] = { |x| ~r4fx[\chorus].set(\mix,   x.linlin(0, 127, 0.0,  1.0)) };
    // APC40 device knobs — main bank 1, sub-bank 4 (b0_ds4_k1..3), x = 0-1
    ~apcBindParam.(\b0_ds4_k1, { |x| ~r4fx[\chorus].set(\rate,  x.linlin(0, 1, 0.05, 5.0)) });
    ~apcBindParam.(\b0_ds4_k2, { |x| ~r4fx[\chorus].set(\depth, x.linlin(0, 1, 0.0, 0.015)) });
    ~apcBindParam.(\b0_ds4_k3, { |x| ~r4fx[\chorus].set(\mix,   x.linlin(0, 1, 0.0, 1.0)) });

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "chorus");
        ~toscFXBind.(page, slot, \r1, { |v| ~r4fx[\chorus].set(\rate,  v.linlin(0, 1, 0.05, 5.0)) },   "rate");
        ~toscFXBind.(page, slot, \r2, { |v| ~r4fx[\chorus].set(\depth, v.linlin(0, 1, 0.0, 0.015)) },  "depth");
        ~toscFXBind.(page, slot, \f,  { |v| ~r4fx[\chorus].set(\mix,   v.linlin(0, 1, 0.0, 1.0)) });
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.4.linlin(0.05, 5.0, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.004.linlin(0.0, 0.015, 0, 1));
        ~toscFXSync.(page, slot, \f, 0.5);
    };
};

~fxTeardown[\r4_chorus] = { |page=nil, slot=nil|
    ~r4fx[\chorus].free;
    ~r4fx[\chorus]    = nil;
    ~r4fx[\setChorus] = nil;
    [\b2_s1_r2, \b2_s2_r2, \b2_s3_r2].do { |k| ~lcn[k] = nil };
    if(~apcParamBindings.notNil) {
        [\b0_ds4_k1, \b0_ds4_k2, \b0_ds4_k3].do { |k| ~apcParamBindings[k] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// ---- r3: biscuit (SynthDef-based, loaded async via fork) ----
// TOSC layout: r1=drive, r2=clock, r3=bits, r4=shape, r5=fxMode, xy1=filter, xy2=naked|dressed, f=dressed(mix)
~fxSetup[\r3_biscuit] = { |page=nil, slot=nil|
    // Free any existing instance before (re)creating — prevents double-synth leak
    ~r3fx[\biscuit].tryPerform(\free);
    ~r3fx[\biscuit]    = nil;
    ~r3fx[\setBiscuit] = nil;

    // Synth creation must be async (SynthDef confirmed via s.sync)
    {
        s.sync;
        ~r3fx[\biscuit] = Synth(\biscuit, [
            \in,      ~r3.inbus.index,
            \out,     ~r3.inbus.index,
            \naked,   0.0,
            \dressed, 1.0
        ], ~r3.effectgroup);

        ~r3_fx = ~r3fx[\biscuit];  // legacy alias — automation/biscuit.scd targets ~r3_fx

        ~r3fx[\setBiscuit] = { |drive, clock, bits, fxMode, shape, filterFreq, filterQ, naked, dressed|
            drive.notNil.if      { ~r3fx[\biscuit].set(\drive,      drive)      };
            clock.notNil.if      { ~r3fx[\biscuit].set(\clock,      clock)      };
            bits.notNil.if       { ~r3fx[\biscuit].set(\bits,       bits)       };
            fxMode.notNil.if     { ~r3fx[\biscuit].set(\fxMode,     fxMode)     };
            shape.notNil.if      { ~r3fx[\biscuit].set(\shape,      shape)      };
            filterFreq.notNil.if { ~r3fx[\biscuit].set(\filterFreq, filterFreq) };
            filterQ.notNil.if    { ~r3fx[\biscuit].set(\filterQ,    filterQ)    };
            naked.notNil.if      { ~r3fx[\biscuit].set(\naked,      naked)      };
            dressed.notNil.if    { ~r3fx[\biscuit].set(\dressed,    dressed)    };
        };
    }.fork;

    // APC40 device knobs — main bank 1, sub-bank 3 (b0_ds3_k1..8), x = 0-1
    // Closures resolve ~r3fx[\biscuit] at call time (same as TOSC — no sync needed)
    ~apcBindParam.(\b0_ds3_k1, { |x| ~r3fx[\biscuit].set(\drive,      x.linlin(0, 1, 0.0,   0.95)) });
    ~apcBindParam.(\b0_ds3_k2, { |x| ~r3fx[\biscuit].set(\clock,      x.linlin(0, 1, 250,   30000)) });
    ~apcBindParam.(\b0_ds3_k3, { |x| ~r3fx[\biscuit].set(\bits,       x.linlin(0, 1, 8,     1)) });  // 8=transparent → 1=max crush
    ~apcBindParam.(\b0_ds3_k4, { |x| ~r3fx[\biscuit].set(\shape,      x.linlin(0, 1, 0,     3)) });
    ~apcBindParam.(\b0_ds3_k5, { |x| ~r3fx[\biscuit].set(\fxMode,     x.linlin(0, 1, 0,     3)) });
    ~apcBindParam.(\b0_ds3_k6, { |x| ~r3fx[\biscuit].set(\filterFreq, x.linexp(0.001, 1, 200, 20000)) });
    ~apcBindParam.(\b0_ds3_k7, { |x| ~r3fx[\biscuit].set(\filterQ,    x.linlin(0, 1, 0.1,   4.0)) });
    ~apcBindParam.(\b0_ds3_k8, { |x| ~r3fx[\biscuit].set(\dressed,    x.linlin(0, 1, 0.0,   1.0)) });

    // TOSC bindings don't need server sync — closures resolve ~r3fx[\biscuit] at call time
    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "biscuit");
        ~toscFXBind.(page, slot, \r1, { |v| ~r3fx[\biscuit].set(\drive,     v.linlin(0, 1, 0.0,   0.95))  }, "drive");
        ~toscFXBind.(page, slot, \r2, { |v| ~r3fx[\biscuit].set(\clock,     v.linlin(0, 1, 250,   30000)) }, "clock");
        ~toscFXBind.(page, slot, \r3, { |v| ~r3fx[\biscuit].set(\bits,      v.linlin(0, 1, 8,     1))     }, "bits");  // 8=transparent → 1=max crush
        ~toscFXBind.(page, slot, \r4, { |v| ~r3fx[\biscuit].set(\shape,     v.linlin(0, 1, 0,     3))     }, "shape");
        ~toscFXBind.(page, slot, \r5, { |v| ~r3fx[\biscuit].set(\fxMode,    v.linlin(0, 1, 0,     3))     }, "fxMode");
        ~toscFXBindXY.(page, slot, 1,
            { |v| ~r3fx[\biscuit].set(\filterFreq, v.linexp(0.001, 1, 200, 20000)) },
            { |v| ~r3fx[\biscuit].set(\filterQ,    v.linlin(0, 1, 0.1, 4.0)) },
            "filter"
        );
        ~toscFXBindXY.(page, slot, 2,
            { |v| ~r3fx[\biscuit].set(\naked,   v.linlin(0.001, 1, 0.0, 1.0)) },
            { |v| ~r3fx[\biscuit].set(\dressed, v.linlin(0, 1, 0.0, 1.0)) },
            "naked|dressed"
        );
        ~toscFXBind.(page, slot, \f, { |v| ~r3fx[\biscuit].set(\dressed, v) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.0);
        ~toscFXSync.(page, slot, \r2, 250.0.linlin(250, 30000, 0, 1));
        ~toscFXSync.(page, slot, \r3, 0.0);
        ~toscFXSync.(page, slot, \r4, 0.0);
        ~toscFXSync.(page, slot, \r5, 0.0);
        ~toscFXSyncXY.(page, slot, 1, 0.5, 0.5);
        ~toscFXSyncXY.(page, slot, 2, 0.0, 1.0);
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\r3_biscuit] = { |page=nil, slot=nil|
    ~r3fx[\biscuit].free;
    ~r3fx[\biscuit]    = nil;
    ~r3fx[\setBiscuit] = nil;
    if(~apcParamBindings.notNil) {
        [\b0_ds3_k1, \b0_ds3_k2, \b0_ds3_k3, \b0_ds3_k4,
         \b0_ds3_k5, \b0_ds3_k6, \b0_ds3_k7, \b0_ds3_k8].do { |k| ~apcParamBindings[k] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \r3, \r4,  \r5,  \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
        ~oscParam[(base ++ "/xy1/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy1/y").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/y").asSymbol] = nil;
    };
};

"Mixer Channel FX Defs & Setup Loaded.".postln;
)
