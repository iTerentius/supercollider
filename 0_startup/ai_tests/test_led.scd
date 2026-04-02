if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    m = MIDIOut.newByName(d.device, d.name);
    "Sending bank LEDs...".postln;
    fork {
        (1..8).do { |i|
            m.control(0, 90 + i, 3);
            0.01.wait;
        };
        "Bank LEDs sent!".postln;
        1.wait;
        0.exit;
    };
};
