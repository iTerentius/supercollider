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

var ep;

~maschineOut = nil;

ep = MIDIClient.destinations.detect { |e|
    e.device.containsi("Maschine") or: { e.name.containsi("Maschine") }
};

if(ep.notNil) {
    ~maschineOut = MIDIOut.newByName(ep.device, ep.name);
    ~maschineOut.latency = s.latency;
    ("midi-out-maschine: found → " ++ ep.device ++ " / " ++ ep.name).postln;
} {
    "midi-out-maschine: Maschine Plus not found — connect and re-evaluate, or set ~maschineOut manually.".warn;
};
)
