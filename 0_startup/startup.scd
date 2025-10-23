(
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 36;
s.options.numInputBusChannels = 0;

if (s.serverRunning.not) { s.boot };

s.waitForBoot {
    // --- Core MIDI + quantized recording + common synths + sample loader
    // "_includes/quant-recording.scd".loadRelative;
    "_synthdefs/synths_common.scd".loadRelative;
    "_includes/sample_loader.scd".loadRelative;
    // "_includes/_midi-ctrl/midi-device-loader.scd".loadRelative; // Launch-controls for just params.
    // APC40mk2
    "_includes/_midi-ctrl/apc40/apc40mk2_loader.scd".loadRelative; // Launch-controls for just params.
    // Launch Controls
    // "_includes/midi-setup.scd".loadRelative;
    // "_includes/_midi-ctrl/launch-control/lc_loader.scd".loadRelative; // Launch-controls for just params.

    "_includes/mixer-channel-16s.scd".loadRelative;
    "_includes/mixer-channel-stem-record.scd".loadRelative;
    // "_includes/ndef-mixer.scd".loadRelative; Helpers
    // "_includes/_helpers/peuc.scd".loadRelative;

    //MIDI Controllers
    // "_includes/_midi-ctrl/launch-control/launch-controls.mixer-channel.scd".loadRelative; // Launch-controls with auto binding for mixer + params for leftovers.
   // s.plotTree;
   // ServerMeter(s);
    // "_includes/mixer-channel-gui.scd".loadRelative;
    "Setup done!".postln;

    // "_includes/_midi-ctrl/apc40/apc_device_group_bind_fix.scd".loadRelative;
    // ~apcArmGrid.();
};
)
