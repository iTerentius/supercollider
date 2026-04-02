if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    m = MIDIOut.newByName(d.device, d.name);
    "Flooding MIDI...".postln;
    100.do { |i|
        m.noteOn(0, i, 127);
    };
    "Flooded!".postln;
};
0.exit;
