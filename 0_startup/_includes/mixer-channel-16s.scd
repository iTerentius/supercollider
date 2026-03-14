// 2025-10-29 consolidated mixer include. master, tracks, returns, fx wiring, nil safe helpers
// Controller bindings are conditional - only applied if the controller is present
(

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

// Per-return fx dictionaries — populated by ~fxSetup calls
~r1fx = (); ~r2fx = (); ~r3fx = (); ~r4fx = ();
~fxSetup[\r1_greyhole].value;
~fxSetup[\r2_combDelay].value;
~fxSetup[\r3_biscuit].value;
~fxSetup[\r4_chorus].value;

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

// ~inlineFXmk: single helper closure — keeps outer block FD count low (SC 255-entry limit)
~inlineFXmk = { |ch, sym|
    ~inlineFX[sym] = ch.playfx({ |in|
        var sig = In.ar(ch.inbus.index, 2);
        HPF.ar(LPF.ar(sig, \lpfreq.kr(18000)), \hpfreq.kr(40))
    });
};

~inlineFX !? { |d| d.do { |fx| fx.tryPerform(\free) } };
~inlineFX = IdentityDictionary.new;

// Tracks
~inlineFXmk.(~t1, \t1);   ~inlineFXmk.(~t2, \t2);   ~inlineFXmk.(~t3, \t3);   ~inlineFXmk.(~t4, \t4);
~inlineFXmk.(~t5, \t5);   ~inlineFXmk.(~t6, \t6);   ~inlineFXmk.(~t7, \t7);   ~inlineFXmk.(~t8, \t8);
~inlineFXmk.(~t9, \t9);   ~inlineFXmk.(~t10, \t10); ~inlineFXmk.(~t11, \t11); ~inlineFXmk.(~t12, \t12);
// Returns
~inlineFXmk.(~r1, \r1);   ~inlineFXmk.(~r2, \r2);   ~inlineFXmk.(~r3, \r3);   ~inlineFXmk.(~r4, \r4);
// Perc submix + sub-channels
~inlineFXmk.(~perc, \perc);
~inlineFXmk.(~pbd1, \pbd1); ~inlineFXmk.(~pbd2, \pbd2);
~inlineFXmk.(~psd1, \psd1); ~inlineFXmk.(~psd2, \psd2);
~inlineFXmk.(~phh1, \phh1); ~inlineFXmk.(~phh2, \phh2);
~inlineFXmk.(~pcp1, \pcp1); ~inlineFXmk.(~pcp2, \pcp2);
~inlineFXmk.(~ptm1, \ptm1); ~inlineFXmk.(~ptm2, \ptm2); ~inlineFXmk.(~ptm3, \ptm3);
~inlineFXmk.(~pcr1, \pcr1); ~inlineFXmk.(~pcr2, \pcr2);
~inlineFXmk.(~pex1, \pex1); ~inlineFXmk.(~pex2, \pex2);
~inlineFXmk = nil;  // release helper

// ~apcMixBind: per-strip helper — 4 bindings (f/r1/r2/r3), pan optional
// Keeps if-block literal count low (SC ~127-entry per-function limit)
~apcMixBind = { |bank, strip, chan, sym, pan = true|
    var b = "b" ++ bank ++ "_s" ++ strip;
    ~apcBindParam.((b ++ "_f").asSymbol,  { |x| chan.level_(x) });
    if(pan) { ~apcBindParam.((b ++ "_r1").asSymbol, { |x| chan.pan_(x.linlin(0, 1, -1, 1)) }) };
    ~apcBindParam.((b ++ "_r2").asSymbol, { |x| ~inlineFX[sym].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.((b ++ "_r3").asSymbol, { |x| ~inlineFX[sym].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
};

// ~toscMixBind: TouchOSC equivalent — values already 0.0-1.0 from TOSC faders/knobs
// TOSC page = bank, column = strip. Addresses: /tosc/b{n}/s{n}/f|r1|r2|r3
~toscMixBind = { |bank, strip, chan, sym|
    var b = "tosc/b" ++ bank ++ "/s" ++ strip;
    ~oscParam[(b ++ "/f").asSymbol]  = { |x| chan.level_(x) };
    ~oscParam[(b ++ "/r1").asSymbol] = { |x| ~inlineFX[sym].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000)) };
    ~oscParam[(b ++ "/r2").asSymbol] = { |x| ~inlineFX[sym].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000)) };
    ~oscParam[(b ++ "/r3").asSymbol] = { |x| chan.pan_(x.linlin(0, 1, -1, 1)) };
};

// ~toscMixSync: push current state for one strip to TOSC + populate ~oscState.
// Reads chan.level / chan.pan; HPF/LPF use SC default Hz converted to normalized 0-1.
// Does NOT fire callbacks — avoids /n_set on synths that may not be alive yet.
// Call after default levels are set. Also useful mid-session to resync a strip.
~toscMixSync = { |bank, strip, chan|
    var b = "tosc/b" ++ bank ++ "/s" ++ strip;
    var push = { |addr, val|
        ~oscState[addr] = val;
        ~toscAddr.sendMsg("/" ++ addr.asString, val);
    };
    push.((b ++ "/f").asSymbol,  chan.level.clip(0, 1));
    push.((b ++ "/r3").asSymbol, chan.pan.linlin(-1, 1, 0, 1));
    push.((b ++ "/r1").asSymbol, 40.0.explin(20.0, 2000.0, 0.001, 1.0));    // HPF 40 Hz
    push.((b ++ "/r2").asSymbol, 18000.0.explin(200.0, 20000.0, 0.001, 1.0)); // LPF 18 kHz
};

// ~lcxlMixBind: analogous helper for LCXL (CC 0-127, exponential mapping)
~lcxlMixBind = { |bank, strip, chan, sym|
    var b = "b" ++ bank ++ "_s" ++ strip;
    ~lcxlParam[(b ++ "_f").asSymbol]  = { |x| chan.level_(x.linlin(0, 127, 0.0, 1.0)) };
    ~lcxlParam[(b ++ "_r1").asSymbol] = { |x| ~inlineFX[sym].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000)) };
    ~lcxlParam[(b ++ "_r2").asSymbol] = { |x| ~inlineFX[sym].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000)) };
    ~lcxlParam[(b ++ "_r3").asSymbol] = { |x| chan.pan_(x.linlin(0, 127, -1, 1)) };
};

