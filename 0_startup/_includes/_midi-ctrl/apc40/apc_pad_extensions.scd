/* 2025-01-24 APC40 mkII Pad Extensions
   Adds support for Functions, Ndefs, and Tdefs (not just Pdefs)
   Adds custom per-pad colors (like LaunchPad Mini)
   Preserves existing banking functionality from apc_boot_all.scd
   Load this AFTER apc_boot_all.scd

   Color Usage:
     ~apcBind.(note, key, quant, color, playColor, onStop)
     - color:     Symbol (\red, \blue, etc.) or Integer (0-127) — LED when stopped
     - playColor: optional, pad pulses at this color when playing (defaults to color)
     - onStop:    optional Function called on toggle-off instead of obj.stop
                  (use with ~makeFxSendTdef for proper FX send cleanup)

   Playing pads pulse (MIDI ch ~apcCfg[\playMode], default 9 = PULSE_1X4).
   Stopped pads are static (ch 0).

   Available colors: \off, \white, \red, \orange, \yellow, \chartreuse, \green,
     \cyan, \sky, \teal, \blue, \indigo, \violet, \purple, \magenta, \pink, \amber

   Run ~apcShowColors.() to list all available color names */

(
// ---- Object Resolver ----
// Returns the actual object for a given key (Pdef, Tdef, Ndef, Function, or String)
// Priority: Function/String > existing Tdef > existing Ndef > Pdef (creates if needed)
~apcGetObj = { |key|
    var obj, proxySpace;
    if(key.isKindOf(Function) or: { key.isString }) {
        obj = key;
    } {
        if(key.isKindOf(Symbol)) {
            // Check Tdef first (explicit task)
            if(Tdef.all[key].notNil) {
                obj = Tdef(key)
            } {
                // Check Ndef (NodeProxy)
                proxySpace = Ndef.dictFor(Server.default);
                if(proxySpace.notNil and: { proxySpace.envir.at(key).notNil }) {
                    obj = Ndef(key)
                } {
                    // Default to Pdef - this creates it if it doesn't exist
                    // (matches original apc_boot_all behavior)
                    obj = Pdef(key)
                }
            }
        }
    };
    obj
};

// ---- Check if object is playing/running ----
~apcIsRunning = { |obj|
    var running = false;
    if(obj.notNil) {
        if(obj.isKindOf(NodeProxy)) {
            running = obj.isMonitoring
        } {
            if(obj.respondsTo(\isPlaying)) {
                running = obj.isPlaying
            }
        }
    };
    running
};

// ---- Enhanced Toggle (replaces simple Pdef toggle) ----
~apcToggleObj = { |note, key, quant = 4, onStop = nil|
    var obj = ~apcGetObj.(key);
    var clock = ~link ?? { TempoClock.default };

    if(obj.notNil) {
        case
        { obj.isKindOf(Function) } {
            // Functions: just call them (one-shot trigger)
            obj.value;
            ["[APC] Function triggered:", key].postln;
            // Flash the LED briefly
            ~apcLEDSet.(note, ~apcColors[\green]);
            AppClock.sched(0.1, { ~apcLEDByState.(note, key); nil });
        }
        { obj.isString } {
            // Strings: interpret as code
            obj.interpret;
            ["[APC] Code executed:", key].postln;
            ~apcLEDSet.(note, ~apcColors[\green]);
            AppClock.sched(0.1, { ~apcLEDByState.(note, key); nil });
        }
        { obj.isKindOf(NodeProxy) } {
            // Ndef: toggle monitoring
            if(obj.isMonitoring) {
                obj.stop;
                ["[APC] Ndef stopped:", key].postln;
            } {
                obj.quant = quant;
                obj.play;
                ["[APC] Ndef playing:", key].postln;
            };
            // Defer LED update - NodeProxy state may not update immediately
            AppClock.sched(0.05, { ~apcLEDByState.(note, key); nil });
        }
        { obj.isKindOf(Tdef) or: { obj.isKindOf(TaskProxy) } } {
            // Tdef: toggle play/stop
            if(obj.isPlaying) {
                if(onStop.notNil) { onStop.value } { obj.stop };
                ["[APC] Tdef stopped:", key].postln;
            } {
                obj.play(clock, quant: quant);
                ["[APC] Tdef playing:", key].postln;
            };
            // Defer LED update
            AppClock.sched(0.05, { ~apcLEDByState.(note, key); nil });
        }
        { obj.isKindOf(Pdef) or: { obj.isKindOf(EventPatternProxy) } } {
            // Pdef: toggle play/stop (original behavior)
            if(obj.isPlaying) {
                obj.stop;
                ["[APC] Pdef stopped:", key].postln;
            } {
                obj.play(clock, quant: quant);
                ["[APC] Pdef playing:", key].postln;
            };
            // Defer LED update
            AppClock.sched(0.05, { ~apcLEDByState.(note, key); nil });
        };
    } {
        ["[APC] No object found for key:", key].postln;
    };
};

// ---- Enhanced LED state (shows state for all object types) ----
// Playing pads pulse (MIDI ch ~apcCfg[\playMode]); stopped pads are static (ch 0).
// Handles both: ~apcLEDByState.(note, key) and ~apcLEDByState.(note, eventBinding)
~apcLEDByStateExt = { |note, keyOrBinding|
    var colors, obj, wantColor, wantChan, binding, actualKey, customColor, playColor, isRunning, isRunningFn;
    colors = ~apcColors;

    if(keyOrBinding.isKindOf(Event)) {
        actualKey = keyOrBinding[\key];
        customColor = keyOrBinding[\color];
        playColor = keyOrBinding[\playColor];
        isRunningFn = keyOrBinding[\isRunning];
    } {
        actualKey = keyOrBinding;
        binding = ~apcPadMap[note];
        if(binding.isKindOf(Event)) {
            customColor = binding[\color];
            playColor = binding[\playColor];
            isRunningFn = binding[\isRunning];
        };
    };

    obj = ~apcGetObj.(actualKey);
    isRunning = if(isRunningFn.notNil) { isRunningFn.value } { ~apcIsRunning.(obj) };

    if(obj.notNil) {
        case
        { isRunning } {
            // Active/playing: pulse — checked first so toggleFn and Function keys pulse correctly
            wantColor = playColor ?? { customColor ?? { colors[\green] } };
            wantChan = ~apcCfg[\playMode] ? 9;
        }
        { obj.isKindOf(Function) or: { obj.isString } } {
            // Function/String, not running: static
            wantColor = customColor ?? { colors[\amber] };
            wantChan = 0;
        }
        {
            // Stopped: static at custom color or amber
            wantColor = customColor ?? { colors[\amber] };
            wantChan = 0;
        };
    } {
        // No object yet — show custom color if bound (pad is "ready"), else off
        wantColor = customColor ?? { colors[\off] };
        wantChan = 0;
    };

    ~apcLEDSet.(note, wantColor, wantChan);
};

// ---- Override the original LED function ----
~apcLEDByState = ~apcLEDByStateExt;

// ---- Enhanced Assign Pad (accepts any object type + custom colors) ----
// color: color when stopped (can be Symbol like \red or Integer 0-127)
// playColor: color when playing (optional, defaults to brighter version of color)
~apcAssignPadExt = { |note, key, quant = 4, color = nil, playColor = nil, onStop = nil|
    var colors = ~apcColors;
    var obj = ~apcGetObj.(key);
    var resolvedColor, resolvedPlayColor;

    // Resolve color symbols to values
    resolvedColor = if(color.isKindOf(Symbol)) { colors[color] } { color };
    resolvedPlayColor = if(playColor.isKindOf(Symbol)) { colors[playColor] } { playColor };

    // Store the binding with metadata
    ~apcPadMap[note] = (
        key: key,
        quant: quant,
        color: resolvedColor,
        playColor: resolvedPlayColor,
        onStop: onStop,
        type: case
            { obj.isKindOf(Function) } { \function }
            { obj.isString } { \string }
            { obj.isKindOf(NodeProxy) } { \ndef }
            { obj.isKindOf(Tdef) or: { obj.isKindOf(TaskProxy) } } { \tdef }
            { obj.isKindOf(Pdef) or: { obj.isKindOf(EventPatternProxy) } } { \pdef }
            { \unknown }
    );

    ~apcLEDByState.(note, key);
    ["[APC] Pad", note, "->", key, "(type:", ~apcPadMap[note][\type],
        "color:", resolvedColor ?? "default", ")"].postln;
};

// ---- Modify the grid listener to use enhanced toggle ----
// We need to update the existing listener
~apcInstallGridListenerExt = {
    var nameOn, nameOff;
    nameOn = \apc40_grid_any_on;
    nameOff = \apc40_grid_any_off;

    MIDIdef.free(nameOn);
    MIDIdef.free(nameOff);

    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var binding, key, row, colByChan, quant, onStop;

        binding = ~apcPadMap[num];
        row = ~apcSceneMap[num];
        colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };

        if(binding.notNil) {
            // Handle both old-style (just key) and new-style (event with key/quant)
            if(binding.isKindOf(Event)) {
                key = binding[\key];
                quant = binding[\quant] ?? { 4 };
                onStop = binding[\onStop];
            } {
                key = binding;
                quant = 4;
                onStop = nil;
            };

            if(vel > 0) {
                ~apcIsDown[num] = true;
                if(binding.isKindOf(Event) and: { binding[\type] == \toggleFn }) {
                    binding[\toggleHandler].value;
                } {
                    ~apcToggleObj.(num, key, quant, onStop);
                };
                ~apcRepaintStops.();
            } {
                ~apcIsDown[num] = false;
                ~apcLEDByState.(num, key);
            };
        } {
            // Scene/Stop handling (unchanged from original)
            if(row.notNil) {
                if(vel > 0) { ~apcToggleRow.(row); ~apcSceneLEDByState.(num); ~apcRepaintStops.(); }
                { ~apcSceneLEDByState.(num) };
            } {
                if(colByChan.notNil) {
                    if(vel > 0) { ~apcStopColumn.(colByChan); ~apcStopColLEDByChan.(chan); ~apcStopAllLED.(); }
                    { ~apcStopColLEDByChan.(chan) };
                } {
                    if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) {
                        if(vel > 0) { ~apcStopAll.() } { ~apcStopAllLED.() };
                    };
                };
            };
        };
    }, nil, nil, ~apcMidiUID);

    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        var binding, key, row, colByChan;

        binding = ~apcPadMap[num];
        row = ~apcSceneMap[num];
        colByChan = if(num == 52) { ~apcStopColChanMap[chan] } { nil };

        if(binding.notNil) {
            if(binding.isKindOf(Event)) { key = binding[\key] } { key = binding };
            // Just update LED on release, don't toggle again
            ~apcIsDown[num] = false;
            ~apcLEDByState.(num, key);
        } {
            if(row.notNil) { ~apcSceneLEDByState.(num) };
            if(colByChan.notNil) { ~apcStopColLEDByChan.(chan); ~apcStopAllLED.() };
            if(~apcStopAllNote.notNil and: { num == ~apcStopAllNote }) { ~apcStopAllLED.() };
        };
    }, nil, nil, ~apcMidiUID);

    "[APC] Extended grid listener installed".postln;
    true
};

