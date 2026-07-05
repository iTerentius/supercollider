// zyn-engine-bridge.scd — bridges the Zynthian "SC" chain engine (Python side:
// zynthian-sc-engine repo, symlinked into zynthian-ui/zyngine/) to a live SC session.
//
// Only loaded on the zynthian host, from startup.scd. Two responsibilities:
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
//   2. MIDIdef.noteOn/noteOff on ~zynVoice — triggers/releases the active patch's
//      Synth. Fed by ZynMidiRouter via zynautoconnect once the "SC" chain exists;
//      dedicated to SC's own MIDI-in port "in0" specifically (zynautoconnect only
//      wires that one port — see jackname_midi regex in the engine's .py file).
//
// No srcID filtering, and this is deliberate, not a shortcut: checked
// /proc/asound/seq/clients live — a2jmidid bridges ALL JACK MIDI into ALSA
// through one single ALSA client ("a2jmidid"), so any two JACK sources routed
// into SC would look identical from srcID's point of view anyway. The real
// isolation is port dedication — "in0" is only ever jack_connect'ed to by
// zynautoconnect for this chain, nothing else — not source-address filtering.

~zynParamTable = IdentityDictionary.new;   // \paramName (Symbol) -> Function(value)
~zynCurrentParams = IdentityDictionary.new; // \paramName (Symbol) -> last-set value
~zynVoice = nil;                           // currently sounding Synth, if any

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
        ~zynParamTable[sym].value(msg[1]);
    }, "/scengine/" ++ sym);
};

MIDIdef.noteOn(\zynNoteOn, { |vel, note|
    ~zynLastVel = vel;
    ~zynVoice = ~zynPatchNoteOn.value(note, vel);
}, chan: nil);

MIDIdef.noteOff(\zynNoteOff, { |vel, note|
    ~zynVoice !? { |v| v.set(\gate, 0) };
}, chan: nil);

"[zyn-engine-bridge] loaded — ~zynParamTable ready, MIDIdef \\zynNoteOn/\\zynNoteOff bound.".postln;
