if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    m = MIDIOut.newByName(d.device, d.name);
    "Flooding MIDI and Sysex...".postln;
    fork {
        100.do { |i|
            m.noteOn(0, i, 127);
        };
        m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
        0.05.wait;
        m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
        100.do { |i|
            m.noteOn(0, i, 127);
        };
        "Flooded!".postln;
        1.wait;
        0.exit;
    }
};
