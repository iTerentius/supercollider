(
~fxDefs    = ();
~fxSetup   = ();
~fxTeardown = ();
~lcn = ~lcn ?? { () };  // LC binding dict — init if not already set by a controller

~fxDefs[\combDelay] = { |in, bus|
    var sig = In.ar(bus, 2);
    CombL.ar(sig,
        maxdelaytime: \maxdt.kr(0.4),
        delaytime:    \dt.kr(0.25),
        decaytime:    \dec.kr(0.6)
    )
};

~fxDefs[\freeVerb] = { |in, bus|
    var sig = In.ar(bus, 2);
    FreeVerb2.ar(sig[0], sig[1],
        mix:  \mix.kr(0.33),
        room: \room.kr(0.5),
        damp: \damp.kr(0.5)
    )
};

~fxDefs[\greyhole] = { |in, bus|
    var sig = In.ar(bus, 2);
    Greyhole.ar(sig,
        \delayTime.kr(2.0),
        \damp.kr(0.0),
        \size.kr(3.0),
        \diff.kr(0.707),
        \feedback.kr(0.1),
        \modDepth.kr(0.1),
        \modFreq.kr(2.0)
    )
};

// Stereo chorus: LFO-modulated short delay, offset 90deg per channel for width
~fxDefs[\chorus] = { |in, bus|
    var sig  = In.ar(bus, 2);
    var lfo  = SinOsc.kr(\rate.kr(0.4), [0, 0.5pi]) * \depth.kr(0.004) + 0.005;
    var wet  = DelayC.ar(sig, 0.05, lfo);
    XFade2.ar(sig, wet, \mix.kr(0.5).linlin(0, 1, -1, 1))
};

// ---- r1: greyhole (default) / freeVerb (swap) ----
~fxSetup[\r1_greyhole] = {
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

    ~lcn[\b1_s1_r1] = { |x| ~r1fx[\greyhole].set(\delayTime, x.linexp(0, 127, 0.1,  5.0)) };   // linexp OK - no zeros
    ~lcn[\b1_s2_r1] = { |x| ~r1fx[\greyhole].set(\damp,      x.linlin(0, 127, 0.0,   1.0)) };   // linlin - has 0
    ~lcn[\b1_s3_r1] = { |x| ~r1fx[\greyhole].set(\size,      x.linlin(0, 127, 0.1,  5.0)) };   // linlin - has 0
    ~lcn[\b1_s4_r1] = { |x| ~r1fx[\greyhole].set(\diff,      x.linlin(0, 127, 0.1,  0.99)) };  // linlin - has 0
    ~lcn[\b1_s5_r1] = { |x| ~r1fx[\greyhole].set(\feedback,  x.linlin(0, 127, 0.1,  0.95)) };  // linlin - capped <1
    ~lcn[\b1_s1_r2] = { |x| ~r1fx[\greyhole].set(\modDepth,  x.linlin(0, 127, 0.0,   1.0)) };   // linlin - has 0
    ~lcn[\b1_s2_r2] = { |x| ~r1fx[\greyhole].set(\modFreq,   x.linexp(0, 127, 0.5, 100.0)) };   // linexp OK - raised min

    ~apcBindParam.(\b1_d1, { |x| ~r1fx[\greyhole].set(\delayTime, x.linexp(0, 127, 0.1, 5.0)) });   // OK - no zeros
    ~apcBindParam.(\b1_d2, { |x| ~r1fx[\greyhole].set(\damp,      x.linlin(0, 127, 0.01, 1.0)) });     // linlin - has 0
    ~apcBindParam.(\b1_d3, { |x| ~r1fx[\greyhole].set(\size,      x.linlin(0, 127, 0.1, 5.0)) });     // linlin - has 0
    ~apcBindParam.(\b1_d4, { |x| ~r1fx[\greyhole].set(\diff,      x.linlin(0, 127, 0.01, 0.99)) });     // linlin - has 0
    ~apcBindParam.(\b1_d5, { |x| ~r1fx[\greyhole].set(\feedback,  x.linlin(0, 127, 0.01, 0.95)) });     // linlin - has 0
    ~apcBindParam.(\b1_d6, { |x| ~r1fx[\greyhole].set(\modDepth,  x.linlin(0, 127, 0.01, 1.0)) });     // linlin - has 0
    ~apcBindParam.(\b1_d7, { |x| ~r1fx[\greyhole].set(\modFreq,   x.linexp(0, 127, 0.5, 100.0)) });   // linexp OK - raised min
};

~fxTeardown[\r1_greyhole] = {
    ~r1fx[\greyhole].free;
    ~r1fx[\greyhole]    = nil;
    ~r1fx[\setGreyhole] = nil;
    [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1, \b1_s4_r1, \b1_s5_r1, \b1_s1_r2].do { |k| ~lcn[k] = nil };
};

~fxSetup[\r1_freeVerb] = {
    ~r1fx[\freeVerb] = ~r1.playfx({ |in| ~fxDefs[\freeVerb].(in, ~r1.inbus.index) });

    ~r1fx[\setFreeVerb] = { |mix, room, damp|
        mix.notNil.if  { ~r1fx[\freeVerb].set(\mix,  mix)  };
        room.notNil.if { ~r1fx[\freeVerb].set(\room, room) };
        damp.notNil.if { ~r1fx[\freeVerb].set(\damp, damp) };
    };

    ~lcn[\b1_s1_r1] = { |x| ~r1fx[\freeVerb].set(\mix,  x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s2_r1] = { |x| ~r1fx[\freeVerb].set(\room, x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s3_r1] = { |x| ~r1fx[\freeVerb].set(\damp, x.linlin(0, 127, 0.0, 1.0)) };
    ~apcBindParam.(\b1_d1, { |x| ~r1fx[\freeVerb].set(\mix, x.linlin(0, 127, 0.0, 10.0)) });   // OK - no zeros
    ~apcBindParam.(\b1_d2, { |x| ~r1fx[\freeVerb].set(\room,      x.linlin(0, 127, 0.01, 1.0)) });     // linlin - has 0
    ~apcBindParam.(\b1_d3, { |x| ~r1fx[\freeVerb].set(\size,      x.linlin(0, 127, 0.01, 5.0)) });     // linlin - has 0
};

~fxTeardown[\r1_freeVerb] = {
    ~r1fx[\freeVerb].free;
    ~r1fx[\freeVerb]    = nil;
    ~r1fx[\setFreeVerb] = nil;
    [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1].do { |k| ~lcn[k] = nil };
};

// ---- r2: combDelay → chorus (series) ----
~fxSetup[\r2_combDelay] = {
    ~r2fx[\combDelay] = ~r2.playfx({ |in| ~fxDefs[\combDelay].(in, ~r2.inbus.index) });

    ~r2fx[\setCombDelay] = { |dt, dec, maxdt|
        dt.notNil.if    { ~r2fx[\combDelay].set(\dt,    dt)    };
        maxdt.notNil.if { ~r2fx[\combDelay].set(\maxdt, maxdt) };
        dec.notNil.if   { ~r2fx[\combDelay].set(\dec,   dec)   };
    };

    ~lcn[\b1_s1_r2] = { |x| ~r2fx[\combDelay].set(\dt,   x.linlin(0, 127, 0.01, 0.4)) };
    ~lcn[\b1_s2_r2] = { |x| ~r2fx[\combDelay].set(\dec,  x.linlin(0, 127, 0.1,  4.0)) };
    ~lcn[\b1_s3_r2] = { |x| ~r2fx[\combDelay].set(\maxdt, x.linlin(0, 127, 0.01, 0.5)) };
    ~apcBindParam.(\b1_d6, { |x| ~r2fx[\combDelay].set(\dec,      x.linlin(0, 127, 0.01, 4.0)) });     // linlin - has 0
    ~apcBindParam.(\b1_d5, { |x| ~r2fx[\combDelay].set(\dt, x.linexp(0, 127, 0.01, 2.0)) });   // OK - no zeros
    // ~apcBindParam.(\b1_d7, { |x| ~r2fx[\combDelay].set(\maxdt,      x.linexp(0, 127, 0.01, 2.0)) });     // linlin - has 0
};

~fxTeardown[\r2_combDelay] = {
    ~r2fx[\combDelay].free;
    ~r2fx[\combDelay]    = nil;
    ~r2fx[\setCombDelay] = nil;
    [\b1_s1_r2, \b1_s2_r2, \b1_s3_r2].do { |k| ~lcn[k] = nil };
};

~fxSetup[\r4_chorus] = {
    ~r4fx[\chorus] = ~r4.playfx({ |in| ~fxDefs[\chorus].(in, ~r4.inbus.index) });

    ~r4fx[\setChorus] = { |rate, depth, mix|
        rate.notNil.if  { ~r4fx[\chorus].set(\rate,  rate)  };
        depth.notNil.if { ~r4fx[\chorus].set(\depth, depth) };
        mix.notNil.if   { ~r4fx[\chorus].set(\mix,   mix)   };
    };

    ~lcn[\b2_s1_r2] = { |x| ~r4fx[\chorus].set(\rate,  x.linlin(0, 127, 0.05, 5.0)) };
    ~lcn[\b2_s2_r2] = { |x| ~r4fx[\chorus].set(\depth, x.linlin(0, 127, 0.0, 0.015)) };
    ~lcn[\b2_s3_r2] = { |x| ~r4fx[\chorus].set(\mix,   x.linlin(0, 127, 0.0,  1.0)) };
};

~fxTeardown[\r4_chorus] = {
    ~r4fx[\chorus].free;
    ~r4fx[\chorus]    = nil;
    ~r4fx[\setChorus] = nil;
    [\b2_s1_r2, \b2_s2_r2, \b2_s3_r2].do { |k| ~lcn[k] = nil };
};

// ---- r3: biscuit (SynthDef-based, loaded async via fork) ----
~fxSetup[\r3_biscuit] = {
    {
        s.sync;
        ~r3fx[\biscuit] = Synth(\biscuit, [
            \in,      ~r3.inbus.index,
            \out,     ~r3.inbus.index,
            \naked,   0.0,
            \dressed, 1.0
        ], ~r3.effectgroup);

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
};

~fxTeardown[\r3_biscuit] = {
    ~r3fx[\biscuit].free;
    ~r3fx[\biscuit]    = nil;
    ~r3fx[\setBiscuit] = nil;
};

"Mixer Channel FX Defs & Setup Loaded.".postln;
)
