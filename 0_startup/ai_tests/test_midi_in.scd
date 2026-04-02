if(MIDIClient.initialized.not) { MIDIClient.init };
MIDIIn.connectAll;
MIDIFunc.trace(true);
"MIDI tracing enabled for 10 seconds. Press pads on the Launchpad!".postln;
{
    10.wait;
    MIDIFunc.trace(false);
    "MIDI tracing disabled.".postln;
    0.exit;
}.fork;
