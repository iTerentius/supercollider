(
// midi-out-deluge.scd
// Auto-detects Deluge and sets up MIDI out + clock task, and (Linux/ALSA
// only — see below) connects its MIDI IN so Deluge -> SC actually receives
// anything (e.g. via midi-in-play.scd).
// Loaded by norns-router.scd — no need to add to startup.scd.
//
// Globals: ~delugeOut, ~delugeCtrl, ~delugeSrcUid, ~startDelugeClock, ~stopDelugeClock
//
// ~delugeOut    — latency-compensated, use in Pbind for pattern output
// ~delugeCtrl   — zero latency, use for real-time CC (MIDIFollow)
// ~delugeSrcUid — uid of the Deluge's MIDI source; pass to ~midiInSrcID
//                 (midi-in-play.scd) to scope that router to just the Deluge.
// ~startDelugeClock.() — sends MIDI start + 24ppqn clock to Deluge
// ~stopDelugeClock.()  — sends MIDI stop + halts clock

var ep, srcEp;

~delugeOut  = nil;
~delugeCtrl = nil;
~delugeSrcUid = nil;

ep = MIDIClient.destinations.detect { |e|
    e.device.containsi("Deluge") or: { e.name.containsi("Deluge") }
};

if(ep.notNil) {
    ~delugeOut = MIDIOut.newByName(ep.device, ep.name);
    ~delugeOut.latency = s.latency;
    ~delugeCtrl = MIDIOut.newByName(ep.device, ep.name);
    ~delugeCtrl.latency = 0;
    // Linux/ALSA only: MIDIOut#connect comes from this build's
    // SCClassLibrary/Platform/linux/SystemOverwrites/extMIDIOut.sc — it
    // doesn't exist on macOS (CoreMIDI sends fine without it). On ALSA,
    // snd_seq_event_output_direct to an unsubscribed destination port
    // silently goes nowhere for a hardware client like the Deluge —
    // without this, ~delugeOut/~delugeCtrl construct fine and .write
    // doesn't error, but nothing actually reaches the device.
    // ~delugeOut and ~delugeCtrl both come from newByName with the same
    // device/port name, so they share the same underlying SC output port
    // (only their uid differs) — connecting just one subscribes that
    // shared port to the Deluge; a second .connect on the same
    // port→destination pair errors "busy", so only call it once. Wrapped
    // in try so re-evaluating this file while already connected (also
    // "busy") doesn't abort the rest of the block.
    if(Platform.case(\osx, { false }, { true })) {
        try {
            ~delugeOut.connect(ep.uid);
            ("midi-out-deluge: MIDIOut connected (ALSA) → " ++ ep.device ++ " / " ++ ep.name).postln;
        } { |err|
            ("midi-out-deluge: MIDIOut connect skipped (already connected) → " ++ ep.device ++ " / " ++ ep.name).postln;
        };
    };
    ("midi-out-deluge: found → " ++ ep.device ++ " / " ++ ep.name).postln;
} {
    "midi-out-deluge: Deluge not found — connect and re-evaluate, or set ~delugeOut manually.".warn;
};

// ---- MIDI IN connection (Deluge -> SC)
// On macOS, midi-setup.scd's MIDIIn.connectAll already covers this. On
// Linux, midi-setup.scd deliberately does NOT connectAll (see its header —
// avoids ALSA errors with devices that are in use/unavailable) and instead
// leaves each device's own loader responsible for connecting itself, same
// as apc_boot_all.scd / lp-param-router.scd / etc. already do for their
// devices. Without this, the Deluge shows up fine in MIDIClient.sources but
// midi-in-play.scd's MIDIdefs never fire, since MIDIdef only receives from
// sources that have been explicitly MIDIIn.connect'ed.
srcEp = MIDIClient.sources.detect { |e|
    e.device.containsi("Deluge") or: { e.name.containsi("Deluge") }
};

if(srcEp.notNil) {
    // Re-evaluating this file while the Deluge is already connected hits
    // ALSA's "Device or resource busy" on a second MIDIIn.connect to the
    // same uid — expected (the old connection is still live and fine), not
    // a real failure. Caught here so it doesn't abort the rest of this
    // block (LCXL passthrough + ~startDelugeClock/~stopDelugeClock defs
    // below), same as every other connect in this codebase currently risks
    // on re-eval.
    try {
        MIDIIn.connect(0, srcEp.uid);
        ("midi-out-deluge: MIDIIn connected → " ++ srcEp.device ++ " / " ++ srcEp.name).postln;
    } { |err|
        ("midi-out-deluge: MIDIIn connect skipped (already connected) → " ++ srcEp.device ++ " / " ++ srcEp.name).postln;
    };
    ~delugeSrcUid = srcEp.uid;
} {
    "midi-out-deluge: Deluge MIDI IN source not found — connect and re-evaluate.".warn;
};

// ---- LCXL → Deluge passthrough (MIDIFollow param control)
// Routes LCXL CCs and notes to ~delugeCtrl so MIDIFollow templates work
// when LCXL is connected to this machine instead of Norns.
if(~lcxlSrcUid.notNil and: { ~delugeCtrl.notNil }) {
    MIDIdef.cc(\lcxlToDeluge, { |val, num, chan|
        ~delugeCtrl.control(chan, num, val);
    }, srcID: ~lcxlSrcUid);
    MIDIdef.noteOn(\lcxlNoteOnToDeluge, { |vel, note, chan|
        ~delugeCtrl.noteOn(chan, note, vel);
    }, srcID: ~lcxlSrcUid);
    MIDIdef.noteOff(\lcxlNoteOffToDeluge, { |vel, note, chan|
        ~delugeCtrl.noteOff(chan, note, vel);
    }, srcID: ~lcxlSrcUid);
    "midi-out-deluge: LCXL → Deluge passthrough active".postln;
} {
    if(~lcxlSrcUid.isNil) {
        "midi-out-deluge: LCXL not found — run ~reconnectMidi.() if connected".warn;
    };
};

// ---- MIDI clock out (SC is tempo master, Deluge slaves)
// Deluge must be set to external/slave clock mode.
// Uses SystemClock so ~link beat phase is unaffected.
~delugeClockTask = nil;

~startDelugeClock = {
    if(~delugeCtrl.notNil) {
        ~delugeClockTask !? { ~delugeClockTask.stop };
        ~delugeCtrl.start;
        ~delugeClockTask = Task({
            loop {
                var bpm = (~link.tempo * 60).round(1);
                ~delugeCtrl.midiClock;
                (60 / (bpm * 24)).wait;
            }
        }).play(SystemClock);
        "Deluge clock: started".postln;
    } {
        "Deluge clock: ~delugeCtrl is nil — Deluge not connected".warn;
    };
};

~stopDelugeClock = {
    ~delugeClockTask !? { ~delugeClockTask.stop };
    ~delugeCtrl !? { ~delugeCtrl.stop };
    "Deluge clock: stopped".postln;
};
)
