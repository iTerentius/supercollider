# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SuperCollider music production workspace with a modular startup system, date-organized projects, and MIDI controller integration. Supports live coding, sample-based composition, and DAW integration.

## Directory Structure

- `0_startup` → symlink to `/home/hypostatic/Music/sc_system/0_startup/` (shared initialization system)
- `_samples` → symlink to `/home/hypostatic/Music/_samples/` (sample library)
- `1_example-notes/` - Learning examples and custom classes
- `2_Templates/` - Reusable Ndef routing and controller mapping templates
- `3_projects/` - Active work organized as `YYYY/YYYY.MM.DD/`
- `4_Misc/` - Scratch files

## Project File Convention

Files in `3_projects/YYYY.MM.DD/` use numbered prefixes for load order:
- `00_main.scd` - Project loader
- `10_defs.scd` - SynthDefs and Ndefs
- `20.[a-z]_base.scd` - Sample assignments, base generators
- `30.[a-z].[0-9]_pats.scd` - Pbind patterns
- `90_controls.scd` - Live performance controls
- `Z_scratch.scd` - Experimental workspace

## Key Globals (from 0_startup)

**Sample System:**
- `~sTree` - Nested dictionary: `~sTree[\folder][\filename]` → Buffer
- `~loadSamps.(path)` - Load sample directory recursively
- `~playBuf.(buf, amp, pan, rate, out)` - Audition helper

**Mixer Channels:**
- `~m1` - Master output
- `~t1..~t12` - Track channels → master
- `~r1..~r4` - Return/FX channels
- `~pbd1, ~psd1, ~phh1...` - Percussion submix channels

**Routing Pattern:**
```supercollider
Synth(\name, [\out, ~t1.inbus.index])
Pbind(\out, ~pbd1.inbus.index, ...)
~ensurePostSend.(~t1, ~r1, 0.3)  // send to return
```

**Clock:**
- `~link` - LinkClock for tempo sync (also set as TempoClock.default)

## Platform Notes

**Linux:** JACK audio to Scarlett 18i20, ALSA MIDI, VirMIDI for DAW
**macOS:** CoreAudio to Scarlett 2i2, IAC Driver for virtual MIDI

The startup system auto-detects platform and configures accordingly.

## MIDI Controllers

Controller loaders in `0_startup/_includes/_midi-ctrl/`:
- APC40 Mk2 - pad triggering via `~apcAssignPad.(pad, pdef)`
- Launch Control XL - fader/knob binding via `~lcxlBindPdef.(cc, pdef)`
- Launch Pad Mini

## Common Patterns

```supercollider
// Load samples
~loadSamps.("path/to/samples/");

// Create pattern routed to mixer
Pdef(\kick, Pbind(
    \instrument, \playBuf,
    \buf, ~sTree[\808][\kick],
    \dur, 1,
    \out, ~pbd1.inbus.index
)).play(~link);

// Live parameter control
Pdefn(\kick_amp, 0.8);

// Ndef parameter tweaking
Ndef(\synth).set(\freq, 440);
```
