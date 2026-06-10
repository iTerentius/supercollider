(
// midi-out-maschine.scd
// Auto-detects Maschine Plus and sets up MIDI out.
// Loaded by norns-router.scd — no need to add to startup.scd.
//
// Globals: ~maschineOut
//
// Maschine Plus supports Ableton Link natively — no MIDI clock needed.
// Enable Link on Maschine Plus and it will follow ~link.tempo automatically.
// Just connect to the same network as SC and turn Link on in Maschine settings.

var ep, idx;

~maschineOut = nil;

idx = MIDIClient.destinations.detectIndex { |e|
    e.device.containsi("Maschine") or: { e.name.containsi("Maschine") }
};

if(idx.notNil) {
    ep = MIDIClient.destinations[idx];
    Platform.case(
        \linux, {
            // Linux/ALSA: newByName doesn't establish the sequencer connection — must connect explicitly
            ~maschineOut = MIDIOut.new(0);
            ~maschineOut.connect(idx);
        },
        {
            // macOS/other: CoreMIDI routes by uid, newByName is sufficient
            ~maschineOut = MIDIOut.newByName(ep.device, ep.name);
        }
    );
    ~maschineOut.latency = s.latency;
    ("midi-out-maschine: found + connected → " ++ ep.device ++ " / " ++ ep.name ++ " (dest idx " ++ idx ++ ")").postln;
} {
    "midi-out-maschine: Maschine Plus not found — connect and re-evaluate, or set ~maschineOut manually.".warn;
};
)
