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

    // For MixerChannel
    // "_includes/_midi-ctrl/lcxl_mixer_auto_bind.scd".loadRelative;
    // "_includes/_midi-ctrl/lcxl_toprows_param_router.scd".loadRelative;
    // "_includes/_midi-ctrl/lcxl_mixer_bank_buttons.scd".loadRelative;
    // "_includes/_midi-ctrl/lcn_param_router.scd".loadRelative;
    // "_includes/_midi-ctrl/cc_bind_hub.scd".loadRelative;
    // ~installCCByNameRouter.();
    // ~load.();                          // loads default map path
    // ~lcxlMix[\cfg].put(\faderBottom_dB, -60);
    // ~lcxlMix[\cfg].put(\faderTop_dB,    12);
    // "_includes/panic-hook.scd".loadRelative;

    // For Regular Params.
    // "_includes/_midi-ctrl/lcxl_lite_router.scd".loadRelative;    // LCXL direct mapping plus LEDs
    "_includes/_midi-ctrl/cc_bind_hub.scd".loadRelative;         // hub first so ~ccEmit exists
    // "_includes/_midi-ctrl/lcxl_param_router_full.scd".loadRelative;    // LCXL direct mapping plus LEDs
    // "_includes/_midi-ctrl/lcn_param_router.scd".loadRelative;    // optional if you still use LCN/ LCXL taper override
    "_includes/_midi-ctrl/lcn_param_router.locked.uid.v3.scd".loadRelative;         // hub first so ~ccEmit exists
    "_includes/_midi-ctrl/lcxl_param_router.locked.uid.v7.scd".loadRelative;         // hub first so ~ccEmit exists
    "_includes/_midi-ctrl/rearm_both_locked_uid.scd".loadRelative;         // hub first so ~ccEmit exists

    "Setup done!".postln;
};
)
