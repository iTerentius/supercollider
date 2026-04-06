(
// -----------------------------------------------------------------------------
// Launchpad Mini [MK3] Universal Launcher (v16)
// Adds: 8-sub-bank system via right-column buttons (CC 89→19, top→bottom)
//   Within each of the 8 top-row banks, right column selects sub-bank 1-8
//   64 total pages (8 banks × 8 sub-banks)
//   ~lpMini[\banks][0..7][0..7]  — bank → subBank → binding dict
//   ~lpMini[\bank]               — active bank index (1-8)
//   ~lpMini[\subBank]            — active sub-bank index (1-8)
//   ~lpMini[\switchBank].(n)     — switch bank, resets to subBank 1
//   ~lpMini[\switchSubBank].(n)  — switch sub-bank within current bank
//   ~lpBindSB.(bank, sub, ref, ...)  — bind to specific bank+sub-bank
//   ~lpBindB.(bank, ref, ...)        — bind to bank sub-bank 1 (back-compat)
//   ~lpBind.(ref, ...)               — bind to active bank+sub-bank (unchanged)
//   CC 91-98: bank select (top row)
//   CC 89,79,...,19: sub-bank select (right column, top→bottom = sub 1-8)
//   Stop All: removed from hardware (CC 19 is now sub-bank 8).
//             ~lpMini[\stopAll] still callable programmatically.
// -----------------------------------------------------------------------------

var pickSrcIdx, pickDest, srcIdx;

if(MIDIClient.initialized.not) { MIDIClient.init };

pickSrcIdx = {
    MIDIClient.sources.detectIndex { |ep|
        ep.device == "Launchpad Mini MK3" and: { ep.name.contains("MI") }
    }
};
pickDest = {
    MIDIClient.destinations.detect { |ep|
        ep.device == "Launchpad Mini MK3" and: { ep.name.contains("MI") }
    }
};

~lpMini = IdentityDictionary.new;
srcIdx = pickSrcIdx.();
if(srcIdx.notNil) {
    ~lpMini[\src] = MIDIClient.sources[srcIdx];
    // macOS: connected early in midi-setup.scd to avoid CoreMIDI deadlock.
    // Linux/ALSA: use targeted UID connection to avoid memory corruption / global crosstalk
    if(Platform.case(\osx, { false }, { true })) {
        MIDIIn.connect(0, ~lpMini[\src].uid);
    };
    ["[LP Mini] MIDIIn connected, found device:", ~lpMini[\src].device].postln;
} {
    ~lpMini[\src] = nil;
};
~lpMini[\dst] = pickDest.();

if (~lpMini[\src].isNil) { "CRITICAL: LP Mini MIDI not found!".warn; };

~lpMini[\out] = ~lpMini[\dst].notNil.if({ MIDIOut.newByName(~lpMini[\dst].device, ~lpMini[\dst].name) }, { nil });
~lpMini[\uid] = ~lpMini[\src].tryPerform(\uid);

// --- BANKING (1-indexed: banks 1-8, sub-banks 1-8 → 64 total pages) ---
~lpMini[\banks]    = Array.fill(8, { Array.fill(8, { IdentityDictionary.new }) });
~lpMini[\bank]     = 1;  // active bank, 1-8
~lpMini[\subBank]  = 1;  // active sub-bank, 1-8
~lpMini[\bindings] = ~lpMini[\banks][0][0];  // always points to banks[bank-1][subBank-1]
~lpMini[\ledCache] = IdentityDictionary.new;

// Right-column CCs top→bottom map to sub-banks 1-8
~lpMini[\subBankCCs] = [89, 79, 69, 59, 49, 39, 29, 19];

~lpMini[\colors] = (
    empty:            0,  pdefDefault: 9, ndefDefault: 95,
    funcDefault:      13, trigger: 21,
    bankActive:       3,  // white: selected bank / sub-bank button
    bankOff:          0,  // off: inactive bank
    subBankOccupied:  1,  // dim: sub-bank has bindings but not selected
    stopAll:          9   // amber: kept for programmatic use only
);

// --- HARDWARE CONTROL ---
~lpMini[\setProgrammerMode] = {
    if(~lpMini[\out].notNil) {
        ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    };
};

~lpMini[\clearGrid] = {
    if(~lpMini[\out].notNil) {
        fork {
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
            0.05.wait;
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
            ~lpMini[\ledCache] = IdentityDictionary.new;
            ~lpMini[\paintBankLEDs].();
            "LP Mini Grid Cleared".postln;
        }
    };
};

// --- SUB-BANK LED INDICATOR ---
// Right column (CC 89,79,...,19): active sub-bank = white, occupied = dim, empty = off
~lpMini[\paintSubBankLEDs] = {
    var sb   = ~lpMini[\subBank];
    var bIdx = ~lpMini[\bank] - 1;
    var out  = ~lpMini[\out];
    if(out.notNil) {
        ~lpMini[\subBankCCs].do { |cc, i|
            var color = if(i + 1 == sb) {
                ~lpMini[\colors][\bankActive]
            } {
                if(~lpMini[\banks][bIdx][i].size > 0) {
                    ~lpMini[\colors][\subBankOccupied]
                } { 0 }
            };
            out.control(0, cc, color);
        };
    };
};

// --- BANK LED INDICATOR ---
// Top row (CC 91-98): active bank = white, others = off; then paints sub-bank column
~lpMini[\paintBankLEDs] = {
    var b   = ~lpMini[\bank];
    var out = ~lpMini[\out];
    if(out.notNil) {
        (1..8).do { |i|
            out.control(0, 90 + i, if(i == b) { ~lpMini[\colors][\bankActive] } { ~lpMini[\colors][\bankOff] });
        };
    };
    ~lpMini[\paintSubBankLEDs].();
    "LP Mini Bank: %/8  SubBank: %/8".format(~lpMini[\bank], ~lpMini[\subBank]).postln;
};

// --- BANK SWITCH ---
// Always resets to sub-bank 1 when changing banks.
~lpMini[\switchBank] = { |newBank|
    newBank = newBank.clip(1, 8);
    ~lpMini[\bank]     = newBank;
    ~lpMini[\subBank]  = 1;
    ~lpMini[\bindings] = ~lpMini[\banks][newBank - 1][0];
    fork {
        if(~lpMini[\out].notNil) {
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
            0.05.wait;
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
        };
        ~lpMini[\ledCache] = IdentityDictionary.new;
        ~lpMini[\paintBankLEDs].();
        ~lpMini[\bindings].keysValuesDo { |note, bindData|
            ~lpMini[\paint].(note, bindData);
        };
    };
};

// --- SUB-BANK SWITCH ---
~lpMini[\switchSubBank] = { |newSubBank|
    newSubBank = newSubBank.clip(1, 8);
    ~lpMini[\subBank]  = newSubBank;
    ~lpMini[\bindings] = ~lpMini[\banks][~lpMini[\bank] - 1][newSubBank - 1];
    fork {
        if(~lpMini[\out].notNil) {
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
            0.05.wait;
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
        };
        ~lpMini[\ledCache] = IdentityDictionary.new;
        ~lpMini[\paintBankLEDs].();
        ~lpMini[\bindings].keysValuesDo { |note, bindData|
            ~lpMini[\paint].(note, bindData);
        };
    };
};

// --- STOP ALL (programmatic — no hardware button assigned in v16) ---
~lpMini[\stopAll] = {
    ~lpMini[\banks].do { |bankArr|
        bankArr.do { |subBankDict|
            subBankDict.keysValuesDo { |note, bindData|
                var obj = ~lpMini[\getObj].(bindData[\key]);
                if(obj.notNil) {
                    var isRunning = if(obj.isKindOf(NodeProxy)) { obj.isMonitoring } { obj.isPlaying };
                    if(isRunning) {
                        var q = bindData[\quant] ?? { 4 };
                        if(bindData[\onStop].notNil) {
                            bindData[\onStop].value;
                        } {
                            if(obj.respondsTo(\stopQ)) { obj.stopQ(q) } { obj.stop };
                        };
                    };
                };
            };
        };
    };
    "LP Mini: All clips stopped".postln;
};

// --- OBJECT RESOLVER ---
~lpMini[\getObj] = { |key|
    var obj;
    if(key.isKindOf(Function) or: { key.isString }) {
        obj = key;
    } {
        if(Pdef.all[key].notNil) { obj = Pdef(key) } {
            if(Tdef.all[key].notNil) { obj = Tdef(key) } {
                var proxySpace = Ndef.dictFor(Server.default);
                if(proxySpace.notNil and: { proxySpace.envir.at(key).notNil }) {
                    obj = Ndef(key)
                }
            }
        }
    };
    obj
};

// --- LED PAINTER ---
~lpMini[\paint] = { |note, bindData|
    var obj, isPlaying, color, channel, key, assignedColor;

    if (bindData.isKindOf(Event)) {
        key = bindData[\key]; assignedColor = bindData[\color];
    } {
        key = bindData; assignedColor = nil;
    };

    if(note.isInteger) {
        // --- toggleFn shortcut ---
        if(bindData.isKindOf(Event) and: { bindData[\type] == \toggleFn }) {
            var active = bindData[\isActive].value;
            channel = if(active) { 2 } { 0 };
            color   = if(active) { bindData[\colorA] } { bindData[\colorB] };
            if(~lpMini[\ledCache][note] != [channel, color]) {
                if(~lpMini[\out].notNil) {
                    ~lpMini[\out].noteOn(channel, note, color);
                    ~lpMini[\ledCache][note] = [channel, color];
                };
            };
        } {

        obj = ~lpMini[\getObj].(key);

        if(obj.isNil) {
            color = ~lpMini[\colors][\empty];
            channel = 0;
        } {
            isPlaying = false;
            if(obj.isKindOf(Pdef) or: { obj.isKindOf(EventPatternProxy) } or: { obj.isKindOf(TaskProxy) }) { isPlaying = obj.isPlaying };
            if(obj.isKindOf(NodeProxy)) { isPlaying = obj.isMonitoring };

            if(isPlaying) {
                channel = 2; // Pulse
                if(assignedColor.notNil) { color = assignedColor } {
                    if(obj.isKindOf(NodeProxy)) { color = ~lpMini[\colors][\ndefDefault] } { color = ~lpMini[\colors][\pdefDefault] };
                };
            } {
                channel = 0; // Static
                if(assignedColor.notNil) { color = assignedColor } {
                    if(obj.isKindOf(Function) or: { obj.isString }) { color = ~lpMini[\colors][\funcDefault] } {
                        if(obj.isKindOf(NodeProxy)) { color = ~lpMini[\colors][\ndefDefault] } { color = ~lpMini[\colors][\pdefDefault] };
                    };
                };
            };
        };

        if(~lpMini[\ledCache][note] != [channel, color]) {
            if(~lpMini[\out].notNil) {
                ~lpMini[\out].noteOn(channel, note, color);
                ~lpMini[\ledCache][note] = [channel, color];
            };
        };
        }; // end toggleFn else
    };
};

// --- TOGGLE HANDLER ---
~lpMini[\toggle] = { |note, bindData|
    var key = bindData[\key];
    var clock = bindData[\clock] ?? { ~link ?? { TempoClock.default } };
    var quant = bindData[\quant] ?? { 4 };

    // toggleFn: two-state function toggle
    if(bindData[\type] == \toggleFn) {
        bindData[\toggleHandler].value;
    } {

    var obj = ~lpMini[\getObj].(key);

    if(obj.notNil) {
        if(obj.isKindOf(Function)) {
            obj.value;
            if(~lpMini[\out].notNil) { ~lpMini[\out].noteOn(0, note, ~lpMini[\colors][\trigger]) };
            ~lpMini[\ledCache][note] = nil;
        } {
            if(obj.isString) {
                obj.interpret;
                if(~lpMini[\out].notNil) { ~lpMini[\out].noteOn(0, note, ~lpMini[\colors][\trigger]) };
                ~lpMini[\ledCache][note] = nil;
            } {
                var isRunning = false;
                if(obj.isKindOf(NodeProxy)) { isRunning = obj.isMonitoring } { isRunning = obj.isPlaying };

                if(isRunning) {
                    if(bindData[\onStop].notNil) {
                        bindData[\onStop].value;
                    } {
                        if(obj.respondsTo(\stopQ)) { obj.stopQ(quant) } { obj.stop };
                    };
                    "[%] Stopping: %".format(note, key).postln;
                } {
                    if(obj.isKindOf(NodeProxy)) {
                        obj.quant = quant; obj.play;
                    } {
                        obj.play(clock, quant: quant);
                    };
                    "[%] Playing: %".format(note, key).postln;
                };
            };
        };
    } {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, bindData);
    };
    }; // end toggleFn else
};

