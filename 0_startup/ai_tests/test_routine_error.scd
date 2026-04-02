if(MIDIClient.initialized.not) { MIDIClient.init };
"Testing routine sleep collision...".postln;
fork {
    100.do { |i|
        0.05.wait;
        "Ticking ".post; i.postln;
    };
    "Done".postln;
    0.exit;
};
