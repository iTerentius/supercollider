if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    "Wait 1...".postln;
    AppClock.sched(3.0, {
        "Testing noteOn/control write...".postln;
        m = MIDIOut.newByName(d.device, d.name);
        m.noteOn(0, 11, 127);
        m.control(0, 11, 127);
        "LED writes done!".postln;
        nil
    });
};
{ 6.wait; 0.exit }.fork(AppClock);
