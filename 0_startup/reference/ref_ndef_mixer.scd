// =============================================================================
// NDEF / NODEPROXY MIXER  (_includes/ndef-mixer.scd)
// =============================================================================
// NOT loaded by default. Load manually:
//   "_includes/ndef-mixer.scd".loadRelative;
// Globals: ~fxConf, ~fxState, ~fxInit, ~fxSetSend, ~fxAddSend, ~fxAddFX,
//          ~fxTracks, ~fxSends, ~fxTaps, ~fxSendSumName, ~fxTapName
//
// Fixed 16-strip boilerplate + APC40 bindings built on top of this engine:
// see CHANNEL STRIP BOILERPLATE below (_includes/ndef-channel-16s.scd,
// _includes/ndef-channel-apc.scd).
//
// A NodeProxy (Ndef) alternative to the ddwMixerChannel system
// (see ref_mixer_channels.scd). Lighter, chainable, built-in crossfade on
// every source change — but you lose ddwMixerChannel's routing/group
// structure, so stems have to be tapped manually (see STEM CAPTURE below).
// Pick one system per session — not meant to run alongside ddwMixerChannel.
//
// Topology (built by ~fxInit):
//   insXXX (your voices, name must start with ~fxConf[\insPrefix], default "ins")
//     -> insXXX_to_s1, insXXX_to_s2 ...  (per-send taps, amt=0 by default)
//          -> s1_sum, s2_sum ...        (Mix of all taps for that send)
//               -> wet_bus              (Mix of all fxPrefix-named Ndefs)
//     -> dry_mix                        (Mix of all insXXX, raw)
//          -> dry_bus
//   master = (dry_bus * dry) + (wet_bus * wet), LeakDC'd, played to ~fxConf[\out]
//
// IMPORTANT: only `master` should ever call `.play`. Every other Ndef in this
// system — your voices included — just needs a source; it wakes up
// automatically the instant something downstream references it via
// Ndef.ar()/Ndef.kr(), which dry_mix/taps/sums already do. See GOTCHAS below
// for why calling `.play` on anything else is actively harmful, not just
// unnecessary.

// --- Config + boot ---
~fxConf = (
    insPrefix: "ins", fxPrefix: "fxs", sends: #[\s1, \s2],
    master: \master, out: 0
);
~fxInit.();                            // (re)builds everything currently in scope

// --- Define a voice (synth source) ---
// Name MUST start with ~fxConf[\insPrefix] ("ins...") or ~fxInit/~fxSetSend
// won't pick it up as a track. No .play — see note above.
Ndef(\insLead)[0] = { |freq = 220, amp = 0.3|
    SinOsc.ar(freq ! 2) * amp * EnvGen.kr(Env.asr(0.01, 1, 0.3), gate: 1)
};

// --- Define a voice (sample source, one-shot Function) ---
Ndef(\insKick)[0] = {
    PlayBuf.ar(1, ~sTree[\808][\kick], loop: 0) ! 2
};

// --- Define a voice (sample source, pattern) ---
// \pBm / \pBs already have an `out` control (see ref_synthdefs.scd) —
// NodeProxy injects its own bus as `out` for each event, same as any
// other pattern-sourced proxy.
Ndef(\insSnare)[0] = Pbind(
    \instrument, \pBm,
    \bufnum, ~sTree[\808][\snare],
    \amp, 0.6,
    \dur, 1
);

// --- Wire sends (auto-registers new tracks, rebuilds sums) ---
// ~fxSetSend is safe to call repeatedly from a live controller: only the
// FIRST call for a given track/send pair rebuilds anything (dry_mix + the
// send sum both need a new Mix() graph when the track count changes).
// Every call after that is a plain Ndef(tap).set(\amt, val) — no rebuild,
// no crossfade, no glitch on other tracks sharing that send.
~fxSetSend.(\insLead, \s1, 0.3);       // insLead -> s1 (reverb send etc.)
~fxSetSend.(\insKick, \s2, 0.15);

// --- Define an FX return (name must start with ~fxConf[\fxPrefix], "fxs") ---
Ndef(\fxsVerb)[0] = {
    var sig = Ndef.ar(\s1_sum, 2);     // pull straight off the send sum
    FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.4)
};
~fxAddFX.(\fxsVerb);                   // rebuild wet_bus to include it