// ---- Convenience binding function (like ~lpBind) ----
// Usage: ~apcBind.(note, key, quant, color, playColor)
// color/playColor: Symbol (\red, \blue, etc.) or Integer (0-127)
// Examples:
//   ~apcBind.(32, \kick);                        // default colors
//   ~apcBind.(32, \kick, 4, \red);               // red when stopped, bright red when playing
//   ~apcBind.(32, \kick, 4, \blue, \brightCyan); // blue stopped, bright cyan playing
//   ~apcBind.(32, \kick, 4, 45);                 // raw color value 45
~apcBind = { |note, key, quant = 4, color = nil, playColor = nil, onStop = nil|
    ~apcAssignPadExt.(note, key, quant, color, playColor, onStop);
};

// ---- Bank-targeted binding (like ~lpBindB) ----
// Usage: ~apcBindB.(bank, note, key, quant, color, playColor, onStop)
// Stores into specific bank regardless of active bank.
~apcBindB = { |bank, note, key, quant = 4, color = nil, playColor = nil, onStop = nil|
    var colors = ~apcColors;
    var obj = ~apcGetObj.(key);
    var resolvedColor, resolvedPlayColor, storedKey, bindEvent;
    bank = bank.clip(1, 8);

    if(key.isKindOf(Function) or: { key.isString }) { storedKey = key } { storedKey = key.asSymbol };
    resolvedColor = if(color.isKindOf(Symbol)) { colors[color] } { color };
    resolvedPlayColor = if(playColor.isKindOf(Symbol)) { colors[playColor] } { playColor };

    bindEvent = (
        key: storedKey,
        quant: quant,
        color: resolvedColor,
        playColor: resolvedPlayColor,
        onStop: onStop,
        type: case
            { obj.isKindOf(Function) } { \function }
            { obj.isString } { \string }
            { obj.isKindOf(NodeProxy) } { \ndef }
            { obj.isKindOf(Tdef) or: { obj.isKindOf(TaskProxy) } } { \tdef }
            { obj.isKindOf(Pdef) or: { obj.isKindOf(EventPatternProxy) } } { \pdef }
            { \unknown }
    );

    ~apcBanks[bank - 1][note] = bindEvent;

    // Only update LED if this is the active bank
    if(bank == ~apcBank) { ~apcLEDByState.(note, storedKey) };
    ["[APC] Pad", note, "->", storedKey, "(bank:", bank, "type:", bindEvent[\type], ")"].postln;
};

