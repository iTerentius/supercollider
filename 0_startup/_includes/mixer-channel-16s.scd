// 2025-10-29 consolidated mixer include. master, tracks, returns, fx wiring, nil safe helpers
// Controller bindings are conditional - only applied if the controller is present
(
var chan;  // declare vars at top

// ---- Safe binding helpers (call only if controller functions exist) ----
~safeBind = { |bindFunc, key, func|
    if(bindFunc.notNil) {
        bindFunc.(key, func);
    };
};

// helper. resolve bus index from a MixerChannel safely
~busOf = { |chan|
    if(chan.notNil and: { chan.respondsTo(\inbus) }) { chan.inbus.index } { 0 }
};

// ================= MIXER CHANNELS =================

// master
~m1.tryPerform(\free);
~m1 = MixerChannel.new(\m1, s, 2, 2, outbus: 0);

// tracks. all outbus -> master inbus
~t1  = MixerChannel.new(\t1,  s, 2, 2, outbus: ~m1.inbus);
~t2  = MixerChannel.new(\t2,  s, 2, 2, outbus: ~m1.inbus);
~t3  = MixerChannel.new(\t3,  s, 2, 2, outbus: ~m1.inbus);
~t4  = MixerChannel.new(\t4,  s, 2, 2, outbus: ~m1.inbus);
~t5  = MixerChannel.new(\t5,  s, 2, 2, outbus: ~m1.inbus);
~t6  = MixerChannel.new(\t6,  s, 2, 2, outbus: ~m1.inbus);
~t7  = MixerChannel.new(\t7,  s, 2, 2, outbus: ~m1.inbus);
~t8  = MixerChannel.new(\t8,  s, 2, 2, outbus: ~m1.inbus);
~t9  = MixerChannel.new(\t9,  s, 2, 2, outbus: ~m1.inbus);
~t10 = MixerChannel.new(\t10, s, 2, 2, outbus: ~m1.inbus);
~t11 = MixerChannel.new(\t11, s, 2, 2, outbus: ~m1.inbus);
~t12 = MixerChannel.new(\t12, s, 2, 2, outbus: ~m1.inbus);

// returns. all outbus -> master inbus
~r1.tryPerform(\free);
~r2.tryPerform(\free);
~r3.tryPerform(\free);
~r4.tryPerform(\free);

~r1 = MixerChannel.new(\r1, s, 2, 2, outbus: ~m1.inbus);
~r2 = MixerChannel.new(\r2, s, 2, 2, outbus: ~m1.inbus);
~r3 = MixerChannel.new(\r3, s, 2, 2, outbus: ~m1.inbus);
~r4 = MixerChannel.new(\r4, s, 2, 2, outbus: ~m1.inbus);

// r1 reverb. read bus explicitly and return wet. do not call Out or ReplaceOut here
~r1_fx = ~r1.playfx({ |in|
    var sig, wet;
    sig = In.ar(~r1.inbus.index, 2);
    wet = FreeVerb2.ar(sig[0], sig[1], \mix.kr(1.0), \room.kr(0.8), \damp.kr(0.2));
    wet
});

// r2 delay. same pattern
~r2_fx = ~r2.playfx({ |in|
    var sig, wet;
    sig = In.ar(~r2.inbus.index, 2);
    wet = CombL.ar(sig, maxdelaytime: \maxdt.kr(0.4), delaytime: \dt.kr(0.25), decaytime: \dec.kr(0.6));
    wet
});

// setters – pass nil to skip a param
// playfx is async so bus mapping at init time is unreliable; .set on the synth works
~setR1 = { |mix, room, damp|
    mix.notNil.if  { ~r1_fx.set(\mix,  mix)  };
    room.notNil.if { ~r1_fx.set(\room, room) };
    damp.notNil.if { ~r1_fx.set(\damp, damp) };
};
~setR2 = { |dt, dec, maxdt |
    dt.notNil.if  { ~r2_fx.set(\dt,  dt)  };
    dt.notNil.if  { ~r2_fx.set(\maxdt, maxdt)  };
    dec.notNil.if { ~r2_fx.set(\dec, dec) };
};

// r3 biscuit. fork + s.sync ensures \biscuit SynthDef has reached server before Synth()
{
    s.sync;
    ~r3_fx = Synth(\biscuit, [
        \in,      ~r3.inbus.index,
        \out,     ~r3.inbus.index,
        \naked,   0.0,
        \dressed, 1.0
    ], ~r3.effectgroup);
}.fork;
~setR3 = { |drive, clock, bits, fxMode, shape, filterFreq, filterQ, naked, dressed|
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

// submix example. perc feeds t1
~perc = MixerChannel.new(\perc, s, 2, 2, outbus: ~t1.inbus);
~pbd1 = MixerChannel.new(\pbd1, s, 2, 2, outbus: ~perc.inbus);
~pbd2 = MixerChannel.new(\pbd2, s, 2, 2, outbus: ~perc.inbus);
~psd1 = MixerChannel.new(\psd1, s, 2, 2, outbus: ~perc.inbus);
~psd2 = MixerChannel.new(\psd2, s, 2, 2, outbus: ~perc.inbus);
~phh1 = MixerChannel.new(\phh1, s, 2, 2, outbus: ~perc.inbus);
~phh2 = MixerChannel.new(\phh2, s, 2, 2, outbus: ~perc.inbus);
~pcp1 = MixerChannel.new(\pcp1, s, 2, 2, outbus: ~perc.inbus);
~pcp2 = MixerChannel.new(\pcp2, s, 2, 2, outbus: ~perc.inbus);
~ptm1 = MixerChannel.new(\ptm1, s, 2, 2, outbus: ~perc.inbus);
~ptm2 = MixerChannel.new(\ptm2, s, 2, 2, outbus: ~perc.inbus);
~ptm3 = MixerChannel.new(\ptm3, s, 2, 2, outbus: ~perc.inbus);
~pcr1 = MixerChannel.new(\pcr1, s, 2, 2, outbus: ~perc.inbus);
~pcr2 = MixerChannel.new(\pcr2, s, 2, 2, outbus: ~perc.inbus);
~pex1 = MixerChannel.new(\pex1, s, 2, 2, outbus: ~perc.inbus);
~pex2 = MixerChannel.new(\pex2, s, 2, 2, outbus: ~perc.inbus);

// convenience. create or replace a post send from any track to any return
~ensurePostSend = { |fromChan, toChan, level = 0.0|
    var h;
    if(fromChan.notNil and: { toChan.notNil }) {
        h = fromChan.newPostSend(toChan, level);
    }{
        h = nil;
    };
    h
};

// ================= INLINE FILTERS (HPF + LPF per channel) =================
// HPF default 40 Hz, LPF default 18 kHz — both transparent at startup.
// APC40: knob row 2 (Sends) = HPF 20 Hz–2 kHz, row 3 (User) = LPF 200 Hz–20 kHz
// LCXL:  knob row r1 (top)  = HPF,              row r2 (mid) = LPF

~inlineFX !? { |d| d.do { |fx| fx.tryPerform(\free) } };
~inlineFX = IdentityDictionary.new;

~inlineFX[\t1]   = ~t1.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t1.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t2]   = ~t2.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t2.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t3]   = ~t3.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t3.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t4]   = ~t4.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t4.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t5]   = ~t5.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t5.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t6]   = ~t6.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t6.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t7]   = ~t7.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t7.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t8]   = ~t8.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t8.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t9]   = ~t9.playfx({   |in| HPF.ar(LPF.ar(In.ar(~t9.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t10]  = ~t10.playfx({  |in| HPF.ar(LPF.ar(In.ar(~t10.inbus.index,  2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t11]  = ~t11.playfx({  |in| HPF.ar(LPF.ar(In.ar(~t11.inbus.index,  2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\t12]  = ~t12.playfx({  |in| HPF.ar(LPF.ar(In.ar(~t12.inbus.index,  2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\r1]   = ~r1.playfx({   |in| HPF.ar(LPF.ar(In.ar(~r1.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\r2]   = ~r2.playfx({   |in| HPF.ar(LPF.ar(In.ar(~r2.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\r3]   = ~r3.playfx({   |in| HPF.ar(LPF.ar(In.ar(~r3.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\r4]   = ~r4.playfx({   |in| HPF.ar(LPF.ar(In.ar(~r4.inbus.index,   2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\perc] = ~perc.playfx({ |in| HPF.ar(LPF.ar(In.ar(~perc.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pbd1] = ~pbd1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pbd1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pbd2] = ~pbd2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pbd2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\psd1] = ~psd1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~psd1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\psd2] = ~psd2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~psd2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\phh1] = ~phh1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~phh1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\phh2] = ~phh2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~phh2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pcp1] = ~pcp1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pcp1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pcp2] = ~pcp2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pcp2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\ptm1] = ~ptm1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~ptm1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\ptm2] = ~ptm2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~ptm2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\ptm3] = ~ptm3.playfx({ |in| HPF.ar(LPF.ar(In.ar(~ptm3.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pcr1] = ~pcr1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pcr1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pcr2] = ~pcr2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pcr2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pex1] = ~pex1.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pex1.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });
~inlineFX[\pex2] = ~pex2.playfx({ |in| HPF.ar(LPF.ar(In.ar(~pex2.inbus.index, 2), \lpfreq.kr(18000)), \hpfreq.kr(40)) });

// ================= CONTROLLER BINDINGS (conditional) =================

// ---- APC40 mkII bindings ----
if(~apcBindParam.notNil) {
    "Binding APC40 mkII controls...".postln;

    // Master fader
    ~apcBindParam.(\master_f, { |x| ~m1.level_(x) });

    // Bank 0: Tracks 1-8 (faders + pan + HPF + LPF)
    ~apcBindParam.(\b0_s1_f,  { |x| ~t1.level_(x) });
    ~apcBindParam.(\b0_s1_r1, { |x| ~t1.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s1_r2, { |x| ~inlineFX[\t1].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s1_r3, { |x| ~inlineFX[\t1].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s2_f,  { |x| ~t2.level_(x) });
    ~apcBindParam.(\b0_s2_r1, { |x| ~t2.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s2_r2, { |x| ~inlineFX[\t2].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s2_r3, { |x| ~inlineFX[\t2].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s3_f,  { |x| ~t3.level_(x) });
    ~apcBindParam.(\b0_s3_r1, { |x| ~t3.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s3_r2, { |x| ~inlineFX[\t3].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s3_r3, { |x| ~inlineFX[\t3].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s4_f,  { |x| ~t4.level_(x) });
    ~apcBindParam.(\b0_s4_r1, { |x| ~t4.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s4_r2, { |x| ~inlineFX[\t4].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s4_r3, { |x| ~inlineFX[\t4].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s5_f,  { |x| ~t5.level_(x) });
    ~apcBindParam.(\b0_s5_r1, { |x| ~t5.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s5_r2, { |x| ~inlineFX[\t5].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s5_r3, { |x| ~inlineFX[\t5].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s6_f,  { |x| ~t6.level_(x) });
    ~apcBindParam.(\b0_s6_r1, { |x| ~t6.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s6_r2, { |x| ~inlineFX[\t6].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s6_r3, { |x| ~inlineFX[\t6].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s7_f,  { |x| ~t7.level_(x) });
    ~apcBindParam.(\b0_s7_r1, { |x| ~t7.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s7_r2, { |x| ~inlineFX[\t7].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s7_r3, { |x| ~inlineFX[\t7].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b0_s8_f,  { |x| ~t8.level_(x) });
    ~apcBindParam.(\b0_s8_r1, { |x| ~t8.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b0_s8_r2, { |x| ~inlineFX[\t8].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b0_s8_r3, { |x| ~inlineFX[\t8].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });

    // Bank 1: Tracks 9-12 + Returns 1-2 (faders + pan + HPF + LPF)
    ~apcBindParam.(\b1_s1_f,  { |x| ~t9.level_(x) });
    ~apcBindParam.(\b1_s1_r1, { |x| ~t9.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b1_s1_r2, { |x| ~inlineFX[\t9].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b1_s1_r3, { |x| ~inlineFX[\t9].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b1_s2_f,  { |x| ~t10.level_(x) });
    ~apcBindParam.(\b1_s2_r1, { |x| ~t10.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b1_s2_r2, { |x| ~inlineFX[\t10].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b1_s2_r3, { |x| ~inlineFX[\t10].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b1_s3_f,  { |x| ~t11.level_(x) });
    ~apcBindParam.(\b1_s3_r1, { |x| ~t11.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b1_s3_r2, { |x| ~inlineFX[\t11].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b1_s3_r3, { |x| ~inlineFX[\t11].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b1_s4_f,  { |x| ~t12.level_(x) });
    ~apcBindParam.(\b1_s4_r1, { |x| ~t12.pan_(x.linlin(0, 1, -1, 1)) });
    ~apcBindParam.(\b1_s4_r2, { |x| ~inlineFX[\t12].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b1_s4_r3, { |x| ~inlineFX[\t12].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b1_s5_f,  { |x| ~r1.level_(x) });
    ~apcBindParam.(\b1_s5_r2, { |x| ~inlineFX[\r1].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b1_s5_r3, { |x| ~inlineFX[\r1].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
    ~apcBindParam.(\b1_s6_f,  { |x| ~r2.level_(x) });
    ~apcBindParam.(\b1_s6_r2, { |x| ~inlineFX[\r2].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.(\b1_s6_r3, { |x| ~inlineFX[\r2].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });

    "APC40 mkII bindings complete.".postln;
} {
    "APC40 mkII not detected, skipping bindings.".postln;
};

// ---- Launch Control XL bindings ----
if(~lcxlParam.notNil) {
    "Binding Launch Control XL controls...".postln;

    // Bank 1: Tracks 1-8 (faders + HPF + LPF + pan)
    ~lcxlParam[\b1_s1_f]  = { |x| ~t1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s1_r1] = { |x| ~inlineFX[\t1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s1_r2] = { |x| ~inlineFX[\t1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s1_r3] = { |x| ~t1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s2_f]  = { |x| ~t2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s2_r1] = { |x| ~inlineFX[\t2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s2_r2] = { |x| ~inlineFX[\t2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s2_r3] = { |x| ~t2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s3_f]  = { |x| ~t3.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s3_r1] = { |x| ~inlineFX[\t3].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s3_r2] = { |x| ~inlineFX[\t3].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s3_r3] = { |x| ~t3.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s4_f]  = { |x| ~t4.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s4_r1] = { |x| ~inlineFX[\t4].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s4_r2] = { |x| ~inlineFX[\t4].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s4_r3] = { |x| ~t4.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s5_f]  = { |x| ~t5.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s5_r1] = { |x| ~inlineFX[\t5].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s5_r2] = { |x| ~inlineFX[\t5].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s5_r3] = { |x| ~t5.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s6_f]  = { |x| ~t6.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s6_r1] = { |x| ~inlineFX[\t6].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s6_r2] = { |x| ~inlineFX[\t6].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s6_r3] = { |x| ~t6.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s7_f]  = { |x| ~t7.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s7_r1] = { |x| ~inlineFX[\t7].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s7_r2] = { |x| ~inlineFX[\t7].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s7_r3] = { |x| ~t7.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b1_s8_f]  = { |x| ~t8.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b1_s8_r1] = { |x| ~inlineFX[\t8].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b1_s8_r2] = { |x| ~inlineFX[\t8].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b1_s8_r3] = { |x| ~t8.pan_(x.linlin(0, 127, -1, 1)) };

    // Bank 2: Tracks 9-12, Returns 1-4 (faders + HPF + LPF + pan)
    ~lcxlParam[\b2_s1_f]  = { |x| ~t9.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s1_r1] = { |x| ~inlineFX[\t9].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s1_r2] = { |x| ~inlineFX[\t9].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s1_r3] = { |x| ~t9.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s2_f]  = { |x| ~t10.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s2_r1] = { |x| ~inlineFX[\t10].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s2_r2] = { |x| ~inlineFX[\t10].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s2_r3] = { |x| ~t10.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s3_f]  = { |x| ~t11.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s3_r1] = { |x| ~inlineFX[\t11].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s3_r2] = { |x| ~inlineFX[\t11].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s3_r3] = { |x| ~t11.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s4_f]  = { |x| ~t12.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s4_r1] = { |x| ~inlineFX[\t12].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s4_r2] = { |x| ~inlineFX[\t12].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s4_r3] = { |x| ~t12.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s5_f]  = { |x| ~r1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s5_r1] = { |x| ~inlineFX[\r1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s5_r2] = { |x| ~inlineFX[\r1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s5_r3] = { |x| ~r1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s6_f]  = { |x| ~r2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s6_r1] = { |x| ~inlineFX[\r2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s6_r2] = { |x| ~inlineFX[\r2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s6_r3] = { |x| ~r2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s7_f]  = { |x| ~r3.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s7_r1] = { |x| ~inlineFX[\r3].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s7_r2] = { |x| ~inlineFX[\r3].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s7_r3] = { |x| ~r3.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b2_s8_f]  = { |x| ~r4.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b2_s8_r1] = { |x| ~inlineFX[\r4].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b2_s8_r2] = { |x| ~inlineFX[\r4].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b2_s8_r3] = { |x| ~r4.pan_(x.linlin(0, 127, -1, 1)) };

    // Bank 3: Perc submix + perc sub-channels (faders + HPF + LPF + pan)
    ~lcxlParam[\b3_s1_f]  = { |x| ~perc.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s1_r1] = { |x| ~inlineFX[\perc].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s1_r2] = { |x| ~inlineFX[\perc].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s1_r3] = { |x| ~perc.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s2_f]  = { |x| ~pbd1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s2_r1] = { |x| ~inlineFX[\pbd1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s2_r2] = { |x| ~inlineFX[\pbd1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s2_r3] = { |x| ~pbd1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s3_f]  = { |x| ~pbd2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s3_r1] = { |x| ~inlineFX[\pbd2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s3_r2] = { |x| ~inlineFX[\pbd2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s3_r3] = { |x| ~pbd2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s4_f]  = { |x| ~psd1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s4_r1] = { |x| ~inlineFX[\psd1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s4_r2] = { |x| ~inlineFX[\psd1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s4_r3] = { |x| ~psd1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s5_f]  = { |x| ~psd2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s5_r1] = { |x| ~inlineFX[\psd2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s5_r2] = { |x| ~inlineFX[\psd2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s5_r3] = { |x| ~psd2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s6_f]  = { |x| ~phh1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s6_r1] = { |x| ~inlineFX[\phh1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s6_r2] = { |x| ~inlineFX[\phh1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s6_r3] = { |x| ~phh1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s7_f]  = { |x| ~phh2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s7_r1] = { |x| ~inlineFX[\phh2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s7_r2] = { |x| ~inlineFX[\phh2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s7_r3] = { |x| ~phh2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b3_s8_f]  = { |x| ~pcp1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b3_s8_r1] = { |x| ~inlineFX[\pcp1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b3_s8_r2] = { |x| ~inlineFX[\pcp1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b3_s8_r3] = { |x| ~pcp1.pan_(x.linlin(0, 127, -1, 1)) };

    // Bank 4: Remaining perc sub-channels (faders + HPF + LPF + pan)
    ~lcxlParam[\b4_s1_f]  = { |x| ~pcp2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s1_r1] = { |x| ~inlineFX[\pcp2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s1_r2] = { |x| ~inlineFX[\pcp2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s1_r3] = { |x| ~pcp2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s2_f]  = { |x| ~ptm1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s2_r1] = { |x| ~inlineFX[\ptm1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s2_r2] = { |x| ~inlineFX[\ptm1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s2_r3] = { |x| ~ptm1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s3_f]  = { |x| ~ptm2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s3_r1] = { |x| ~inlineFX[\ptm2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s3_r2] = { |x| ~inlineFX[\ptm2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s3_r3] = { |x| ~ptm2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s4_f]  = { |x| ~ptm3.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s4_r1] = { |x| ~inlineFX[\ptm3].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s4_r2] = { |x| ~inlineFX[\ptm3].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s4_r3] = { |x| ~ptm3.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s5_f]  = { |x| ~pcr1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s5_r1] = { |x| ~inlineFX[\pcr1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s5_r2] = { |x| ~inlineFX[\pcr1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s5_r3] = { |x| ~pcr1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s6_f]  = { |x| ~pcr2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s6_r1] = { |x| ~inlineFX[\pcr2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s6_r2] = { |x| ~inlineFX[\pcr2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s6_r3] = { |x| ~pcr2.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s7_f]  = { |x| ~pex1.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s7_r1] = { |x| ~inlineFX[\pex1].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s7_r2] = { |x| ~inlineFX[\pex1].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s7_r3] = { |x| ~pex1.pan_(x.linlin(0, 127, -1, 1)) };
    ~lcxlParam[\b4_s8_f]  = { |x| ~pex2.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[\b4_s8_r1] = { |x| ~inlineFX[\pex2].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[\b4_s8_r2] = { |x| ~inlineFX[\pex2].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[\b4_s8_r3] = { |x| ~pex2.pan_(x.linlin(0, 127, -1, 1)) };

    // Bank 8: Master on strip 8
    ~lcxlParam[\b8_s8_f]  = { |x| ~m1.level_(x.linlin(0, 127, 0.0, 4.0)) };

    "Launch Control XL bindings complete.".postln;
};

// ================= DEFAULT LEVELS =================

~m1.level_(4.0);
~t1.level_(1.0);
~t2.level_(1.0);
~t3.level_(1.0);
~t4.level_(1.0);
~t5.level_(1.0);
~t6.level_(1.0);
~t7.level_(1.0);
~t8.level_(1.0);
~t9.level_(1.0);
~t10.level_(1.0);
~t11.level_(1.0);
~t12.level_(1.0);
~perc.level_(1.0);
~r1.level_(0.6);
~r2.level_(0.6);
~r3.level_(0.6);
~r4.level_(0.6);

"Mixer channels initialized.".postln;
)
