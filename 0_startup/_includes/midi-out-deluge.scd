(
// midi-out-deluge.scd
// Auto-detects Deluge and sets up MIDI out + clock task.
// Loaded by norns-router.scd — no need to add to startup.scd.
//
// Globals: ~delugeOut, ~delugeCtrl, ~startDelugeClock, ~stopDelugeClock
//
// ~delugeOut  — latency-compensated, use in Pbind for pattern output
// ~delugeCtrl — zero latency, use for real-time CC (MIDIFollow)
// ~startDelugeClock.() — sends MIDI start + 24ppqn clock to Deluge
// ~stopDelugeClock.()  — sends MIDI stop + halts clock

var ep;

~delugeOut  = nil;
~delugeCtrl = nil;

ep = MIDIClient.destinations.detect { |e|
    e.device.containsi("Deluge") or: { e.name.containsi("Deluge") }
};

if(ep.notNil) {
    ~delugeOut = MIDIOut.newByName(ep.device, ep.name);
    ~delugeOut.latency = s.latency;
    ~delugeCtrl = MIDIOut.newByName(ep.device, ep.name);
    ~delugeCtrl.latency = 0;
    ("midi-out-deluge: found → " ++ ep.device ++ " / " ++ ep.name).postln;
} {
    "midi-out-deluge: Deluge not found — connect and re-evaluate, or set ~delugeOut manually.".warn;
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
    if(~delugeOut.notNil) {
        ~delugeClockTask.stop;
        ~delugeOut.start;
        ~delugeClockTask = Task({
            loop {
                var bpm = (~link.tempo * 60).round(1);
                ~delugeOut.midiClock;
                (60 / (bpm * 24)).wait;
            }
        }).play(SystemClock);
        "Deluge clock: started".postln;
    } {
        "Deluge clock: ~delugeOut is nil — Deluge not connected".warn;
    };
};

~stopDelugeClock = {
    ~delugeClockTask.stop;
    ~delugeOut !? { ~delugeOut.stop };
    "Deluge clock: stopped".postln;
};
)
