if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI") };
if(d.notNil) {
    m = MIDIOut(0, d.uid);
    "Sending sysex...".postln;
    m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    "Sysex sent!".postln;
} {
    "No VirMIDI found".postln;
};
0.exit;
