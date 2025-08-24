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

    // --- SuperDirt (create once)
    ~dirt = ~dirt ?? { SuperDirt(2, s) };
    ~dirt.loadSoundFiles;   // default Dirt paths
    ~dirt.loadSoundFiles("~/Music/supercollider/_samples/*");
    ~dirt.loadSoundFiles("~/Music/supercollider/_samples/**");
    ~dirt.loadSoundFiles("~/Music/supercollider/_samples/**/*");
    ~dirt.loadSoundFiles("~/Music/supercollider/_samples/**/**/*");
    s.sync; // wait for sample scan to finish

    // --- start Dirt; send orbits to stereo bus pairs (0,2,4,…,24)
    ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32]);
    s.sync;

    // optional convenient aliases: ~d1, ~d2, … for however many orbits actually exist
    ~dirt.orbits.do { |o, i| ("d" ++ (i + 1)).asSymbol.envirPut(o) };

    // create a synchronized clock
    // l = LinkClock(1).latency_(Server.default.latency);

    // --- collect each orbit’s dry bus (you already had this)
    ~dirtbusses = ~dirt.orbits.collect { |x| x.dryBus };

    // --- your readorb synthdef (unchanged)
    SynthDef(\readorb, { |out, amp = 1, n = 0, obus = 0|
        var bus = Select.kr(n, ~dirtbusses);
        var sound = InFeedback.ar(bus, ~dirt.numChannels);
        Out.ar(out, sound * (amp * 2.5));
    }).add;

    "_includes/midi-setup.scd".loadRelative;
    "_includes/_midi-ctrl/lcxl-control.scd".loadRelative;
    "_includes/_midi-ctrl/apc40mk2-control.scd".loadRelative;
    // --- bring up SuperDirtMixer (assumes ~dirt is running; see file below)
    // "_includes/superdirt-mixer.scd".loadRelative;
    // --- SC Meters
    "_includes/sc-gui-meters.scd".loadRelative;
    // ---Quantized recording function
    "_includes/quant-recording.scd".loadRelative;
    // -- Tidal & SC sync setup
    // "_includes/sc-tidal-sync.scd".loadRelative;
    // --- your synthdefs that reference ~dirt.numChannels can safely load now
    "_synthdefs/synths_common.scd".loadRelative;
    "_includes/tidal-dry-bus.scd".loadRelative;

    // Defer side-effects until everything is loaded:
    AppClock.sched(0.2, {
        if(File.exists(~lcxlMapPath.())) {
            ~loadMap.();
        }{
            ~pp.("loadMap", (info: "no file", path: ~lcxlMapPath.()));
            // optionally auto-prompt first-run
            // ~pp.("hint", (a: "Run ~startDeviceLearn.() then ~startLearn.() once"));
        };
        nil
    });
    "Setup done!".postln;
};
)


