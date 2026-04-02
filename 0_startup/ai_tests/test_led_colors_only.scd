if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("VirMIDI 0-2") };
if(d.notNil) {
    "Wait...".postln;
    AppClock.sched(3.0, {
        "Testing LED VirMIDI write...".postln;
        m = MIDIOut.newByName(d.device, d.name);
        100.do { |i|
            m.noteOn(0, i, 127);
            m.control(0, i, 127);
        };
        "LED writes done!".postln;
        nil
    });
};
{ 6.wait; 0.exit }.fork(AppClock);
