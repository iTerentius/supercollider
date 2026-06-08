(
// norns-router.scd
// OSC router: Norns Shield (arcologies BEACON cells) → SC → Deluge.
// Load after midi-setup.scd.
//
// BEACON cells in arcologies send /arc/trigger with an integer ID (1-99).
// Register handlers in ~song keyed by that integer — no symbol names needed.
// Norns sends the number; the meaning lives entirely on the SC side.
//
// Future work (not implemented):
// - Grid state monitoring: SC as second serialosc listener via monomeSC/serialosc.
//   Read active arcologies metabolism zones to weight Prand choices per pattern.

var delugeOutEp;

// ---- Deluge MIDI out
// Run MIDIClient.destinations.do {|ep,i| [i, ep.device, ep.name].postln} to find the
// exact strings for your Deluge. The detect block matches case-insensitively.
~delugeOut = nil;
delugeOutEp = MIDIClient.destinations.detect { |ep|
    ep.device.containsi("Deluge") or: { ep.name.containsi("Deluge") }
};
if(delugeOutEp.notNil) {
    ~delugeOut = MIDIOut.newByName(delugeOutEp.device, delugeOutEp.name);
    ~delugeOut.latency = s.latency;
    ("norns-router: delugeOut → " ++ delugeOutEp.device ++ " / " ++ delugeOutEp.name).postln;
} {
    "norns-router: Deluge not found in MIDIClient.destinations — connect device and re-evaluate, or set ~delugeOut manually.".warn;
};

// ---- LCXL → Deluge passthrough (MIDIFollow param control)
// Routes LCXL CCs and notes directly to Deluge so MIDIFollow templates work
// when LCXL is connected to this machine instead of Norns.
// ~lcxlSrcUid is set by midi-setup.scd; run ~reconnectMidi.() if nil.
if(~lcxlSrcUid.notNil) {
    MIDIdef.cc(\lcxlToDeluge, { |val, num, chan|
        ~delugeOut.control(chan, num, val);
    }, srcID: ~lcxlSrcUid);
    MIDIdef.noteOn(\lcxlNoteOnToDeluge, { |vel, note, chan|
        ~delugeOut.noteOn(chan, note, vel);
    }, srcID: ~lcxlSrcUid);
    MIDIdef.noteOff(\lcxlNoteOffToDeluge, { |vel, note, chan|
        ~delugeOut.noteOff(chan, note, vel);
    }, srcID: ~lcxlSrcUid);
    "norns-router: LCXL → Deluge passthrough active".postln;
} {
    "norns-router: LCXL not found — run ~reconnectMidi.() if connected".warn;
};

// ---- song handler table
// Keys are the integer IDs set on BEACON cells in arcologies (1-99).
// Populate per project:
//   ~song[1] = { ~toggle.(\bassline) };
//   ~song[2] = { ~oneshot.(\fill, 2) };
~song = ();

// ---- SC → Deluge MIDI clock (SC is tempo master)
// SC drives Deluge tempo via 24ppqn MIDI clock. ~link is master;
// tempo changes propagate to Norns via Link and to Deluge via this clock.
// Uses SystemClock (isolated from ~link) to avoid disrupting Link beat phase.
// Change tempo from anywhere: ~link.tempo = bpm / 60
//
// ~startDelugeClock.()  — sends MIDI start + begins clock pulses
// ~stopDelugeClock.()   — sends MIDI stop + halts pulses
~delugeClockTask = nil;

~startDelugeClock = {
    ~delugeClockTask.stop;
    ~delugeOut.start;
    ~delugeClockTask = Task({
        loop {
            ~delugeOut.midiClock;
            (1 / (~link.tempo * 24)).wait;
        }
    }).play(SystemClock);
    "Deluge clock: started".postln;
};

~stopDelugeClock = {
    ~delugeClockTask.stop;
    ~delugeOut.stop;
    "Deluge clock: stopped".postln;
};

// ---- OSC listener
// Receives /arc/trigger from arcologies BEACON cells.
// msg format: [path, arg1, ...] — id is msg[1].
// Norns default send port is 57120 (SC default receive port).
OSCdef(\arcRouter, { |msg|
    var id = msg[1].asInteger;
    var handler = ~song[id];
    if(handler.notNil) {
        handler.((id: id));
    } {
        ("norns-router: unhandled id " ++ id).postln;
    };
}, "/arc/trigger");

// ---- utility functions
// ~activePdefs tracks what's playing so ~songStop only hits song patterns.
~activePdefs = Set.new;

~play = { |sym|
    Pdef(sym).play(~link);
    ~activePdefs.add(sym);
};

~stop = { |sym|
    Pdef(sym).stop;
    ~activePdefs.remove(sym);
};

~toggle = { |sym|
    if(Pdef(sym).isPlaying) {
        Pdef(sym).stop;
        ~activePdefs.remove(sym);
    } {
        Pdef(sym).play(~link);
        ~activePdefs.add(sym);
    }
};

// Play for N bars then stop. Default 1 bar; pass bars: 2 for a 2-bar fill.
~oneshot = { |sym, bars=1|
    var p = Pdef(sym);
    p.play(~link);
    ~activePdefs.add(sym);
    ~link.sched(~link.beatsPerBar * bars, {
        p.stop;
        ~activePdefs.remove(sym);
        nil
    });
};

// Stop only patterns started via this router — leaves anything else in SC running.
~songStop = {
    ~activePdefs.do { |sym| Pdef(sym).stop };
    ~activePdefs = Set.new;
    "songStop: all patterns stopped".postln;
};

"norns-router: loaded".postln;
)
