/* 2025-10-19 add-on — device knobs CC (per bank) with boot + panic auto-arm */
/* single () block, vars at top, no ) in comments */

(
var ensureID, norm7;
ensureID = { |sym| if(currentEnvironment.at(sym).isNil) { currentEnvironment.put(sym, IdentityDictionary.new) } };
ensureID.(\apcParamBindings);

~apcDevCCBase  = ~apcDevCCBase  ? 16;   /* CC16..23 map to d1..8 */
~apcDevCCCount = ~apcDevCCCount ? 8;

/* helper: \b{bank}_d{1..8} */
~apcParamKeyForDevice = { |bank, dev|
    var b, d;
    b = bank.clip(0, 7);
    d = dev.clip(1, 8);
    ("b" ++ b ++ "_d" ++ d).asSymbol
};

/* tiny utils */
norm7 = { |v| (v.asFloat.clip(0, 127)) / 127.0 };

/* install or re-install the CC listener */
~apcInstallDevKnobCC = {
    var name, base, count;
    name = \apc_dev_knobs_cc;
    base = ~apcDevCCBase;
    count = ~apcDevCCCount;

    MIDIdef.free(name);
    MIDIdef.cc(name, { |val, num, chan, src|
        var idx, dev, key, x, bankNow, f;
        if((num >= base) and: { num < (base + count) }) {
            idx = num - base;       /* 0..7 */
            dev = idx + 1;          /* 1..8 */
            bankNow = ~apcBank ? 0; /* fall back to 0 if not set yet */
            key = ~apcParamKeyForDevice.(bankNow, dev);
            x = norm7.(val);

            if(~apcApplyParam.notNil) {
                ~apcApplyParam.(key, x);
            }{
                f = ~apcParamBindings[key];
                if(f.notNil) { f.value(x) };
            };

            /* uncomment for verbose logging
            ["[DEV CC]", "cc", num, "dev", dev, "bank", bankNow, "x", x.round(0.001)].postln;
            */
        };
    });

    "[device knob CC armed]".postln; true
};

/* arm now */
~apcInstallDevKnobCC.();

/* add a dedicated CmdPeriod hook just for this listener */
CmdPeriod.remove(~apcDevKnobPanicHook);
~apcDevKnobPanicHook = {
    AppClock.sched(0.0, { ~apcInstallDevKnobCC.(); nil });
};
CmdPeriod.add(~apcDevKnobPanicHook);

/* also re-arm after library recompile */
StartUp.remove(~apcDevKnobStartHook);
~apcDevKnobStartHook = { ~apcInstallDevKnobCC.() };
StartUp.add(~apcDevKnobStartHook);

/* optional tiny self-check */
if(~apcParamKeyForDevice.notNil) { ("[dev binding key sample] " ++ ~apcParamKeyForDevice.(0, 3)).postln };
)

