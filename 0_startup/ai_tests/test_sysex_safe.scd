if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("Launchpad Mini MK3") and: { ep.name.endsWith("DA") } };
if(d.notNil) {
    "Found DA port, attempting newByName sysex...".postln;
    m = MIDIOut.newByName(d.device, d.name);
    m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    "Sent. If we crash here, newByName is still causing the stall.".postln;
} {
    "LP Mini not connected".postln;
};
{ 1.wait; 0.exit }.fork(AppClock);
