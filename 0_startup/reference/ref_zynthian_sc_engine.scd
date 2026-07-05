// =============================================================================
// ZYNTHIAN SC ENGINE  (zynthian-sc-engine repo + _includes/_zyn-patches/)
// =============================================================================
// SuperCollider as a REAL Zynthian chain: touchscreen-visible, with
// MIDI-learnable knobs and live MIDI note-in — not just raw JACK audio
// routing into a zynmixer channel (that manual-prototype stage is gone;
// zynautoconnect owns the audio routing now that SC is a registered engine).
//
// Three repos involved:
//   supercollider (this repo)  — SC-side patch code + OSC/MIDI bridge, in
//                                0_startup/_includes/_zyn-patches/
//   zynthian-sc-engine         — Python engine class + preset yml files.
//                                /zynthian/zynthian-sc-engine (own git repo,
//                                kept separate from both supercollider and
//                                zynthian-ui on purpose). Symlinked into:
//                                  zynthian-ui/zyngine/zynthian_engine_supercollider.py
//                                  zynthian-my-data/presets/sc
//   zynthian-ui                — third-party repo, three small edits:
//                                zyngine/__init__.py (import + __all__),
//                                zyngine/zynthian_chain_manager.py
//                                (engine2class + single_processor_engines),
//                                zyngine/zynthian_lv2.py (standalone_engine_info
//                                — see "engine_config.json" gotcha below).
//
// Architecture:
//   Zynthian touchscreen (knob turn)
//     -> zynthian_controller.send_value() [zynthian-ui]
//     -> liblo.send(osc_target, "/scengine/<param>", value)
//     -> SC OSCdef (zyn-engine-bridge.scd) -> ~zynParamTable[sym].value(v)
//
//   Zynthian MIDI (ZynMidiRouter, via a2jmidid bridge)
//     -> SC's own ALSA MIDI-in port "in0" (dedicated — see jackname_midi
//        regex in zynthian_engine_supercollider.py)
//     -> MIDIdef.noteOn/noteOff (zyn-engine-bridge.scd) -> ~zynPatchNoteOn
//
//   SC itself is ONE PERSISTENT process (sclang+scsynth), booted once by
//   startup.scd's `if(hostname == "zynthian")` branch — NOT spawned per
//   chain/preset like every other Zynthian engine (Pd included). This keeps
//   Ndef/Pbind live-coding state alive across chain add/remove, but means
//   the framework's normal "engine.start() sets things up" assumption
//   doesn't hold for us — see Gotchas below, this bit hard.

// =============================================================================
// HOW TO ADD A NEW PATCH/PRESET
// =============================================================================
//
// 1. Write the instrument as a self-contained file:
//      0_startup/_includes/_zyn-patches/<name>-patch.scd
//    Must define:
//      - its own SynthDef(s) — don't `.load` the shared _synthdefs/ files
//        (see "Shared synthdefs file" gotcha below)
//      - ~zynPatchNoteOn = { |note, vel| Synth(\yourDef, [...]) }
//        Must return the Synth (zyn-engine-bridge.scd stores it as
//        ~zynVoice so note-off can release it via .set(\gate, 0) — your
//        SynthDef needs a `gate` arg feeding an EnvGen with doneAction: 2).
//      - One ~zynRegisterParam.(\name, setterFunc, defaultValue) call per
//        knob you want exposed. setterFunc should update ~zynVoice:
//          ~zynRegisterParam.(\cutoff, { |v| ~zynVoice !? { |s| s.set(\cutoff, v) } }, 2000);
//        IMPORTANT: ~zynPatchNoteOn must read ~zynCurrentParams[\cutoff]
//        (not a hardcoded default) when building each new Synth — a synth
//        only exists between note-on/note-off, so it does NOT inherit
//        whatever the previous note had its knobs turned to. See the
//        "knob reverts after under a second" gotcha below.
//
// 2. Create the matching Zynthian preset directory — TWO levels deep,
//    bank then preset (a single level silently gets misread as an empty
//    bank — see gotcha below):
//      /zynthian/zynthian-sc-engine/presets/sc/<BankName>/<presetName>/zynconfig.yml
//    Shape (same schema zynthian_engine_puredata.py uses):
//      GroupTitle:
//        paramName:
//          name: "Display Name"
//          value: <default>
//          value_min: <min>
//          value_max: <max>
//          osc_path: "/scengine/<paramName>"   // must match ~zynRegisterParam's name
//
// 3. Point startup.scd at the new patch file — inside the
//    `if(hostname == "zynthian")` branch's post-boot AppClock.sched
//    callback, alongside zyn-engine-bridge.scd. Only ONE patch file loads
//    at a time currently (multi-patch switching isn't wired up — see
//    "Not yet built" below), so swap the line rather than adding a second:
//      "/root/.../0_startup/_includes/_zyn-patches/zyn-engine-bridge.scd".load;
//      "/root/.../0_startup/_includes/_zyn-patches/<name>-patch.scd".load;
//
// 4. Restart both:
//      tmux kill-session -t sc; tmux new-session -d -s sc 'sclang'
//      systemctl restart zynthian.service
//    (SC and the Zynthian UI are independent processes — either can be
//    restarted alone depending on what you changed. Python/yml changes
//    only need the service restart; .scd patch changes only need SC.)
//
// 5. On the touchscreen: Add Instrument Chain -> Sampler -> SuperCollider ->
//    <BankName> -> <presetName>. Knobs should appear immediately.
//
// Test the SC side standalone BEFORE touching Zynthian at all — this
// environment's own tmux session lets you eval code directly and catches
// most bugs faster than a full touchscreen round-trip:
//   tmux send-keys -t sc -l '~zynVoice = ~zynPatchNoteOn.value(60, 100);'
//   tmux send-keys -t sc Enter
//   tmux send-keys -t sc -l 'NetAddr("127.0.0.1", 57120).sendMsg("/scengine/cutoff", 500.0);'
//   tmux send-keys -t sc Enter
//   tmux capture-pane -t sc -p -S -20

