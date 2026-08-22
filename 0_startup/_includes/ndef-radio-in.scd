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
    // PipeWire/WirePlumber auto-connects its default sink's MONITOR ports
    // (a tap of the Scarlett's own OUTPUT, not the mic) to any freshly-
    // created JACK input ports it finds - confirmed live 2026-08-22:
    // JACK:in_3/4 came up already wired to
    // alsa_output...Scarlett...sink:monitor_FL/FR the moment scsynth first
    // booted with numInputBusChannels=4, with nothing else involved yet.
    // That's a closed digital loop (master out -> hardware -> its own
    // monitor -> back into these input channels -> \insRadio/whatever it
    // feeds -> FX -> master...) entirely independent of the mic - same
    // class of problem the Zynthian branch above already works around via
    // jack_disconnect after boot. Torn down here, generically (by parsing
    // what's actually connected rather than hardcoding the monitor port
    // name), before anything - including sc-radio - ever gets a chance to
    // route real signal through these channels.
    (~radioInChans + 1).do { |ch|
        var port = "JACK:in_" ++ ch;
        ("pw-link -l > /tmp/.pwl_$$; awk -v d=\"" ++ port
            ++ "\" '$0==d{f=1;next} f&&/^  \\|<- /{print substr($0,7)} f&&!/^  \\|<- /{f=0}' /tmp/.pwl_$$"
            ++ " | while read -r s; do pw-link -d \"$s\" \"" ++ port
            ++ "\" 2>/dev/null; done; rm -f /tmp/.pwl_$$").unixCmd;
    };

    Ndef(\insRadio, { SoundIn.ar(~radioInChans) });
    ~ndefChanMk.(\insRadio);
    ~fxSetSend.(\insRadio, \s1, 0);
    ~fxSetSend.(\insRadio, \s2, 0);
    // Muted by default at boot - unmute with the nvim <leader>ir keymap
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
