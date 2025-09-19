(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 36;
s.options.numInputBusChannels = 0;
// s.latency = 0.5;

if (s.serverRunning.not) { s.boot };

s.waitForBoot {

    "_includes/midi-setup.scd".loadRelative;

    // ---Quantized recording function
    "_includes/quant-recording.scd".loadRelative;

    // --- your synthdefs that reference ~dirt.numChannels can safely load now
    "_synthdefs/synths_common.scd".loadRelative;

    "_includes/sample_loader.scd".loadRelative;
    // --- tidal track mute LCXL
    // "_includes/tidal-dry-bus.scd".loadRelative;
 
    // "_includes/_midi-ctrl/lcxl-control.scd".loadRelative;
    // after MIDI init and your other includes:
    "_includes/_midi-ctrl/lcxl-sc-cc-router.scd".loadRelative;
    "_includes/mixer-channel.scd".loadRelative;

    "_includes/_midi-ctrl/lcxl_mixer_core_bridge.scd".loadRelative;
    "_includes/_midi-ctrl/lcxl_bank_planA_map.scd".loadRelative;
    // --- SC Meters
    // "_includes/sc-gui-meters.scd".loadRelative;

    "Setup done!".postln;
};
)


