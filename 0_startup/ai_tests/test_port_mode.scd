if(MIDIClient.initialized.not) { MIDIClient.init };
// Completely minimal test to open ONLY the DA port with NO VirMIDI routing
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("Launchpad Mini MK3") and: { ep.name.endsWith("DA") } };
if(d.notNil) {
    "Found DA port, attempting direct ALSA sysex...".postln;
    m = MIDIOut(0, d.uid);
    m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    "Sent. If we crash here, the DA port itself cannot handle SysEx on Linux ALSA.".postln;
} {
    "LP Mini not connected".postln;
};
{ 1.wait; 0.exit }.fork(AppClock);