// ================= CONTROLLER BINDINGS (conditional) =================

// ---- APC40 mkII bindings ----
if(~apcBindParam.notNil) {
    "Binding APC40 mkII controls...".postln;

    ~apcBindParam.(\master_f, { |x| ~m1.level_(x) });

    // Bank 0: Tracks 1-8
    ~apcMixBind.(0, 1, ~t1, \t1);  ~apcMixBind.(0, 2, ~t2, \t2);
    ~apcMixBind.(0, 3, ~t3, \t3);  ~apcMixBind.(0, 4, ~t4, \t4);
    ~apcMixBind.(0, 5, ~t5, \t5);  ~apcMixBind.(0, 6, ~t6, \t6);
    ~apcMixBind.(0, 7, ~t7, \t7);  ~apcMixBind.(0, 8, ~t8, \t8);

    // Bank 1: Tracks 9-12, Returns 1-2 (returns: no pan)
    ~apcMixBind.(1, 1, ~t9,  \t9);   ~apcMixBind.(1, 2, ~t10, \t10);
    ~apcMixBind.(1, 3, ~t11, \t11);  ~apcMixBind.(1, 4, ~t12, \t12);
    ~apcMixBind.(1, 5, ~r1, \r1, false);
    ~apcMixBind.(1, 6, ~r2, \r2, false);

    "APC40 mkII bindings complete (banks 0-1).".postln;
} {
    "APC40 mkII not detected, skipping bindings.".postln;
};

// ---- APC40 mkII bindings (perc banks 2-3) ----
if(~apcBindParam.notNil) {

    // Bank 2: Perc submix + sub-channels
    ~apcMixBind.(2, 1, ~perc, \perc);  ~apcMixBind.(2, 2, ~pbd1, \pbd1);
    ~apcMixBind.(2, 3, ~pbd2, \pbd2);  ~apcMixBind.(2, 4, ~psd1, \psd1);
    ~apcMixBind.(2, 5, ~psd2, \psd2);  ~apcMixBind.(2, 6, ~phh1, \phh1);
    ~apcMixBind.(2, 7, ~phh2, \phh2);  ~apcMixBind.(2, 8, ~pcp1, \pcp1);

    // Bank 3: Remaining perc sub-channels
    ~apcMixBind.(3, 1, ~pcp2, \pcp2);  ~apcMixBind.(3, 2, ~ptm1, \ptm1);
    ~apcMixBind.(3, 3, ~ptm2, \ptm2);  ~apcMixBind.(3, 4, ~ptm3, \ptm3);
    ~apcMixBind.(3, 5, ~pcr1, \pcr1);  ~apcMixBind.(3, 6, ~pcr2, \pcr2);
    ~apcMixBind.(3, 7, ~pex1, \pex1);  ~apcMixBind.(3, 8, ~pex2, \pex2);

    "APC40 mkII bindings complete (banks 2-3).".postln;
} {
    "APC40 mkII not detected, skipping bindings.".postln;
};

