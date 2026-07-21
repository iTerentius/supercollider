// =============================================================================
// NDEF / NODEPROXY MIXER  (_includes/ndef-mixer.scd)
// =============================================================================
// NOT loaded by default. Load manually:
//   "_includes/ndef-mixer.scd".loadRelative;
// Globals: ~fxConf, ~fxState, ~fxInit, ~fxSetSend, ~fxAddSend, ~fxAddFX,
//          ~fxTracks, ~fxSends, ~fxTaps, ~fxSendSumName, ~fxTapName
//
// A NodeProxy (Ndef) alternative to the ddwMixerChannel system
// (see ref_mixer_channels.scd). Lighter, chainable, built-in crossfade on
// every source change — but you lose ddwMixerChannel's routing/group
// structure, so stems have to be tapped manually (see STEM CAPTURE below).
//
// Topology (built by ~fxInit):
//   insXXX (your voices, name must start with ~fxConf[\insPrefix], default "ins")
//     -> insXXX_to_s1, insXXX_to_s2 ...  (per-send taps, amt=0 by default)
//          -> s1_sum, s2_sum ...        (Mix of all taps for that send)
//               -> wet_bus              (Mix of all fxPrefix-named Ndefs)
//     -> dry_mix                        (Mix of all insXXX, raw)
//          -> dry_bus
//   master = (dry_bus * dry) + (wet_bus * wet), LeakDC'd, played to ~fxConf[\out]

// --- Config + boot ---
~fxConf = (
    insPrefix: "ins", fxPrefix: "fxs", sends: #[\s1, \s2],
    master: \master, out: 0
);
~fxInit.();                            // (re)builds everything currently in scope

// --- Define a voice (synth source) ---
// Name MUST start with ~fxConf[\insPrefix] ("ins...") or ~fxInit/~fxSetSend
// won't pick it up as a track.
Ndef(\insLead, { |freq = 220, amp = 0.3|
    SinOsc.ar(freq ! 2) * amp * EnvGen.kr(Env.asr(0.01, 1, 0.3), gate: 1)
}).play;

// --- Define a voice (sample source, one-shot Function) ---
Ndef(\insKick, {
    PlayBuf.ar(1, ~sTree[\808][\kick], loop: 0) ! 2
}).play;

// --- Define a voice (sample source, pattern) ---
// \pBm / \pBs already have an `out` control (see ref_synthdefs.scd) —
// NodeProxy injects its own bus as `out` for each event, same as any
// other pattern-sourced proxy.
Ndef(\insSnare).source = Pbind(
    \instrument, \pBm,
    \bufnum, ~sTree[\808][\snare],
    \amp, 0.6,
    \dur, 1
);
Ndef(\insSnare).play;

// --- Wire sends (auto-registers new tracks, rebuilds sums) ---
~fxSetSend.(\insLead, \s1, 0.3);       // insLead -> s1 (reverb send etc.)
~fxSetSend.(\insKick, \s2, 0.15);

// --- Define an FX return (name must start with ~fxConf[\fxPrefix], "fxs") ---
Ndef(\fxsVerb, {
    var sig = Ndef.ar(\s1_sum, 2);     // pull straight off the send sum
    FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.4)
}).play;
~fxAddFX.(\fxsVerb);                   // rebuild wet_bus to include it

// --- Add a new send bus at runtime ---
~fxAddSend.(\s3);
~fxConf[\sends] = ~fxState[\sends];    // keep config in sync if you inspect it later

// --- Master dry/wet balance ---
Ndef(\master).set(\dry, 1, \wet, 0.8, \amp, 1);

// --- Crossfade on source change (built in, no extra code) ---
Ndef(\insLead).fadeTime = 2;           // seconds
Ndef(\insLead).source = { SawDL.ar(110) * 0.2 ! 2 };  // fades over 2s, not a hard cut

// --- Chaining: any Ndef can read another by name ---
Ndef(\insLeadFX, { Ndef.ar(\insLead, 2) * LFPulse.kr(4) });

// =============================================================================
// STEM CAPTURE
// =============================================================================
// No built-in NodeProxy .record in SC 3.14 — RecNodeProxy/.record on NodeProxy
// is stale/legacy documentation and does not exist in this install (verified
// against the installed class library — do not rely on old JITLib tutorials
// for this). Capture stems the same way ~stemDiskStart does for
// ddwMixerChannel: a DiskOut synth reading straight off the proxy's bus,
// placed at the tail of the RootNode so it sees post-fade, current-block
// signal regardless of what's downstream.
//
// Works on ANY Ndef — a raw voice (pre-fx), a tap (post-send level), a sum,
// dry_bus/wet_bus, or master. Ndef must be playing (or at least have a bus
// allocated) before you read .index.

~ndefRecordStart = { |names, path, numFrames = 0|
    var idxs, buf, synth, defName;
    idxs = names.collect { |n| Ndef(n).index };
    if(idxs.includes(nil)) {
        "~ndefRecordStart: one or more Ndefs have no bus yet — .play them first".warn;
        ^nil
    };
    defName = \__ndefDiskOut__;
    SynthDef(defName, { |bufnum = 0|
        DiskOut.ar(bufnum, idxs.collect { |i| In.ar(i, 2) }.flat)
    }).add;
    s.sync;
    buf = Buffer.alloc(s, 65536, idxs.size * 2);
    buf.write(path, "WAV", "int24", numFrames, 0, leaveOpen: true);
    synth = Synth(defName, [\bufnum, buf], RootNode(s), \addToTail);
    (finalize: {
        synth.free;
        s.sync;
        buf.close;
        buf.free;
    })
};

// --- Capture two voices to one interleaved file (2ch per name) ---
~rec = ~ndefRecordStart.([\insLead, \insKick], "~/recordings/ndef_take.wav".standardizePath);
// ... play ...
~rec[\finalize].();                    // stop, close, free — same shape as ~stemStopNow

// --- Capture the master bus only ---
~rec = ~ndefRecordStart.([\master], "~/recordings/ndef_master.wav".standardizePath);
~rec[\finalize].();

// For beat-quantized start/stop, interleave-split via ffmpeg, MIDI/history
// capture alongside the audio, reuse ~stemDiskStart's machinery instead of
// this — it just needs bus indices, not MixerChannel objects specifically.
// See ref_stem_recording.scd.

// =============================================================================
// CLEANUP
// =============================================================================
Ndef(\insLead).end;                    // fades out (uses .fadeTime) then frees the synth
Ndef(\insLead).clear;                  // stop + remove definition entirely
Ndef.all.do(_.clear);                  // nuke everything — use with care

// =============================================================================
// PROXYSPACE (optional, not used by this file)
// =============================================================================
// ProxySpace.push(s) rebinds `~name = ...` globally to create/replace Ndefs,
// shortening `Ndef(\x).source = {...}; Ndef(\x).play` to `~x = {...}`.
//
// Tradeoff: it hijacks environment-variable assignment for the WHOLE
// interpreter while pushed, which collides with the huge number of
// ~-prefixed globals ddwMixerChannel/mixer-channel-16s.scd already owns
// (~t1, ~r1, ~m1, ~link, etc.) — those are plain object refs, not proxies,
// and mixing the two in one session is a foot-gun. If you want to try it,
// do it in a throwaway scratch file, not alongside the mixer-channel system.
(
p = ProxySpace.push(s);
~x = { SinOsc.ar(440) * 0.1 ! 2 };
~x.play;
)
p.pop;                                  // restore normal environment
