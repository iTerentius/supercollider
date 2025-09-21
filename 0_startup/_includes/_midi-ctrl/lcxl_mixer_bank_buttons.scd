(
// =====================================================================
// LCXL bank select (bottom-row buttons) + LED feedback — 4-bank, configurable
// - Coexists with lcxl_mixer_auto_bind.scd (no changes needed there).
// - Bottom row buttons default to notes 73..80 (strip 1..8).
// - Press a button to set bank; LEDs reflect active bank.
// - Prev/Next (CC106/107) also update LEDs.
// - NO top-level 'var': only env fields & per-callback locals.
// =====================================================================

// Own / re-own our MIDIdefs
MIDIdef.free(\lcxl_bank_btns);
MIDIdef.free(\lcxl_bank_prev);
MIDIdef.free(\lcxl_bank_next);

~lcxlAB      = ~lcxlAB      ? ();  // from auto-binder
~lcxlAB_BTN  = ~lcxlAB_BTN  ? ();  // this module’s env

// ---------- CONFIG (edit the values in this block to taste) ----------
~lcxlAB_BTN[\config] = ~lcxlAB_BTN[\config] ? ();
~lcxlAB_BTN[\config].put(\fixedBanks,        (~lcxlAB_BTN[\config][\fixedBanks]        ?? { 4 }));          // EXACTLY 4 banks
~lcxlAB_BTN[\config].put(\btnNotes,          (~lcxlAB_BTN[\config][\btnNotes]          ?? { (73..80) }));   // bottom row
~lcxlAB_BTN[\config].put(\palette,           (~lcxlAB_BTN[\config][\palette]           ?? { (selected: 60, unselected: 62) })); // 60=green, 62=yellow/white-ish
~lcxlAB_BTN[\config].put(\resetOnLoad,       (~lcxlAB_BTN[\config][\resetOnLoad]       ?? { false }));      // send CC 0→0 to clear device LEDs for template?
~lcxlAB_BTN[\config].put(\forceClearExtra,   (~lcxlAB_BTN[\config][\forceClearExtra]   ?? { false }));      // also clear across extra channels (helps with “stuck” LEDs)
~lcxlAB_BTN[\config].put(\extraClearChannels,(~lcxlAB_BTN[\config][\extraClearChannels]?? { (0..15) }));    // 0-based channels to clear if forceClearExtra=true

// Copy device + channel from binder
~lcxlAB_BTN[\chan0] = ~lcxlAB[\chan0] ? 8;     // learned 9 → incoming 8
~lcxlAB_BTN[\srcID] = ~lcxlAB[\srcID];         // may be nil → accept any source

// MIDIOut to LCXL for LEDs (prefer non-HUI)
~lcxlAB_BTN[\out] = ~lcxlAB_BTN[\out] ? {
    var dest;
    dest = MIDIClient.destinations.detect({ |d|
        d.device.asString.contains("Launch Control XL")
        and: { d.name.asString.contains("(Launch Control XL)") }
    });
    if(dest.isNil) {
        dest = MIDIClient.destinations.detect({ |d|
            d.device.asString.contains("Launch Control XL")
            or:    { d.name.asString.contains("Launch Control XL") }
        });
    };
    if(dest.notNil) { MIDIOut.newByName(dest.device, dest.name) } { nil }
}.value;

// ---------- HELPERS ----------
~lcxlAB_BTN[\clearRow] = {
    var out, ch, notes;
    out   = ~lcxlAB_BTN[\out];
    ch    = ~lcxlAB_BTN[\chan0];
    notes = ~lcxlAB_BTN[\config][\btnNotes];
    if(out.isNil) { "[lcxl] No MIDIOut to LCXL (clearRow)".postln; ^nil };
    if(notes.isNil) { notes = (73..80) };

    // clear on current channel
    notes.do { |n| out.noteOn(ch, n, 0) };

    // optionally, also clear on extra channels (kills stale LEDs left by other templates)
    if(~lcxlAB_BTN[\config][\forceClearExtra] == true) {
        var chans = ~lcxlAB_BTN[\config][\extraClearChannels];
        chans.do { |c| notes.do { |n| out.noteOn(c, n, 0) } };
    };

    "[lcxl] bottom row cleared".postln;
};

~lcxlAB_BTN[\resetDeviceLEDs] = {
    var out, chans;
    out   = ~lcxlAB_BTN[\out];
    chans = (~lcxlAB_BTN[\config][\forceClearExtra] == true)
        .if({ ~lcxlAB_BTN[\config][\extraClearChannels] }, { [~lcxlAB_BTN[\chan0]] });
    if(out.isNil) { "[lcxl] No MIDIOut to LCXL (reset)".postln; ^nil };
    // CC 0, value 0 is Novation’s “LED reset for template (channel selects template)”
    chans.do { |c| out.control(c, 0, 0) };
    "[lcxl] device LED reset sent (CC0=0)".postln;
};

~lcxlAB_BTN[\refreshLEDs] = {
    var out, ch, notes, b, onVel, offVel, banks, n, vel, i;
    out   = ~lcxlAB_BTN[\out];
    ch    = ~lcxlAB_BTN[\chan0];
    notes = ~lcxlAB_BTN[\config][\btnNotes];
    banks = ~lcxlAB_BTN[\config][\fixedBanks];
    b     = (~lcxlAB[\bankIdx] ? 0).clip(0, banks-1);
    onVel  = (~lcxlAB_BTN[\config][\palette][\selected]).asInteger;
    offVel = (~lcxlAB_BTN[\config][\palette][\unselected]).asInteger;

    if(out.isNil) { "[lcxl] no MIDIOut to LCXL; LED refresh skipped".postln; ^nil };
    if(notes.isNil) { notes = (73..80) };

    // 1) hard clear all 8 first (prevents leftover greens on 5..8)
    notes.do { |nn| out.noteOn(ch, nn, 0) };

    // 2) paint only 0..(banks-1) as “valid” banks; keep others off
    i = 0;
    while({ i < banks }, {
        n = notes[i];
        vel = if(i == b) { onVel } { offVel };
        out.noteOn(ch, n, vel);
        i = i + 1;
    });
};

~lcxlAB_BTN[\setBank] = { |newIdx|
    var idx, banks;
    banks = ~lcxlAB_BTN[\config][\fixedBanks];
    idx = newIdx.clip(0, banks-1);
    ~lcxlAB[\bankIdx] = idx;         // binder reads this at runtime
    ~lcxlAB[\showBanner].();         // reuse binder’s banner
    ~lcxlAB_BTN[\refreshLEDs].();
};

// ---------- MIDI BINDINGS (note buttons + prev/next) ----------
MIDIdef.noteOn(\lcxl_bank_btns, { |vel, note, chan, src|
    var notes, idx, banks;
    notes = ~lcxlAB_BTN[\config][\btnNotes];
    banks = ~lcxlAB_BTN[\config][\fixedBanks];
    if(notes.isNil) { notes = (73..80) };
    idx = notes.indexOf(note);

    if(
        (vel > 0)
        and: { chan == ~lcxlAB_BTN[\chan0] }
        and: { (~lcxlAB[\srcID].isNil or: { src == ~lcxlAB[\srcID] }) }
        and: { idx.notNil }
        and: { idx < banks }
    ) {
        ~lcxlAB_BTN[\setBank].(idx);
    };
}, nil, ~lcxlAB_BTN[\chan0], ~lcxlAB[\srcID]);

MIDIdef.cc(\lcxl_bank_prev, { |val, cc, chan, src|
    if(val >= 64) {
        var banks = ~lcxlAB_BTN[\config][\fixedBanks];
        var idx   = ((~lcxlAB[\bankIdx] ? 0) - 1) % banks;
        ~lcxlAB_BTN[\setBank].(idx);
    };
}, 106, nil, ~lcxlAB[\srcID]);

MIDIdef.cc(\lcxl_bank_next, { |val, cc, chan, src|
    if(val >= 64) {
        var banks = ~lcxlAB_BTN[\config][\fixedBanks];
        var idx   = ((~lcxlAB[\bankIdx] ? 0) + 1) % banks;
        ~lcxlAB_BTN[\setBank].(idx);
    };
}, 107, nil, ~lcxlAB[\srcID]);

// ---------- One-time init sequence ----------
if(~lcxlAB_BTN[\config][\resetOnLoad] == true) {
    ~lcxlAB_BTN[\resetDeviceLEDs].();
};
~lcxlAB_BTN[\clearRow].();
~lcxlAB_BTN[\refreshLEDs].();

"[lcxl bank buttons] armed with fixedBanks=% palette=%  (chan=%)."
    .format(~lcxlAB_BTN[\config][\fixedBanks], ~lcxlAB_BTN[\config][\palette], ~lcxlAB_BTN[\chan0]).postln;
)