// --- GROUP LAUNCHER ---
~lpMini[\launchList] = { |noteList|
    var bindList = List.new;
    var anyPlaying = false;

    noteList.do { |n|
        var b = ~lpMini[\bindings][n];
        if(b.notNil) {
            var obj = ~lpMini[\getObj].(b[\key]);
            if(obj.notNil) {
                var running = false;
                if(obj.isKindOf(NodeProxy)) { running = obj.isMonitoring };
                if(obj.isKindOf(Pdef) or: {obj.isKindOf(Tdef)}) { running = obj.isPlaying };
                if(running) { anyPlaying = true };
                bindList.add( (note: n, bind: b, obj: obj, running: running) );
            };
        };
    };

    if(bindList.size > 0) {
        if(anyPlaying) {
            "--- Group Stop (% items) ---".format(bindList.size).postln;
            bindList.do { |item|
                if(item[\running]) {
                    var q = item[\bind][\quant] ?? { 4 };
                    if(item[\obj].respondsTo(\stopQ)) { item[\obj].stopQ(q) } { item[\obj].stop };
                };
            };
        } {
            "--- Group Play (% items) ---".format(bindList.size).postln;
            bindList.do { |item|
                var obj = item[\obj];
                if(obj.isKindOf(Function)) { obj.value; };
                if(obj.isString) { obj.interpret; };

                if(item[\running].not) {
                    var clk = item[\bind][\clock] ?? { ~link ?? { TempoClock.default } };
                    var q = item[\bind][\quant] ?? { 4 };

                    if(obj.isKindOf(NodeProxy)) {
                        obj.quant = q; obj.play;
                    } {
                        if(obj.isKindOf(Pdef) or: {obj.isKindOf(Tdef)}) {
                            obj.play(clk, quant: q);
                        };
                    };
                };
            };
        };
    };
};