// =============================================================================
// GOTCHAS  (all found by live debugging on the actual box — read before
// touching zynthian_engine_supercollider.py or assuming "it should just work")
// =============================================================================
//
// - engine.start() is NEVER called anywhere by zynthian_chain_manager.py or
//   zynthian_processor.py. Every other engine that needs setup-on-start
//   calls it ITSELF (Pd calls self.stop()/self.start() from inside its own
//   set_preset(), as part of restarting its subprocess). Since our engine
//   has no subprocess, nothing was calling start() for us — meaning
//   osc_init() (which sets self.osc_target, where knob changes get OSC-sent)
//   never ran, and every knob turn silently went nowhere. Fixed by moving
//   osc_init() + the MIDI-jackname refresh into __init__ directly, which is
//   guaranteed to run exactly once per persistent instance.
//
// - zynthian_processor.set_preset() unconditionally does
//   `if preset_id in self.engine.preset_favs:` — but preset_favs stays None
//   until load_bank_list()'s favorites-check lazily initializes it to {},
//   and the UI's single-bank shortcut (we only have one bank per engine
//   instance so far) skips that screen entirely. Crashes with a TypeError
//   before our own set_preset() ever runs — symptom was "preset shows in
//   the list but selecting it shows zero knobs, no error visible anywhere."
//   Fixed: initialize self.preset_favs = {} directly in __init__.
//
// - Our set_preset() must call processor.refresh_controllers() ITSELF (same
//   as Pd's does) — the calling UI code does not do this after preset
//   selection. Without it, get_controllers_dict() only ever runs once, at
//   chain-creation time (before any preset is picked, zctrl_config still
//   None then) — the control screen gets built empty and is never rebuilt.
//
// - Knobs "reverting after under a second": a synth only exists between
//   note-on and note-off. A new note-on builds a brand-new Synth from
//   scratch — it does NOT inherit whatever the PREVIOUS (now-freed) synth
//   had its knobs set to. On a sequenced/repeating note this looks exactly
//   like the knob change silently undoing itself. Fix (already in
//   zyn-engine-bridge.scd): ~zynRegisterParam tracks ~zynCurrentParams[sym]
//   on every OSC-driven change, and every patch's ~zynPatchNoteOn must read
//   from ~zynCurrentParams (not a hardcoded/SynthDef default) when building
//   each new note's Synth.
//
// - Preset directories need TWO levels of depth:
//   presets/sc/<Bank>/<preset>/zynconfig.yml — matching Pd's
//   presets/puredata/<bank>/<preset>/ layout exactly. A single-level
//   presets/sc/<preset>/zynconfig.yml gets silently misread as a BANK
//   (empty of real presets, nothing shows up).
//
// - The touchscreen's "Add Instrument Chain" engine list comes from a
//   SEPARATE cache, /zynthian/config/engine_config.json, generated from
//   zyngine/zynthian_lv2.py's `standalone_engine_info` dict — NOT directly
//   from zynthian_chain_manager.py's `engine2class`. Adding an engine to
//   engine2class is necessary but not sufficient for it to appear anywhere
//   on the touchscreen; standalone_engine_info needs the entry too, AND
//   engine_config.json (the cache) needs regenerating — either delete it to
//   force a fresh rebuild on next boot, or add the entry directly (safer,
//   doesn't disturb other engines' rankings/IDs — see git history in
//   zynthian-sc-engine for the exact dict shape used).
//
// - startup.scd runs via the ~/.config/SuperCollider/startup.scd SYMLINK;
//   .loadRelative resolves against the symlink's OWN directory, not this
//   repo. Any file loaded from the `if(hostname == "zynthian")` branch
//   needs an absolute path + .load instead (same workaround the
//   raspberrypi branch above it already uses, for the same reason).
//
// - Loading the whole shared _synthdefs/synths_common.scd (instead of a
//   self-contained SynthDef in the patch file) pulls in a \cello SynthDef
//   that references Decimator — a UGen class not compiled into this box's
//   SC build. `.load` compiles an entire file as ONE compilation unit, so
//   that one missing class silently aborts EVERY SynthDef in the file, not
//   just \cello. This is why each zyn-patch defines its own SynthDef(s)
//   rather than depending on the shared cross-platform file.
//
// - No MIDI srcID filtering in zyn-engine-bridge.scd, and this is
//   deliberate: a2jmidid bridges ALL JACK MIDI into ALSA through one single
//   ALSA client ("a2jmidid"), so two different JACK sources routed into SC
//   would look identical from srcID's point of view anyway. The actual
//   isolation is port dedication — "in0" is only ever jack_connect'ed to by
//   zynautoconnect for this specific chain; nothing else should ever be
//   wired there.

