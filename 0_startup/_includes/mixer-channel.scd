// 2025-09-16 21:45 America-Chicago  mixer36 drop-in v9  master 0 1
// Design
// - master MixerChannel -> hardware 0 1
// - 9 stereo tracks -> master
// - 8 stereo FX returns -> master
// - post fader sends via newPostSend
// - FX returns process by reading their own inbus with In.ar then output
// Helpers
// - ~m36_fxReset  clears a return and attaches a new effect
// - ~m36_soloFX  mutes all returns except one
// - ~m36_zeroTrackSends  zeroes sends for a track
// - ~m36_scopeFx  scopes the return input bus
// Style  vars at top of functions  no right paren in comments

(
s.waitForBoot({
    var totalMono, totalStereo, numTracks, numSends, hwOut;
    var master, tracks, fxs, sends;

    if(~m36_freeAll.notNil) { ~m36_freeAll.() };

    // ---------- config ----------
    totalMono   = 36;
    totalStereo = (totalMono / 2).asInteger;  // 18
    numTracks   = 9;
    numSends    = (totalStereo - (1 + numTracks)).max(0); // 8
    hwOut       = 0;                          // hardware 0 1

    // ---------- master ----------
    master = MixerChannel("m36_master", s, 2, 2, level: 0.9, outbus: hwOut);

    // ---------- fx returns ----------
    fxs = Array.fill(numSends, { |i|
        MixerChannel("m36_fx" ++ (i + 1), s, 2, 2, level: 0.9, outbus: master)
    });

    s.sync;

    // attach processing to first two returns by reading the return's inbus
    if(fxs.size > 0) {
        fxs[0].stop;
        fxs[0].play({
            var sig, wet, mix, room, damp;
            mix = 0.25; room = 0.85; damp = 0.25;
            sig = In.ar(fxs[0].inbus, 2);
            wet = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
            wet
        });
    };
    if(fxs.size > 1) {
        fxs[1].stop;
        fxs[1].play({
            var sig, dl, time, fb, wetAmt, out;
            time = 0.33; fb = 0.42; wetAmt = 0.5;
            sig  = In.ar(fxs[1].inbus, 2);
            dl   = LocalIn.ar(2);
            dl   = DelayC.ar(sig + (dl * fb), 1.0, [time, time * 1.12]);
            LocalOut.ar(dl);
            out  = XFade2.ar(sig, dl, (wetAmt * 2) - 1, 1);
            Limiter.ar(out, 0.95)
        });
    };

    s.sync;

    // ---------- tracks ----------
    tracks = Array.fill(numTracks, { |ti|
        MixerChannel("m36_tr" ++ (ti + 1), s, 2, 2, level: 0.8, outbus: master)
    });

    s.sync;

    // ---------- post sends track -> fx ----------
    sends = Array.fill(numTracks, { |ti|
        var row;
        row = Array.fill(numSends, { |si|
            tracks[ti].newPostSend(fxs[si], 0.0)
        });
        row
    });

    // ---------- publish ----------
    ~m36_numTracks = numTracks;
    ~m36_numSends  = numSends;
    ~m36_master    = master;
    ~m36_tracks    = tracks;
    ~m36_fxchans   = fxs;
    ~m36_sends     = sends;

    // route helper
    ~m36_in = { |trackIndex=0|
        var ch, idx;
        idx = trackIndex.asInteger;
        ch  = ~m36_tracks.wrapAt(idx);
        ch.inbus
    };

    // set send amount
    ~m36_setSend = { |trackIndex=0, sendIndex=0, level=0.3|
        var snd, ti, si, lev;
        ti = trackIndex.asInteger;
        si = sendIndex.asInteger;
        lev = level.clip(0, 1);
        snd = ~m36_sends.wrapAt(ti).wrapAt(si);
        snd.level_(lev);
    };

    // demo
    ~m36_demo = { |trackIndex=2|
        var tr;
        tr = trackIndex.clip(0, (~m36_tracks.size - 1).max(0));
        ~m36_master.level_(0.9);
        ~m36_tracks[tr].level_(0.8);
        ~m36_tracks[tr].play({ Blip.ar([220, 221], 5, 0.08) });
        ~m36_setSend.(tr, 0, 0.6);
        ~m36_setSend.(tr, 1, 0.35);
        "demo on track ".post; (tr + 1).postln;
    };

    // helpers
    ~m36_fxReset = { |which=0, func|
        var fx, f;
        fx = ~m36_fxchans.wrapAt(which);
        fx.effectgroup.freeAll;
        fx.synthgroup.freeAll;
        f = func;
        fx.play(f);
        fx
    };

    ~m36_soloFX = { |which=0|
        var i, n;
        i = 0; n = ~m36_numSends ? 0;
        while { i < n } {
            ~m36_fxchans[i].level_( if(i == which.asInteger, 0.9, 0.0) );
            i = i + 1;
        };
    };

    ~m36_zeroTrackSends = { |ti=0|
        var i, n, t;
        i = 0; n = ~m36_numSends ? 0; t = ti.asInteger;
        while { i < n } {
            ~m36_setSend.(t, i, 0.0);
            i = i + 1;
        };
    };

    ~m36_scopeFx = { |which=0|
        var fx, idx;
        fx  = ~m36_fxchans.wrapAt(which);
        idx = fx.inbus.index;
        s.scope(2, idx);
    };

    // debug
    ~m36_debug = {
        "m36 ready ".post; (~m36_tracks.notNil) and: { ~m36_tracks.size == ~m36_numTracks };
        " tracks ".post; (~m36_tracks ? []).size.post;
        " fx returns ".post; (~m36_fxchans ? []).size.post;
        " post sends created ".post; (~m36_sends ? []).flat.size.postln;
    };

    // cleanup
    ~m36_freeAll = {
        var chans;
        chans = ~m36_tracks ? [];
        chans.do({ |ch| ch.notNil.if({ ch.free }) });
        (~m36_fxchans ? []).do({ |fxc| fxc.notNil.if({ fxc.free }) });
        ~m36_master.notNil.if({ ~m36_master.free });
        ~m36_sends = nil; ~m36_tracks = nil; ~m36_fxchans = nil; ~m36_master = nil;
        "[m36] freed".postln;
    };

    "[m36] ready  master 0 1  tracks ".post; numTracks.post; "  sends ".post; numSends.postln;
});
)

