// TouchOSC Pad Router
// LP Mini-style pad launcher over OSC. Depends on tosc-router.scd.
//
// Globals:
//   ~toscPads          — registry: Symbol(addr) → binding dict
//   ~toscPadColors     — named RGBA color dict
//   ~toscPadBind.(bank, row, col, key, color, playColor, onStop, label)
//   ~toscRowBind.(bank, row)   — group toggle: all pads in that row
//   ~toscColBind.(bank, col)   — group toggle: all pads in that col
//   ~toscPadPaint.(addr)       — repaint one pad from current play state
//   ~toscPadPaintAll.()        — repaint all pads (call after reconnect/score load)
//
// Addresses (leading slash stripped by dispatcher):
//   tosc/p{bank}/{row}/{col}       — pad
//   tosc/p{bank}/r/{row}           — row launcher
//   tosc/p{bank}/c/{col}           — col launcher
//
// TOSC feedback:
//   /tosc/p{bank}/{row}/{col}/color  r g b a   — color (playing vs stopped)
//   /tosc/p{bank}/{row}/{col}/label  "string"  — pad label text
//
// Row/col launcher behavior: any playing → stop all; none playing → start all.

(

// Teardown: stop any running pads from previous instance
if(~toscPads.notNil) {
    ~toscPads.keysValuesDo { |addr, b|
        var obj = ~toscPadGetObj !? { ~toscPadGetObj.(b[\key]) };
        if(obj.notNil and: { ~toscPadIsRunning !? { ~toscPadIsRunning.(obj) } ?? { false } }) {
            if(b[\onStop].notNil) { b[\onStop].value } { obj.tryPerform(\stop) };
        };
    };
};
// Always blank the full grid on load (covers recompile where globals are wiped)
if(~toscAddr.notNil) {
    #[1].do { |bank|
        (1..11).do { |row|
            (1..18).do { |col|
                ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/state", 0.0);
                ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/label", "");
                ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/nums", "");
            };
        };
    };
    "TouchOSC pad router: grid blanked.".postln;
};

~toscPads = IdentityDictionary.new;

~toscPadColors = (
    off:     [0.15, 0.15, 0.15, 1.0],
    white:   [1.0,  1.0,  1.0,  1.0],
    red:     [1.0,  0.2,  0.2,  1.0],
    orange:  [1.0,  0.5,  0.1,  1.0],
    amber:   [1.0,  0.6,  0.0,  1.0],
    yellow:  [1.0,  0.9,  0.1,  1.0],
    green:   [0.2,  1.0,  0.3,  1.0],
    cyan:    [0.1,  0.9,  1.0,  1.0],
    sky:     [0.3,  0.6,  1.0,  1.0],
    blue:    [0.2,  0.4,  1.0,  1.0],
    indigo:  [0.4,  0.2,  1.0,  1.0],
    purple:  [0.7,  0.2,  1.0,  1.0],
    pink:    [1.0,  0.3,  0.7,  1.0],
    magenta: [1.0,  0.1,  0.9,  1.0]
);

// ---- Object resolver: Symbol → Tdef > Ndef > Pdef; Function passed through ----
~toscPadGetObj = { |key|
    if(key.isKindOf(Function)) { key } {
        if(Tdef.all[key].notNil) {
            Tdef(key)
        } {
            var ps = Ndef.dictFor(Server.default);
            if(ps.notNil and: { ps.envir.at(key).notNil }) { Ndef(key) } { Pdef(key) }
        }
    }
};

// ---- Playing state ----
~toscPadIsRunning = { |obj|
    if(obj.isNil) { false } {
        if(obj.isKindOf(NodeProxy)) { obj.isMonitoring } {
            if(obj.respondsTo(\isPlaying)) { obj.isPlaying } { false }
        }
    }
};

// ---- Color index table ----
// Encodes named colors as float index: x = colorIndex * 0.05 (stopped), x = 1.0 (playing).
// Decoded in TOSC Lua: x > 0.9 → playing (green), else floor(x*20+0.1) → color index.
~toscColorIndex = (
    amber:   0,  // default stopped
    orange:  1,
    yellow:  2,
    cyan:    3,
    blue:    4,
    indigo:  5,
    purple:  6,
    pink:    7,
    magenta: 8,
    red:     9,
    white:   10,
    sky:     11,
    green:   12,
    off:     13
);

