(
// Cross-platform startup.scd
// Detects platform and configures audio/MIDI accordingly

var platform, hostname, zynInstance, effectiveHost, basePath;

// ---- detect platform + host
platform = Platform.case(
    \osx,   { \macos },
    \linux, { \linux },
    \windows, { \windows },
    { \unknown }
);
hostname = "hostname".unixCmdGetStdOut.stripWhiteSpace;
// RaspPad3 has reported hostname "zynthian" (its old Zynthian OS image, never
// renamed from the default) and now "raspberrypi" (a plain Bookworm/trixie
// re-image) at different times — either would otherwise collide with the
// main Zynthian's own hostname == "zynthian" branches below, or fall through
// to the generic Linux fallback. It's a different physical box — Scarlett
// Solo 4th Gen over JACK, no zynthian-ui SC engine wiring — so it needs the
// plain scsynth-boot path (synthdefs/mixer/samples), not the MIDI-only/
// zynmixer-wired one. Distinguish by actual sound card instead of hostname:
// the real Zynthian has a HiFiBerry, RaspPad3 has a Scarlett — this also
// makes detection survive RaspPad3's own re-images/hostname changes.
effectiveHost = if(
    "aplay -l | grep -qi Scarlett".systemCmd == 0
) { "raspad" } { hostname };
// Distinguishes the two concurrent sclang processes on the zynthian host
// itself (both run this SAME startup.scd, via the same ~/.config/
// SuperCollider/startup.scd symlink) — empty string for the original/
// slicer+subtractive1 session, "bass" for the second process launched by
// supercollider-bass.service (SC_ZYN_INSTANCE=bass sclang -u 57121).
zynInstance = "echo $SC_ZYN_INSTANCE".unixCmdGetStdOut.stripWhiteSpace;
("Platform detected: " ++ platform ++ " / " ++ hostname ++ (if(zynInstance.size > 0) { " / instance=" ++ zynInstance } { "" })).postln;

// ---- ddwMixerChannel quark (mixer-channel-16s.scd / mixer-channel-stem-record.scd
// depend on its MixerChannel class). Auto-installs on first boot on a fresh machine
// (e.g. after a re-image); a no-op on every boot after that.
if(Quarks.isInstalled("ddwMixerChannel").not) {
    "ddwMixerChannel not found — installing (first run on this machine)...".postln;
    Quarks.install("ddwMixerChannel");

    // Headless sclang builds (no Qt/GUI kit compiled in — true of this Zynthian's
    // build) can't compile any of the *Gui.sc files pulled in by ddwMixerChannel's
    // dependency chain (crucial-library, ddwGUIEnhancements): they reference
    // View/Window/ObjectGui etc., which don't exist here, and abort class-library
    // compilation entirely. None of that GUI code is needed for MixerChannel's core
    // routing/send/stem-record functionality, so on a headless build it's excluded.
    // On a machine with a real GUI kit (Mac/desktop Linux), skip this — those files
    // are legitimately useful there (the mixer GUI board).
    if('GUI'.asClass.isNil) {
        "No GUI kit in this sclang build — excluding GUI-only quark files.".postln;
        Quarks.uninstall("ddwGUIEnhancements");
        [
            "crucial-library/Gui",
            "crucial-library/Sample/SampleGui.sc",
            "crucial-library/Crucial.sc",   // GUI skin setup only; base SC already has \unipolar/\bipolar specs
            "crucial-library/UncoupledUsefulThings/KeyCodeResponderGui.sc",
            "crucial-library/Editors/NumberEditorGui.sc",
            "crucial-library/Editors/EnvEditorGui.sc",
            "crucial-library/Sequencers/HasSubjectGui.sc",
            "crucial-library/Instr/InstrGui.sc",
            "crucial-library/Instr/PatchGui.sc",
            "crucial-library/Scheduling/TempoGui.sc",
            "crucial-library/ServerTools/ServerGui.sc",
            "crucial-library/deprecated-3.5.sc",
            "crucial-library/Players/PlayerMixerGui.sc",
            "crucial-library/Players/PlayerBasicOpsGui.sc",
            "crucial-library/Players/SFP/SFPGui.sc",
            "crucial-library/Players/SimpleTriggerGui.sc",
            "crucial-library/Players/AbstractPlayerGui.sc",
            "crucial-library/Players/BeatClockPlayerGui.sc",
            "ddwMixerChannel/MixerScopeGui.sc"
        ].do { |rel| LanguageConfig.addExcludePath(Quarks.folder +/+ rel) };
        LanguageConfig.store(LanguageConfig.currentPath);
    };

    "ddwMixerChannel install complete — recompiling class library to load it...".postln;
    thisProcess.recompile;
};

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
    { effectiveHost == "zynthian" } {
        // Zynthian: MIDI-only host, scsynth will not be booted
        "Audio config: Zynthian (MIDI only, no scsynth)".postln;
    }
    { effectiveHost == "raspad" } {
        // RaspPad3: Scarlett Solo 4th Gen over JACK, straight to its main out —
        // no zynthian-ui chain wiring, no jack_disconnect from system:playback
        // (jackd's default auto-connect IS the desired routing here).
        Server.default.addr = NetAddr("127.0.0.1", 57110);  // localhost -> ::1 gotcha, same as raspberrypi/zynthian below
        s.options.numOutputBusChannels = 2;
        s.options.numInputBusChannels  = 2;
        s.options.sampleRate = 48000;
        s.options.memSize = 65536;
        s.options.numBuffers = 1024;
        s.options.maxNodes = 1024;
        s.options.blockSize = 64;
        s.options.hardwareBufferSize = 512;  // matches this box's actual jackd -p 512
        s.options.device = "JACK";
        "Audio config: RaspPad3 / Scarlett Solo via JACK".postln;
    }
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

// Boot scsynth only on hosts that use it
if((effectiveHost != "zynthian") && (effectiveHost != "raspberrypi")) {
    Server.killAll;  // ensure previous scsynth is gone before boot (avoids macOS AVAudio race)

    // waitForBoot handles the boot itself; a separate s.boot here double-triggers it
    // ("server 'localhost' already booting") and can leave the booting flag stuck → "not started".
    // Deferred via AppClock, same as the zynthian/bass branches below and for the same
    // reason (see their comment): calling waitForBoot synchronously during startup.scd's
    // own special early execution can leave the booting flag stuck forever with scsynth
    // never actually spawned. Confirmed hanging exactly this way on RaspPad3's "raspad"
    // branch (2026-07-24) once it started reaching this shared block.
    // thisProcess.nowExecutingPath is only valid NOW, before deferring — capture it so
    // the loadRelative calls below (rewritten as basePath-joined .load) still resolve
    // correctly once actually running inside the deferred AppClock callback. Resolved
    // through readlink -f since nowExecutingPath reports the ~/.config/SuperCollider/
    // startup.scd SYMLINK's own directory, not the real workspace dir the symlink
    // points at (confirmed live on RaspPad3 — a bare .dirname landed one level shallow).
    basePath = ("readlink -f " ++ thisProcess.nowExecutingPath).unixCmdGetStdOut.stripWhiteSpace.dirname;
    AppClock.sched(0.1, {
    s.waitForBoot {
        // --- Core synths + sample loader (always load)
        (basePath +/+ "_synthdefs/synths_common.scd").load;
        (basePath +/+ "_synthdefs/ufn_defs.scd").load;
        (basePath +/+ "_synthdefs/analog_synthdefs.scd").load;
        (basePath +/+ "_synthdefs/neutron.scd").load;
        (basePath +/+ "_synthdefs/model_d.scd").load;
        (basePath +/+ "_synthdefs/biscuit.scd").load;
        (basePath +/+ "_includes/sample_loader.scd").load;
        (basePath +/+ "_synthdefs/fx_defs.scd").load;
        (basePath +/+ "_synthdefs/ilfx_cores.scd").load;

        // --- MIDI setup (cross-platform)
        (basePath +/+ "_includes/midi-setup.scd").load;

        // --- MIDI Controllers (auto-detect: APC40 mkII > Launch Control XL)
        (basePath +/+ "_includes/_midi-ctrl/midi-device-loader.scd").load;

        // Launch Pad Mini - uncomment if you use it
        (basePath +/+ "_includes/_midi-ctrl/launch-pad-mini/lp-param-router.scd").load;

        s.sync; // ensure all SynthDefs are registered on server before mixer init

        // --- TouchOSC OSC router (always load — no device detection needed)
        // "_includes/_osc-ctrl/tosc-router.scd".loadRelative;
        // "_includes/_osc-ctrl/tosc-pad-router.scd".loadRelative;
        // "_includes/_osc-ctrl/tosc-fx.scd".loadRelative;  // defines ~toscFXBind/~toscFXSync used by fx_defs ~fxSetup functions

        // --- Mixer channels (with conditional controller bindings)
        // "_includes/mixer-channel-16s.scd".loadRelative;
        // "_includes/ndef2mixer-channel.scd".loadRelative;  // routes Ndefs into ddwMixerChannel strips — depends on mixer-channel-16s.scd above, orphaned while that's disabled
        (basePath +/+ "_includes/ndef-mixer.scd").load;
        (basePath +/+ "_includes/ndef-fx-route.scd").load;      // fx-to-fx routing (~fxRoute), needs ~fxAddFX
        (basePath +/+ "_includes/ndef-channel-16s.scd").load;
        (basePath +/+ "_includes/ndef-channel-apc.scd").load;   // optional, APC40 bindings
        (basePath +/+ "_includes/midi-in-play.scd").load;       // general MIDI-in -> synth router
        // ~stemDiskStart is pure function definitions — no dependency on real
        // MixerChannels existing, safe to load with mixer-channel-16s.scd off.
        // Used with Ndefs via ~ndefAsChan (see ndef-stem-record.scd).
        (basePath +/+ "_includes/mixer-channel-stem-record.scd").load;
        (basePath +/+ "_includes/ndef-stem-record.scd").load;

        // --- Helpers
        (basePath +/+ "_includes/_helpers/helpers.scd").load;
        (basePath +/+ "_includes/cc-logger.scd").load;

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
        (basePath +/+ "_includes/norns-router.scd").load;

        // --- Cleanup any launchpad state if present
        if(~lpMini.notNil) { ~lpMini[\clearGrid].(); };

        Ndef.dictFor(s).clock = ~link;
        Ndef.dictFor(s).quant = 1;
        Ndef.dictFor(s).fadeTime = 3;

        ("Setup done! (" ++ platform ++ " / " ++ hostname ++ ")").postln;
    };
    nil
    });
};

// --- Raspberry Pi: lean control layer (host for norns + Maschine+/Deluge)
// Flow: norns (arcologies) OSC → SC functions → MIDI out to Maschine+/Deluge.
// Link syncs norns / Maschine+ / SC; Deluge is MIDI-slaved (~startDelugeClock).
// SC-internal audio (synthdefs/samples/mixer) is intentionally NOT loaded here.
// Gated on effectiveHost, not raw hostname: RaspPad3 also reports hostname
// "raspberrypi" post re-image, but effectiveHost resolves it to "raspad" (Scarlett
// present) instead, correctly excluding it here. Without this, both this lean
// block AND the full-stack block above would fire on RaspPad3, double-loading
// midi-setup.scd and failing the second MIDIOut connect with "Device or resource
// busy" (confirmed live, 2026-07-24) — only a hostname genuinely acting as the
// lean norns/Maschine+/Deluge hub (no Scarlett) should reach this branch.
if(effectiveHost == "raspberrypi") {
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

    Ndef.dictFor(s).clock = ~link;
    Ndef.dictFor(s).quant = 1;
    Ndef.dictFor(s).fadeTime = 3;
    // --- Norns arcologies router
    // Defines ~song / ~play / ~toggle / ~oneshot and OSC handlers (/arc/trigger,
    // /arc/stop, /arc/start). Auto-loads midi-out-maschine.scd + midi-out-deluge.scd.
    "/home/hypo/Music/supercollider/0_startup/_includes/norns-router.scd".load;

    ("Setup done! (" ++ platform ++ " / " ++ hostname ++ ")").postln;
};

// --- Zynthian: MIDI control layer + scsynth (audio, joined onto Zynthian's own JACK server)
// Gated to the ORIGINAL/slicer+subtractive1 process only — the second
// (bass) sclang process runs the separate branch below instead, so the two
// don't both try to boot a Server on the same port/JACK device.
if(effectiveHost == "zynthian" and: { zynInstance != "bass" }) {
    MIDIClient.init;
    // Found 2026-07-13, once a second concurrent sclang process existed to
    // compare against: SC's ALSA MIDI client name is a FIXED "SuperCollider"
    // string baked into its ALSA MIDI backend — it is NOT derived from
    // s.options.device, so every persistent sclang process on this box ends
    // up with an ALSA client of the exact same name, differing only by
    // numeric client ID. zynthian_engine_supercollider.py's MIDI-jackname
    // discovery used to scan /proc/asound/seq/clients BY NAME — harmless
    // with only one such process, but genuinely ambiguous (and a real
    // regression risk to whichever chain the wrong scsynth session's MIDI
    // got wired into) now that a second one exists. Writing this process's
    // own MIDIClient.getClientID to a fixed, per-instance file lets the
    // Python engine read the exact right ID directly instead of guessing
    // from a non-unique name.
    File.use("/tmp/sc_midi_clientid", "w", { |f| f.write(MIDIClient.getClientID.asString) });
    ~out = MIDIOut.newByName("Midi Through", "Midi Through Port-0");
    ~out.latency = 0;

    // Boot scsynth as just another client of Zynthian's already-running jackd
    // (which owns the HiFiBerry hw directly, so scsynth must NOT try to open its
    // own audio device). Channel count/rate/period mirror jackd's actual invocation
    // (`ps aux | grep jackd`): stereo I/O, 48kHz, 128-frame period.
    // Scsynth's own out ports get wired into zynmixer chain 4 (input_04a/b) once
    // booted, below — a free chain slot, independent of chains 1-3 which are live
    // instruments. Gives SC its own fader/FX/mute strip on the Zynthian touchscreen.
    // localhost resolves to ::1 on this Pi (same gotcha as the raspberrypi host
    // above) — scsynth's OSC listener is IPv4-only, so force it or sclang spawns
    // scsynth fine but never completes the boot handshake (stuck "booting" forever).
    Server.default.addr = NetAddr("127.0.0.1", 57110);
    // On the JACK driver, ServerOptions.device is the JACK CLIENT NAME, not a
    // backend selector (this build is JACK-only already). Setting it to the
    // literal string "JACK" previously named the client "JACK" instead of
    // "SuperCollider", silently breaking any jack_connect targeting the
    // expected client name.
    s.options.device = "SuperCollider";
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;
    s.options.sampleRate = 48000;
    s.options.memSize = 65536;
    s.options.numBuffers = 1024;
    s.options.maxNodes = 1024;
    s.options.blockSize = 64;
    s.options.hardwareBufferSize = 128;

    // s.boot relies internally on fork/OSCFunc-based timeouts (Server:prPingApp)
    // to detect "no server yet" before spawning scsynth. Calling it synchronously
    // during startup.scd's own special early execution (before the interpreter's
    // clock scheduler is fully pumping) leaves that fork's callback stuck forever —
    // scsynth never even gets spawned (booting stays true, pid stays nil indefinitely).
    // A short AppClock defer sidesteps this; confirmed s.boot works immediately when
    // not called synchronously at startup-file top level.
    AppClock.sched(0.1, {
        s.waitForBoot {
            "scsynth booted as a JACK client".postln;
            // jackd auto-connects new clients straight to hardware on boot —
            // remove that so the "SC" Zynthian chain's own zynmixer routing
            // (owned by zynautoconnect now that SC is a registered chain engine —
            // see zynthian-sc-engine/zyngine/zynthian_engine_supercollider.py)
            // is the only path to the speakers, not a hardcoded second one.
            "jack_disconnect \"SuperCollider:out_1\" \"system:playback_1\"".unixCmd;
            "jack_disconnect \"SuperCollider:out_2\" \"system:playback_2\"".unixCmd;

            // SC-as-Zynthian-chain bridge — needs a booted server (Buffer.read/
            // sendCollection below), so this must run post-boot, not at top level.
            "/root/Music/supercollider/0_startup/_includes/_zyn-patches/zyn-engine-bridge.scd".load;

            // Each patch file registers itself into ~zynPatches (see
            // zyn-engine-bridge.scd) rather than activating immediately —
            // explicit list, not an auto-scan of the directory, so that
            // gb1-patch.scd (still broken, still runs its setup at top
            // level rather than registering — see reference doc) can stay
            // in the folder without clobbering whichever patch loads after
            // it. Add new patches here as they're written.
            "/root/Music/supercollider/0_startup/_includes/_zyn-patches/subtractive1-patch.scd".load;
            "/root/Music/supercollider/0_startup/_includes/_zyn-patches/slicer-patch.scd".load;

            ~zynLoadPatch.(\subtractive1);   // boot default; touchscreen preset selection overrides
        };
        nil
    });

    // Route Midi Through into ZynMidiRouter so SC MIDI reaches Zynthian chains.
    // Midi Through is ALSA-only; a2jmidid bridges it to JACK where ZynMidiRouter lives.
    "jack_connect \"a2j:Midi Through [14] (capture): Midi Through Port-0\" \"ZynMidiRouter:seq_in\"".unixCmd;

    // Also fan the same stream straight to the Deluge, if it's currently
    // connected via USB (its own ALSA seq client, "Deluge" — not bridged into
    // JACK at all: a2j_control --status shows "Hardware not exported" on this
    // box, so hardware MIDI only ever shows up via plain ALSA seq, never as a
    // jack_connect-able port). Detected by name rather than hardcoded, since
    // the physical cabling changes often (USB vs DIN-via-mio, cables get
    // moved between devices) — silently does nothing if the Deluge isn't
    // currently on USB. 2026-07: was previously wired via mio+DIN instead
    // (jackd owned that rawmidi device directly as a JACK port,
    // "system:midi_playback_1") — moved to USB to sidestep a Zynthian-side
    // clock-sync issue (Vangelis' zynseq runs its internal clock at 1920 PPQN
    // vs Oram's 24 PPQN, and per the lead dev, deriving a stable 1920 PPQN
    // internal clock from a 24 PPQN external MIDI clock signal isn't
    // currently reliable — unrelated to this connection, just why DIN got
    // dropped in favor of USB here). mio is now expected to carry
    // Norns -> Deluge instead, a separate path this doesn't need to touch.
    if("aconnect -l | grep -q \"client.*'Deluge'\"".systemCmd == 0) {
        if("aconnect \"Midi Through\" \"Deluge\"".systemCmd == 0) {
            "Connected Midi Through -> Deluge (USB).".postln;
        } {
            // Reason unconfirmed (EAGAIN from ALSA) - not the same thing as
            // the zynseq clock-resolution issue above, as far as we know.
            // Non-fatal either way - SC keeps booting.
            "Deluge seen via USB but couldn't auto-connect (EAGAIN) — connect manually if needed.".postln;
        };
    } {
        "Deluge not found via USB — skipping (fine if it's on DIN/mio today instead).".postln;
    };

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

    // --- Push Link tempo into Zynthian's own tempo (zynseq)
    // Zynthian has no Link support, so it never picks up the Deluge/M+ tempo on its
    // own. Its GUI/CUIA OSC server (zynthian_gui.py) listens on 127.0.0.1:1370 and
    // /CUIA/SET_TEMPO <bpm> sets zynseq's tempo directly — no MIDI clock or clock-source
    // mode change needed, unlike the Deluge (which has no such OSC endpoint and is
    // slaved via M+'s Link-driven MIDI clock over USB instead).
    // ~link.tempo already tracks the live Link session (M+ is presumably a Link peer),
    // so polling it here closes the loop: M+ tempo change → Link → ~link.tempo → OSC → Zynthian.
    ~zynOSC = NetAddr("127.0.0.1", 1370);
    ~syncZynTempo = { ~zynOSC.sendMsg("/CUIA/SET_TEMPO", (~link.tempo * 60).asFloat) };
    ~syncZynTempo.();

    if(~zynTempoWatch.notNil) { ~zynTempoWatch.stop };
    ~zynTempoWatch = Task({
        var lastBpm = (~link.tempo * 60).round(0.01);
        loop {
            var bpm = (~link.tempo * 60).round(0.01);
            if(bpm != lastBpm) {
                lastBpm = bpm;
                ~syncZynTempo.();
            };
            1.wait;
        };
    }).play(SystemClock);

    "Setup done! (zynthian)".postln;
};

// --- Zynthian: second sclang process, dedicated to the "SB" (SuperCollider
// Bass) chain — runs concurrently with the branch above instead of sharing
// its scsynth/JACK client/OSC port. Launched by supercollider-bass.service
// as `SC_ZYN_INSTANCE=bass sclang -u 57121`. No MIDI-Through/Deluge-USB/
// LinkClock-tempo-push setup here (that's the master/slicer session's job);
// this session only needs its own scsynth + MIDI note-in via its own
// dedicated ALSA client, same mechanism the branch above already uses.
if(effectiveHost == "zynthian" and: { zynInstance == "bass" }) {
    // MIDIClient.init is what actually CREATES this process's ALSA/JACK MIDI
    // client and its in0-in7/out0-out5 ports (confirmed live 2026-07-13:
    // without this, no "SCBass" ALSA client ever appears in
    // /proc/asound/seq/clients at all, so zynthian_engine_sc_bass's
    // _refresh_midi_jackname() finds nothing and this chain gets no MIDI
    // note-in path whatsoever — the port isn't just unwired, it doesn't
    // exist). No MIDIOut.newByName("Midi Through", ...) needed here (unlike
    // the main branch) — this session doesn't send MIDI out anywhere, only
    // receives note-in from ZynMidiRouter via zynautoconnect.
    MIDIClient.init;
    // Same fixed-ALSA-client-name issue as the main branch above (SC's ALSA
    // MIDI client is always literally named "SuperCollider" regardless of
    // s.options.device) — write THIS process's own client ID to its own
    // file so zynthian_engine_sc_bass reads the right one directly.
    File.use("/tmp/scbass_midi_clientid", "w", { |f| f.write(MIDIClient.getClientID.asString) });

    // localhost resolves to ::1 on this Pi — same IPv4 gotcha as the main
    // zynthian branch above.
    Server.default.addr = NetAddr("127.0.0.1", 57111);
    // Distinct JACK client name — must NOT contain "SuperCollider" as a
    // substring (found 2026-07-13): zynautoconnect wires processor audio via
    // jclient.get_ports(processor.get_jackname(True), ...), and JACK's
    // get_ports treats that name as an UNANCHORED REGEX. A name like
    // "SuperColliderBass" would also match the other chain's "SuperCollider"
    // pattern and get its ports pulled into the wrong chain.
    s.options.device = "SCBass";
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;
    s.options.sampleRate = 48000;
    s.options.memSize = 65536;
    s.options.numBuffers = 1024;
    s.options.maxNodes = 1024;
    s.options.blockSize = 64;
    s.options.hardwareBufferSize = 128;

    // Same AppClock.sched-deferred boot as the main branch — s.boot's
    // internal fork/OSCFunc-based timeout detection doesn't work reliably
    // called synchronously at startup.scd's own top-level execution.
    AppClock.sched(0.1, {
        s.waitForBoot {
            "scsynth (bass) booted as a JACK client".postln;
            "jack_disconnect \"SCBass:out_1\" \"system:playback_1\"".unixCmd;
            "jack_disconnect \"SCBass:out_2\" \"system:playback_2\"".unixCmd;

            "/root/Music/supercollider/0_startup/_includes/_zyn-patches/zyn-engine-bridge.scd".load;
            "/root/Music/supercollider/0_startup/_includes/_zyn-patches/bass8-patch.scd".load;

            ~zynLoadPatch.(\bass8);
        };
        nil
    });

    "Setup done! (zynthian / instance=bass)".postln;
};
)