// --- Add a new send bus at runtime ---
~fxAddSend.(\s3);
~fxConf[\sends] = ~fxState[\sends];    // keep config in sync if you inspect it later

// =============================================================================
// FX-TO-FX ROUTING  (_includes/ndef-fx-route.scd — ~fxRoute)
// =============================================================================
// DAW-style "route one return into another" (reverb into delay, so you hear
// delay repeats OF the reverb tail — genuine serial processing, not just two
// returns coexisting in wet_bus). Matrix-capable: any number of sources into
// any target, each independently live-adjustable, same LaunchPad-matrix-of-
// toggles workflow as the ddwMixerChannel projects that used this pattern.
//
// Same tap+sum+live-\amt shape as ~fxSetSend, just retargeted fx->fx instead
// of track->send. Repeat ~fxRoute calls on an existing connection are a plain
// .set(\amt, val) — no rebuild, no glitch on other connections into the same
// target, same efficiency lesson as ~fxSetSend.
//
// CONSTRAINT: a fx can only be a routing TARGET if it's defined via
// ~fxRouteReg instead of a plain [0] = {...} — its [0] has to be rebuildable
// ("normal input + whatever's currently routed in") whenever a connection
// changes, so its core DSP and its normal input are registered separately.
// Any EXISTING fx works fine as a routing SOURCE with zero changes — only
// targets need ~fxRouteReg.
Ndef(\fxsBitcrush)[0] = { |rate=8000, bits=6, mix=1|
    var sig = Ndef.ar(\s1_sum, 2);
    ~fxg[\bitcrush].(sig, rate, bits, mix)
};
~fxAddFX.(\fxsBitcrush);

// \fxsDelay defined as a ROUTABLE TARGET instead of a plain [0] = {...}
~fxRouteReg.(\fxsDelay, \s2_sum, { |sig| CombL.ar(sig, 0.4, \dt.kr(0.375), \dec.kr(1.5)) });

~fxRoute.(\fxsVerb, \fxsDelay, 0.4);       // verb -> delay
~fxRoute.(\fxsBitcrush, \fxsDelay, 0.2);   // ALSO bitcrush -> delay, same target, independent amt
~fxRoute.(\fxsVerb, \fxsDelay, 0);         // dial to nothing without fully removing
~fxUnroute.(\fxsVerb, \fxsDelay);          // fully remove — rebuilds delay without that tap
//
// For a LaunchPad/APC matrix of toggles: each pad is just
// ~fxRoute.(rowFx, colFx, x) — same shape as any other
// ~apcBindParam/~lpBind callback, no new controller-binding pattern needed.

// --- Master dry/wet balance ---
Ndef(\master).set(\dry, 1, \wet, 0.8, \amp, 1);

// --- Crossfade on source change (built in, no extra code) ---
Ndef(\insLead).fadeTime = 2;           // seconds
Ndef(\insLead)[0] = { SawDL.ar(110) * 0.2 ! 2 };  // fades over 2s, not a hard cut

// --- Chaining: any Ndef can read another by name ---
Ndef(\insLeadFX)[0] = { Ndef.ar(\insLead, 2) * LFPulse.kr(4) };

// =============================================================================
// .source = obj  vs  [0] = obj  —  THESE ARE NOT THE SAME THING
// =============================================================================
// `.source_` is literally defined as `this.put(nil, obj, 0)` — it passes
// index: nil, not index: 0. That nil propagates into NodeProxy's internal
// prepareOtherObjects, which treats a nil index as "this is a full
// redefinition" and calls removeAllToBundle — wiping EVERY other index
// ([1], [2], [3]...), not just the one you're setting.
//
// `[0] = obj` passes the real index (0), which only clears/replaces that one
// slot and leaves filters at other indices untouched.
//
// Concretely: if a voice already has a filter chain (level/pan/EQ) stamped
// on it at [1]/[2]/[3] and you do `Ndef(\ins1).source = {...}` to route a
// new synth into it, the ENTIRE filter chain silently disappears — no error,
// no warning, and every control you set afterward (amp, pan, ...) does
// nothing because the objects that declared those controls are gone. This
// was the root cause of a very long "the fader doesn't do anything" session.
//
// Rule of thumb: once a proxy has more than just a source, always use
// `[0] = obj`, never `.source = obj`.
Ndef(\ins1)[0] = { Ndef.ar(\insKick, 2) };   // correct — preserves [1]/[2]/[3]
// Ndef(\ins1).source = { Ndef.ar(\insKick, 2) };  // WRONG — wipes the filter chain

