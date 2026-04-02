if(MIDIClient.initialized.not) { MIDIClient.init };
"Attempting sysex with uid 0".postln;
try {
    MIDIOut(0, 0).sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    "Success with 0".postln;
} { "Failed with 0".postln };

"Attempting sysex with large uid".postln;
try {
    MIDIOut(0, 1000000).sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    "Success with large".postln;
} { "Failed with large".postln };
0.exit;
