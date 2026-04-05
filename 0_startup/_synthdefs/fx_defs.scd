(
~fxDefs    = ();
~fxSetup   = ();
~fxTeardown = ();

// ~fxSetup[key].(ret, retFx, ds, page, slot)
//   ret   — MixerChannel to host the FX (e.g. ~r1)
//   retFx — state dict for this return   (e.g. ~r1fx)
//   ds    — APC40 device sub-bank index  (nil = skip APC bindings)
//   page  — TouchOSC FX page             (nil = skip TOSC)
//   slot  — TouchOSC FX slot             (nil = skip TOSC)
//
// ~fxTeardown[key].(retFx, ds, page, slot)

// =============================================================================
// FX SYNTH DEFINITIONS
// =============================================================================

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

~fxDefs[\spectral] = { |in, bus|
    var sig, chains, wetFreeze, wetSmear, wet, mix, amp, freeze, smear, freezeSmear, chunk;
    sig = In.ar(bus, 2);
    mix = \mix.kr(1);
    amp = \amp.kr(0.4);
    chunk = \chunk.kr(2048);
    freeze = \freeze.kr(0);
    smear = \smear.kr(0);
    freezeSmear = \freezeSmear.kr(0);

    chains = sig.collect({ |chan| FFT(LocalBuf(chunk), chan) });
    wetFreeze = IFFT(chains.collect({ |chain| PV_Freeze(chain, freeze) }));
    wetSmear  = IFFT(chains.collect({ |chain| PV_MagSmear(chain, smear) }));

    wet = XFade2.ar(wetFreeze, wetSmear, freezeSmear * 2 - 1);
    XFade2.ar(sig, wet, mix * 2 - 1) * amp;
};

// =============================================================================
// GREYHOLE
// TOSC layout: r1=delayTime, r2=feedback, r3=diff, xy1(x=size, y=damp), xy2(x=modDepth, y=modFreq), f=mix
// =============================================================================

~fxSetup[\greyhole] = { |ret, retFx, ds=nil, page=nil, slot=nil|
    retFx[\greyhole].tryPerform(\free);
    retFx[\greyhole] = nil; retFx[\setGreyhole] = nil;
    retFx[\greyhole] = ret.playfx({ |in| ~fxDefs[\greyhole].(in, ret.inbus.index) });

    retFx[\setGreyhole] = { |delayTime, damp, size, diff, feedback, modDepth, modFreq|
        delayTime.notNil.if { retFx[\greyhole].set(\delayTime, delayTime) };
        damp.notNil.if      { retFx[\greyhole].set(\damp,      damp) };
        size.notNil.if      { retFx[\greyhole].set(\size,      size) };
        diff.notNil.if      { retFx[\greyhole].set(\diff,      diff) };
        feedback.notNil.if  { retFx[\greyhole].set(\feedback,  feedback) };
        modDepth.notNil.if  { retFx[\greyhole].set(\modDepth,  modDepth) };
        modFreq.notNil.if   { retFx[\greyhole].set(\modFreq,   modFreq) };
    };

    if(ds.notNil and: { ~apcBindParam.notNil }) {
        var dsk = { |n| ("b0_ds" ++ ds ++ "_k" ++ n).asSymbol };
        ~apcBindParam.(dsk.(1), { |x| retFx[\greyhole].set(\delayTime, x.linexp(0.001, 1, 0.1,  5.0)) });
        ~apcBindParam.(dsk.(2), { |x| retFx[\greyhole].set(\damp,      x.linlin(0, 1, 0.0,   1.0)) });
        ~apcBindParam.(dsk.(3), { |x| retFx[\greyhole].set(\size,      x.linlin(0, 1, 0.1,   5.0)) });
        ~apcBindParam.(dsk.(4), { |x| retFx[\greyhole].set(\diff,      x.linlin(0, 1, 0.01,  0.99)) });
        ~apcBindParam.(dsk.(5), { |x| retFx[\greyhole].set(\feedback,  x.linlin(0, 1, 0.01,  0.95)) });
        ~apcBindParam.(dsk.(6), { |x| retFx[\greyhole].set(\modDepth,  x.linlin(0, 1, 0.0,   1.0)) });
        ~apcBindParam.(dsk.(7), { |x| retFx[\greyhole].set(\modFreq,   x.linexp(0.001, 1, 0.5, 100.0)) });
        ~apcBindParam.(dsk.(8), { |x| retFx[\greyhole].set(\mix,       x.linlin(0, 1, 0.0,   1.0)) });
    };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "greyhole");
        ~toscFXBind.(page, slot, \r1, { |v| retFx[\greyhole].set(\delayTime, v.linexp(0, 1, 0.1, 5.0)) },  "time");
        ~toscFXBind.(page, slot, \r2, { |v| retFx[\greyhole].set(\feedback,  v.linlin(0, 1, 0.1, 0.95)) }, "fdbk");
        ~toscFXBind.(page, slot, \r3, { |v| retFx[\greyhole].set(\diff,      v.linlin(0, 1, 0.1, 0.99)) }, "diff");
        ~toscFXBindXY.(page, slot, 1,
            { |v| retFx[\greyhole].set(\size, v.linlin(0, 1, 0.1, 5.0)) },
            { |v| retFx[\greyhole].set(\damp, v.linlin(0, 1, 0.0, 1.0)) },
            "sz|dmp"
        );
        ~toscFXBindXY.(page, slot, 2,
            { |v| retFx[\greyhole].set(\modDepth, v.linlin(0, 1, 0.01, 1.0)) },
            { |v| retFx[\greyhole].set(\modFreq,  v.linexp(0, 1, 0.5, 100.0)) },
            "modDepth|modFreq"
        );
        ~toscFXBind.(page, slot, \f, { |v| retFx[\greyhole].set(\mix, v) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 2.0.explin(0.1, 5.0, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.1.linlin(0.1, 0.95, 0, 1));
        ~toscFXSync.(page, slot, \r3, 0.707.linlin(0.1, 0.99, 0, 1));
        ~toscFXSyncXY.(page, slot, 1, 3.0.linlin(0.1, 5.0, 0, 1), 0.0);
        ~toscFXSyncXY.(page, slot, 2, 0.1.linlin(0.01, 1.0, 0, 1), 2.0.explin(0.5, 100.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\greyhole] = { |retFx, ds=nil, page=nil, slot=nil|
    retFx[\greyhole].free;
    retFx[\greyhole]    = nil;
    retFx[\setGreyhole] = nil;
    if(ds.notNil and: { ~apcParamBindings.notNil }) {
        (1..8).do { |n| ~apcParamBindings[("b0_ds" ++ ds ++ "_k" ++ n).asSymbol] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \r3, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
        ~oscParam[(base ++ "/xy1/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy1/y").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/y").asSymbol] = nil;
    };
};

// =============================================================================
// FREEVERB
// TOSC layout: r1=room, r2=damp, f=mix
// =============================================================================

~fxSetup[\freeVerb] = { |ret, retFx, ds=nil, page=nil, slot=nil|
    retFx[\freeVerb].tryPerform(\free);
    retFx[\freeVerb] = nil; retFx[\setFreeVerb] = nil;
    retFx[\freeVerb] = ret.playfx({ |in| ~fxDefs[\freeVerb].(in, ret.inbus.index) });

    retFx[\setFreeVerb] = { |mix, room, damp|
        mix.notNil.if  { retFx[\freeVerb].set(\mix,  mix)  };
        room.notNil.if { retFx[\freeVerb].set(\room, room) };
        damp.notNil.if { retFx[\freeVerb].set(\damp, damp) };
    };

    if(ds.notNil and: { ~apcBindParam.notNil }) {
        var dsk = { |n| ("b0_ds" ++ ds ++ "_k" ++ n).asSymbol };
        ~apcBindParam.(dsk.(1), { |x| retFx[\freeVerb].set(\room, x.linlin(0, 1, 0.0, 1.0)) });
        ~apcBindParam.(dsk.(2), { |x| retFx[\freeVerb].set(\damp, x.linlin(0, 1, 0.0, 1.0)) });
        ~apcBindParam.(dsk.(3), { |x| retFx[\freeVerb].set(\mix,  x.linlin(0, 1, 0.0, 1.0)) });
    };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "freeVerb");
        ~toscFXBind.(page, slot, \r1, { |v| retFx[\freeVerb].set(\room, v.linlin(0, 1, 0.0, 1.0)) }, "room");
        ~toscFXBind.(page, slot, \r2, { |v| retFx[\freeVerb].set(\damp, v.linlin(0, 1, 0.0, 1.0)) }, "damp");
        ~toscFXBind.(page, slot, \f,  { |v| retFx[\freeVerb].set(\mix,  v.linlin(0, 1, 0.0, 1.0)) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.5.linlin(0.0, 1.0, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.5.linlin(0.0, 1.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\freeVerb] = { |retFx, ds=nil, page=nil, slot=nil|
    retFx[\freeVerb].free;
    retFx[\freeVerb]    = nil;
    retFx[\setFreeVerb] = nil;
    if(ds.notNil and: { ~apcParamBindings.notNil }) {
        (1..8).do { |n| ~apcParamBindings[("b0_ds" ++ ds ++ "_k" ++ n).asSymbol] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// =============================================================================
// COMBDELAY
// TOSC layout: r1=time, r2=decay, f=mix
// =============================================================================

~fxSetup[\combDelay] = { |ret, retFx, ds=nil, page=nil, slot=nil|
    retFx[\combDelay].tryPerform(\free);
    retFx[\combDelay] = nil; retFx[\setCombDelay] = nil;
    retFx[\combDelay] = ret.playfx({ |in| ~fxDefs[\combDelay].(in, ret.inbus.index) });

    retFx[\setCombDelay] = { |dt, dec, maxdt|
        dt.notNil.if    { retFx[\combDelay].set(\dt,    dt)    };
        maxdt.notNil.if { retFx[\combDelay].set(\maxdt, maxdt) };
        dec.notNil.if   { retFx[\combDelay].set(\dec,   dec)   };
    };

    if(ds.notNil and: { ~apcBindParam.notNil }) {
        var dsk = { |n| ("b0_ds" ++ ds ++ "_k" ++ n).asSymbol };
        ~apcBindParam.(dsk.(1), { |x| retFx[\combDelay].set(\dt,    x.linlin(0, 1, 0.01, 0.4)) });
        ~apcBindParam.(dsk.(2), { |x| retFx[\combDelay].set(\dec,   x.linlin(0, 1, 0.1,  4.0)) });
        ~apcBindParam.(dsk.(3), { |x| retFx[\combDelay].set(\maxdt, x.linlin(0, 1, 0.01, 0.5)) });
        ~apcBindParam.(dsk.(4), { |x| retFx[\combDelay].set(\mix,   x.linlin(0, 1, 0.0,  1.0)) });
    };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "comb");
        ~toscFXBind.(page, slot, \r1, { |v| retFx[\combDelay].set(\dt,  v.linlin(0, 1, 0.01, 0.4)) }, "time");
        ~toscFXBind.(page, slot, \r2, { |v| retFx[\combDelay].set(\dec, v.linlin(0, 1, 0.1,  4.0)) }, "decay");
        ~toscFXBind.(page, slot, \f,  { |v| retFx[\combDelay].set(\mix, v) }, "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.25.linlin(0.01, 0.4, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.6.linlin(0.1, 4.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\combDelay] = { |retFx, ds=nil, page=nil, slot=nil|
    retFx[\combDelay].free;
    retFx[\combDelay]    = nil;
    retFx[\setCombDelay] = nil;
    if(ds.notNil and: { ~apcParamBindings.notNil }) {
        (1..8).do { |n| ~apcParamBindings[("b0_ds" ++ ds ++ "_k" ++ n).asSymbol] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// =============================================================================
// CHORUS
// TOSC layout: r1=rate, r2=depth, f=mix
// =============================================================================

~fxSetup[\chorus] = { |ret, retFx, ds=nil, page=nil, slot=nil|
    retFx[\chorus].tryPerform(\free);
    retFx[\chorus] = nil; retFx[\setChorus] = nil;
    retFx[\chorus] = ret.playfx({ |in| ~fxDefs[\chorus].(in, ret.inbus.index) });

    retFx[\setChorus] = { |rate, depth, mix|
        rate.notNil.if  { retFx[\chorus].set(\rate,  rate)  };
        depth.notNil.if { retFx[\chorus].set(\depth, depth) };
        mix.notNil.if   { retFx[\chorus].set(\mix,   mix)   };
    };

    if(ds.notNil and: { ~apcBindParam.notNil }) {
        var dsk = { |n| ("b0_ds" ++ ds ++ "_k" ++ n).asSymbol };
        ~apcBindParam.(dsk.(1), { |x| retFx[\chorus].set(\rate,  x.linlin(0, 1, 0.05, 5.0)) });
        ~apcBindParam.(dsk.(2), { |x| retFx[\chorus].set(\depth, x.linlin(0, 1, 0.0, 0.015)) });
        ~apcBindParam.(dsk.(3), { |x| retFx[\chorus].set(\mix,   x.linlin(0, 1, 0.0, 1.0)) });
    };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "chorus");
        ~toscFXBind.(page, slot, \r1, { |v| retFx[\chorus].set(\rate,  v.linlin(0, 1, 0.05, 5.0)) },  "rate");
        ~toscFXBind.(page, slot, \r2, { |v| retFx[\chorus].set(\depth, v.linlin(0, 1, 0.0, 0.015)) }, "depth");
        ~toscFXBind.(page, slot, \f,  { |v| retFx[\chorus].set(\mix,   v.linlin(0, 1, 0.0, 1.0)) });
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.4.linlin(0.05, 5.0, 0, 1));
        ~toscFXSync.(page, slot, \r2, 0.004.linlin(0.0, 0.015, 0, 1));
        ~toscFXSync.(page, slot, \f, 0.5);
    };
};

~fxTeardown[\chorus] = { |retFx, ds=nil, page=nil, slot=nil|
    retFx[\chorus].free;
    retFx[\chorus]    = nil;
    retFx[\setChorus] = nil;
    if(ds.notNil and: { ~apcParamBindings.notNil }) {
        (1..8).do { |n| ~apcParamBindings[("b0_ds" ++ ds ++ "_k" ++ n).asSymbol] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// =============================================================================
// BISCUIT  (SynthDef-based)
// TOSC layout: r1=drive, r2=clock, r3=bits, r4=shape, r5=fxMode, xy1=filter, xy2=naked|dressed, f=mix
// =============================================================================

~fxSetup[\biscuit] = { |ret, retFx, ds=nil, page=nil, slot=nil|
    retFx[\biscuit].tryPerform(\free);
    retFx[\biscuit]    = nil;
    retFx[\setBiscuit] = nil;

    // Defer Synth creation until MixerChannelReconstructor confirms ~r3 is ready.
    // s.sync does NOT wait for doQueue (scheduled 1ms later on SystemClock) — groups
    // may not exist on the server yet when ~fxSetup runs. doWhenReady queues via the
    // same serialized MixerChannelReconstructor pipeline, so it fires after groups land.
    // \addAfter effectgroup places biscuit between effectgroup (inline HPF/LPF) and the
    // fader synth: correct chain = filter → biscuit → fader.
    ret.doWhenReady({
        retFx[\biscuit] = Synth(\biscuit, [
            \in,      ret.inbus.index,
            \out,     ret.inbus.index,
            \naked,   0.0,
            \dressed, 1.0
        ], ret.effectgroup, \addAfter);
    });

    retFx[\setBiscuit] = { |drive, clock, bits, fxMode, shape, filterFreq, filterQ, naked, dressed|
        drive.notNil.if      { retFx[\biscuit].set(\drive,      drive)      };
        clock.notNil.if      { retFx[\biscuit].set(\clock,      clock)      };
        bits.notNil.if       { retFx[\biscuit].set(\bits,       bits)       };
        fxMode.notNil.if     { retFx[\biscuit].set(\fxMode,     fxMode)     };
        shape.notNil.if      { retFx[\biscuit].set(\shape,      shape)      };
        filterFreq.notNil.if { retFx[\biscuit].set(\filterFreq, filterFreq) };
        filterQ.notNil.if    { retFx[\biscuit].set(\filterQ,    filterQ)    };
        naked.notNil.if      { retFx[\biscuit].set(\naked,      naked)      };
        dressed.notNil.if    { retFx[\biscuit].set(\dressed,    dressed)    };
    };

    // APC bindings use closures — resolve retFx[\biscuit] at call time (no sync needed)
    if(ds.notNil and: { ~apcBindParam.notNil }) {
        var dsk = { |n| ("b0_ds" ++ ds ++ "_k" ++ n).asSymbol };
        ~apcBindParam.(dsk.(1), { |x| retFx[\biscuit].set(\drive,      x.linlin(0, 1, 0.0,   0.95)) });
        ~apcBindParam.(dsk.(2), { |x| retFx[\biscuit].set(\clock,      x.linlin(0, 1, 250,   30000)) });
        ~apcBindParam.(dsk.(3), { |x| retFx[\biscuit].set(\bits,       x.linlin(0, 1, 8,     1)) });  // 8=transparent → 1=max crush
        ~apcBindParam.(dsk.(4), { |x| retFx[\biscuit].set(\shape,      x.linlin(0, 1, 0,     3)) });
        ~apcBindParam.(dsk.(5), { |x| retFx[\biscuit].set(\fxMode,     x.linlin(0, 1, 0,     3)) });
        ~apcBindParam.(dsk.(6), { |x| retFx[\biscuit].set(\filterFreq, x.linexp(0.001, 1, 200, 20000)) });
        ~apcBindParam.(dsk.(7), { |x| retFx[\biscuit].set(\filterQ,    x.linlin(0, 1, 0.1,   4.0)) });
        ~apcBindParam.(dsk.(8), { |x| retFx[\biscuit].set(\dressed,    x.linlin(0, 1, 0.0,   1.0)) });
    };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "biscuit");
        ~toscFXBind.(page, slot, \r1, { |v| retFx[\biscuit].set(\drive,     v.linlin(0, 1, 0.0,   0.95))  }, "drive");
        ~toscFXBind.(page, slot, \r2, { |v| retFx[\biscuit].set(\clock,     v.linlin(0, 1, 250,   30000)) }, "clock");
        ~toscFXBind.(page, slot, \r3, { |v| retFx[\biscuit].set(\bits,      v.linlin(0, 1, 8,     1))     }, "bits");
        ~toscFXBind.(page, slot, \r4, { |v| retFx[\biscuit].set(\shape,     v.linlin(0, 1, 0,     3))     }, "shape");
        ~toscFXBind.(page, slot, \r5, { |v| retFx[\biscuit].set(\fxMode,    v.linlin(0, 1, 0,     3))     }, "fxMode");
        ~toscFXBindXY.(page, slot, 1,
            { |v| retFx[\biscuit].set(\filterFreq, v.linexp(0.001, 1, 200, 20000)) },
            { |v| retFx[\biscuit].set(\filterQ,    v.linlin(0, 1, 0.1, 4.0)) },
            "filter"
        );
        ~toscFXBindXY.(page, slot, 2,
            { |v| retFx[\biscuit].set(\naked,   v.linlin(0.001, 1, 0.0, 1.0)) },
            { |v| retFx[\biscuit].set(\dressed, v.linlin(0, 1, 0.0, 1.0)) },
            "naked|dressed"
        );
        ~toscFXBind.(page, slot, \f, { |v| retFx[\biscuit].set(\dressed, v) }, "mix");
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

~fxTeardown[\biscuit] = { |retFx, ds=nil, page=nil, slot=nil|
    retFx[\biscuit].free;
    retFx[\biscuit]    = nil;
    retFx[\setBiscuit] = nil;
    if(ds.notNil and: { ~apcParamBindings.notNil }) {
        (1..8).do { |n| ~apcParamBindings[("b0_ds" ++ ds ++ "_k" ++ n).asSymbol] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \r3, \r4, \r5, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
        ~oscParam[(base ++ "/xy1/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy1/y").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/x").asSymbol] = nil;
        ~oscParam[(base ++ "/xy2/y").asSymbol] = nil;
    };
};

// =============================================================================
// SPECTRAL
// =============================================================================

~fxSetup[\spectral] = { |ret, retFx, ds=nil, page=nil, slot=nil|
    retFx[\spectral].tryPerform(\free);
    retFx[\spectral] = nil; retFx[\setSpectral] = nil;
    retFx[\spectral] = ret.playfx({ |in| ~fxDefs[\spectral].(in, ret.inbus.index) });

    retFx[\setSpectral] = { |mix, amp, chunk, freeze, smear, freezeSmear|
        mix.notNil.if         { retFx[\spectral].set(\mix,         mix)         };
        amp.notNil.if         { retFx[\spectral].set(\amp,         amp)         };
        chunk.notNil.if       { retFx[\spectral].set(\chunk,       chunk)       };
        freeze.notNil.if      { retFx[\spectral].set(\freeze,      freeze)      };
        smear.notNil.if       { retFx[\spectral].set(\smear,       smear)       };
        freezeSmear.notNil.if { retFx[\spectral].set(\freezeSmear, freezeSmear) };
    };

    if(ds.notNil and: { ~apcBindParam.notNil }) {
        var dsk = { |n| ("b0_ds" ++ ds ++ "_k" ++ n).asSymbol };
        var chunks = [128, 256, 512, 1024, 2048];
        ~apcBindParam.(dsk.(1), { |x| retFx[\spectral].set(\chunk,       chunks[(x.linlin(0, 1, 0, 4).round.asInteger)]) });
        ~apcBindParam.(dsk.(2), { |x| retFx[\spectral].set(\freeze,      x.linlin(0, 1, 0, 1).round.asInteger) });
        ~apcBindParam.(dsk.(3), { |x| retFx[\spectral].set(\smear,       x.linlin(0, 1, 0, 1).round.asInteger) });
        ~apcBindParam.(dsk.(4), { |x| retFx[\spectral].set(\freezeSmear, x.linlin(0, 1, 0, 1)) });
        ~apcBindParam.(dsk.(5), { |x| retFx[\spectral].set(\amp,         x.linlin(0, 1, 0.01, 3.0)) });
        ~apcBindParam.(dsk.(6), { |x| retFx[\spectral].set(\mix,         x.linlin(0, 1, 0.0,  1.0)) });
    };

    if(page.notNil and: { slot.notNil }) {
        ~toscFXLabel.(page, slot, "spectral");
        ~toscFXBind.(page, slot, \r1, { |v| retFx[\spectral].set(\freeze,      v.linlin(0, 1, 0, 1).round.asInteger) }, "freeze");
        ~toscFXBind.(page, slot, \r2, { |v| retFx[\spectral].set(\smear,       v.linlin(0, 1, 0, 1).round.asInteger) }, "smear");
        ~toscFXBind.(page, slot, \r3, { |v| retFx[\spectral].set(\freezeSmear, v.linlin(0, 1, 0, 1)) },                 "frzSmr");
        ~toscFXBind.(page, slot, \r4, { |v| retFx[\spectral].set(\amp,         v.linlin(0, 1, 0.01, 3.0)) },            "amp");
        ~toscFXBind.(page, slot, \f,  { |v| retFx[\spectral].set(\mix,         v) },                                    "mix");
        // Sync defaults
        ~toscFXSync.(page, slot, \r1, 0.0);
        ~toscFXSync.(page, slot, \r2, 0.0);
        ~toscFXSync.(page, slot, \r3, 0.0);
        ~toscFXSync.(page, slot, \r4, 0.4.linlin(0.01, 3.0, 0, 1));
        ~toscFXSync.(page, slot, \f, 1.0);
    };
};

~fxTeardown[\spectral] = { |retFx, ds=nil, page=nil, slot=nil|
    retFx[\spectral].free;
    retFx[\spectral]    = nil;
    retFx[\setSpectral] = nil;
    if(ds.notNil and: { ~apcParamBindings.notNil }) {
        (1..8).do { |n| ~apcParamBindings[("b0_ds" ++ ds ++ "_k" ++ n).asSymbol] = nil };
    };
    if(page.notNil and: { slot.notNil }) {
        var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
        [\r1, \r2, \r3, \r4, \f].do { |c| ~oscParam[(base ++ "/" ++ c).asSymbol] = nil };
    };
};

// =============================================================================
// ADDITIONAL FX DEFS (no ~fxSetup — use inline via playfx or Ndef)
// =============================================================================

// Bitcrusher — sample rate + bit depth reduction
// Params: \rate (100–44100 Hz), \bits (1–16), \mix (0–1)
~fxDefs[\bitcrush] = { |in, bus|
    var sig, wet;
    sig = In.ar(bus, 2);
    wet = Decimator.ar(sig, \rate.kr(44100), \bits.kr(8));
    XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// Ring modulator
// Params: \freq (20–2000 Hz), \mix (0–1)
~fxDefs[\ringmod] = { |in, bus|
    var sig, wet;
    sig = In.ar(bus, 2);
    wet = sig * SinOsc.ar(\freq.kr(440));
    XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// Wavefolder
// Params: \gain (1–20), \mix (0–1)
~fxDefs[\fold] = { |in, bus|
    var sig, wet;
    sig = In.ar(bus, 2);
    wet = (sig * \gain.kr(4)).fold2(1);
    XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(0.5)
};

// Glitch — LFO-modulated decimation
// Params: \rate (0.1–10), \mix (0–1)
~fxDefs[\glitch] = { |in, bus|
    var sig, wet;
    sig = In.ar(bus, 2);
    wet = Decimator.ar(
        sig,
        LFTri.ar(\rate.kr(1) * 0.5).range(200, 6000),
        LFPulse.kr(\rate.kr(1) * 0.5, 0.5).range(6, 14)
    ) + sig;
    XFade2.ar(sig, wet, \mix.kr(0.7).linlin(0, 1, -1, 1)) * \amp.kr(0.8)
};

// Pitch shimmer — PitchShift in semitones
// Params: \shift (semitones, e.g. 12 = up one octave), \time (0.01–0.5), \mix (0–1)
~fxDefs[\shimmer] = { |in, bus|
    var sig, wet;
    sig = In.ar(bus, 2);
    wet = PitchShift.ar(sig,
        windowSize:      0.2,
        pitchRatio:      \shift.kr(12).midiratio,
        pitchDispersion: 0.01,
        timeDispersion:  \time.kr(0.1)
    );
    XFade2.ar(sig, wet, \mix.kr(0.4).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// Stutter — continuous stereo record + TGrains playback
// Params: \rate (0.5–8 repeats/sec), \mix (0–1)
~fxDefs[\stutter] = { |in, bus|
    var sig, trig, bufL, bufR, wet;
    sig  = In.ar(bus, 2);
    trig = Impulse.kr(\rate.kr(2));
    bufL = LocalBuf(SampleRate.ir * 2, 1);
    bufR = LocalBuf(SampleRate.ir * 2, 1);
    wet  = [
        TGrains.ar(1, trig, bufL, 1, BufDur.kr(bufL) / 2, 0.25),
        TGrains.ar(1, trig, bufR, 1, BufDur.kr(bufR) / 2, 0.25)
    ];
    RecordBuf.ar(sig[0], bufL, loop: 1);
    RecordBuf.ar(sig[1], bufR, loop: 1);
    XFade2.ar(sig, wet, \mix.kr(0.5).linlin(0, 1, -1, 1)) * \amp.kr(1)
};

// Pitch shift (simple ratio version)
// Params: \shift (ratio: 1.0=unchanged, 2.0=+octave, 0.5=-octave), \mix (0–1)
~fxDefs[\pitchShift] = { |in, bus|
    var sig, wet;
    sig = In.ar(bus, 2);
    wet = PitchShift.ar(sig, 0.1, \shift.kr(1.0), 0.01, 0.01);
    XFade2.ar(sig, wet, \mix.kr(0.5).linlin(0, 1, -1, 1))
};

// Granular freeze — records continuously, freeze=1 holds buffer for grain playback
// Params: \freeze (0/1), \rate (playback rate), \scatter (grain pos scatter), \mix (0–1)
~fxDefs[\granFreeze] = { |in, bus|
    var sig, freeze, rate, scatter, trig, bufL, bufR, wet;
    sig     = In.ar(bus, 2);
    freeze  = \freeze.kr(0);
    rate    = \rate.kr(1.0);
    scatter = \scatter.kr(0.05);
    trig    = Impulse.ar(20);
    bufL    = LocalBuf(SampleRate.ir * 2, 1);
    bufR    = LocalBuf(SampleRate.ir * 2, 1);
    // freeze=1 mutes input to RecordBuf — buffer holds last captured content
    RecordBuf.ar(sig[0] * (1 - freeze), bufL, loop: 1);
    RecordBuf.ar(sig[1] * (1 - freeze), bufR, loop: 1);
    wet = [
        TGrains.ar(1, trig, bufL, rate, BufDur.kr(bufL) * 0.5,
            0.1, scatter * TRand.kr(-1, 1, trig), 0.5, 2),
        TGrains.ar(1, trig, bufR, rate, BufDur.kr(bufR) * 0.5,
            0.1, scatter * TRand.kr(-1, 1, trig), 0.5, 2)
    ];
    XFade2.ar(sig, wet, \mix.kr(0.8).linlin(0, 1, -1, 1))
};

// ~ufn aliases — FX functions available for Ndef / playfx experimentation.
// Usage: Ndef(\x, { ~fxDefs[\greyhole].(0, ~r1.inbus.index) });
~ufn = ~ufn ? ();
~ufn[\combDelay]  = ~fxDefs[\combDelay];
~ufn[\freeVerb]   = ~fxDefs[\freeVerb];
~ufn[\greyhole]   = ~fxDefs[\greyhole];
~ufn[\chorus]     = ~fxDefs[\chorus];
~ufn[\spectral]   = ~fxDefs[\spectral];
~ufn[\bitcrush]   = ~fxDefs[\bitcrush];
~ufn[\ringmod]    = ~fxDefs[\ringmod];
~ufn[\fold]       = ~fxDefs[\fold];
~ufn[\glitch]     = ~fxDefs[\glitch];
~ufn[\shimmer]    = ~fxDefs[\shimmer];
~ufn[\stutter]    = ~fxDefs[\stutter];
~ufn[\pitchShift] = ~fxDefs[\pitchShift];
~ufn[\granFreeze] = ~fxDefs[\granFreeze];

"Mixer Channel FX Defs & Setup Loaded.".postln;
)