// --- WATCHER ---
// Watches only the current page (bindings = active bank+subBank dict).
~lpMini[\watcher] = Routine {
    loop {
        if(~lpMini[\out].notNil) {
            ~lpMini[\bindings].keysValuesDo { |note, bindData|
                var key = bindData[\key];
                var obj = ~lpMini[\getObj].(key);
                var isRunning = false;
                var wantColor;

                if(bindData[\type] == \toggleFn) {
                    isRunning = bindData[\isActive].value;
                    wantColor = if(isRunning) { bindData[\colorA] } { bindData[\colorB] };
                } {
                    if(obj.notNil) {
                        if(obj.isKindOf(Function) or: { obj.isString }) {
                            wantColor = bindData[\color] ?? { ~lpMini[\colors][\trigger] };
                        } {
                            if(obj.isKindOf(NodeProxy)) { isRunning = obj.isMonitoring } { isRunning = obj.isPlaying };
                            wantColor = if(isRunning) { ~lpMini[\colors][\play] } { bindData[\color] ?? { ~lpMini[\colors][\stop] } };
                        };
                    } {
                        wantColor = bindData[\color] ?? { ~lpMini[\colors][\stop] };
                    };
                };

                if(~lpMini[\ledCache][note] != wantColor) {
                    ~lpMini[\paint].(note, bindData);
                };
            };
        };
        0.1.wait;
    }
}.play(AppClock);

