// Ndef synth that accepts MIDI CC value for frequency
(
Ndef(\ccfreq, { |out = 0, freq = 440|
    var sig;
    sig = SinOsc.ar(freq);
    Out.ar(out, sig * 0.1);
});
)

// Map MIDI CC (e.g., CC 1 on channel 0) to Ndef frequency
MIDIIn.connectAll;
MIDIdef.cc(\ccfreq, { |val, num, chan, src|
    // Map CC value (0-127) to frequency range (e.g., 40-2000 Hz)
    var freq = val.linexp(0, 127, 40, 2000);
    Ndef(\ccfreq).set(\freq, freq);
}, 1, 0); // CC number 1, channel 0

Ndef(\ccfreq).play;

