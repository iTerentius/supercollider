// Internet-radio input channel strip. Feeds mpv's JACK output (started/
// stopped via ~/.local/bin/sc-radio, patched to JACK:in_3/in_4 by that
// script) into the ndef-mixer/ndef-channel-16s rig as an ordinary Ndef
// channel strip - full amp/mute/pan/HPF/LPF controls, FX sends and all,
// same as ins1-12.
//
// Named \iRadio rather than reusing one of the ins1-12 slots so it never
// collides with whatever's plugged into those during a live session -
// deliberately NOT "ins"-prefixed, so ~fxInit's insPrefix scan never
// auto-discovers it and no boot-time ~fxSetSend call is needed either (see
// below) - it only ever becomes an FX-routed track when a project calls
// ~fxSetSend.(\iRadio, ...) itself, live, same as any track it adds on
// the fly. Confirmed live 2026-08-22: calling ~fxSetSend on a *new* track
// name at boot - cold, moments after ndef-channel-16s.scd's own ~fxInit()
// just built the whole ins1-12/dry_mix/master chain - corrupted
// Ndef(\dry_mix)'s rebuild and silently broke ALL ins1-12 routing to
// master for the rest of the session, not just the radio strip. That
// rebuild path is only ever exercised live, mid-session, from project
// code elsewhere in this codebase - never at cold boot - so it stays
// that way here too now.
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
    // monitor -> back into these input channels -> \iRadio/whatever it
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

    Ndef(\iRadio, { SoundIn.ar(~radioInChans) });
    ~ndefChanMk.(\iRadio);
    // No boot-time ~fxSetSend here - see header comment. Route it to FX
    // sends from project code (e.g. play.scd), live, when actually needed:
    //   ~fxSetSend.(\iRadio, \s1, 0.5);
    // Muted by default at boot - unmute with the nvim <leader>ir keymap
    // (toggles both ~/.local/bin/sc-radio and this mute state together),
    // or by hand by evaluating: Ndef(\iRadio).set(\mute, 0);
    Ndef(\iRadio).set(\amp, 1, \mute, 1, \pan, 0, \hpfreq, 20, \lpfreq, 18000);

    // ---- SWAP FROM SC, WITHOUT LEAVING THE EDITOR ----
    // <leader>ir (see nvim keymaps) is a pure toggle - it only prompts for a
    // URL when nothing's playing; pressing it again while live just stops.
    // These are for swapping straight from a .scd buffer instead, since
    // sc-radio itself now supports an in-place source swap (kill old ->
    // wait for its JACK client to release -> start new) rather than
    // requiring a separate stop.
    // ~radioSwap.("http://..." or "bbc_radio_four") - starts or hot-swaps
    // the stream, unmuting \iRadio only once sc-radio confirms the new
    // source actually patched in - never unmutes into dead air on a
    // failed/broken URL. sc-radio's own stdout (which source, or the
    // failure reason) posts automatically via unixCmd's default postOutput.
    ~radioSwap = { |urlOrStationId|
        var quoted = "'" ++ urlOrStationId.asString.replace("'", "'\\''") ++ "'";
        ("sc-radio " ++ quoted).unixCmd({ |exitCode|
            if(exitCode == 0) {
                Ndef(\iRadio).set(\mute, 0);
            } {
                ("~radioSwap: sc-radio failed (exit " ++ exitCode ++ ") - check: tmux attach -t sc-radio").warn;
            };
        });
    };

    // ~radioStop.() - stops + mutes.
    ~radioStop = {
        "sc-radio".unixCmd;
        Ndef(\iRadio).set(\mute, 1);
    };

    ("Radio input ready: Ndef(\\iRadio) <- JACK:in_"
        ++ (~radioInChans[0] + 1) ++ "/in_" ++ (~radioInChans[1] + 1)
        ++ " (muted by default).").postln;
} {
    "Radio input not configured on this host (no ~radioInChans set) - skipping.".postln;
};
)
