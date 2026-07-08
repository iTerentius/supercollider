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
//   Zynthian touchscreen (preset selection)
//     -> engine.set_preset() [zynthian_engine_supercollider.py]
//     -> liblo.send(osc_target, "/scengine/loadpatch", presetDirName)
//     -> SC OSCdef -> ~zynLoadPatch.(name) -> runs ~zynPatches[name],
//        which is what actually sets ~zynPatchNoteOn / calls
//        ~zynRegisterParam for that patch (see "Real preset switching"
//        below — every patch file loads at boot but stays inert until
//        selected this way).
//
//   Zynthian MIDI (ZynMidiRouter, via a2jmidid bridge)
//     -> SC's own ALSA MIDI-in port "in0" (dedicated — see jackname_midi
//        regex in zynthian_engine_supercollider.py)
//     -> MIDIdef.noteOn/noteOff (zyn-engine-bridge.scd) -> ~zynPatchNoteOn
//        (whichever patch is currently active)
//
//   SC itself is ONE PERSISTENT process (sclang+scsynth), booted once by
//   startup.scd's `if(hostname == "zynthian")` branch — NOT spawned per
//   chain/preset like every other Zynthian engine (Pd included). This keeps
//   Ndef/Pbind live-coding state alive across chain add/remove, but means
//   the framework's normal "engine.start() sets things up" assumption
//   doesn't hold for us — see Gotchas below, this bit hard.
//
// Real preset switching: every patch file loaded at SC boot defines its
// SynthDef(s) and registers an "activate" Function into ~zynPatches[\name]
// — it does NOT call ~zynRegisterParam / set ~zynPatchNoteOn at load time.
// Only ~zynLoadPatch.(\name) (triggered by set_preset()'s OSC message, or
// once at boot for the default patch) actually makes a patch live. This is
// why a patch's setup code has to be wrapped in a Function rather than run
// directly — see step 1 below.

