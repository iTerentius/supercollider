"Starting test".postln;
~testCrash = {
    // just boot and wait
    s.waitForBoot {
        "Booted".postln;
        2.wait;
        "Sending MIDI sysex".postln;
        d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
        if(d.notNil) {
            m = MIDIOut.newByName(d.device, d.name);
            m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
            0.05.wait;
            m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
            (1..8).do { |i| m.control(0, 90+i, 3) };
            "MIDI Sent".postln;
        };
        4.wait;
        "Done waiting".postln;
        0.exit;
    };
};
~testCrash.();
