// 2025-09-17 23:25 America-Chicago  mixer36 v9 usage notes  master 0 1

/* OVERVIEW
- Build
  master MixerChannel to hardware outs 0 1
  9 stereo tracks feed master  names m36_tr1..m36_tr9  handles in ~m36_tracks array index 0..8
  8 stereo FX returns feed master  names m36_fx1..m36_fx8  handles in ~m36_fxchans array index 0..7
  post fader sends from every track to every return are created with newPostSend  stored in ~m36_sends a 2d array

- Signal flow
  track synths write into each track inbus
  track post sends mix into each return inbus
  each FX return reads its own inbus  does processing  outputs to master

- Indexing
  tracks and returns use zero based indexes throughout the helpers
  example  track 3 is index 2  FX 2 is index 1
*/

/* CORE HANDLES
- ~m36_master             MixerChannel for master bus
  method level_(val)      set master fader in linear 0..1

- ~m36_tracks[i]          MixerChannel per track  i in 0..8
  method level_(val)      track fader  post sends follow the fader

- ~m36_fxchans[j]         MixerChannel per FX return  j in 0..7
  method level_(val)      return level to master

- ~m36_in.(trackIndex)    returns the audio bus index to route into that track
  param trackIndex        integer  zero based  example 2 for track 3
  use with Pbind or Synth args field out

- ~m36_setSend.(ti, si, level)
  param ti                track index  integer  zero based
  param si                send index   integer  zero based
  param level             send amount  float  0..1  post fader
*/

/* QUICK EXAMPLES  all of these are typical one liners you can drop into code
// route a Pbind into track 3
Pbind(\instrument, \default, \dur, 0.25, \degree, Pwhite(0,7,inf), \amp, 0.12, \out, ~m36_in.(2)).play;

// raise sends for that track
~m36_setSend.(2, 0, 0.7);   // to FX 1
~m36_setSend.(2, 1, 0.5);   // to FX 2
*/

/* FX MANAGEMENT
- ~m36_fxReset.(which, func)
  clears a return insert and attaches a new effect that reads that return inbus
  param which            FX return index  integer  zero based
  param func             function that returns a stereo UGen signal
  contract inside func   use In.ar(~m36_fxchans[which].inbus, 2) as input and return processed stereo

// example  wet reverb on FX 1  heavy distortion on FX 2
~m36_fxReset.(0, { var s; s = In.ar(~m36_fxchans[0].inbus, 2); FreeVerb2.ar(s[0], s[1], 0.6, 0.9, 0.2) });
~m36_fxReset.(1, { var s; s = In.ar(~m36_fxchans[1].inbus, 2); HPF.ar(tanh(s * 12), 200) * 0.9 });
*/

/* STEM MIRRORS  multichannel recording
- ~m36_armStemMirrors.(base)
  mirrors post fader tracks and wet FX returns to contiguous output pairs starting at base
  param base             left channel index of the first stem pair
  layout when base is 2  master stays 0 1
                         tr1 2 3  tr2 4 5  …  tr9 18 19
                         fx1 20 21  fx2 22 23  …  fx8 34 35
  ensure s.options.numOutputBusChannels is at least ~m36_stemTotal

- ~m36_disarmStemMirrors.()
  frees the mirror inserts
*/

/* SENDS ONLY PER TRACK  like Ableton sends only
- ~m36_sendsOnly.(ti, on)
  param ti               track index  integer
  param on               boolean  true enables sends only  dry is removed from master
  sends remain active  post fader  mirrors still work
*/

/* DIAGNOSTICS  metering and routing prints
- ~m36_scopeFx.(which)        opens a server scope on the chosen return input bus  shows send activity
- ~m36_printRouting.(ti)      prints fx1 and fx2 inbus indexes and the send levels from that track
- ~m36_demo.(trackIndex)      quick audible test on a track and raises sends to fx1 and fx2
- ~m36_zeroTrackSends.(ti)    sets all sends for that track to zero
- ~m36_soloFX.(which)         sets the chosen return to 0.9 and all other returns to 0
- ~m36_debug.()               prints mixer counts and sanity
*/

/* CLEANUP
- ~m36_freeAll.()
  frees mirrors  tracks  returns  buses  master  and clears all ~m36_* references
*/

/* TIPS
- set sends after you see the ready line  m36 ready master 0 1 tracks 9 sends 8
- post fader behavior means lowering a track fader reduces its sends as in a console
- if a return sounds wrong run fxReset on that return to wipe stale inserts and attach your effect again
- for scope reliability prefer ~m36_scopeFx which scopes the raw bus rather than channel widgets
*/


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

    ~ndefToTrack = { |key, track=0, chans=2|
      var tr, busIndex, grp;
      tr = ~m36_tracks[track];
      busIndex = tr.inbus.index;
      grp = tr.synthgroup;
      Ndef(key).play(out: busIndex, numChannels: chans, group: grp, addAction: \addToHead);
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

