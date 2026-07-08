// zyn-engine-bridge.scd — bridges the Zynthian "SC" chain engine (Python side:
// zynthian-sc-engine repo, symlinked into zynthian-ui/zyngine/) to a live SC session.
//
// Only loaded on the zynthian host, from startup.scd. Three responsibilities:
//   0. ~zynPatches / ~zynLoadPatch — real preset switching. Every patch file
//      loaded at boot registers an "activate" Function into
//      ~zynPatches[\name] instead of setting ~zynPatchNoteOn/calling
//      ~zynRegisterParam directly — it only actually becomes the live
//      instrument once ~zynLoadPatch.(\name) runs that Function. Triggered
//      by the engine's set_preset() sending "/scengine/loadpatch <name>"
//      (a plain liblo.send, not a per-parameter zynthian_controller message
//      — this is a command, not a knob value).
//   1. ~zynRegisterParam(name) — zynthian_controller.send_value() (zyngine/
//      zynthian_controller.py:472-489) sends ONE OSC message PER PARAMETER when
//      its engine doesn't override send_controller_value(): liblo.send(osc_target,
//      zctrl.osc_path, zctrl.value) — a distinct literal path per param (e.g.
//      "/scengine/amp"), single float/bool arg. SC's OSCdef only does EXACT path
//      matching by default (pattern matching, per its own docs, is for wildcards
//      in an INCOMING sender's address, not for a receiver to catch a family of
//      exact paths with one wildcard registration) — so instead of one generic
//      dispatcher, each patch calls ~zynRegisterParam(\name) once per exposed
//      param, which both stores its setter in ~zynParamTable and registers the
//      one literal OSCdef for "/scengine/<name>". zynconfig.yml's osc_path
//      entries must match: "/scengine/<paramName>".
//   2. MIDIdef.noteOn/noteOff on ~zynVoices — triggers/releases the active patch's
//      Synth, tracked PER NOTE NUMBER (not a single global voice — see the
//      "overlapping notes" gotcha below). Fed by ZynMidiRouter via zynautoconnect
//      once the "SC" chain exists; dedicated to SC's own MIDI-in port "in0"
//      specifically (zynautoconnect only wires that one port — see jackname_midi
//      regex in the engine's .py file).
//
// No srcID filtering, and this is deliberate, not a shortcut: checked
// /proc/asound/seq/clients live — a2jmidid bridges ALL JACK MIDI into ALSA
// through one single ALSA client ("a2jmidid"), so any two JACK sources routed
// into SC would look identical from srcID's point of view anyway. The real
// isolation is port dedication — "in0" is only ever jack_connect'ed to by
// zynautoconnect for this chain, nothing else — not source-address filtering.

~zynParamTable = IdentityDictionary.new;   // \paramName (Symbol) -> Function(value)
~zynCurrentParams = IdentityDictionary.new; // \paramName (Symbol) -> last-set value

// note number (Integer) -> currently sounding Synth for THAT note. Was a
// single ~zynVoice global — bug found 2026-07-08: if note B's note-on
// arrived before note A's note-off (any overlap — chords, fast playing,
// even just testing on the touchscreen), ~zynVoice got overwritten to B,
// so A's note-off then sent gate=0 to B's synth instead of A's. A's synth
// never got released and sustained forever (Env.adsr's sustain stage holds
// indefinitely until gate drops) — the only fix was removing the whole
// chain, since stop() only calls osc_end(), it doesn't kill live synths.
// Per-note tracking means each note-off can only ever target its own note's
// synth, regardless of what else is held.
~zynVoices = IdentityDictionary.new;

// Apply a control change to every CURRENTLY PLAYING held voice — for
// live-tweaking a gated/sustained patch's knobs (subtractive1) while notes
// are held. isPlaying-guarded for the same reason noteOff is: a stale/freed
// node ID would otherwise throw "FAILURE IN SERVER /n_set Node <n> not
// found" on the next knob turn.
~zynSetAllVoices = { |ctrlName, value|
    ~zynVoices.do { |synth| if(synth.notNil and: { synth.isPlaying }) { synth.set(ctrlName, value) } };
};

~zynPatches = IdentityDictionary.new;       // \patchName (Symbol) -> activate Function
~zynActivePatch = nil;                      // \patchName of whichever is currently live