// =============================================================================
// FILTER CHAIN + PATTERN CONTROL
// =============================================================================
// Ndef indices [1], [2], [3]... are a filter chain applied in order on top of
// whatever's at [0]. `\filter -> func` marks an index as a filter (reads the
// proxy's own current bus as `in`, replaces it) instead of a new source.
Ndef(\insLead)[1] = \filter -> { |in, cutoff = 800| RLPF.ar(in, cutoff, 0.3) };

// CAVEAT, empirically found (not fully root-caused): a named control declared
// inside a \filter -> function does not reliably respond to
// Ndef(\x).set(\name, val) the way a control declared on the SOURCE (index 0)
// does. In one debugging session, `.set` on a filter's own control was a
// consistent no-op even though the filter was verifiably still attached
// ([N] non-nil, name present in .controlNames) — moving the exact same
// control to the source function fixed it immediately. Suspect: the
// \filter role's internal XOut/EnvGate crossfade wrapper (used so a NEW
// filter can fade in over an OLD one) may not be exposing the control the
// same way a plain source does. Until this is root-caused: if you need to
// externally .set() a parameter live (fader, pattern, etc.), put it on the
// SOURCE at [0], not inside a \filter -> function. Since \pset/\xset (below)
// are themselves just patterned wrappers around .set()/.xset(), they likely
// inherit the same limitation on filter-only controls — prefer targeting
// source-level controls with them too until this is confirmed either way.

// A Pbind at another index can drive a control directly — use role \pset
// (hard jump) or \xset (smoothed via control-bus mapping).
// Verified against JITLib source (wrapForNodeProxy.sc): \pset/\xset route
// per-event key/value pairs through the proxy's SHARED nodeMap, which
// broadcasts to every same-named control across every index. The key must
// match exactly, and the control must already exist on the proxy (build
// whatever declares it first) or early pset events are dropped.
Ndef(\insLead)[2] = \pset -> Pbind(
    \cutoff, Pseq([400, 800, 1200, 2000], inf),
    \dur, 1
);
// Same shape, smoothed instead of stepped:
// Ndef(\insLead)[2] = \xset -> Pbind(\cutoff, Pseq([...], inf), \dur, 1);

// =============================================================================
// GLOBAL CLOCK + QUANT
// =============================================================================
// NodeProxy has no built-in global default for clock/quant (only fadeTime
// has a classvar, NodeProxy.defaultFadeTime, and that only affects NEW
// instances, not ones already playing). The real mechanism: Ndef.all is
// backed by a per-server ProxySpace, and every Ndef(key) creation routes
// through that space's initProxy, which stamps its clock/quant/fadeTime onto
// the new proxy. Setting these on the space also retroactively pushes to
// every Ndef that already exists.
Ndef.dictFor(s).clock = ~link;
Ndef.dictFor(s).quant = 1;              // snap .play and .source= swaps to the beat grid
//
// Without quant, `.play`/`.source=` fire immediately at "now" with no
// beat-snapping — two Ndefs started at different real-time moments end up
// phase-offset from each other even though they're ticking on the same
// clock. This is the most common cause of "my Ndefs seem out of sync."

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

// ~ndefRecordStart above is intentionally minimal: raw interleaved capture
// only. It does NOT do beat-quantized start/stop, autoSplit into individual
// stereo stems, captureHistory, or captureMidi — ~stemDiskStart
// (ddwMixerChannel) has all of that already, and full feature parity with
// Ndefs doesn't need a reimplementation — see _includes/ndef-stem-record.scd
// (~ndefAsChan): a one-line adapter Event that answers `.inbus`/`.name`,
// which is the ONLY thing ~stemDiskStart ever calls on a track/return. Lets
// you pass Ndefs into the real, unmodified ~stemDiskStart directly:
//   ~stemStop = ~stemDiskStart.(
//       tracks:  [~ndefAsChan.(Ndef(\ins1)), ~ndefAsChan.(Ndef(\ins2))],
//       returns: [~ndefAsChan.(Ndef(\fxsVerb))],
//       clock: ~link, autoSplit: true, captureHistory: true, captureMidi: true
//   );
// Quantized start/stop, autoSplit, captureHistory all work identically to
// ddwMixerChannel this way — none of that logic cares what supplied the bus
// index. captureMidi has one real caveat, but it's orthogonal to Ndefs
// entirely: it only captures ev[\type] nil/\note events, so a \type \grain
// pattern (see the sustain/legato-race fix elsewhere in this codebase) won't
// show up in the .mid file on EITHER system — see ndef-stem-record.scd for
// the full explanation. Reach for ~ndefRecordStart only when you want a
// quick raw capture and don't need any of the above. Full ~stemDiskStart
// kwarg reference (splitCodec, dirPath defaults, etc.): ref_stem_recording.scd
// — requires mixer-channel-stem-record.scd loaded (it's pure function
// definitions, no dependency on real MixerChannels existing, so it's safe to
// load standalone even with mixer-channel-16s.scd itself disabled).

