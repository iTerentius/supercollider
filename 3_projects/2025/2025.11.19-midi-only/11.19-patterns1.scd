MIDIClient.init;
~mOut = MIDIOut.new(0);
~mOut.connect(0);
~mOut.control(0, 1, 40);
~mOut.noteOn(0, 61, 60);
~mOut.postln


Pbind(\type, \midi, )
MIDIClient.init;
MIDIClient.destinations.do(_.postln);
MIDIClient.sources.do(_.postln);
(
// 2025-11-21
var devName, portName;

//MIDIClient.init;

devName = "Virtual Raw MIDI 8-0";
portName = "VirMIDI 8-0";

~mOut = MIDIOut.newByName(devName, portName);

if (~mOut.isNil) {
    "MIDIOut.newByName failed, falling back to index 0".warn;
    ~mOut = MIDIOut.new(0);
    ~mOut.connect(0);
};

~mOut.latency = s.latency;
)
