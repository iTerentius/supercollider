// Inline HPF + LPF per channel
// APC40: knob row 2 (Sends button) = HPF, row 3 (User button) = LPF
// LCXL:  knob row r1 (top)         = HPF, row r2 (middle)     = LPF
// Defaults: HPF=40Hz (transparent rumble cut), LPF=18kHz (transparent air cut)
(
var makeFilt = { |chan, sym|
    var bus = chan.inbus;  // captured here — playfx Function does not pass in to the SynthDef
    ~inlineFX[sym] = chan.playfx({ |in|
        var sig = In.ar(bus, 2);
        HPF.ar(LPF.ar(sig, \lpfreq.kr(18000)), \hpfreq.kr(40))
    });
    ["[InlineFX] filter on", sym].postln;
};

// Free previous instances on re-eval
~inlineFX !? { |d| d.do { |fx| fx.tryPerform(\free) } };
~inlineFX = IdentityDictionary.new;

// Tracks
makeFilt.(~t1,  \t1);  makeFilt.(~t2,  \t2);  makeFilt.(~t3,  \t3);  makeFilt.(~t4,  \t4);
makeFilt.(~t5,  \t5);  makeFilt.(~t6,  \t6);  makeFilt.(~t7,  \t7);  makeFilt.(~t8,  \t8);
makeFilt.(~t9,  \t9);  makeFilt.(~t10, \t10); makeFilt.(~t11, \t11); makeFilt.(~t12, \t12);

// Returns
makeFilt.(~r1, \r1);  makeFilt.(~r2, \r2);  makeFilt.(~r3, \r3);  makeFilt.(~r4, \r4);

// Perc submix + sub-channels
makeFilt.(~perc, \perc);
makeFilt.(~pbd1, \pbd1); makeFilt.(~pbd2, \pbd2);
makeFilt.(~psd1, \psd1); makeFilt.(~psd2, \psd2);
makeFilt.(~phh1, \phh1); makeFilt.(~phh2, \phh2);
makeFilt.(~pcp1, \pcp1); makeFilt.(~pcp2, \pcp2);
makeFilt.(~ptm1, \ptm1); makeFilt.(~ptm2, \ptm2); makeFilt.(~ptm3, \ptm3);
makeFilt.(~pcr1, \pcr1); makeFilt.(~pcr2, \pcr2);
makeFilt.(~pex1, \pex1); makeFilt.(~pex2, \pex2);

// ---- APC40: row 2 = HPF (20 Hz–2 kHz), row 3 = LPF (200 Hz–20 kHz) ----
if(~apcBindParam.notNil) {
    // Bank 0 (APC physical bank 1): strips 1–8 → ~t1 through ~t8
    8.do { |i|
        var strip = i + 1;
        var sym = ("t" ++ strip).asSymbol;
        ~apcBindParam.(~apcParamKeyForKnob.(0, strip, 2), { |x|
            ~inlineFX[sym].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000))
        });
        ~apcBindParam.(~apcParamKeyForKnob.(0, strip, 3), { |x|
            ~inlineFX[sym].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000))
        });
    };
    // Bank 1 (APC physical bank 2): strips 1–4 → ~t9 through ~t12
    4.do { |i|
        var strip = i + 1;
        var sym = ("t" ++ (i + 9)).asSymbol;
        ~apcBindParam.(~apcParamKeyForKnob.(1, strip, 2), { |x|
            ~inlineFX[sym].tryPerform(\set, \hpfreq, x.linexp(0.001, 1.0, 20, 2000))
        });
        ~apcBindParam.(~apcParamKeyForKnob.(1, strip, 3), { |x|
            ~inlineFX[sym].tryPerform(\set, \lpfreq, x.linexp(0.001, 1.0, 200, 20000))
        });
    };
    "[InlineFX] APC40 bindings registered (r2=HPF, r3=LPF).".postln;
};

// ---- LCXL: r1 = HPF, r2 = LPF (CC 0–127, exponential mapping) ----
if(~lcxlParam.notNil) {
    // Bank 1: strips 1–8 → ~t1 through ~t8
    8.do { |i|
        var strip = i + 1;
        var sym = ("t" ++ strip).asSymbol;
        ~lcxlParam[("b1_s" ++ strip ++ "_r1").asSymbol] = { |x|
            ~inlineFX[sym].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000))
        };
        ~lcxlParam[("b1_s" ++ strip ++ "_r2").asSymbol] = { |x|
            ~inlineFX[sym].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000))
        };
    };
    // Bank 2: strips 1–4 → ~t9 through ~t12
    4.do { |i|
        var strip = i + 1;
        var sym = ("t" ++ (i + 9)).asSymbol;
        ~lcxlParam[("b2_s" ++ strip ++ "_r1").asSymbol] = { |x|
            ~inlineFX[sym].tryPerform(\set, \hpfreq, x.clip(1, 127).linexp(1, 127, 20, 2000))
        };
        ~lcxlParam[("b2_s" ++ strip ++ "_r2").asSymbol] = { |x|
            ~inlineFX[sym].tryPerform(\set, \lpfreq, x.clip(1, 127).linexp(1, 127, 200, 20000))
        };
    };
    "[InlineFX] LCXL bindings registered (r1=HPF, r2=LPF).".postln;
};

"[InlineFX] HPF+LPF filters loaded on all channels.".postln;
)