// ---- Launch Control XL bindings ----
if(~lcxlParam.notNil) {
    "Binding Launch Control XL controls...".postln;

    // Bank 1: Tracks 1-8
    ~lcxlMixBind.(1, 1, ~t1, \t1);  ~lcxlMixBind.(1, 2, ~t2, \t2);
    ~lcxlMixBind.(1, 3, ~t3, \t3);  ~lcxlMixBind.(1, 4, ~t4, \t4);
    ~lcxlMixBind.(1, 5, ~t5, \t5);  ~lcxlMixBind.(1, 6, ~t6, \t6);
    ~lcxlMixBind.(1, 7, ~t7, \t7);  ~lcxlMixBind.(1, 8, ~t8, \t8);

    // Bank 2: Tracks 9-12, Returns 1-4
    ~lcxlMixBind.(2, 1, ~t9,  \t9);   ~lcxlMixBind.(2, 2, ~t10, \t10);
    ~lcxlMixBind.(2, 3, ~t11, \t11);  ~lcxlMixBind.(2, 4, ~t12, \t12);
    ~lcxlMixBind.(2, 5, ~r1,  \r1);   ~lcxlMixBind.(2, 6, ~r2,  \r2);
    ~lcxlMixBind.(2, 7, ~r3,  \r3);   ~lcxlMixBind.(2, 8, ~r4,  \r4);

    "Launch Control XL bindings complete (banks 1-2).".postln;
};

// ---- Launch Control XL bindings (perc banks 3-4) ----
if(~lcxlParam.notNil) {

    // Bank 3: Perc submix + sub-channels
    ~lcxlMixBind.(3, 1, ~perc, \perc);  ~lcxlMixBind.(3, 2, ~pbd1, \pbd1);
    ~lcxlMixBind.(3, 3, ~pbd2, \pbd2);  ~lcxlMixBind.(3, 4, ~psd1, \psd1);
    ~lcxlMixBind.(3, 5, ~psd2, \psd2);  ~lcxlMixBind.(3, 6, ~phh1, \phh1);
    ~lcxlMixBind.(3, 7, ~phh2, \phh2);  ~lcxlMixBind.(3, 8, ~pcp1, \pcp1);

    // Bank 4: Remaining perc sub-channels
    ~lcxlMixBind.(4, 1, ~pcp2, \pcp2);  ~lcxlMixBind.(4, 2, ~ptm1, \ptm1);
    ~lcxlMixBind.(4, 3, ~ptm2, \ptm2);  ~lcxlMixBind.(4, 4, ~ptm3, \ptm3);
    ~lcxlMixBind.(4, 5, ~pcr1, \pcr1);  ~lcxlMixBind.(4, 6, ~pcr2, \pcr2);
    ~lcxlMixBind.(4, 7, ~pex1, \pex1);  ~lcxlMixBind.(4, 8, ~pex2, \pex2);

    // Bank 8: Master on strip 8
    ~lcxlParam[\b8_s8_f] = { |x| ~m1.level_(x.linlin(0, 127, 0.0, 4.0)) };

    "Launch Control XL bindings complete (banks 3-4).".postln;
};

// ---- TouchOSC bindings ----
if(~oscParam.notNil) {
    "Binding TouchOSC controls...".postln;

    ~oscParam['tosc/master/f'] = { |x| ~m1.level_(x.linlin(0, 1, 0.0, 4.0)) };

    // Bank 1: Tracks 1-8
    ~toscMixBind.(1, 1, ~t1, \t1);  ~toscMixBind.(1, 2, ~t2, \t2);
    ~toscMixBind.(1, 3, ~t3, \t3);  ~toscMixBind.(1, 4, ~t4, \t4);
    ~toscMixBind.(1, 5, ~t5, \t5);  ~toscMixBind.(1, 6, ~t6, \t6);
    ~toscMixBind.(1, 7, ~t7, \t7);  ~toscMixBind.(1, 8, ~t8, \t8);

    // Bank 2: Tracks 9-12, Returns 1-4
    ~toscMixBind.(2, 1, ~t9,  \t9);   ~toscMixBind.(2, 2, ~t10, \t10);
    ~toscMixBind.(2, 3, ~t11, \t11);  ~toscMixBind.(2, 4, ~t12, \t12);
    ~toscMixBind.(2, 5, ~r1,  \r1);   ~toscMixBind.(2, 6, ~r2,  \r2);
    ~toscMixBind.(2, 7, ~r3,  \r3);   ~toscMixBind.(2, 8, ~r4,  \r4);

    "TouchOSC bindings complete (banks 1-2).".postln;
};