// =============================================================================
// HOW TO ADD A NEW PATCH/PRESET
// =============================================================================
//
// 1. Write the instrument as a self-contained file:
//      0_startup/_includes/_zyn-patches/<name>-patch.scd
//    Must define:
//      - its own SynthDef(s), OUTSIDE the ~zynPatches Function (defined
//        unconditionally at load time, same on every boot) — don't `.load`
//        the shared _synthdefs/ files (see "Shared synthdefs file" gotcha).
//      - ~zynPatches[\<name>] = { ... } wrapping the patch's actual setup:
//          ~zynPatches[\yourPatch] = {
//              ~zynPatchNoteOn = { |note, vel| Synth(\yourDef, [...]).register(true) };
//              ~zynRegisterParam.(\cutoff, { |v| ~zynSetAllVoices.(\cutoff, v) }, 2000);
//              // ...one ~zynRegisterParam call per knob you want exposed
//          };
//        This Function does NOT run at load time — only when
//        ~zynLoadPatch.(\yourPatch) is called (touchscreen preset select,
//        or the one hardcoded default-patch call in startup.scd). This is
//        what lets multiple patches coexist without one clobbering another
//        at boot.
//      - ~zynPatchNoteOn must return the Synth, chained with .register(true)
//        (NodeWatcher — makes .isPlaying track reality; see the isPlaying
//        gotcha below) and must read ~zynCurrentParams[\cutoff] (not a
//        hardcoded default) when building each new Synth — see the "knob
//        reverts after under a second" gotcha below. zyn-engine-bridge.scd
//        stores it in ~zynVoices, keyed by MIDI note number (not a single
//        global — see the "stuck notes" gotcha), so note-off releases
//        exactly that note. Two shapes exist:
//          - Sustained/gated (subtractive1-patch.scd): SynthDef has a
//            `gate` arg feeding EnvGen(..., doneAction: 2); setterFuncs do
//            real work via ~zynSetAllVoices (applies to every held voice).
//          - One-shot (slicer-patch.scd): SynthDef frees itself on a fixed
//            internal envelope, no `gate` arg at all — note-off's
//            .set(\gate, 0) is skipped once the isPlaying guard sees the
//            voice already self-freed (NOT a harmless no-op if you skip
//            that guard — see gotcha below), and every setterFunc can just
//            be {} (a no-op) since ~zynRegisterParam's ~zynCurrentParams
//            tracking is what actually matters — there's no "sustained
//            voice" to live-update.
//    For a buffer/sample-based patch whose folder is picked LIVE from the
//    touchscreen (rather than fixed at SC boot): see slicer-patch.scd's
//    ~zynSlicerLoadFolder + an is_path zynconfig.yml controller
//    (osc_path: "/scengine/samplefolder", NOT run through
//    ~zynRegisterParam — see that OSCdef's own comment for why a file-path
//    string can't go through the generic value normalization). The
//    touchscreen's file browser only ever calls back with a FILE (tapping a
//    folder just navigates into it, no "select this folder" action exists),
//    so the OSC handler takes the PARENT DIRECTORY of whatever file got
//    tapped. \mode picks seq (cycle in order, like Pseq) vs rand (random, no
//    immediate repeat, like Pxrand) — see the "Boolean.asFloat" gotcha below
//    if adding a similar toggle-controlled param.
//    (Retired 2026-07-08: the old fixed-kit approach, one ~zynMakeMultiSlicePatch
//    call per hardcoded folder in slice-multi-patch.scd — superseded by the
//    live picker above once every kit needed its own preset anyway.)
//
// 2. Create the matching Zynthian preset directory — TWO levels deep,
//    bank then preset (a single level silently gets misread as an empty
//    bank — see gotcha below). The preset directory's own NAME must match
//    the ~zynPatches key exactly (set_preset() derives it via
//    os.path.basename):
//      /zynthian/zynthian-sc-engine/presets/sc/<BankName>/<name>/zynconfig.yml
//    Shape (same schema zynthian_engine_puredata.py uses):
//      GroupTitle:
//        paramName:
//          name: "Display Name"
//          value: <default>
//          value_min: <min>
//          value_max: <max>
//          osc_path: "/scengine/<paramName>"   // must match ~zynRegisterParam's name
//          is_integer: true    // optional, for whole-number knobs
//          is_toggle: true     // optional, for on/off knobs
//    More than 4 params in one GroupTitle auto-paginates into "<Group>#1",
//    "<Group>#2", ... (touchscreen shows at most 4 knobs per screen) —
//    nothing to do here, just don't be surprised by the extra page.
//
// 3. Add the new file to startup.scd's explicit patch-loading list — inside
//    the `if(hostname == "zynthian")` branch's post-boot AppClock.sched
//    callback, alongside zyn-engine-bridge.scd and the other patch files
//    (an explicit list, not an auto-scan of the directory — see the
//    "gb1-patch.scd stays inert" gotcha below for why):
//      "/root/.../0_startup/_includes/_zyn-patches/<name>-patch.scd".load;
//    If this is meant to be the boot default, update the
//    `~zynLoadPatch.(\...)` call right after the load list too — otherwise
//    it's only reachable by selecting its preset on the touchscreen.
//
// 4. Restart both:
//      tmux kill-session -t sc; tmux new-session -d -s sc 'sclang'
//      systemctl restart zynthian.service
//    (SC and the Zynthian UI are independent processes — either can be
//    restarted alone depending on what you changed. Python/yml changes
//    only need the service restart; .scd patch changes only need SC.)
//
// 5. On the touchscreen: Add Instrument Chain -> Sampler -> SuperCollider ->
//    <BankName> -> <name>. Knobs should appear immediately, and selecting
//    it should swap which SynthDef actually sounds on the next MIDI note.
//
// Test the SC side standalone BEFORE touching Zynthian at all — this
// environment's own tmux session lets you eval code directly and catches
// most bugs faster than a full touchscreen round-trip:
//   tmux send-keys -t sc -l '~zynVoices[60] = ~zynPatchNoteOn.value(60, 100);'
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
// - get_controllers_dict() must paginate into screens of at most 4
//   controllers — the touchscreen shows 4 knobs per screen with no
//   scroll/pagination WITHIN a screen, so a naive "one screen per
//   zynconfig.yml group" implementation silently makes the 5th+ controller
//   invisible (no error, they just never appear anywhere). Fixed to chunk
//   like zynthian_engine_puredata does: bare group name if it fits on one
//   screen, "<group>#1", "<group>#2", ... if it needs more.
//
// - `is_toggle: true` params arrive as REAL OSC booleans, not 0.0/1.0
//   floats: zynthian_controller.get_ctrl_osc_val() sends `self.value > 0` (a
//   Python bool), and liblo encodes that as an OSC 'T'/'F' type tag, which
//   SC's OSC receiver decodes as an SC Boolean (true/false), not a Float.
//   Confirmed live: a patch comparing a toggle param with `< 0.5` threw
//   "Message '<' not understood. RECEIVER: false" on the FIRST toggle touch
//   — and since that comparison lived inside ~zynPatchNoteOn, the exception
//   silently killed every note-on afterward (no Synth ever got created,
//   total silence, "even setting it back" doesn't help since the stored
//   value is a Boolean either way).
//
// - .set() on an already-freed node ID is a real server-side error, not a
//   silent no-op — found 2026-07-08. One-shot patches (slicer) free their
//   Synth via their own short internal envelope, often well before MIDI
//   note-off arrives. The old assumption ("no gate arg, so .set(\gate,0)
//   harmlessly no-ops — SC ignores .set on unknown control names") is only
//   true for a LIVE node with an unrecognized control name; it does NOT
//   apply once the node itself no longer exists. Confirmed live: "FAILURE
//   IN SERVER /n_set Node <n> not found" printed on every one-shot trigger
//   whose note-off arrived after the voice had already self-freed. Fixed:
//   every Synth(...) creation site chains .register(true) — plain .register
//   (no argument) defaults to assumePlaying: false, so isPlaying would
//   incorrectly read false immediately after creation too; only
//   .register(true) makes it correctly read true right away and flip false
//   only on the real /n_end. Every .set() call on a tracked voice (noteOff,
//   plus subtractive1's knob setters) is now guarded: if(v.isPlaying) {...}.
//
// - Boolean.asFloat is NOT IMPLEMENTED in this box's SC class library —
//   found 2026-07-08, a deeper bug than the one above and NOT fixed by it.
//   The original fix for the previous gotcha was `msg[1].asFloat` in
//   ~zynRegisterParam's OSCdef — but confirmed live that `true.asFloat`
//   itself throws "Message 'asFloat' not understood" on this build,
//   regardless of where the boolean came from. So that "fix" was itself
//   silently crashing the OSCdef on every real touchscreen toggle touch
//   (server-console only — invisible on the touchscreen), never updating
//   ~zynCurrentParams at all. This is why Reverse looked completely inert
//   for a while even though the SynthDef's own reversal math tested out
//   correct in isolation (verified via FFT cross-correlation on real
//   recorded audio) — the toggle's value just never arrived. Real Booleans
//   DO support `.if()` here (confirmed live) — it's the control-flow
//   primitive, not a numeric-conversion convenience method — so the OSCdef
//   now branches explicitly: `if(raw.isKindOf(Boolean)) { raw.if(1.0, 0.0) }
//   { raw.asFloat }`. Test with a REAL Python-liblo boolean send, not SC's
//   own native `true`/`false` literals sent via NetAddr — those apparently
//   get silently numified before transmission and don't exercise this bug
//   at all (confirmed: `NetAddr(...).sendMsg(path, true)` from within SC
//   never crashed, but `/zynthian/venv/bin/python3 -c "import liblo; ...
//   liblo.send(addr, path, True)"` did, until this fix). Would affect every
//   is_toggle control in this codebase, not just one.
//
// - Single global ~zynVoice → stuck notes on overlapping note-on/note-off —
//   found 2026-07-08. If note B's note-on arrived before note A's note-off
//   (a chord, fast playing, even just testing on the touchscreen while a
//   note rings), the single ~zynVoice global got overwritten to point at B,
//   so A's note-off ended up targeting the wrong synth — A's own synth
//   never got `gate 0` and sustained forever (Env.adsr's sustain stage
//   holds indefinitely). Confirmed live via s.queryAllNodes(true) — found a
//   real orphaned scBasic node with gate:1 from ordinary touchscreen use.
//   Since stop() only calls osc_end() (see architecture note — no
//   subprocess to kill), the only fix at the time was removing the whole
//   chain. Fixed: ~zynVoices (IdentityDictionary, MIDI note number -> that
//   note's Synth) replaces ~zynVoice; noteOff looks up and releases only
//   its own note's entry, then removeAt's it. ~zynSetAllVoices.(ctrlName,
//   value) (iterates every currently-playing held voice) replaces
//   subtractive1's old single-~zynVoice knob setters — a knob turn now
//   affects every held note, not just whichever was struck last.
//
// - gb1-patch.scd is intentionally NOT in startup.scd's patch-loading list.
//   It still runs its setup at top level (not wrapped in ~zynPatches[\gb1])
//   from before real preset switching existed — loading it alongside the
//   others would activate it immediately and clobber whichever patch loads
//   after it, since it doesn't go through ~zynLoadPatch at all. It'll need
//   converting to the ~zynPatches pattern (see step 1 above) before it can
//   safely coexist with other patches, whenever it's revisited.
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
// - Removing/disabling the SC chain from the touchscreen does NOT stop
//   sound — stop() only calls osc_end(), by design (see architecture note
//   above: no subprocess to kill). Acceptable for a personal live-coding
//   box, but a real deviation from every other engine's behavior. The
//   per-note ~zynVoices fix (gotchas above) means a note that already
//   received a normal note-off can no longer get "stuck" this way, but a
//   note that's still genuinely held when you remove the chain will still
//   keep sounding — same as ever, just a smaller blast radius now.
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
//
// Manually switch the active patch (bypassing the touchscreen entirely),
// from within the sc tmux session:
// NetAddr("127.0.0.1", 57120).sendMsg("/scengine/loadpatch", "slicer");
