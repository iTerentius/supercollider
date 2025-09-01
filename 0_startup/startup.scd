(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 36;
s.options.numInputBusChannels = 0;
// s.latency = 0.5;

//boot the server (don’t use s.reboot in startup)
if (s.serverRunning.not) { s.boot };

s.waitForBoot {

    // ----------------------------------------------------------------
    // your sample preloads (keep or remove as you like)
    // b = SoundFile.collectIntoBuffers("~/Music/supercollider/_samples/808s_by_SHD/Classic/C/*");
    // ("default_synthdefs.scd").loadRelative;
    // ("Snippets.scd").loadRelative;
    // StageLimiter.activate;   // if you use BatLib
    // ----------------------------------------------------------------

    // Map path MUST be a String when used with File.exists
    // ~lcxlMapPath = {
    //     var base = if(thisProcess.nowExecutingPath.notNil) {
    //         PathName(thisProcess.nowExecutingPath).pathOnly   // String
    //     }{
    //         Platform.userHomeDir                              // String
    //     };
    //     (base +/+ "_includes/_midi-ctrl/lcxl-track-mute.map").asString
    // };
    // SuperDirt
    // "_includes/superdirt.scd".loadRelative;
    // "_includes/superdirt-mixer.scd".loadRelative;

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
    (thisProcess.nowExecutingPath.dirname +/+ "_includes/_midi-ctrl/lcxl-sc-cc-router.scd").load;
    // "_includes/_midi-ctrl/lcxl-sc-cc-router.scd".loadRelative;
    // install & load LCXL router
    ~lcxlInit.();   // <-- safe, idempotent, only call once

    // --- SC Meters
    "_includes/sc-gui-meters.scd".loadRelative;

    // AppClock.sched(0.2, {
    //     var p;
    //     ~installCCByNameRouter.();
    //     ~installBankButtons.();
    //
    //     p = ~lcxlMapPath.().asString;
    //     if (File.exists(p)) {
    //         ~loadMap.();      // restores UID, channel, ccMap
    //     } {
    //         ~pp.("loadMap", (info:"no file", path:p));
    //     };
    //     nil   // <- important to stop rescheduling
    // });
    "Setup done!".postln;
};
)