// ---- Send playing state to one pad ----
// Encodes color as x value: 0.95 = playing, (colorIndex+1)*0.05 = stopped (range 0.05–0.70).
// Range avoids 0.0 (BUTTON release artifact) and 1.0 (BUTTON press artifact).
// TOSC Lua filters x < 0.01 and x > 0.98, decodes stopped as floor(x*20+0.1)-1.
~toscPadSendColor = { |addr, colorKey|
    var b = ~toscPads[addr];
    if(b.notNil) {
        var isPlaying = (colorKey == b[\playColor]);
        var xVal = if(isPlaying) {
            0.95
        } {
            var idx = ~toscColorIndex[colorKey] ?? { ~toscColorIndex[b[\color]] } ?? { 0 };
            (idx + 1) * 0.05
        };
        ~toscAddr.sendMsg("/tosc/p" ++ b[\bank] ++ "/" ++ b[\row] ++ "/col" ++ b[\col] ++ "/state", xVal);
    };
};

// ---- Repaint one pad from current play state ----
~toscPadPaint = { |addr|
    var b = ~toscPads[addr];
    if(b.notNil) {
        var running = ~toscPadIsRunning.(~toscPadGetObj.(b[\key]));
        ~toscPadSendColor.(addr, if(running) { b[\playColor] } { b[\color] });
    }
};

// ---- Repaint all registered pads ----
~toscPadPaintAll = {
    ~toscPads.keysDo { |addr| ~toscPadPaint.(addr) };
    "TouchOSC pads: repainted all.".postln;
};

// ---- Sync TOSC pad color for a specific key (call after LP Mini or other controller toggles) ----
// Usage: ~toscPadSyncKey.(\bd1)
~toscPadSyncKey = { |key|
    ~toscPads.keysValuesDo { |addr, b|
        if(b[\key] == key) { ~toscPadPaint.(addr) };
    };
};

// ---- Full sync: state + labels + nums ----
~toscPadSyncAll = {
    ~toscPads.keysValuesDo { |addr, b|
        ~toscPadPaint.(addr);
        ~toscAddr.sendMsg("/tosc/p" ++ b[\bank] ++ "/" ++ b[\row] ++ "/col" ++ b[\col] ++ "/label", b[\label]);
        ~toscAddr.sendMsg("/tosc/p" ++ b[\bank] ++ "/" ++ b[\row] ++ "/col" ++ b[\col] ++ "/nums", b[\col].asString ++ "-" ++ b[\row].asString);
    };
    "TouchOSC pads: synced all.".postln;
};

// ---- Toggle one pad ----
~toscPadToggle = { |addr|
    var b = ~toscPads[addr];
    if(b.notNil) {
        var obj     = ~toscPadGetObj.(b[\key]);
        var running = ~toscPadIsRunning.(obj);
        var clock   = ~link ?? { TempoClock.default };
        case
        { obj.isKindOf(Function) } {
            obj.value;
            ~toscPadSendColor.(addr, b[\playColor]);
            AppClock.sched(0.15, { ~toscPadPaint.(addr); nil });
        }
        { running } {
            if(b[\onStop].notNil) { b[\onStop].value } { obj.tryPerform(\stop) };
            AppClock.sched(0.05, { ~toscPadPaint.(addr); nil });
        }
        { true } {
            obj.tryPerform(\play, clock);
            AppClock.sched(0.05, { ~toscPadPaint.(addr); nil });
        };
    }
};

// ---- Bind a pad ----
// bank, row, col : Integer
// key            : Symbol (Pdef/Tdef/Ndef) or Function
// color          : Symbol from ~toscPadColors — stopped state (default \white)
// playColor      : Symbol — playing state (defaults to color)
// onStop         : Function called instead of obj.stop on toggle-off (optional)
// label          : String shown on pad (defaults to key.asString)
~toscPadBind = { |bank, row, col, key, color = \white, playColor, onStop, label|
    var addr = ("tosc/p" ++ bank ++ "/" ++ row ++ "/" ++ col).asSymbol;
    var lbl  = label ?? { if(key.isKindOf(Symbol)) { key.asString } { "fn" } };
    var pc   = playColor ?? { color };

    ~toscPads[addr] = (
        key: key, color: color, playColor: pc, onStop: onStop, label: lbl,
        bank: bank, row: row, col: col
    );
    ~oscParam[addr] = { |val| if(val > 0.5) { ~toscPadToggle.(addr) } };

    ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/label", lbl);
    ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/nums", col.asString ++ "-" ++ row.asString);
    ~toscPadPaint.(addr);
};

