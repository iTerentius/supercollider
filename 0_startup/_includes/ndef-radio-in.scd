// Internet-radio input channel strip. Feeds mpv's JACK output (started/
// stopped via ~/.local/bin/sc-radio, patched to JACK:in_3/in_4 by that
// script) into the ndef-mixer/ndef-channel-16s rig as an ordinary Ndef
// channel strip - full amp/mute/pan/HPF/LPF controls, FX sends and all,
// same as ins1-12.
//
// Named \insRadio rather than reusing one of the ins1-12 slots so it never
// collides with whatever's plugged into those during a live session -
// still "ins"-prefixed, so ~fxInit's insPrefix scan picks it up like any
// other track.
//
// ~radioInChans is set only by the hostname == "hypo-fm" branch in
// startup.scd (the only host currently wired with dedicated radio-in
// channels) - nil everywhere else, so this file is safe to load
// unconditionally on every host without reading out-of-range, or
// hardware-meaningful on hosts with more real inputs, SoundIn channels.
(
if(~radioInChans.notNil) {
    Ndef(\insRadio, { SoundIn.ar(~radioInChans) });
    ~ndefChanMk.(\insRadio);
    ~fxSetSend.(\insRadio, \s1, 0);
    ~fxSetSend.(\insRadio, \s2, 0);
    // Muted by default at boot - unmute with the nvim <leader>sr keymap
    // (toggles both ~/.local/bin/sc-radio and this mute state together),
    // or by hand by evaluating: Ndef(\insRadio).set(\mute, 0);
    Ndef(\insRadio).set(\amp, 1, \mute, 1, \pan, 0, \hpfreq, 20, \lpfreq, 18000);
    ("Radio input ready: Ndef(\\insRadio) <- JACK:in_"
        ++ (~radioInChans[0] + 1) ++ "/in_" ++ (~radioInChans[1] + 1)
        ++ " (muted by default).").postln;
} {
    "Radio input not configured on this host (no ~radioInChans set) - skipping.".postln;
};
)
