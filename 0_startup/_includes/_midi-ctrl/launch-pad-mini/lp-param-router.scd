(
// -----------------------------------------------------------------------------
// Launchpad Mini [MK3] Universal Launcher (v15)
// Adds: 8-bank system via Left (CC 93) / Right (CC 94) top buttons
//   - ~lpMini[\banks][0..7]  — per-bank binding dicts
//   - ~lpMini[\bank]         — active bank index
//   - ~lpMini[\switchBank]   — switch banks, clears grid, repaints LEDs
//   - ~lpBindB.(bank, ...)   — bind to a specific bank
//   - ~lpBind.(...)          — binds to active bank (unchanged API)
//   CC 93/94 intercepted; column launch remains on 91,92,95-98
// -----------------------------------------------------------------------------

var pickSrcIdx, pickDest, srcIdx;

if(MIDIClient.initialized.not) { MIDIClient.init };

pickSrcIdx = {
    MIDIClient.sources.detectIndex { |ep|
        ep.device == "Launchpad Mini MK3" and: { ep.name.contains("MIDI") }
    }
};
pickDest = {
    MIDIClient.destinations.detect { |ep|
        ep.device == "Launchpad Mini MK3" and: { ep.name.contains("MIDI") }
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

// --- BANKING (1-indexed: banks 1-8) ---
~lpMini[\banks]    = Array.fill(8, { IdentityDictionary.new });
~lpMini[\bank]     = 1;  // active bank, 1-8
~lpMini[\bindings] = ~lpMini[\banks][0];  // banks[bank-1]
~lpMini[\ledCache] = IdentityDictionary.new;
~lpMini[\stopAllLedCache] = nil;

~lpMini[\colors] = (
    empty:       0, pdefDefault: 9, ndefDefault: 95,
    funcDefault: 13, trigger: 21,
    bankActive:  3,   // white: selected bank
    bankOff:     0,   // off: inactive bank
    stopAll:     9    // amber: stop-all indicator
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

// --- BANK LED INDICATOR ---
// Lights Left (CC 93) / Right (CC 94) top buttons to show navigation availability
~lpMini[\paintBankLEDs] = {
    var b = ~lpMini[\bank];
    var out = ~lpMini[\out];
    if(out.notNil) {
        (1..8).do { |i|
            out.control(0, 90 + i, if(i == b) { ~lpMini[\colors][\bankActive] } { ~lpMini[\colors][\bankOff] });
        };
    };
    "LP Mini Bank: %/8".format(b).postln;
};

// --- BANK SWITCH ---
~lpMini[\switchBank] = { |newBank|
    newBank = newBank.clip(1, 8);
    ~lpMini[\bank]     = newBank;
    ~lpMini[\bindings] = ~lpMini[\banks][newBank - 1];
    fork {
        if(~lpMini[\out].notNil) {
            // Clear grid: live mode then back to programmer
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
            0.05.wait;
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
        };
        ~lpMini[\ledCache] = IdentityDictionary.new;  // watcher repaints new bank
        ~lpMini[\paintBankLEDs].();
    };
};

// --- STOP ALL ---
~lpMini[\stopAll] = {
    ~lpMini[\banks].do { |bankDict|
        bankDict.keysValuesDo { |note, bindData|
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
~lpMini[\watcher] = Routine {
    loop {
        if(~lpMini[\out].notNil) {
            var anyPlaying = false;
            var wantStopAllColor;
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

                // Only paint if state changed
                if(~lpMini[\ledCache][note] != wantColor) {
                    ~lpMini[\paint].(note, bindData);
                };
            };

            // Handle Stop All Button LED
            ~lpMini[\banks].do { |bankDict|
                bankDict.do { |bData|
                    if(anyPlaying.not and: { bData[\type] != \toggleFn }) {
                        var o = ~lpMini[\getObj].(bData[\key]);
                        if(o.notNil and: { o.isKindOf(Function).not }) {
                            if(o.isKindOf(NodeProxy)) {
                                if(o.isMonitoring) { anyPlaying = true }
                            } {
                                if(o.isPlaying) { anyPlaying = true }
                            };
                        };
                    };
                };
            };

            // Only send if state changed
            wantStopAllColor = if(anyPlaying) { ~lpMini[\colors][\stopAll] } { 0 };
            if(~lpMini[\stopAllLedCache] != wantStopAllColor) {
                ~lpMini[\out].control(0, 19, wantStopAllColor);
                ~lpMini[\stopAllLedCache] = wantStopAllColor;
            };
        };
        0.1.wait;
    }
}.play(AppClock);

// --- BINDING API ---
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
    "LP Bound Pad % (Bank %)".format(note, ~lpMini[\bank]).postln;
};

// --- BANK-TARGETED BINDING API ---
// Bind to a specific bank regardless of active bank.
~lpBindB = { |bank, ref, key, color=nil, clock=nil, quant=nil, onStop=nil|
    var note, storedKey;
    bank = bank.clip(1, 8);
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };

    if(key.isKindOf(Function) or: { key.isString }) { storedKey = key; } { storedKey = key.asSymbol; };

    ~lpMini[\banks][bank - 1][note] = (
        key: storedKey, color: color, clock: clock, quant: quant, onStop: onStop
    );

    // Only update display if this is the active bank
    if(bank == ~lpMini[\bank]) {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][note]);
    };
    "LP Bound Pad % (Bank %)".format(note, bank).postln;
};

// --- TOGGLE FUNCTION BINDING API ---
// Two-state toggle: press once → fnA + colorA (pulsing); press again → fnB + colorB (static)
// colorA/colorB are LP Mini palette indices (integers).
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
    "LP ToggleFn Bound Pad % (Bank %)".format(note, ~lpMini[\bank]).postln;
};

// Bank-targeted version of ~lpBindToggleFn.
~lpBindBToggleFn = { |bank, ref, fnA, fnB, colorA = 21, colorB = 9|
    var note, active = false;
    bank = bank.clip(1, 8);
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };
    ~lpMini[\banks][bank - 1][note] = (
        key: {}, type: \toggleFn,
        colorA: colorA, colorB: colorB,
        isActive: { active },
        toggleHandler: {
            active = active.not;
            if(active) { fnA.value } { fnB.value };
            ~lpMini[\ledCache][note] = nil;
            if(bank == ~lpMini[\bank]) {
                ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][note]);
            };
        }
    );
    if(bank == ~lpMini[\bank]) {
        ~lpMini[\ledCache][note] = nil;
        ~lpMini[\paint].(note, ~lpMini[\banks][bank - 1][note]);
    };
    "LP ToggleFn Bound Pad % (Bank %)".format(note, bank).postln;
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
    if(val > 0) {
        // 1. Bank Select (Top Buttons CC 91-98 → banks 1-8)
        if(cc >= 91 and: { cc <= 98 }) {
            ~lpMini[\switchBank].(cc - 90);
        };

        // 2. Stop All (Bottom-right side button CC 19)
        if(cc == 19) { ~lpMini[\stopAll].() };
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

// Paint initial bank LED state
~lpMini[\paintBankLEDs].();

"--- Launchpad Mini MK3 Universal Launcher Loaded (v15 + Banking 1-8) ---".postln;
)
// -----------------------------------------------------------------------------
// EXAMPLES
// -----------------------------------------------------------------------------

// // Bind to active bank (same as before)
// ~lpBind.([1, 1], \beat, 45);
//
// // Bind to a specific bank (1-8)
// ~lpBindB.(1, [1, 1], \kick, 9);    // bank 1, bottom-left
// ~lpBindB.(2, [1, 1], \snare, 21);  // bank 2, same pad position
//
// // Switch banks via hardware: press Left/Right top buttons
// // Or programmatically:
// ~lpMini[\switchBank].(2);
//
// // Current bank index:
// ~lpMini[\bank].postln;
//
// // Bank LEDs: Left (CC93) lights white when bank > 0
// //            Right (CC94) lights white when bank < 7
