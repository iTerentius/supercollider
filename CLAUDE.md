# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

SuperCollider music production workspace with a modular startup system, date-organized projects, and MIDI controller integration. Supports live coding, sample-based composition, and DAW integration.

## Directory Structure

```
supercollider/
├── 0_startup/               # Shared startup system (formerly sc_system, now merged)
│   ├── startup.scd          # Main boot (platform detection, load order)
│   ├── reference/           # API reference docs per controller/subsystem
│   ├── _synthdefs/          # SynthDefs
│   └── _includes/
│       ├── sample_loader.scd
│       ├── midi-setup.scd
│       ├── mixer-channel-16s.scd
│       ├── mixer-channel-stem-record.scd
│       ├── quant-recording.scd
│       ├── _helpers/        # helpers.scd — ~makeFxSendTdef etc.
│       └── _midi-ctrl/      # Controller loaders
├── Extensions/              # SC class extensions (ext_stopQ, Psection, etc.)
├── _samples/                # Symlink to sample library
├── 1_example-notes/         # Learning examples and custom classes
├── 2_Templates/             # Reusable Ndef routing and controller mapping templates
├── 3_projects/              # Active work organized as YYYY/YYYY.MM.DD/
└── 4_Misc/                  # Scratch files
```

## Boot Sequence (`0_startup/startup.scd`)

1. Platform detection (macOS/Linux)
2. Audio device config (Scarlett 18i20 on Linux/JACK, Scarlett 2i2 on macOS/CoreAudio)
3. Server boot: memSize 131072, 1024 buffers, blockSize 64
4. Load synthdefs → sample_loader → midi-setup → midi-device-loader → LP Mini router
5. Mixer channels → helpers → LinkClock at 120 BPM

## Project File Convention

Files in `3_projects/YYYY/YYYY.MM.DD/` — recent projects use freeform naming:
- `arrangement.scd` / `score.scd` - main structure
- `parts/` - per-instrument pattern files
- `lib/` - bindings, config, fx
- `control.scd` - live performance controls
- `scratch.scd` - experimental workspace

## Core Globals

### Sample System (`_includes/sample_loader.scd`)
- `~sTree` - Nested dict: `~sTree[\folder][\file]` → Buffer
- `~loadSamps.(path)` - Recursive audio file loader
- `~playBuf.(buf, out, amp, rate, loop, start, pan)` - Audition helper
- `~pBuf.(pattern)` - Wraps Pbind to auto-select instrument from `\buf` key

### Mixer Channels (`_includes/mixer-channel-16s.scd`)
```
~m1 (Master, out 0)
├── ~t1..~t12 (Tracks)
└── ~r1..~r4 (Returns: r1=reverb, r2=delay)

~perc (→ ~t1)
├── ~pbd1, ~pbd2 (Bass drums)
├── ~psd1, ~psd2 (Snares)
├── ~phh1, ~phh2 (Hi-hats)
└── ...
```
- `~ensurePostSend.(from, to, level)` - Create/replace post-fader send

### Routing Pattern
```supercollider
Synth(\name, [\out, ~t1.inbus.index])
Pbind(\out, ~pbd1.inbus.index, ...)
~ensurePostSend.(~t1, ~r1, 0.3)  // send to return
```

### Clock
- `~link` - LinkClock for tempo sync (also set as TempoClock.default)

### MIDI (`_includes/midi-setup.scd`)
- `~mOut` - MIDIOut to DAW (IAC on macOS, VirMIDI on Linux)

## MIDI Controllers

Reference docs in `0_startup/reference/` for each controller.

### Launch Pad Mini MK3
- `~lpBind.(ref, key, color, clock, quant, onStop)` - Bind pad (6 args)
- `ref` = [row, col] or MIDI note 11-88
- `onStop` (optional Function) - called instead of `obj.stop` on toggle-off; use for Tdef cleanup

### APC40 Mk2
- `~apcBind.(note, key, quant, color, playColor)` - Extended binding
- `~apcAssignPad.(pad, pdef)` - Legacy binding
- **Note:** APC40 does NOT yet have `onStop` support (pending — needed for Linux setup)

### Launch Control XL
- `~lcxlBindPdef.(cc, pdef)` - Fader/knob binding

## Helpers (`_includes/_helpers/helpers.scd`)

### `~makeFxSendTdef.(name, src, ret, level=1)`
Creates a toggle Tdef for a post-fader FX send. Returns the stopper function for use as `onStop`.
```supercollider
~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1));
// ~fxSendStop[name] also holds the stopper for later access
```

**SC gotcha:** `protect{}` does NOT fire when a Routine/Tdef is killed via `stop`/`stopQ` (hard primitive kill). The helper uses a while+flag loop so the Tdef exits naturally and cleanup runs. The `onStop` arg to `~lpBind` sets the flag instead of calling `stop`.

## Platform Notes

**Linux:** JACK audio, Scarlett 18i20, ALSA MIDI, VirMIDI for DAW
**macOS:** CoreAudio, Scarlett 2i2, IAC Driver for virtual MIDI

Startup auto-detects platform. `_samples` is a symlink — reset after pulling on a new machine.

## Extensions (`Extensions/`)

- `ext_stopQ.sc` - Adds `.stopQ(quant)` to TaskProxy for quantized stop
- `Psection.sc` - Pattern combinator for sectional composition
- `ext_Patterns.sc`, `Pswing.sc` - Additional pattern extensions

Extensions need to be in SC's extension path. Add `Extensions/` to `sclang_conf.yaml` or symlink into `Platform.userExtensionDir`.

## Common Patterns

```supercollider
// Load samples
~loadSamps.("path/to/samples/");

// Pattern routed to mixer
Pdef(\kick, Pbind(
    \instrument, \playBuf,
    \buf, ~sTree[\808][\kick],
    \dur, 1,
    \out, ~pbd1.inbus.index
)).play(~link);

// Live parameter control
Pdefn(\kick_amp, 0.8);

// Stem recording
~stemStop = ~stemDiskStart.(
    tracks: [~t1, ~t2], returns: [~r1],
    fileBase: "session", dirPath: "~/recordings",
    clock: ~link, autoSplit: true
);
~stemStop.(beats: 4);
```
