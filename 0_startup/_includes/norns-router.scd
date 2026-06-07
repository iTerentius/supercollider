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

// ---- song handler table
// Keys are the integer IDs set on BEACON cells in arcologies (1-99).
// Populate per project:
//   ~song[1] = { ~toggle.(\bassline) };
//   ~song[2] = { ~oneshot.(\fill, 2) };
~song = ();

// ---- OSC listener
// Receives /arc/trigger from arcologies BEACON cells.
// msg format: [path, arg1, ...] — id is msg[1].
// Norns default send port is 57120 (SC default receive port).
OSCdef(\arcRouter, { |msg|
    var id = msg[1];
    var handler = ~song[id];
    if(handler.notNil) {
        handler.((id: id));
    } {
        ("norns-router: unhandled id " ++ id).postln;
    };
}, "/arc/trigger");

// ---- utility functions
~play   = { |sym| Pdef(sym).play(~link) };
~stop   = { |sym| Pdef(sym).stop };
~toggle = { |sym|
    if(Pdef(sym).isPlaying) { Pdef(sym).stop } { Pdef(sym).play(~link) }
};

// Play for N bars then stop. Default 1 bar; pass bars: 2 for a 2-bar fill.
~oneshot = { |sym, bars=1|
    var p = Pdef(sym);
    p.play(~link);
    ~link.sched(~link.beatsPerBar * bars, { p.stop; nil });
};

"norns-router: loaded".postln;
)
