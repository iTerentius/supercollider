(
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 36;
s.options.numInputBusChannels = 0;

if (s.serverRunning.not) { s.boot };

s.waitForBoot {
    "Current!".postln;
    // --- Core MIDI + quantized recording + common synths + sample loader
    "_includes/midi-setup.scd".loadRelative;
    "_includes/quant-recording.scd".loadRelative;
    "_synthdefs/synths_common.scd".loadRelative;
    "_includes/sample_loader.scd".loadRelative;
    "_includes/_midi-ctrl/launch-control/launch-controls.scd".loadRelative; // Launch-controls for just params.
    "_includes/mixer-channel-16s.scd".loadRelative;
    "_includes/mixer-channel-stem-record.scd".loadRelative;
    // "_includes/ndef-mixer.scd".loadRelative;
    // Helpers
    // "_includes/_helpers/peuc.scd".loadRelative;

    //MIDI Controllers
    // "_includes/_midi-ctrl/launch-control/launch-controls.mixer-channel.scd".loadRelative; // Launch-controls with auto binding for mixer + params for leftovers.
   // s.plotTree;
   // ServerMeter(s);
    // "_includes/mixer-channel-gui.scd".loadRelative;
    "Setup done!".postln;
};
)