// =============================================================================
// SUBMIX GROUPS (e.g. a drum kit)
// =============================================================================
// The `sends` in this file are a PARALLEL AUX SEND (like a reverb send), not
// a group insert — every insXXX is summed into dry_mix unconditionally, so
// pointing several voices at a send with amt:1 duplicates them, it doesn't
// group them.
//
// The rule: name the individual voices WITHOUT the insPrefix, so ~fxInit's
// auto-discovery never sees them as separate tracks — that's it, no special
// "vox"-style naming convention required, any non-"ins" name works
// identically (\a, \b, \kick, whatever you want). This applies to a single
// ROUTED voice too, not just a multi-voice submix (e.g. \kit, not \inskit,
// if you're routing one voice into a strip rather than building a kit).
//
// Two ways to actually get the group into the mix — pick based on whether
// you're using the fixed ins1-12 strip boilerplate (ndef-channel-16s.scd):

// ---- Option A (recommended if you're using the ins1-12 strips already) ----
// Build the submix un-prefixed, then route it into an EXISTING strip exactly
// like you would a single voice. The strip already has amp/mute/pan/HPF-LPF
// from ~ndefChanMk AND an APC binding (if ndef-channel-apc.scd is loaded) —
// nothing extra to build for the group level at all, it's already there.
Ndef(\kick)[0] = { PlayBuf.ar(1, ~sTree[\808][\kick],  loop: 0) ! 2 };
Ndef(\snare)[0] = { PlayBuf.ar(1, ~sTree[\808][\snare], loop: 0) ! 2 };
~ndefChanMk.(\kick);    // independent per-voice amp/mute/pan/HPF-LPF (optional but recommended)
~ndefChanMk.(\snare);

Ndef(\kit)[0] = {
    var mix = Mix([Ndef.ar(\kick, 2), Ndef.ar(\snare, 2)]);
    Compander.ar(mix, mix, thresh: 0.5, slopeAbove: 0.4)   // optional group glue comp
};
// No ~ndefChanMk on \kit itself — the strip it's about to feed already
// provides amp/mute/pan/HPF-LPF at the group level, so adding another
// identical stage here would just be redundant double-processing.

Ndef(\ins1)[0] = { |amp = 1| Ndef.ar(\kit, 2) * amp };   // .ar(), not bare Ndef(\kit) — see gotcha below
// \ins1 is already "ins"-prefixed (it's one of the pre-built 12 strips), so
// its own fader/mute/pan AND sends work with zero extra setup:
~fxSetSend.(\ins1, \s1, 0.3);     // whole kit -> reverb, same call as any single track

// ---- Option B (standalone submix, not tied to a fixed strip) ----
// Useful if you're not using ndef-channel-16s.scd, or want a submix that
// isn't one of your 12 strips. The submix Ndef itself becomes the "ins"
// track directly — give IT the ~ndefChanMk treatment since there's no strip
// downstream to provide it:
//   Ndef(\insDrums)[0] = { Mix([Ndef.ar(\kick, 2), Ndef.ar(\snare, 2)]) };
//   ~ndefChanMk.(\insDrums, hasPan: false);
//   ~fxSetSend.(\insDrums, \s1, 0.3);

// Voices are independently tappable for stems via ~ndefRecordStart either
// way, addressed by their own names (\kick, \snare) regardless of which
// option routes them to the output.

