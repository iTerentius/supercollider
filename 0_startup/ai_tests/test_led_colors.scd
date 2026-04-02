if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("Launchpad Mini MK3") and: { ep.name.endsWith("DA") } };
if(d.notNil) {
    "Wait...".postln;
    AppClock.sched(3.0, {
        "Testing LED write lock...".postln;
        m = MIDIOut(0, d.uid);
        m.connect(d.uid);
        100.do { |i|
            m.noteOn(0, i, 127);
            m.control(0, i, 127);
        };
        "LED writes done!".postln;
        nil
    });
};
{ 6.wait; 0.exit }.fork(AppClock);