// =============================================================================
// NOT YET BUILT
// =============================================================================
// - Multi-preset switching: only one patch file loads at a time (step 3
//   above). set_preset() doesn't send SC any "switch active patch" message —
//   selecting a different preset on the touchscreen only reloads its
//   zynconfig.yml (knobs), not the actual running SynthDef/note-on function.
//   To support real preset switching, set_preset() would need to OSC-message
//   SC with which patch to activate, and zyn-engine-bridge.scd would need a
//   registry of patches (keyed by preset name) to swap ~zynPatchNoteOn /
//   ~zynRegisterParam calls against, rather than one .scd file being
//   hardcoded in startup.scd.
// - Removing/disabling the SC chain from the touchscreen does NOT stop
//   sound — stop() only calls osc_end(), by design (see architecture note
//   above: no subprocess to kill). Acceptable for a personal live-coding
//   box, but a real deviation from every other engine's behavior.
// - gb1 (GrainBuf/sample-based voice) produced no audible output even at
//   massively boosted gain (amp=20) — the entire downstream pipeline was
//   independently confirmed working via a plain oscillator synth
//   (\scBasic) instead, so the issue is specific to gb1's own signal chain,
//   not the Zynthian integration. Root cause not yet isolated. The file is
//   still at _zyn-patches/gb1-patch.scd if picking this back up.

// =============================================================================
// USEFUL COMMANDS
// =============================================================================
//
// Restart SC (independent of the Zynthian UI service), from a shell:
// tmux kill-session -t sc 2>/dev/null; tmux new-session -d -s sc 'sclang'
// tmux capture-pane -t sc -p -S -30              // check boot log
// tmux send-keys -t sc -l 'someCode;'; tmux send-keys -t sc Enter   // eval code
//
// Restart the Zynthian UI service (picks up engine.py / zynconfig.yml changes):
// systemctl restart zynthian.service
// rm -rf /zynthian/zynthian-ui/zyngine/__pycache__     // if editing the .py directly
//
// Check SC's audio/MIDI JACK routing:
// jack_lsp -c | grep -A2 "^SuperCollider"
//
// Check for python-side errors:
// journalctl -u zynthian.service --no-pager -n 200 | grep -iE "error|traceback"