// --- Temporarily dropping ONE voice from the kit ---
// Two different tools depending on what you actually want:
//   Ndef(\kick).set(\mute, 1);   // silences JUST the kick, \kit/\ins1 stay
//                                 // live for everything else. Nothing gets
//                                 // freed, so re-evaluating something
//                                 // downstream (\kit, \ins1, a send, an FX
//                                 // return) can't "wake it back up" the way
//                                 // .free would — see GOTCHAS below.
//   Ndef(\kick).pause;            // if \kick is PATTERN-driven: actually
//   Ndef(\kick).resume;           // stops new events from firing (not just
//                                 // silences audio) — respects
//                                 // Ndef(\kick).quant/.clock on resume.
// \mute silences audio but a pattern keeps firing (still spawning nodes,
// just quiet ones). .pause/.resume stops events firing at all, but is a
// whole-proxy operation — fine here since each voice is its own Ndef, but
// wouldn't selectively scope to "just one layer" if you ever put multiple
// independently-controlled streams on different indices of the SAME Ndef
// rather than as separate voices like this.
// If instead you want a pattern to drive \amp for musical effect (a hi-hat
// rhythm, a tremolo LFO via .map) while STILL being able to mute reliably,
// that's exactly why \amp and \mute are separate controls — a pattern
// owning \amp will silently overwrite a manual .set(\amp, 0), but never
// touches \mute.
//
// Same amp-vs-mute reasoning applies at the \ins1 level for the whole kit
// at once: Ndef(\ins1).set(\mute, 1) silences the entire group without
// touching any individual voice's own mute state.

// =============================================================================
// CHANNEL STRIP BOILERPLATE
// (_includes/ndef-channel-16s.scd, _includes/ndef-channel-apc.scd)
// =============================================================================
// A fixed 12-track + 2-return layout on top of this engine, mirroring
// mixer-channel-16s.scd's shape (see ref_mixer_channels.scd) for anyone
// switching between the two systems.
//
// Load order:
//   "_includes/ndef-mixer.scd".loadRelative;
//   "_includes/ndef-channel-16s.scd".loadRelative;
//   "_includes/ndef-channel-apc.scd".loadRelative;   // optional, APC40 only
//
// ndef-channel-16s.scd:
//   ~ndefChanMk.(name, hasPan: true) — stamps an amp+mute / pan / HPF-LPF
//   filter chain onto a Ndef (indices [1]/[2]/[3]), BEFORE any real source
//   exists. \amp and \mute are separate multipliers (in * amp * (1 - mute))
//   specifically so a pattern/LFO can own \amp for musical effect while
//   \mute stays a reliable, nothing-else-touches-it manual override — see
//   SUBMIX GROUPS above for the motivating case.
//   Pre-builds \ins1.."\ins12" (plug a voice in later, see below) and two
//   returns, \fxsVerb (reverb) / \fxsDelay (delay), using the same named
//   controls as the ddwMixerChannel return FX (\mix/\room/\damp, \dt/\dec).
//   Calls the existing ~fxInit to wire it all up.
//
//   Gotcha this file works around: adding a filter to a still-neutral proxy
//   probes your function with a channel-less Silent.ar (defaults to MONO) to
//   infer its output shape — that locks the WHOLE proxy to 1 channel, and a
//   later stereo-only filter (e.g. Balance2.ar(in[0], in[1], pan)) then
//   throws "Message 'at' not understood" on `in`, because `in` came through
//   as a scalar OutputProxy, not a 2-element array. Fix: call
//   `nd.initBus(\audio, 2)` FIRST, before adding any filter — forces stereo
//   up front, idempotent on re-evaluation (no-ops if already matching).
//
// Plug a voice into a strip — use [0] =, NOT .source= (see the section above
// on why: .source= wipes the amp/pan/HPF-LPF filter chain ~ndefChanMk just
// built at [1]/[2]/[3]):
//   Ndef(\ins1)[0] = { PlayBuf.ar(2, buf, loop: 0) };
//   Ndef(\ins2)[0] = Pbind(\instrument, \pBm, \bufnum, buf, \dur, 1);
//
//   Also name the voice itself something that does NOT start with "ins" if
//   it's meant to feed a strip rather than be its own track (e.g. \kit, not
//   \inskit) — same reasoning as SUBMIX GROUPS above, just for a single
//   routed voice: ~fxInit's discovery would otherwise double-count it as an
//   independent track, bypassing the strip's fader entirely.
//
// ndef-channel-apc.scd:
//   ~apcNdefChanBind.(bank, strip, name, pan: true) — mirrors ~apcMixBind:
//     fader   -> Ndef(name).set(\amp, x)
//     row 1   -> Ndef(name).set(\pan, x.linlin(0, 1, -1, 1))     (if pan)
//     row 2/3 -> Ndef(name).set(\hpfreq, ...) / .set(\lpfreq, ...)
//   Bank 0 = ins1-8, bank 1 = ins9-12 + fxsVerb/fxsDelay (pan: false).
//   Master fader -> Ndef(\master).set(\amp, x.linlin(0, 1, 0, 4.0)).
//
//   Do NOT use NodeProxy's .vol/.vol_ for this — that controls the gain of
//   the proxy's OWN .play() monitor synth (a separate, parallel path
//   straight to hardware out), not the bus content other Ndefs read via
//   Ndef.ar(). It has zero effect on what dry_mix hears.

