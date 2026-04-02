if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    m = MIDIOut.newByName(d.device, d.name);
    m.latency = 0;
    
    // Send a tight burst of CCs, which is what watcher does
    "Sending CC burst...".postln;
    fork {
        100.do { |i| 
            m.control(0, 19, i % 127);
        };
        "CC burst sent".postln;
        1.wait;
        0.exit;
    }
};
