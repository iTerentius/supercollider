if(MIDIClient.initialized.not) { MIDIClient.init };
d = MIDIClient.destinations.detect { |ep| ep.name.containsi("APC40 mkII") };
if(d.notNil) {
    "Wait...".postln;
    AppClock.sched(3.0, {
        "Testing ALSA write lock with APC and routine...".postln;
        m = MIDIOut.newByName(d.device, d.name);
        try {
            Routine {
                100.do { |i|
                    m.noteOn(0, i, 127);
                    0.05.wait;
                };
                "LED writes done!".postln;
            }.play(AppClock);
        } { |e| "Routine primitive failed".postln; };
        nil
    });
};
{ 6.wait; 0.exit }.fork(AppClock);