// =============================================================================
// CLEANUP
// =============================================================================
Ndef(\insLead).end;                    // fades out (uses .fadeTime) then frees the synth
Ndef(\insLead).clear;                  // stop + remove definition entirely
Ndef.all.do(_.clear);                  // nuke everything — use with care

// =============================================================================
// GOTCHAS
// =============================================================================
// - `.source = obj` is NOT the same as `[0] = obj` — it wipes every other
//   index. See ".source = obj vs [0] = obj" section above. This one cost an
//   entire debugging session (fader "doing nothing" was the filter chain
//   silently gone, not a broken control).
//
// - FIXED (was previously a live bug in ndef-mixer.scd, corrected in the
//   file itself): every internal node — every tap, every send-sum, dry_mix,
//   dry_bus, wet_bus — used to call bare `.play`, which opens a direct
//   monitor straight to hardware out 0 (that's literally what "monitoring"
//   means in the JITLib source — the same mechanism that makes
//   `Ndef(\x, {...}).play` audible in a one-liner demo). That meant every one
//   of them was ALSO playing, unattenuated, in parallel with whatever
//   master's dry/wet/amp scaling did — the reason master's fader couldn't
//   reach true silence. Only `master` calls `.play` now. Same reasoning
//   applies to voices you define yourself: don't `.play` them, just give
//   them a source — see the IMPORTANT note at the top of this file.
//
// - FIXED (was previously a live bug in ndef-mixer.scd, corrected in the
//   file itself): `~fxInit`'s auto-discovery scanned `Ndef.all.keys` for
//   names starting with `insPrefix`/`fxPrefix`. `Ndef.all` is keyed by
//   SERVER NAME (`server.name -> ProxySpace`), not by Ndef name — that scan
//   always found nothing, meaning `~fxState[\tracks]` was permanently empty
//   and `dry_mix`/`wet_bus` were structurally silent regardless of how many
//   tracks/returns actually existed. `~fxSetSend` worked around this
//   accidentally, since it manually appends to `~fxState[\tracks]` and never
//   relied on the scan — which is why manual single-track registration
//   always worked while bulk auto-discovery (used by ndef-channel-16s.scd)
//   silently never found anything. Fixed to
//   `Ndef.dictFor(s).envir.keys` — that's the dictionary that's actually
//   keyed by Ndef name, for the current server.
//
// - `\filter -> func`'s own named controls don't reliably respond to
//   `.set()` — see the CAVEAT under FILTER CHAIN + PATTERN CONTROL above.
//   Keep anything you need to control live on the source, not the filter.
//
// - SC's built-in NdefMixer GUI has a broken record button: it calls
//   RecordProxyMixer(...), and that class does not exist anywhere in SC
//   3.14.1 (verified — no source file, no class definition in the installed
//   class library). It will always throw "Message 'new' not understood,
//   RECEIVER: nil" on click. Not fixable from user code; use
//   ~ndefRecordStart above instead.
//
// - After a long stretch of live-rebuilding the same Ndefs interactively
//   (repeated ~fxInit/~ndefChanMk calls, .clear, reshaping filter chains,
//   etc. in one long-running sclang/scsynth session), watch the post window
//   for `late` scheduling messages or `makeSynthMsgWithTags: buffer overflow`
//   — that's accumulated stale synth state (old crossfaded-out synths that
//   never got freed in time) piling up, not a code bug. If things start
//   behaving inconsistently after heavy iteration — a control that worked a
//   minute ago suddenly doesn't, or a filter chain seems to randomly vanish
//   — do a full restart before debugging further. A clean interpreter+server
//   is the only reliable way to tell whether a fix actually worked versus
//   whether you're chasing leftover session garbage.

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
