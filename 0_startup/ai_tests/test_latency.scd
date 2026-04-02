if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    "Wait 1...".postln;
    AppClock.sched(4.5, {
        "Sending sysex...".postln;
        m = MIDIOut.newByName(d.device, d.name);
        // NO latency, NO wait. Send entirely synchronous
        m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
        m.sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
        "Sysex done!".postln;
        nil
    });
};
{ 10.wait; 0.exit }.fork(AppClock);
