(
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 36;
s.options.numInputBusChannels = 0;

if (s.serverRunning.not) { s.boot };

s.waitForBoot {

    // --- Core MIDI + quantized recording + common synths + sample loader
    "_includes/midi-setup.scd".loadRelative;
    "_includes/quant-recording.scd".loadRelative;
    "_synthdefs/synths_common.scd".loadRelative;
    "_includes/sample_loader.scd".loadRelative;

    // --- LCXL router must load before CC map + bindings
    // "_includes/_midi-ctrl/lcxl-sc-cc-router.scd".loadRelative;

    // --- Load your saved CC map (so bindings have keys/chan to attach to)
    // ~installCCByNameRouter.();  // from router include
    // ~ccLoad.();                  // loads lcxl-router.map / _lcxl_cc_map.txt

    // --- Optional: posts bank changes; if you KEEP this, you may want to
    //     DISABLE the big banner inside the binder to avoid double prints.
    // "_includes/_midi-ctrl/lcxl-bank-post.scd".loadRelative;

    // --- Your mixer: defines ~m36_* objects and/or setters like ~m36_setLevel/~m36_setPan
    //"_includes/mixer-channel.scd".loadRelative;

    // --- LCXL → Mixer (levels + pan), 3-bank (b0/b1/b2) binder
    //     REPLACES: _includes/_midi-ctrl/lcxl_mixer_core_bridge.scd
    //
    // Put the new file here (use the 3-bank code I sent and save it as):
    //     _includes/_midi-ctrl/lcxl_mixer_bind_3bank.scd
    //
    // "_includes/_midi-ctrl/lcxl_mixer_bind_3bank.scd".loadRelative;

    // --- Optional Plan-A filler (only if you still use that helper)
    s.plotTree;
    ServerMeter(s);
     
    //"_includes/_midi-ctrl/lcxl_toprows_param_router.scd".loadRelative;
    //"_includes/_midi-ctrl/lcxl_mixer_bank_buttons.scd".loadRelative;
    //"_includes/_midi-ctrl/lcn_param_router.scd".loadRelative;
    //"_includes/_midi-ctrl/cc_bind_hub.scd".loadRelative;
    //"_includes/panic-hook.scd".loadRelative;

    "Setup done!".postln;
};
)