// --- BINDING API ---
// Bind to active bank + active sub-bank (same as before).
~lpBind = { |ref, key, color=nil, clock=nil, quant=nil, onStop=nil|
    var note, storedKey;
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };

    if(key.isKindOf(Function) or: { key.isString }) { storedKey = key; } { storedKey = key.asSymbol; };

    ~lpMini[\bindings][note] = (
        key: storedKey, color: color, clock: clock, quant: quant, onStop: onStop
    );

    ~lpMini[\ledCache][note] = nil;
    ~lpMini[\paint].(note, ~lpMini[\bindings][note]);
    "LP Bound Pad % (Bank % Sub %)".format(note, ~lpMini[\bank], ~lpMini[\subBank]).postln;
};

// --- BANK-TARGETED BINDING API (back-compat: always targets sub-bank 1) ---
~lpBindB = { |bank, ref, key, color=nil, clock=nil, quant=nil, onStop=nil|
    var note, storedKey;
    bank = bank.clip(1, 8);
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };

    if(key.isKindOf(Function) or: { key.isString }) { storedKey = key; } { storedKey = key.asSymbol; };

    ~lpMini[\banks][bank - 1][0][note] = (
        key: storedKey, color: color, clock: clock, quant: quant, onStop: onStop
    );

    if(bank == ~lpMini[\bank] and: { ~lpMini[\subBank] == 1 }) {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][0][note]);
    };
    "LP Bound Pad % (Bank % Sub 1)".format(note, bank).postln;
};