// ---- TouchOSC bindings (perc banks 3-4) ----
if(~oscParam.notNil) {

    // Bank 3: Perc submix + sub-channels
    ~toscMixBind.(3, 1, ~perc, \perc);  ~toscMixBind.(3, 2, ~pbd1, \pbd1);
    ~toscMixBind.(3, 3, ~pbd2, \pbd2);  ~toscMixBind.(3, 4, ~psd1, \psd1);
    ~toscMixBind.(3, 5, ~psd2, \psd2);  ~toscMixBind.(3, 6, ~phh1, \phh1);
    ~toscMixBind.(3, 7, ~phh2, \phh2);  ~toscMixBind.(3, 8, ~pcp1, \pcp1);

    // Bank 4: Remaining perc sub-channels
    ~toscMixBind.(4, 1, ~pcp2, \pcp2);  ~toscMixBind.(4, 2, ~ptm1, \ptm1);
    ~toscMixBind.(4, 3, ~ptm2, \ptm2);  ~toscMixBind.(4, 4, ~ptm3, \ptm3);
    ~toscMixBind.(4, 5, ~pcr1, \pcr1);  ~toscMixBind.(4, 6, ~pcr2, \pcr2);
    ~toscMixBind.(4, 7, ~pex1, \pex1);  ~toscMixBind.(4, 8, ~pex2, \pex2);

    "TouchOSC bindings complete (banks 3-4).".postln;
};

~apcMixBind = nil;
~lcxlMixBind = nil;
~toscMixBind = nil;

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

// ================= TOUCHOSC INITIAL SYNC =================
// Push default mixer state to TOSC so faders show correct positions on startup.
if(~toscSend.notNil) {
    ~oscState['tosc/master/f'] = ~m1.level.linlin(0, 4, 0, 1);
    ~toscAddr.sendMsg("/tosc/master/f", ~oscState['tosc/master/f']);

    // Bank 1: Tracks 1-8
    ~toscMixSync.(1, 1, ~t1);  ~toscMixSync.(1, 2, ~t2);
    ~toscMixSync.(1, 3, ~t3);  ~toscMixSync.(1, 4, ~t4);
    ~toscMixSync.(1, 5, ~t5);  ~toscMixSync.(1, 6, ~t6);
    ~toscMixSync.(1, 7, ~t7);  ~toscMixSync.(1, 8, ~t8);

    // Bank 2: Tracks 9-12, Returns 1-4
    ~toscMixSync.(2, 1, ~t9);   ~toscMixSync.(2, 2, ~t10);
    ~toscMixSync.(2, 3, ~t11);  ~toscMixSync.(2, 4, ~t12);
    ~toscMixSync.(2, 5, ~r1);   ~toscMixSync.(2, 6, ~r2);
    ~toscMixSync.(2, 7, ~r3);   ~toscMixSync.(2, 8, ~r4);

    // Bank 3: Perc submix + sub-channels
    ~toscMixSync.(3, 1, ~perc);  ~toscMixSync.(3, 2, ~pbd1);
    ~toscMixSync.(3, 3, ~pbd2);  ~toscMixSync.(3, 4, ~psd1);
    ~toscMixSync.(3, 5, ~psd2);  ~toscMixSync.(3, 6, ~phh1);
    ~toscMixSync.(3, 7, ~phh2);  ~toscMixSync.(3, 8, ~pcp1);

    // Bank 4: Remaining perc sub-channels
    ~toscMixSync.(4, 1, ~pcp2);  ~toscMixSync.(4, 2, ~ptm1);
    ~toscMixSync.(4, 3, ~ptm2);  ~toscMixSync.(4, 4, ~ptm3);
    ~toscMixSync.(4, 5, ~pcr1);  ~toscMixSync.(4, 6, ~pcr2);
    ~toscMixSync.(4, 7, ~pex1);  ~toscMixSync.(4, 8, ~pex2);

    "TouchOSC: initial mixer state synced.".postln;
};

"Mixer channels initialized.".postln;
)
