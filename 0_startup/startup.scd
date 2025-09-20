(
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 36;
s.options.numInputBusChannels = 0;

if (s.serverRunning.not) { s.boot };

s.waitForBoot {

    "_includes/midi-setup.scd".loadRelative;

    "_includes/quant-recording.scd".loadRelative;
    "_synthdefs/synths_common.scd".loadRelative;
    "_includes/sample_loader.scd".loadRelative;

    // --- LCXL router must be before bindings/bridge
    "_includes/_midi-ctrl/lcxl-sc-cc-router.scd".loadRelative;

    // load your saved CC map (so bindings have keys to attach to)
    ~installCCByNameRouter.();
    ~ccLoad.();

    // (optional) bank number print when you change banks
    "_includes/_midi-ctrl/lcxl-bank-post.scd".loadRelative;

    // your mixer (defines ~m36_tr1..~m36_tr16 etc.)
    "_includes/mixer-channel.scd".loadRelative;

    // bind LCXL → mixer (levels + pan)
    "_includes/_midi-ctrl/lcxl_mixer_core_bridge.scd".loadRelative;

    // optional: only if you still use the default “Plan A” map filler
    "_includes/_midi-ctrl/lcxl_bank_planA_map.scd".loadRelative;

    "Setup done!".postln;
};
)