// --- BANK+SUB-BANK TARGETED BINDING API ---
~lpBindSB = { |bank, subBank, ref, key, color=nil, clock=nil, quant=nil, onStop=nil|
    var note, storedKey;
    bank    = bank.clip(1, 8);
    subBank = subBank.clip(1, 8);
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };

    if(key.isKindOf(Function) or: { key.isString }) { storedKey = key; } { storedKey = key.asSymbol; };

    ~lpMini[\banks][bank - 1][subBank - 1][note] = (
        key: storedKey, color: color, clock: clock, quant: quant, onStop: onStop
    );

    if(bank == ~lpMini[\bank] and: { subBank == ~lpMini[\subBank] }) {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][subBank - 1][note]);
    };
    "LP Bound Pad % (Bank % Sub %)".format(note, bank, subBank).postln;
};

// --- TOGGLE FUNCTION BINDING API ---
// Bind to active bank + active sub-bank.
~lpBindToggleFn = { |ref, fnA, fnB, colorA = 21, colorB = 9|
    var note, active = false;
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };
    ~lpMini[\bindings][note] = (
        key: {}, type: \toggleFn,
        colorA: colorA, colorB: colorB,
        isActive: { active },
        toggleHandler: {
            active = active.not;
            if(active) { fnA.value } { fnB.value };
            ~lpMini[\ledCache][note] = nil;
            ~lpMini[\paint].(note, ~lpMini[\bindings][note]);
        }
    );
    ~lpMini[\ledCache][note] = nil;
    ~lpMini[\paint].(note, ~lpMini[\bindings][note]);
    "LP ToggleFn Bound Pad % (Bank % Sub %)".format(note, ~lpMini[\bank], ~lpMini[\subBank]).postln;
};

// Bank-targeted toggle fn (sub-bank 1, back-compat).
~lpBindBToggleFn = { |bank, ref, fnA, fnB, colorA = 21, colorB = 9|
    var note, active = false;
    bank = bank.clip(1, 8);
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };
    ~lpMini[\banks][bank - 1][0][note] = (
        key: {}, type: \toggleFn,
        colorA: colorA, colorB: colorB,
        isActive: { active },
        toggleHandler: {
            active = active.not;
            if(active) { fnA.value } { fnB.value };
            ~lpMini[\ledCache][note] = nil;
            if(bank == ~lpMini[\bank] and: { ~lpMini[\subBank] == 1 }) {
                ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][0][note]);
            };
        }
    );
    if(bank == ~lpMini[\bank] and: { ~lpMini[\subBank] == 1 }) {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][0][note]);
    };
    "LP ToggleFn Bound Pad % (Bank % Sub 1)".format(note, bank).postln;
};

