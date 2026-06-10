(
// Cross-platform startup.scd
// Detects platform and configures audio/MIDI accordingly

var platform, hostname;

// ---- detect platform + host
platform = Platform.case(
    \osx,   { \macos },
    \linux, { \linux },
    \windows, { \windows },
    { \unknown }
);
hostname = "hostname".unixCmdGetStdOut.stripWhiteSpace;
("Platform detected: " ++ platform ++ " / " ++ hostname).postln;

// ---- platform-specific audio configuration
case
{ platform == \macos } {
    // Scarlett 2i2 on macOS (CoreAudio)
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels  = 2;
    s.options.numOutputBusChannels = 36;
    s.options.numInputBusChannels = 0;
    s.options.sampleRate = 48000;
    s.options.memSize = 131072;
    s.options.numBuffers = 1024;
    s.options.maxNodes = 4096;
    s.options.blockSize = 64;
    // CoreAudio uses device name directly, or nil for default
    // s.options.device = "Scarlett 2i2 USB";
    "Audio config: macOS / Scarlett 2i2".postln;
}
{ platform == \linux } {
    case
    { hostname == "raspberrypi" } {
        // localhost resolves to ::1 on this Pi — force IPv4 so sclang finds scsynth
        Server.default.addr = NetAddr("127.0.0.1", 57110);
        s.options.numOutputBusChannels = 2;
        s.options.numInputBusChannels  = 2;
        s.options.sampleRate = 48000;
        s.options.memSize = 65536;
        s.options.numBuffers = 1024;
        s.options.maxNodes = 1024;
        s.options.blockSize = 128;
        s.options.hardwareBufferSize = 256;
        // Route scsynth through PipeWire's JACK layer
        Server.program = "/home/hypo/.local/bin/pw-scsynth";
        "Audio config: Raspberry Pi".postln;
    }
    { // Scarlett 18i20 on Linux (JACK)
        s.options.numOutputBusChannels = 20;    // Scarlett 18i20 -> 10 stereo outs
        s.options.numInputBusChannels  = 20;    // up to 10 stereo ins
        s.options.sampleRate = 48000;
        s.options.memSize = 131072;
        s.options.numBuffers = 1024;
        s.options.maxNodes = 4096;
        s.options.blockSize = 64;
        s.options.hardwareBufferSize = 128;     // match JACK frames/period
        s.options.device = "JACK";              // route through JACK
        "Audio config: Linux / Scarlett 18i20 via JACK".postln;
    };
}
{ // fallback
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels  = 2;
    "Audio config: using defaults".postln;
};

Server.killAll;  // ensure previous scsynth is gone before boot (avoids macOS AVAudio race)

// waitForBoot handles the boot itself; a separate s.boot here double-triggers it
// ("server 'localhost' already booting") and can leave the booting flag stuck → "not started".
s.waitForBoot {
    if(hostname == "raspberrypi") {
        // --- Raspberry Pi: lean control layer (host for norns + Maschine+/Deluge)
        // Flow: norns (arcologies) OSC → SC functions → MIDI out to Maschine+/Deluge.
        // Link syncs norns / Maschine+ / SC; Deluge is MIDI-slaved (~startDelugeClock).
        // SC-internal audio (synthdefs/samples/mixer) is intentionally NOT loaded here.

        // --- MIDI setup (cross-platform): ~mOut, ~lcxlSrcUid, ~reconnectMidi
        "/home/hypo/Music/supercollider/0_startup/_includes/midi-setup.scd".load;

        // --- LinkClock setup
        // 1. CLEAR existing clocks to kill zombies (safe on re-evaluation)
        if (~link.notNil) { ~link.clear; ~link = nil; };
        LinkClock.all.do({ |c| c.clear }); // scorched earth: clear ALL LinkClocks
        // 2. CREATE fresh clock + sane default tempo
        ~link = LinkClock(1);
        ~link.permanent = true;
        TempoClock.default = ~link;
        ~link.tempo = 120/60;
        Pdef.defaultQuant = 4;

        // --- Norns arcologies router
        // Defines ~song / ~play / ~toggle / ~oneshot and OSC handlers (/arc/trigger,
        // /arc/stop, /arc/start). Auto-loads midi-out-maschine.scd + midi-out-deluge.scd.
        "/home/hypo/Music/supercollider/0_startup/_includes/norns-router.scd".load;

        ("Setup done! (" ++ platform ++ " / " ++ hostname ++ ")").postln;
    } {
        // --- Core synths + sample loader (always load)
        "_synthdefs/synths_common.scd".loadRelative;
        "_synthdefs/ufn_defs.scd".loadRelative;
        "_synthdefs/analog_synthdefs.scd".loadRelative;
        "_synthdefs/neutron.scd".loadRelative;
        "_synthdefs/model_d.scd".loadRelative;
        "_synthdefs/biscuit.scd".loadRelative;
        "_includes/sample_loader.scd".loadRelative;
        "_synthdefs/fx_defs.scd".loadRelative;

        // --- MIDI setup (cross-platform)
        "_includes/midi-setup.scd".loadRelative;

        // --- MIDI Controllers (auto-detect: APC40 mkII > Launch Control XL)
        "_includes/_midi-ctrl/midi-device-loader.scd".loadRelative;

        // Launch Pad Mini - uncomment if you use it
        "_includes/_midi-ctrl/launch-pad-mini/lp-param-router.scd".loadRelative;

        s.sync; // ensure all SynthDefs are registered on server before mixer init

        // --- TouchOSC OSC router (always load — no device detection needed)
        // "_includes/_osc-ctrl/tosc-router.scd".loadRelative;
        // "_includes/_osc-ctrl/tosc-pad-router.scd".loadRelative;
        // "_includes/_osc-ctrl/tosc-fx.scd".loadRelative;  // defines ~toscFXBind/~toscFXSync used by fx_defs ~fxSetup functions

        // --- Mixer channels (with conditional controller bindings)
        "_includes/mixer-channel-16s.scd".loadRelative;
        "_includes/mixer-channel-stem-record.scd".loadRelative;
        "_includes/ndef2mixer-channel.scd".loadRelative;

        // --- Helpers
        "_includes/_helpers/helpers.scd".loadRelative;
        "_includes/cc-logger.scd".loadRelative;

        // --- LinkClock setup
        // 1. CLEAR existing clocks to kill Zombies
        if (~link.notNil) { ~link.clear; ~link = nil; };
        LinkClock.all.do({ |c| c.clear }); // Scorched earth policy: clear ALL LinkClocks

        // 2. CREATE the new clock
        ~link = LinkClock(1).latency_(Server.default.latency - 0.567);
        ~link.permanent = true;

        TempoClock.default = ~link;
        // 3. RESET Tempo to a sane default (120 BPM) immediately
        ~link.tempo = 120/60;

        Pdef.defaultQuant = 4;

        q = q ?? (); // A common SC pattern to create a global storage dict
        q.bw = NetAddr("127.0.0.1", 9001);
        Event.addEventType(\bw, {
            // We use q.bw instead of ~bw to avoid nil receiver errors
            var path = ~path.asString;
            if(path.beginsWith("//")) { path = path.keep(path.size * -1 + 1) };
            q.bw.sendMsg(path, ~val);
        });

        // --- Norns arcologies router (uncomment when using Norns + Deluge workflow)
        "_includes/norns-router.scd".loadRelative;

        // --- Cleanup any launchpad state if present
        if(~lpMini.notNil) { ~lpMini[\clearGrid].(); };

        ("Setup done! (" ++ platform ++ " / " ++ hostname ++ ")").postln;
    };
};
)
