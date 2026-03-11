(
// =============================================================================
// Helpers
// =============================================================================

// --- FX Send Toggle Tdef ---
// Creates a Tdef that toggles a post-send on/off, suitable for single-pad
// LP Mini / APC40 bindings with LED state tracking via isPlaying.
//
// SC gotcha: protect{} does NOT fire on thread kill (stop/stopQ is a hard
// primitive kill). The while+flag pattern lets the Tdef exit naturally so
// cleanup runs. Pass the returned stopper as onStop to ~lpBind.
//
// Usage:
//   ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1);
//   ~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~fxSendStop[\bd1_fx_1]);
//
//   // or inline (makeFxSendTdef returns the stopper):
//   ~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1));
//
// ~fxSendStop[name] — stopper dict, accessible for rebinding or other use

~fxSendStop = IdentityDictionary.new;

~makeFxSendTdef = { |name, src, ret, level=1|
    var flag = false, node = nil;
    var stopper = { flag = false };

    Tdef(name, {
        protect {
            flag = true;
            node.tryPerform(\free);
            node = ~ensurePostSend.(src, ret, level);
            while { flag } { 0.2.wait };
        } {
            node.tryPerform(\free);
            node = nil;
            flag = false;
        }
    });

    ~fxSendStop[name] = stopper;
    stopper
};

// In your helpers file
~fxDefs = ();
~fxSetters = ();
~fxSetup = ();
~fxTeardown = ();

~fxDefs[\combDelay] = { |in, bus|
    var sig = In.ar(bus, 2);
    CombL.ar(sig,
        maxdelaytime: \maxdt.kr(0.4),
        delaytime: \dt.kr(0.25),
        decaytime: \dec.kr(0.6)
    )
};

~fxDefs[\freeVerb] = { |in, bus|
    var sig = In.ar(bus, 2);
    FreeVerb2.ar(sig[0], sig[1],
        mix: \mix.kr(0.33),
        room: \room.kr(0.5),
        damp: \damp.kr(0.5)
    )
};

~fxDefs[\greyhole] = {|in, bus|
  var sig, wet;
  sig = In.ar(bus,  2);
  wet = Greyhole.ar(
    sig,
    \delayTime.kr(2.0),  
    \damp.kr(0.0),  
    \size.kr(3.0),  
    \diff.kr(0.707),  
    \feedback.kr(0.1),  
    \modDepth.kr(0.1),  
    \modFreq.kr(2.0),  
  );
  wet;
};

~fxSetup[\r1_freeverb] = {
  ~r1fx[\r1_freeverb] = ~r1.playfx(~fxDefs[\freeverb]);

  ~r1fx[\setFreeverb] = { |mix, room, damp|
      mix.notNil.if  { ~r1fx.set(\mix,  mix)  };
      room.notNil.if { ~r1fx.set(\room, room) };
      damp.notNil.if { ~r1fx.set(\damp, damp) };
  };
  ~lcn[\b1_s1_r1] = { |x| ~r1fx.set(\mix, x.linlin(0, 127, 0.1, 10.0)) };
  ~lcn[\b1_s2_r1] = { |x| ~r1fx.set(\room,x.linlin(0, 127, 0.0, 1.0)) };
  ~lcn[\b1_s3_r1] = { |x| ~r1fx.set(\damp,x.linlin(0, 127, 0.0, 5.0)) };
}; 

~fxTeardown[\r1_freeverb] = {
  ~r1fx[\freeverb].free;
  ~r1fx[\freeverb] = nil;
  ~r1fx[\setFreeverb] = nil;
  [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1].do { |k|
      ~lcn[k] = nil;
  };
}

~fxSetup[\r1_greyhole] = {
    ~r1fx[\greyhole] = ~r1.playfx(~fxDefs[\greyhole]);

    ~r1fx[\setGreyhole] = { |delayTime, damp, size, diff, feedback, modDepth, modFreq|
        delayTime.notNil.if { ~r1fx[\greyhole].set(\delayTime, delayTime) };
        damp.notNil.if      { ~r1fx[\greyhole].set(\damp,      damp) };
        size.notNil.if      { ~r1fx[\greyhole].set(\size,      size) };
        diff.notNil.if      { ~r1fx[\greyhole].set(\diff,      diff) };
        feedback.notNil.if  { ~r1fx[\greyhole].set(\feedback,  feedback) };
        modDepth.notNil.if  { ~r1fx[\greyhole].set(\modDepth,  modDepth) };
        modFreq.notNil.if   { ~r1fx[\greyhole].set(\modFreq,   modFreq) };
    };

    ~lcn[\b1_s1_r1] = { |x| ~r1fx.set(\delayTime, x.linlin(0, 127, 0.1, 10.0)) };
    ~lcn[\b1_s2_r1] = { |x| ~r1fx.set(\damp,      x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s3_r1] = { |x| ~r1fx.set(\size,      x.linlin(0, 127, 0.0, 5.0)) };
    ~lcn[\b1_s4_r1] = { |x| ~r1fx.set(\diff,      x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s5_r1] = { |x| ~r1fx.set(\feedback,  x.linlin(0, 127, 0.0, 1.0)) };
    ~lcn[\b1_s1_r2] = { |x| ~r1fx.set(\modDepth,  x.linlin(0, 127, 0.0, 1.0)) };
};

~fxTeardown[\r1_greyhole] = {
    ~r1fx[\greyhole].free;
    ~r1fx[\greyhole] = nil;
    ~r1fx[\setGreyhole] = nil;
    [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1, \b1_s4_r1, \b1_s5_r1, \b1_s1_r2, \b1_s2_r2].do { |k|
        ~lcn[k] = nil;
    };
};

~fxSetup[\r2_combDelay] = {|in,  bus|
  ~r2fx[\combDelay] = ~r2.playfx(~fxDefs[\combDelay]);
  ~r2fx[\setCombDelay] = { |dt, dec, maxdt |
    dt.notNil.if  { ~r2fx.set(\dt,  dt)  };
    maxdt.notNil.if  { ~r2fx.set(\maxdt, maxdt)  };
    dec.notNil.if { ~r2fx.set(\dec, dec) };
  };
};

~fxTeardown[\r2_combDelay] = {
    ~r1fx[\combDelay].free;
    ~r1fx[\combDelay] = nil;
    ~r1fx[\setCombDelay] = nil;
    // [\b1_s1_r1, \b1_s2_r1, \b1_s3_r1, \b1_s4_r1, \b1_s5_r1, \b1_s1_r2, \b1_s2_r2].do { |k|
    //     ~lcn[k] = nil;
    // };
};

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
          drive.notNil.if      { ~r3_fx.set(\drive,      drive)      };
          clock.notNil.if      { ~r3_fx.set(\clock,      clock)      };
          bits.notNil.if       { ~r3_fx.set(\bits,       bits)       };
          fxMode.notNil.if     { ~r3_fx.set(\fxMode,     fxMode)     };
          shape.notNil.if      { ~r3_fx.set(\shape,      shape)      };
          filterFreq.notNil.if { ~r3_fx.set(\filterFreq, filterFreq) };
          filterQ.notNil.if    { ~r3_fx.set(\filterQ,    filterQ)    };
          naked.notNil.if      { ~r3_fx.set(\naked,      naked)      };
          dressed.notNil.if    { ~r3_fx.set(\dressed,    dressed)    };
      };

        // controller bindings here if needed
        // ~lcn[\b1_s1_r3] = { |x| ~r3fx[\biscuit].set(\naked, x.linlin(0, 127, 0.0, 1.0)) };
    }.fork;
};

~fxTeardown[\r3_biscuit] = {
    ~r3fx[\biscuit].free;
    ~r3fx[\biscuit] = nil;
    ~r3fx[\setBiscuit] = nil;
    ~lcn[\b1_s1_r3] = nil;
};

"Helpers loaded.".postln;
)


