/* 2025-10-19 add-on — device knobs CC (per bank) with boot + panic auto-arm */
/* 2026-03-22 — device sub-bank: Record Arm buttons (note 48, ch 0-7) select
                sub-bank for the 8 device knobs. Mirrors main bank (note 50, ch 0-7).
   Key format: b{mainBank-1}_ds{devSubBank}_k{knob1..8}
   e.g. b0_ds1_k1, b0_ds2_k3, b7_ds8_k8 */
/* single () block, vars at top, no ) in comments */

(
var ensureID, norm7;
ensureID = { |sym| if(currentEnvironment.at(sym).isNil) { currentEnvironment.put(sym, IdentityDictionary.new) } };
ensureID.(\apcParamBindings);

~apcDevCCBase     = ~apcDevCCBase     ? 16;   /* CC16..23 = device knobs k1..8 */
~apcDevCCCount    = ~apcDevCCCount    ? 8;
~apcDevSubBank    = ~apcDevSubBank    ? 1;     /* active device sub-bank 1-8 */
~apcDevSubBtnNote = ~apcDevSubBtnNote ? 48;   /* Record Arm: note 48, ch 0-7 */

/* Key: b{mainBank-1}_ds{devSubBank}_k{knob} */
~apcParamKeyForDevice = { |bank, sub, knob|
    ("b" ++ bank.clip(0,7) ++ "_ds" ++ sub.clip(1,8) ++ "_k" ++ knob.clip(1,8)).asSymbol
};

norm7 = { |v| (v.asFloat.clip(0, 127)) / 127.0 };

/* ---- Sub-bank LED painter ---- */
~apcPaintDevSubBank = {
    var onColor, offColor, note;
    note     = ~apcDevSubBtnNote;
    onColor  = ~apcColors[\green] ? 21;
    offColor = ~apcColors[\off]   ? 0;
    8.do { |i|
        var c = if((i + 1) == ~apcDevSubBank) { onColor } { offColor };
        ~apcPadLEDch.(note, c, i);
        AppClock.sched(0.03, { ~apcPadLEDch.(note, c, i) });
    };
};

/* ---- Change device sub-bank ---- */
~apcChangeDevSubBank = { |n|
    ~apcDevSubBank = n.clip(1, 8);
    ~apcPaintDevSubBank.();
    ["[DEV SUBBANK]", ~apcDevSubBank].postln;
};

/* ---- Sub-bank button listener (note 48, ch 0-7) ---- */
~apcInstallDevSubBankButtons = {
    var nameOn, nameOff, note;
    nameOn = \apc_dev_subbank_on; nameOff = \apc_dev_subbank_off;
    note = ~apcDevSubBtnNote;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        if(num == note and: { chan >= 0 } and: { chan <= 7 } and: { vel > 0 }) {
            ~apcChangeDevSubBank.(chan + 1);
        };
    }, nil, nil, ~apcMidiUID);
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(num == note and: { chan >= 0 } and: { chan <= 7 }) {
            ~apcPaintDevSubBank.();
        };
    }, nil, nil, ~apcMidiUID);
    "[dev sub-bank buttons armed (note 48, ch 0-7)]".postln; true
};

/* ---- Device knob CC listener ---- */
~apcInstallDevKnobCC = {
    var name, base, count;
    name = \apc_dev_knobs_cc; base = ~apcDevCCBase; count = ~apcDevCCCount;
    MIDIdef.free(name);
    MIDIdef.cc(name, { |val, num, chan, src|
        var idx, knob, key, x, f;
        if((num >= base) and: { num < (base + count) }) {
            idx  = num - base;
            knob = idx + 1;
            key  = ~apcParamKeyForDevice.(~apcBank - 1, ~apcDevSubBank, knob);
            x    = norm7.(val);
            if(~apcApplyParam.notNil) {
                ~apcApplyParam.(key, x);
            } {
                f = ~apcParamBindings[key];
                if(f.notNil) { f.value(x) };
            };
        };
    });
    "[device knob CC armed]".postln; true
};

/* ---- Boot ---- */
~apcInstallDevKnobCC.();
~apcInstallDevSubBankButtons.();
~apcPaintDevSubBank.();

/* ---- CmdPeriod + StartUp hooks ---- */
CmdPeriod.remove(~apcDevKnobPanicHook);
~apcDevKnobPanicHook = {
    AppClock.sched(0.0, {
        ~apcInstallDevKnobCC.();
        ~apcInstallDevSubBankButtons.();
        ~apcPaintDevSubBank.();
        nil
    });
};
CmdPeriod.add(~apcDevKnobPanicHook);

StartUp.remove(~apcDevKnobStartHook);
~apcDevKnobStartHook = { ~apcInstallDevKnobCC.(); ~apcInstallDevSubBankButtons.() };
StartUp.add(~apcDevKnobStartHook);

("[dev knob key sample] " ++ ~apcParamKeyForDevice.(0, 2, 3)).postln;
)