~zynLoadPatch = { |name|
    var sym = name.asSymbol;
    var fn = ~zynPatches[sym];
    if(fn.notNil) {
        fn.value;
        ~zynActivePatch = sym;
        ("[zyn-engine-bridge] activated patch: " ++ sym).postln;
    } {
        ("[zyn-engine-bridge] no such patch registered: " ++ sym).warn;
    };
};

OSCdef(\zynLoadPatch, { |msg| ~zynLoadPatch.value(msg[1].asSymbol) }, "/scengine/loadpatch");

// `default` is applied immediately to ~zynCurrentParams so a patch's
// ~zynPatchNoteOn can read a sane value even before any knob has been
// touched. Every subsequent OSC-driven change updates ~zynCurrentParams
// too — not just the live voice via setterFunc — because a synth only
// exists between note-on and note-off; a new note-on builds a brand new
// Synth from scratch, and without this it would silently reset to
// zynconfig.yml's static default rather than whatever the knob was last
// turned to (this is exactly what looked like a knob change "reverting"
// after under a second on a sequenced/repeating note).
~zynRegisterParam = { |name, setterFunc, default = 0|
    var sym = name.asSymbol;
    ~zynCurrentParams[sym] = default;
    ~zynParamTable[sym] = { |v|
        ~zynCurrentParams[sym] = v;
        setterFunc.value(v);
    };
    OSCdef(("zynParam_" ++ sym).asSymbol, { |msg|
        // zynthian_controller.get_ctrl_osc_val() (zyngine/zynthian_controller.py)
        // sends `self.value > 0` — a real Python bool — for any zctrl with
        // is_toggle: true, which liblo encodes as an OSC 'T'/'F' type tag,
        // not a 0.0/1.0 float. SC's OSC receiver decodes that as an SC
        // Boolean (true/false), not a Float — confirmed live: a patch
        // comparing ~zynCurrentParams[\mode] < 0.5 threw
        // "Message '<' not understood. RECEIVER: false" the first time a
        // toggle knob was touched, silently killing every note-on
        // afterward (an exception inside ~zynPatchNoteOn means no Synth
        // ever gets created).
        //
        // Bug found 2026-07-08, this fix's PREDECESSOR (`.asFloat`) doesn't
        // actually work on THIS box's SC build: confirmed live that
        // `true.asFloat` itself throws "Message 'asFloat' not understood" —
        // Boolean/True/False don't implement asFloat in this class library,
        // even though real Numbers do. Every is_toggle param (rev, mode, and
        // any future one) was silently crashing this OSCdef on every touch
        // from the real touchscreen (Python's liblo sends genuine OSC 'T'/'F'
        // tags) — never updating ~zynCurrentParams at all, which is why e.g.
        // Reverse looked like it did nothing. `.if()` IS implemented on real
        // Booleans (confirmed live) and is the actual control-flow primitive,
        // not a numeric-conversion convenience method — so branch on
        // isKindOf(Boolean) explicitly rather than relying on a conversion
        // method that isn't there.
        var raw = msg[1];
        var val = if(raw.isKindOf(Boolean)) { raw.if(1.0, 0.0) } { raw.asFloat };
        ~zynParamTable[sym].value(val);
    }, "/scengine/" ++ sym);
};

MIDIdef.noteOn(\zynNoteOn, { |vel, note|
    ~zynLastVel = vel;
    ~zynVoices[note] = ~zynPatchNoteOn.value(note, vel);
}, chan: nil);

MIDIdef.noteOff(\zynNoteOff, { |vel, note|
    // Guarded by isPlaying, not just !?: one-shot patches (slicer) free
    // their Synth on their own short internal envelope, often well before
    // note-off arrives — .set() on an
    // already-freed node ID isn't a silent no-op like an unknown control
    // name is, it's a real server-side failure ("FAILURE IN SERVER /n_set
    // Node <n> not found"), logged on every one-shot trigger whose note-off
    // shows up late. isPlaying only tracks reality if the Synth was created
    // with .register(true) (NodeWatcher) — see every ~zynPatchNoteOn.
    var synth = ~zynVoices[note];
    synth !? { |v| if(v.isPlaying) { v.set(\gate, 0) } };
    // Remove (not just nil the value) so ~zynVoices doesn't accumulate a
    // stale entry per distinct note number over a long session.
    ~zynVoices.removeAt(note);
}, chan: nil);

"[zyn-engine-bridge] loaded — ~zynParamTable ready, MIDIdef \\zynNoteOn/\\zynNoteOff bound.".postln;