// Bank+sub-bank targeted toggle fn.
~lpBindSBToggleFn = { |bank, subBank, ref, fnA, fnB, colorA = 21, colorB = 9|
    var note, active = false;
    bank    = bank.clip(1, 8);
    subBank = subBank.clip(1, 8);
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };
    ~lpMini[\banks][bank - 1][subBank - 1][note] = (
        key: {}, type: \toggleFn,
        colorA: colorA, colorB: colorB,
        isActive: { active },
        toggleHandler: {
            active = active.not;
            if(active) { fnA.value } { fnB.value };
            ~lpMini[\ledCache][note] = nil;
            if(bank == ~lpMini[\bank] and: { subBank == ~lpMini[\subBank] }) {
                ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][subBank - 1][note]);
            };
        }
    );
    if(bank == ~lpMini[\bank] and: { subBank == ~lpMini[\subBank] }) {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][subBank - 1][note]);
    };
    "LP ToggleFn Bound Pad % (Bank % Sub %)".format(note, bank, subBank).postln;
};

// --- VARIANT GROUP BINDING (radio-button: only one pad active at a time) ---
// variants: array of [ref, fn, color] — one entry per pad
// defaultIdx: which starts active (0-indexed)
// Example:
//   ~lpBindBVariants.(5, [
//       [[1, 1], ~phrFns[\v1_808k][\a], 21],
//       [[2, 1], ~phrFns[\v1_808k][\b], 9],
//   ]);
~lpBindBVariants = { |bank, variants, defaultIdx=0, colorInactive=1|
    var cur = defaultIdx;
    var notes = variants.collect { |v|
        var ref = v[0];
        if(ref.isArray) { ((9 - ref[0]) * 10) + ref[1] } { ref };
    };
    bank = bank.clip(1, 8);

    variants.do { |v, i|
        var note = notes[i];
        var fn   = v[1];
        var col  = v[2];
        ~lpMini[\banks][bank - 1][0][note] = (
            key: {}, type: \toggleFn,
            colorA: col, colorB: colorInactive,
            isActive: { cur == i },
            toggleHandler: {
                cur = i;
                fn.value;
                notes.do { |n|
                    ~lpMini[\ledCache][n] = nil;
                    if(bank == ~lpMini[\bank] and: { ~lpMini[\subBank] == 1 }) {
                        ~lpMini[\paint].(n, ~lpMini[\banks][bank - 1][0][n]);
                    };
                };
            }
        );
    };

    if(bank == ~lpMini[\bank] and: { ~lpMini[\subBank] == 1 }) {
        notes.do { |n|
            ~lpMini[\ledCache][n] = nil;
            ~lpMini[\paint].(n, ~lpMini[\banks][bank - 1][0][n]);
        };
    };
    "LP VariantGroup Bound (Bank %, % pads, default: %)".format(bank, variants.size, defaultIdx).postln;
};

// Sub-bank targeted variant group binding.
~lpBindSBVariants = { |bank, subBank, variants, defaultIdx=0, colorInactive=1|
    var cur = defaultIdx;
    var notes = variants.collect { |v|
        var ref = v[0];
        if(ref.isArray) { ((9 - ref[0]) * 10) + ref[1] } { ref };
    };
    bank    = bank.clip(1, 8);
    subBank = subBank.clip(1, 8);

    variants.do { |v, i|
        var note = notes[i];
        var fn   = v[1];
        var col  = v[2];
        ~lpMini[\banks][bank - 1][subBank - 1][note] = (
            key: {}, type: \toggleFn,
            colorA: col, colorB: colorInactive,
            isActive: { cur == i },
            toggleHandler: {
                cur = i;
                fn.value;
                notes.do { |n|
                    ~lpMini[\ledCache][n] = nil;
                    if(bank == ~lpMini[\bank] and: { subBank == ~lpMini[\subBank] }) {
                        ~lpMini[\paint].(n, ~lpMini[\banks][bank - 1][subBank - 1][n]);
                    };
                };
            }
        );
    };

    if(bank == ~lpMini[\bank] and: { subBank == ~lpMini[\subBank] }) {
        notes.do { |n|
            ~lpMini[\ledCache][n] = nil;
            ~lpMini[\paint].(n, ~lpMini[\banks][bank - 1][subBank - 1][n]);
        };
    };
    "LP VariantGroup Bound (Bank % Sub %, % pads, default: %)".format(bank, subBank, variants.size, defaultIdx).postln;
};