// ---- Row launcher: any playing → stop all; none playing → start all ----
~toscRowBind = { |bank, row|
    var addr = ("tosc/p" ++ bank ++ "/r/" ++ row).asSymbol;
    ~oscParam[addr] = { |val|
        if(val > 0.5) {
            var pads  = ~toscPads.select { |b| b[\bank] == bank and: { b[\row] == row } };
            var anyOn = pads.any { |b| ~toscPadIsRunning.(~toscPadGetObj.(b[\key])) };
            var clock = ~link ?? { TempoClock.default };
            pads.keysValuesDo { |padAddr, b|
                var obj     = ~toscPadGetObj.(b[\key]);
                var running = ~toscPadIsRunning.(obj);
                if(anyOn) {
                    if(running) {
                        if(b[\onStop].notNil) { b[\onStop].value } { obj.tryPerform(\stop) }
                    }
                } {
                    if(running.not) { obj.tryPerform(\play, clock) }
                }
            };
            AppClock.sched(0.05, { pads.keysDo { |a| ~toscPadPaint.(a) }; nil });
        }
    }
};

// ---- Col launcher: any playing → stop all; none playing → start all ----
~toscColBind = { |bank, col|
    var addr = ("tosc/p" ++ bank ++ "/c/" ++ col).asSymbol;
    ~oscParam[addr] = { |val|
        if(val > 0.5) {
            var pads  = ~toscPads.select { |b| b[\bank] == bank and: { b[\col] == col } };
            var anyOn = pads.any { |b| ~toscPadIsRunning.(~toscPadGetObj.(b[\key])) };
            var clock = ~link ?? { TempoClock.default };
            pads.keysValuesDo { |padAddr, b|
                var obj     = ~toscPadGetObj.(b[\key]);
                var running = ~toscPadIsRunning.(obj);
                if(anyOn) {
                    if(running) {
                        if(b[\onStop].notNil) { b[\onStop].value } { obj.tryPerform(\stop) }
                    }
                } {
                    if(running.not) { obj.tryPerform(\play, clock) }
                }
            };
            AppClock.sched(0.05, { pads.keysDo { |a| ~toscPadPaint.(a) }; nil });
        }
    }
};

// ---- Stop all running pads across all banks ----
~toscPadStopAll = {
    ~toscPads.keysValuesDo { |addr, b|
        var obj = ~toscPadGetObj.(b[\key]);
        if(~toscPadIsRunning.(obj)) {
            if(b[\onStop].notNil) { b[\onStop].value } { obj.tryPerform(\stop) };
        };
    };
    AppClock.sched(0.1, { ~toscPadPaintAll.(); nil });
    "TouchOSC pads: stopped all.".postln;
};
~oscParam['tosc/p/all'] = { |val| if(val > 0.5) { ~toscPadStopAll.() } };

// ---- Page-switch repaint: PAGER 'dev' sends this when pads page is selected ----
~oscParam['tosc/pads/visible'] = { ~toscPadPaintAll.() };

// ---- Clear all bindings and blank the full device grid ----
// Stops running pads, removes ~oscParam callbacks, clears registry,
// then blanks every pad on the device (bank 1: 11 rows × 18 cols).
~toscPadClearAll = {
    ~toscPads.keysValuesDo { |addr, b|
        var obj = ~toscPadGetObj.(b[\key]);
        if(~toscPadIsRunning.(obj)) {
            if(b[\onStop].notNil) { b[\onStop].value } { obj.tryPerform(\stop) };
        };
        ~oscParam.removeAt(addr);
    };
    ~toscPads = IdentityDictionary.new;
    // Blast full grid regardless of what was registered
    #[1].do { |bank|
        (1..11).do { |row|
            (1..18).do { |col|
                ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/state", 0.0);
                ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/label", "");
                ~toscAddr.sendMsg("/tosc/p" ++ bank ++ "/" ++ row ++ "/col" ++ col ++ "/nums", "");
            };
        };
    };
    "TouchOSC pads: all bindings cleared and grid blanked.".postln;
};

// ---- Pre-register launchers for bank 1 (18 cols, 11 rows) ----
// Launchers look up ~toscPads at trigger time so registration order doesn't matter.
#[1].do { |bank|
    (1..18).do { |col| ~toscColBind.(bank, col) };
    (1..11).do { |row| ~toscRowBind.(bank, row) };
};

"TouchOSC pad router loaded.".postln;

)
