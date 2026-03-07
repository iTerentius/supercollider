// =============================================================================
// sc_system reference — index
// =============================================================================
// Individual reference files in ./reference/ folder:
//
//   ref_sample_loader.scd    — ~sTree, ~fbufs, ~loadSamps, ~playBuf, ~chopSample
//   ref_mixer_channels.scd   — ddwMixerChannel topology, routing, playfx, sends
//   ref_lcxl.scd             — Launch Control XL param router (banks, faders, knobs, pads)
//   ref_launch_control.scd   — Launch Control (small) router (banks, knobs, LEDs)
//   ref_launchpad_mini.scd   — Launchpad Mini MK3 grid bindings
//   ref_apc40.scd            — APC40 mkII grid, faders, knobs, scenes
//   ref_midi_setup.scd       — ~mOut DAW MIDI output
//   ref_synthdefs.scd        — synth definitions (\pBs, \pBm, \gb1, \duck, etc.)
//   ref_stem_recording.scd   — multi-track stem recording
//   ref_quant_recording.scd  — quantized server recording
//   ref_linkclock.scd        — ~link (LinkClock) tempo/sync
//   ref_extensions.scd       — .stopQ and other extensions
//   ref_common_patterns.scd  — full workflow examples
//
// Files loaded via startup.scd (in order):
//   _synthdefs/synths_common.scd
//   _includes/sample_loader.scd
//   _includes/midi-setup.scd
//   _includes/_midi-ctrl/launch-control/lc_loader.scd
//     -> lc-lcxl-router-revamp.scd
//   _includes/_midi-ctrl/launch-pad-mini/lp-param-router.scd
//   _includes/mixer-channel-16s.scd
//
// Not loaded by startup.scd but available as standalone includes:
//   _includes/mixer-channel-stem-record.scd
//   _includes/quant-recording.scd
//   _includes/record-on-start.scd