// --- MIDI LISTENERS ---
MIDIdef.free(\lpMini_note);
MIDIdef.free(\lpMini_cc);

if(~lpMini[\uid].notNil) {
    MIDIdef.noteOn(\lpMini_note, { |vel, note, chan, src|
        if(vel > 0) {
            var bindData = ~lpMini[\bindings][note];
            if(bindData.notNil) {
                ~lpMini[\toggle].(note, bindData);
            };
        };
    }, nil, nil, ~lpMini[\uid]);
} {
    "[LP Mini] Not connected — skipping note listener".postln;
};

if(~lpMini[\uid].notNil) {
    MIDIdef.cc(\lpMini_cc, { |val, cc, chan, src|
        var sbIdx;
        if(val > 0) {
            // 1. Bank Select (Top Buttons CC 91-98 → banks 1-8)
            if(cc >= 91 and: { cc <= 98 }) {
                ~lpMini[\switchBank].(cc - 90);
            };

            // 2. Sub-Bank Select (Right Column CC 89,79,...,19 → sub-banks 1-8)
            sbIdx = ~lpMini[\subBankCCs].indexOf(cc);
            if(sbIdx.notNil) {
                ~lpMini[\switchSubBank].(sbIdx + 1);
            };
        };
    }, nil, nil, ~lpMini[\uid]);
} {
    "[LP Mini] Not connected — skipping CC listener".postln;
};

// --- RECOVERY ---
CmdPeriod.add({
    {
        if(~lpMini[\dst].notNil) {
             ~lpMini[\out] = MIDIOut.newByName(~lpMini[\dst].device, ~lpMini[\dst].name);
             ~lpMini[\out].latency = 0;
        };
        ~lpMini[\setProgrammerMode].();
        ~lpMini[\paintBankLEDs].();
        if(~lpMini[\watcher].isPlaying.not) { ~lpMini[\watcher].reset.play(AppClock) };
        "LP Mini Refreshed".postln;
    }.defer(0.5);
});

// Paint initial bank + sub-bank LED state
~lpMini[\paintBankLEDs].();

"--- Launchpad Mini MK3 Universal Launcher Loaded (v16 + Sub-Banking 8×8 = 64 pages) ---".postln;
)
// -----------------------------------------------------------------------------
// API SUMMARY
// -----------------------------------------------------------------------------
//
// Bind to active page (bank+subBank):
//   ~lpBind.([row, col], \key, color, clock, quant, onStop)
//
// Bind to specific bank (sub-bank 1, back-compat):
//   ~lpBindB.(bank, [row, col], \key, color, clock, quant, onStop)
//
// Bind to specific bank + sub-bank:
//   ~lpBindSB.(bank, subBank, [row, col], \key, color, clock, quant, onStop)
//
// Toggle-fn variants:
//   ~lpBindToggleFn.(ref, fnA, fnB, colorA, colorB)       // active page
//   ~lpBindBToggleFn.(bank, ref, fnA, fnB, colorA, colorB)  // bank, sub 1
//   ~lpBindSBToggleFn.(bank, sub, ref, fnA, fnB, colorA, colorB)
//
// Navigation:
//   CC 91-98 (top row)           → ~lpMini[\switchBank].(1-8)   [resets to sub 1]
//   CC 89,79,...,19 (right col)  → ~lpMini[\switchSubBank].(1-8)
//   ~lpMini[\switchBank].(n)     — programmatic bank switch
//   ~lpMini[\switchSubBank].(n)  — programmatic sub-bank switch
//   ~lpMini[\bank]               — current bank (1-8)
//   ~lpMini[\subBank]            — current sub-bank (1-8)
//
// Utilities:
//   ~lpMini[\stopAll].()         — stop all running clips (all 64 pages)
//   ~lpMini[\clearGrid].()       — clear display, repaint current page + LEDs
//   ~lpMini[\launchList].(notes) — group play/stop by note list (current page)
//
// Layout convention (suggested):
//   Columns = voices/tracks (stay within one column across sub-banks)
//   Sub-bank overflow: col 9+ wraps to col 1+ on next sub-bank of same bank
//   Right column: lit white = current sub-bank, dim = has bindings, off = empty
