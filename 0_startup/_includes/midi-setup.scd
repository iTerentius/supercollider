(
// 2025-12-13 midi-setup.scd (cross-platform)
// Purpose:
// - Connect MIDI *inputs* only for your hardware controllers (LCXL + optional LC)
// - Do NOT connect IAC as MIDIIn, so Bitwig/IAC traffic cannot trigger SC MIDIdefs
// - Provide variables for filtering MIDIdefs by src uid
// - Provide a MIDIOut for sending patterns to DAW (IAC on macOS, VirMIDI on Linux)

var srcs, dests, platform;
var lcxlInIdx, lcxlHuiInIdx, lcInIdx, iacInIdx;
var lcxlInEp, lcxlHuiInEp, lcInEp, iacInEp;
var iacOutEp, virMidiOutEp;
var connectIdx, postSources;
var useHui, devName, portName;

// ---- init
// On Linux, MIDIClient is pre-initialized before s.boot (see startup.scd) to avoid
// a PipeWire race condition. Guard against re-init which would drop existing connections.
if(MIDIClient.initialized.not) { MIDIClient.init };
srcs = MIDIClient.sources;
dests = MIDIClient.destinations;

// ---- detect platform
platform = Platform.case(
    \osx,   { \macos },
    \linux, { \linux },
    \windows, { \windows },
    { \unknown }
);
("Platform detected: " ++ platform).postln;

// ---- helper: print sources with index + uid (useful when things move)
postSources = {
    "MIDI Sources (index, device, name, uid):".postln;
    srcs.do { |ep, i| [i, ep.device, ep.name, ep.uid].postln };
    "MIDI Destinations (index, device, name, uid):".postln;
    dests.do { |ep, i| [i, ep.device, ep.name, ep.uid].postln };
};

// uncomment if you want it every boot
// postSources.();

// ---- detect indexes for hardware controllers (works on both platforms)
lcxlInIdx = srcs.detectIndex { |ep|
    ep.device.containsi("Launch Control XL") and: { ep.name.containsi("Launch Control XL") }
};

lcxlHuiInIdx = srcs.detectIndex { |ep|
    ep.device.containsi("Launch Control XL") and: { ep.name.containsi("HUI") }
};

lcInIdx = srcs.detectIndex { |ep|
    ep.device.containsi("Launch Control") and: { ep.device.containsi("XL").not }
};

// macOS only: detect IAC
iacInIdx = srcs.detectIndex { |ep|
    ep.device.containsi("IAC Driver") and: { ep.name.containsi("Main") }
};

// ---- choose whether SC should listen to LCXL HUI port
// For pad note/CC triggering you typically want the non-HUI port.
useHui = false;

// endpoints for convenience
lcxlInEp = (lcxlInIdx.notNil).if { srcs[lcxlInIdx] } { nil };
lcxlHuiInEp = (lcxlHuiInIdx.notNil).if { srcs[lcxlHuiInIdx] } { nil };
lcInEp = (lcInIdx.notNil).if { srcs[lcInIdx] } { nil };
iacInEp = (iacInIdx.notNil).if { srcs[iacInIdx] } { nil };

// ---- connect helper (used for Linux path below)
connectIdx = { |idx|
    if(idx.notNil) {
        MIDIIn.connect(0, srcs[idx].uid);
        ("MIDIIn connected: " ++ srcs[idx].device ++ " / " ++ srcs[idx].name).postln;
    };
};

// ---- MIDI input connection (platform-specific)
case
{ platform == \macos } {
    // macOS: connectAll before any controller loaders run.
    // IMPORTANT: all connects must happen here — calling MIDIIn.connect after MIDIdefs
    // are registered deadlocks CoreMIDI on macOS.
    // MIDIIn.connectAll includes IAC, but all controller MIDIdefs filter by UID so
    // IAC/DAW traffic cannot accidentally trigger them.
    MIDIIn.connectAll;
    "MIDIIn: all sources connected".postln;

    // uid vars for MIDIdef filtering
    ~lcxlSrcUid = if(useHui) {
        lcxlHuiInEp.notNil.if { lcxlHuiInEp.uid } { nil }
    } {
        lcxlInEp.notNil.if { lcxlInEp.uid } { nil }
    };
    ~lcSrcUid = lcInEp.notNil.if { lcInEp.uid } { nil };
}
{ platform == \linux } {
    // Linux/ALSA: Do NOT connect MIDI inputs here
    // Each controller loader (APC, LCXL, etc.) handles its own connections
    // This avoids ALSA errors with devices that are in use or unavailable
    ~lcxlSrcUid = nil;
    ~lcSrcUid = nil;
    "Linux: MIDI inputs handled by controller loaders".postln;
};

// ---- MIDIOut setup (platform-specific)
~mOut = nil;

case
{ platform == \macos } {
    // Try IAC Driver first
    iacOutEp = dests.detect { |ep|
        ep.device.containsi("IAC Driver") and: { ep.name.containsi("Main") }
    };
    if(iacOutEp.notNil) {
        ~mOut = MIDIOut.newByName(iacOutEp.device, iacOutEp.name);
        ("MIDIOut set to: " ++ iacOutEp.device ++ " / " ++ iacOutEp.name).postln;
    } {
        "WARNING: IAC MIDI destination not found.".warn;
    };
}
{ platform == \linux } {
    // Try Virtual Raw MIDI / VirMIDI
    virMidiOutEp = dests.detect { |ep|
        ep.device.containsi("Virtual Raw MIDI") or: { ep.device.containsi("VirMIDI") }
    };
    if(virMidiOutEp.notNil) {
        ~mOut = MIDIOut.newByName(virMidiOutEp.device, virMidiOutEp.name);
        ("MIDIOut set to: " ++ virMidiOutEp.device ++ " / " ++ virMidiOutEp.name).postln;
    } {
        "WARNING: Virtual MIDI destination not found. Trying index 0...".warn;
    };
};

// Fallback if ~mOut is still nil
if(~mOut.isNil) {
    "MIDIOut.newByName failed, falling back to index 0".warn;
    ~mOut = MIDIOut.new(0);
    ~mOut.connect(0);
};

~mOut.latency = s.latency;

// ---- reconnect helper (macOS: CoreMIDI drops MIDIIn subscriptions on USB events)
// Call ~reconnectMidi.() any time MIDI input stops working without restarting SC.
~reconnectMidi = {
    MIDIIn.disconnectAll;
    MIDIIn.connectAll;
    "MIDIIn: all sources reconnected".postln;
};

// ---- summary
[
    "midi-setup done (" ++ platform ++ ")",
    "LCXL src uid", ~lcxlSrcUid,
    "LC src uid", ~lcSrcUid,
    "~mOut", ~mOut
].postln;
)
