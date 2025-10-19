/* 2025-10-19 11:14 — apc_param_router v2b: banks via small buttons (note 50 ch0..7), faders CC7 ch0..7, master CC14 ch0 */
/* rules: single () block, declare vars at top of funcs, no ) in comments */

(
/* ---------- normalize shared params ---------- */
var tmp, colorsDict;
colorsDict = IdentityDictionary[\off -> 0, \amber -> 126, \green -> 21];

if(~apcParam.isNil) {
    ~apcParam = IdentityDictionary.new;
} {
    if(~apcParam.isKindOf(IdentityDictionary).not) {
        tmp = IdentityDictionary.new;
        ~apcParam.keysValuesDo { |k, v| tmp[k] = v };
        ~apcParam = tmp;
    };
};
if(~apcParam[\colors].isNil)    { ~apcParam[\colors] = colorsDict };
if(~apcParam[\gridChan].isNil)  { ~apcParam[\gridChan] = 0 };

/* ---------- state ---------- */
~apcBank            = ~apcBank            ? 0;                       // 0..7
~apcParamBindings   = ~apcParamBindings   ? IdentityDictionary.new;  // \bN_sM_f or \master_f -> Function

/* bank select small buttons: all are note 50 on channels 0..7 */
~apcBankBtnNote     = ~apcBankBtnNote     ? 50;
~apcBankBtnChans    = ~apcBankBtnChans    ? (0..7);

/* faders: strips 1..8 are CC 7 on channels 0..7, master is CC 14 on channel 0 */
~apcStripFaderCC    = ~apcStripFaderCC    ? 7;
~apcMasterFaderCC   = ~apcMasterFaderCC   ? 14;
~apcMasterFaderChan = ~apcMasterFaderChan ? 0;

/* ---------- utils ---------- */
~apcParamKeyFor = { |bank, strip|
    var b, s;
    b = bank.clip(0, 7);
    s = strip.clip(1, 8);
    ("b" ++ b ++ "_s" ++ s ++ "_f").asSymbol
};

~apcBindParam = { |key, func|
    var f; f = func;
    ~apcParamBindings[key] = f;
    ["[apcBindParam] bound", key].postln;
};

~apcApplyParam = { |key, x|
    var f; f = ~apcParamBindings[key];
    if(f.notNil) { f.value(x) } { ["[apcApplyParam] no binding for", key].postln };
};

~apcNorm7 = { |val| (val.asFloat.clip(0, 127)) / 127.0 };

/* LED helpers on a specific channel */
~apcPadLEDch = ~apcPadLEDch ? { |note, color, chan|
    var out;
    out = ~apcOut ?? { ~apcForceAPCOut !? { ~apcForceAPCOut.() } };
    if(out.notNil) { out.latency = 0.0; out.noteOn(chan, note, color) };
};

/* ---------- bank button LED paint ---------- */
~apcPaintBankBtn = { |bankIdx|
    var colors, want, chan;
    colors = ~apcParam[\colors];
    chan = bankIdx.clip(0, 7);
    want = (bankIdx == ~apcBank).if(colors[\green], colors[\amber]);
    ~apcPadLEDch.(~apcBankBtnNote, want, chan);
    AppClock.sched(0.03, { ~apcPadLEDch.(~apcBankBtnNote, want, chan) });
};

~apcPaintAllBanks = {
    0.until(8, { |i| ~apcPaintBankBtn.(i) });
};

/* ---------- bank switch listener (press latch, ignore release) ---------- */
~apcInstallBankButtons = {
    var nameOn, nameOff, note, chans;
    nameOn = \apc_bank_on; nameOff = \apc_bank_off;
    note = ~apcBankBtnNote; chans = ~apcBankBtnChans;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);

    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var idx;
        if(num == note and: { chans.includes(chan) }) {
            if(vel > 0) {
                idx = chan;    // channel selects bank
                ~apcBank = idx;
                "[APC PARAM] bank -> b".post; ~apcBank.postln;
                ~apcPaintAllBanks.();
            }{
                ~apcPaintBankBtn.(chan);
            };
        };
    });

    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(num == note and: { chans.includes(chan) }) {
            ~apcPaintBankBtn.(chan);
        };
    });

    "[APC PARAM] bank button listener armed".postln;
    true
};

/* ---------- fader CC handler ---------- */
~apcInstallFaderCC = {
    var name, stripCC, masterCC, masterCh;
    name = \apc_faders_cc;
    stripCC = ~apcStripFaderCC;
    masterCC = ~apcMasterFaderCC;
    masterCh = ~apcMasterFaderChan;
    MIDIdef.free(name);

    MIDIdef.cc(name, { |val, num, chan, src|
        var x, stripIdx, key;
        if(num == masterCC and: { chan == masterCh }) {
            x = ~apcNorm7.(val);
            ~apcApplyParam.(\master_f, x);
            ^nil;
        };
        if(num == stripCC and: { chan >= 0 } and: { chan <= 7 }) {
            stripIdx = chan + 1;                     // chan 0..7 → strip 1..8
            key = ~apcParamKeyFor.(~apcBank, stripIdx);
            x = ~apcNorm7.(val);
            ~apcApplyParam.(key, x);
        };
    });

    "[APC PARAM] Fader CC listener armed".postln;
    true
};

/* ---------- setup helpers ---------- */
~apcParamInstall = {
    ~apcInstallBankButtons.();
    ~apcInstallFaderCC.();
    ~apcPaintAllBanks.();
    "[APC PARAM] installed".postln;
    true
};

~apcParamRepaint = {
    ~apcPaintAllBanks.();
    "[APC PARAM] bank LEDs repainted".postln;
    true
};

/* ---------- example bindings ----------
~apcBindParam.(\b0_s1_f, { |x| ~t1.level_(x) });
~apcBindParam.(\b0_s2_f, { |x| ~t2.level_(x) });
~apcBindParam.(\b1_s1_f, { |x| ~t9.level_(x) });     // same strip on bank 1
~apcBindParam.(\master_f, { |x| ~master.level_(x) });
*/
)

