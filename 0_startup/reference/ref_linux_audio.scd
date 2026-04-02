// =============================================================================
// LINUX AUDIO & MIDI ROUTING  (PipeWire / Scarlett 18i20 / ALSA)
// =============================================================================

// -----------------------------------------------------------------------------
// AUDIO: SC (JACK) <-> Scarlett 18i20
// -----------------------------------------------------------------------------
// SC (scsynth) appears as a "JACK" node in PipeWire with 20 in/20 out ports.
// WirePlumber will auto-connect it to the default sink unless blocked.
//
// Key files:
//   ~/.local/bin/sc-scarlett-connect.sh   — pw-link watch script (1:1, 20ch)
//   ~/.config/systemd/user/sc-scarlett-connect.service
//   ~/.config/pipewire/jack.conf.d/90-scsynth-no-autoconnect.conf
//
// The .conf file sets node.autoconnect=false for scsynth/supernova so
// WirePlumber doesn't stomp on the 1:1 hw mapping with its default policy.
//
// Port naming:
//   SC output:   JACK:out_1 .. JACK:out_20
//   SC input:    JACK:in_1  .. JACK:in_20
//   Scarlett hw: alsa_output.hw_USB_0:playback_AUX0..AUX19 (0-indexed)
//                alsa_input.hw_USB_0:capture_AUX0..AUX19

// Check live connections:
//   pw-link -l | grep -A2 "^JACK:out_"

// Service commands:
//   systemctl --user status  sc-scarlett-connect.service
//   systemctl --user restart sc-scarlett-connect.service
//   systemctl --user stop    sc-scarlett-connect.service

// -----------------------------------------------------------------------------
// SCARLETT HARDWARE MIXER — headphone reset gotcha
// -----------------------------------------------------------------------------
// The 18i20 has an internal DSP mixer (Mix A–L) that independently controls
// what each physical output hears. On USB power loss / reconnect the device
// reloads its flash preset, which sets ALL inputs in Mix A/B/C to +12.0 dB.
// This causes every source (analogue + PCM) to be summed at max gain into the
// output — extremely loud and distorted, sounds "doubled".
//
// Symptom: audio from SC suddenly much louder/distorted, especially headphones.
// Headphone output is typically sourced from Mix A (L) and Mix B (R).
//
// Fix via alsa-scarlett-gui (AUR: alsa-scarlett-gui):
//   Mix A row: all knobs -> -inf, then PCM 1 -> 0.0
//   Mix B row: all knobs -> -inf, then PCM 2 -> 0.0
//   Mix C–L: leave at -inf unless specifically used
//
// To check alsamixer for the Scarlett (find card number first):
//   aplay -l | grep -i scarlett       // find card N
//   alsamixer -c N                    // open mixer for that card
//   // F3=Playback  F4=Capture  F5=All  F6=Select card

// Verify routing (should be clean 1:1, no duplicate connections):
//   pw-link -l | grep -A2 "^JACK:out_"

// -----------------------------------------------------------------------------
// MIDI OUTPUT: APC40 LEDs + ~mOut (DAW)
// -----------------------------------------------------------------------------
// MIDIOut.newByName on Linux/PipeWire does NOT create stable connections.
// aconnect links are dropped immediately by PipeWire. Must use pw-link.
//
// Key file:  ~/.local/bin/sc-midi-connect.sh  (+ sc-midi-connect.service)
//
// Connections (managed by service):
//   SC:out0  -> APC40 mkII MIDI 1 (playback)    // ~apcOut LEDs
//   SC:out1  -> VirMIDI 0-0 (playback)           // ~mOut DAW notes
//   SC:out6  -> LP Mini MK3 MI (playback)        // ~lpMini LEDs (see below)
//
// Service commands:
//   systemctl --user status  sc-midi-connect.service
//   systemctl --user restart sc-midi-connect.service
//
// If APC LEDs are dark after boot:
//   1. systemctl --user status sc-midi-connect.service  // check it's running
//   2. In SC: ~apcIntroGenericMode.(); AppClock.sched(0.1, { ~apcRepaintAll.() })

// -----------------------------------------------------------------------------
// MIDI OUTPUT: LP Mini MK3 LEDs (Linux)
// -----------------------------------------------------------------------------
// LP Mini MK3: LED commands must go to the MI port, NOT the DA port.
// DA port receives no LED response on Linux.
//
// Working path:
//   SC ~lpMini[\out]  (port 6)
//   -> PipeWire SuperColliderout6
//   -> pw-link -> LP Mini MK3 MI (playback)    // direct, no VirMIDI hop
//
// If LP Mini grid is dark:
//   1. systemctl --user status sc-midi-connect.service
//   2. In SC: ~lpMini[\clearGrid].(); AppClock.sched(0.2, { ~lpMini[\repaint].() })

// -----------------------------------------------------------------------------
// PIPEWIRE SERVICE MANAGEMENT
// -----------------------------------------------------------------------------
// Restart PipeWire stack (e.g. after config changes, or if audio goes silent):
//   systemctl --user restart wireplumber pipewire-pulse pipewire
//
// Restart individual services:
//   systemctl --user restart pipewire
//   systemctl --user restart pipewire-pulse
//   systemctl --user restart wireplumber
//
// Check PipeWire status:
//   systemctl --user status pipewire pipewire-pulse wireplumber
//   pw-link -l          // all current links
//   pw-link -o          // output ports
//   pw-link -i          // input ports
//   pw-dump             // full PipeWire node/port dump (verbose)
//
// After restarting PipeWire, also restart SC routing services:
//   systemctl --user restart sc-scarlett-connect.service sc-midi-connect.service

// -----------------------------------------------------------------------------
// BOOT ORDER / DEPENDENCY SUMMARY
// -----------------------------------------------------------------------------
// 1. PipeWire + WirePlumber start at login (systemd user session)
// 2. 90-scsynth-no-autoconnect.conf prevents WP from auto-linking scsynth
// 3. SC boots (scsynth starts as JACK client)
// 4. sc-scarlett-connect.service detects JACK node, runs 1:1 audio pw-links
// 5. sc-midi-connect.service detects SC MIDI ports, runs MIDI pw-links
//
// If SC is restarted (not a full reboot), both watch services will detect
// the new JACK/MIDI nodes and re-establish connections automatically.
