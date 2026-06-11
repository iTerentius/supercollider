(
// norns-router.scd
// OSC router: Norns Shield (arcologies BEACON cells) → SC.
// Load after midi-setup.scd. Device-specific MIDI out files are
// loaded automatically at the end of this file.
//
// BEACON cells in arcologies send /arc/trigger with an integer ID (1-99).
// Register handlers in ~song keyed by that integer — no symbol names needed.
// Norns sends the number; the meaning lives entirely on the SC side.
//
// Future work (not implemented):
// - Grid state monitoring: SC as second serialosc listener via monomeSC/serialosc.
//   Read active arcologies metabolism zones to weight Prand choices per pattern.

// ---- song handler table
// Keys are the integer IDs set on BEACON cells in arcologies (1-99).
// Populate per project:
//   ~song[1] = { ~toggle.(\bassline) };
//   ~song[2] = { ~oneshot.(\fill, 2) };
// Retrigger cooldown is set per-cell on the Norns grid (BEACON RETRIG param, in beats).
// 0 = fire every trigger (default). SC enforces the lockout via ~lastTriggerBeat.
~song = ();

// Tracks the ~link beat at which each ID last fired, for cooldown gating.
~lastTriggerBeat = ();

// ---- OSC listener
// Receives /arc/trigger from arcologies BEACON cells.
// msg[1] = integer id, msg[2] = retrigger cooldown in beats (0 = no lockout).
// SC default receive port is 57120; set target IP in Norns PARAMS → BEACON / OSC.
OSCdef(\arcRouter, { |msg|
    var id       = msg[1].asInteger;
    var cooldown = msg[2].asFloat;
    var handler  = ~song[id];
    if(handler.notNil) {
        var last = (~lastTriggerBeat[id] ? -1e10);
        if((~link.beats - last) >= cooldown) {
            ~lastTriggerBeat[id] = ~link.beats;
            handler.value((id: id));
        };
    } {
        ("norns-router: unhandled id " ++ id).postln;
    };
}, "/arc/trigger");

// ---- utility functions
// ~activePdefs tracks what's playing so ~songStop only hits song patterns.
// ~songLocked is set on arcologies pause and cleared on resume.
// While locked, ~play/~toggle/~oneshot are no-ops — residual BEACON signals
// that fire after arcologies pauses cannot restart patterns.
~activePdefs  = Set.new;
~songLocked   = false;
// Per-sym cancelation tokens for ~oneshot. Each call mints a new Object;
// the scheduled stop checks identity so a superseded stop is a no-op.
~oneshotFlags = ();

~play = { |sym|
    if(~songLocked.not) {
        Pdef(sym).play(~link);
        ~activePdefs.add(sym);
    };
};

~stop = { |sym|
    Pdef(sym).stop;
    ~activePdefs.remove(sym);
};

~toggle = { |sym|
    if(~songLocked.not) {
        if(Pdef(sym).isPlaying) {
            Pdef(sym).stop;
            ~activePdefs.remove(sym);
        } {
            Pdef(sym).play(~link);
            ~activePdefs.add(sym);
        };
    };
};

// Play for N bars then stop. Default 1 bar; pass bars: 2 for a 2-bar fill.
// Uses nextTimeOnGrid so the stop is scheduled from when the Pdef actually
// starts (next quant boundary), not from when ~oneshot is called. Without
// this, a trigger arriving just after a boundary queues the Pdef to the
// next boundary but fires the stop at now+4, cutting off after 1 note.
// The flag token ensures a superseded stop (from a previous call) never
// kills a freshly-restarted instance.
~oneshot = { |sym, bars=1|
    if(~songLocked.not) {
        var p         = Pdef(sym);
        var q         = Pdef.defaultQuant ? 1;
        var startBeat = ~link.nextTimeOnGrid(q);
        var flag      = Object.new;
        ~oneshotFlags[sym] = flag;
        p.play(~link);
        ~activePdefs.add(sym);
        ~link.schedAbs(startBeat + (~link.beatsPerBar * bars), {
            if(~oneshotFlags[sym] === flag) {
                p.stop;
                ~activePdefs.remove(sym);
                ~oneshotFlags.removeAt(sym);
            };
            nil
        });
    };
};

// Stop only patterns started via this router — leaves anything else in SC running.
~songStop = {
    ~songLocked = true;
    ~activePdefs.do { |sym| Pdef(sym).stop };
    ~activePdefs  = Set.new;
    ~lastTriggerBeat = ();
    ~oneshotFlags = ();
    "songStop: all patterns stopped".postln;
};

~songResume = {
    ~songLocked = false;
    "songResume: patterns unlocked".postln;
};

// ---- arcologies transport sync
// Arcologies pause → /arc/stop  → ~songStop  (lock + stop all)
// Arcologies play  → /arc/start → ~songResume (unlock)
OSCdef(\arcStop,  { ~songStop.()   }, "/arc/stop");
OSCdef(\arcStart, { ~songResume.() }, "/arc/start");

// ---- MIDI device outputs (auto-detected, no startup.scd changes needed)
"midi-out-deluge.scd".loadRelative;
"midi-out-maschine.scd".loadRelative;

"norns-router: loaded".postln;
)
