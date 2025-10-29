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

    // --- APC40mk2 ----
    // "_includes/_midi-ctrl/apc40/apc40mk2_loader.scd".loadRelative; // Launch-controls for just params.

    // --- Launch Controls ---
    "_includes/midi-setup.scd".loadRelative;
    "_includes/_midi-ctrl/launch-control/lc_loader.scd".loadRelative; // Launch-controls for just params.

    // --- ddWMixerChannel
    "_includes/mixer-channel-16s.scd".loadRelative;
    ~stemBaseDir = Platform.userHomeDir +/+ "Music/SC_Recordings";
    "_includes/mixer-channel-stem-record.scd".loadRelative;
    // "_includes/mixer-channel-gui.scd".loadRelative;

    // --- Ndef Mixer
    // "_includes/ndef-mixer.scd".loadRelative; Helpers
    // "_includes/_helpers/peuc.scd".loadRelative;

   // s.plotTree;
   // ServerMeter.new;
   // FreqScope.new;
   // Stethoscope.new;
   // HelpBrowser.new;
 
   // Ableton LinkClock
   // "_includes/ableton-link-gui.scd".loadRelative;
  ~link = LinkClock(1).latency_(Server.default.latency);

    "[Setup done!]".postln;
};
)
