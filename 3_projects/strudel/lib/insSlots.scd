// insSlots.scd
// The \insN mixer channels do double duty: each carries a manually-evaluated
// "test source" slot (see play.scd) AND is also a destination bus for
// ~midiInMap'd Deluge clips. A slot left non-nil from an earlier eval (even
// from a previous day's session, since Ndef state persists for the life of
// the running sclang process) plays silently underneath whatever else is on
// that bus — including into recordings — with no indication until playback.
//
// ~insSlots is the single source of truth for which [ndefKey, slotIdx] pairs
// are "test sources" worth checking. Keep it in sync with play.scd's
// Ndef(\insN)[i] = ... assignments.
(
~insSlots = [
    [\ins1, 0],
    [\ins2, 0],
    [\ins3, 0],
    [\ins4, 0],
    [\ins4, 1],
    [\ins4, 2],
    [\ins4, 3],
    [\ins5, 0],
];

~insSlotsClear = {
    ~insSlots.do { |pair| Ndef(pair[0])[pair[1]] = nil };
    "[insSlots] all test slots cleared.".postln;
};

// Truthful, on-demand check against live Ndef state (not a cached flag) —
// call this right before recording so a leftover slot can't go unnoticed
// until you're listening back.
~insSlotsCheck = {
    var active = ~insSlots.select { |pair| Ndef(pair[0])[pair[1]].notNil };
    if(active.isEmpty) {
        "[insSlots] check: all test slots clear.".postln;
    } {
        ("[insSlots] CHECK — test slot(s) still live and WILL be recorded: "
            ++ active.collect { |p| p[0].asString ++ "[" ++ p[1] ++ "]" }.join(", ")
        ).warn;
    };
    active;
};
)