// ---- Helper to list available colors ----
~apcShowColors = {
    "Available APC40 colors:".postln;
    ~apcColors.keys.asArray.sort.do { |k|
        ["  ", k, "->", ~apcColors[k]].postln;
    };
};

// ---- Two-state function toggle pad ----
// Analogous to ~toscPadBindToggleFn.
// Press once:  call fnA, pad shows colorA (pulsing).
// Press again: call fnB, pad shows colorB (static).
// colorA/colorB : Symbols from ~apcColors or Integer (0-127).
~apcBindToggleFn = { |note, fnA, fnB, colorA = \green, colorB = \blue|
    var colors = ~apcColors;
    var active = false;
    var resolvedA = if(colorA.isKindOf(Symbol)) { colors[colorA] } { colorA };
    var resolvedB = if(colorB.isKindOf(Symbol)) { colors[colorB] } { colorB };
    ~apcPadMap[note] = (
        key: {}, type: \toggleFn,
        color: resolvedB, playColor: resolvedA,
        isRunning: { active },
        toggleHandler: {
            active = active.not;
            if(active) { fnA.value } { fnB.value };
            ~apcLEDByState.(note, ~apcPadMap[note]);
        }
    );
    ~apcLEDByState.(note, ~apcPadMap[note]);
};

// ---- Bank-targeted two-state toggle (like ~apcBindB) ----
~apcBindToggleFnB = { |bank, note, fnA, fnB, colorA = \green, colorB = \blue|
    var colors = ~apcColors;
    var active = false;
    var resolvedA = if(colorA.isKindOf(Symbol)) { colors[colorA] } { colorA };
    var resolvedB = if(colorB.isKindOf(Symbol)) { colors[colorB] } { colorB };
    var bindEvent;
    bank = bank.clip(1, 8);
    bindEvent = (
        key: {}, type: \toggleFn,
        color: resolvedB, playColor: resolvedA,
        isRunning: { active },
        toggleHandler: {
            active = active.not;
            if(active) { fnA.value } { fnB.value };
            ~apcLEDByState.(note, ~apcPadMap[note]);
        }
    );
    ~apcBanks[bank - 1][note] = bindEvent;
    if(bank == ~apcBank) {
        ~apcPadMap[note] = bindEvent;
        ~apcLEDByState.(note, bindEvent);
    };
};

// ---- Install the extended listener ----
~apcInstallGridListenerExt.();

// ---- Add to CmdPeriod recovery ----
CmdPeriod.remove(~apcExtPanicHook);
~apcExtPanicHook = {
    AppClock.sched(0.1, {
        ~apcInstallGridListenerExt.();
        nil
    });
};
CmdPeriod.add(~apcExtPanicHook);

"--- APC40 mkII Pad Extensions Loaded ---".postln;
"    Supports: Pdef, Tdef, Ndef, Function, String".postln;
"    Usage: ~apcBind.(note, key, quant, color, playColor, onStop)         -- active bank".postln;
"           ~apcBindB.(bank, note, key, quant, color, playColor, onStop)  -- specific bank (1-8)".postln;
"    Colors: ~apcShowColors.() to list available colors".postln;
)
