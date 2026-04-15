(
// Cross-platform startup.scd
// Detects platform and configures audio/MIDI accordingly

var platform;

// ---- detect platform
platform = Platform.case(
    \osx,   { \macos },
    \linux, { \linux },
    \windows, { \windows },
    { \unknown }
);
("Platform detected: " ++ platform).postln;

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
    // Scarlett 18i20 on Linux (JACK)
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
}
{ // fallback
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels  = 2;
    "Audio config: using defaults".postln;
};

Server.killAll;  // ensure previous scsynth is gone before boot (avoids macOS AVAudio race)
s.boot;

s.waitForBoot {
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
    "_includes/_osc-ctrl/tosc-router.scd".loadRelative;
    // "_includes/_osc-ctrl/tosc-pad-router.scd".loadRelative;
    "_includes/_osc-ctrl/tosc-fx.scd".loadRelative;  // defines ~toscFXBind/~toscFXSync used by fx_defs ~fxSetup functions

    // --- Mixer channels (with conditional controller bindings)
    "_includes/mixer-channel-16s.scd".loadRelative;
    "_includes/mixer-channel-stem-record.scd".loadRelative;
    "_includes/ndef2mixer-channel.scd".loadRelative;

    // --- Helpers
    "_includes/_helpers/helpers.scd".loadRelative;

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

    // --- Cleanup any launchpad state if present
    if(~lpMini.notNil) { ~lpMini[\clearGrid].(); };

    ("Setup done! (" ++ platform ++ ")").postln;
};
)
