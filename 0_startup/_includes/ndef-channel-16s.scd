// Ndef-based channel strip boilerplate — mirrors mixer-channel-16s.scd's
// track/return layout, built on top of ndef-mixer.scd's tap/send engine.
// Not meant to run alongside ddwMixerChannel — pick one system per session.
//
// NOT loaded by default. Load in this order:
//   "_includes/ndef-mixer.scd".loadRelative;
//   "_includes/ndef-channel-16s.scd".loadRelative;
//   "_includes/ndef-channel-apc.scd".loadRelative;   // optional, APC40 bindings
//
// Globals: ~ndefChanMk, ~insNames
// Reuses ~fxConf/~fxInit/~fxSetSend/~fxAddSend/~fxAddFX from ndef-mixer.scd —
// this file does not redeclare ~fxConf, it just uses ndef-mixer.scd's default
// (insPrefix "ins", fxPrefix "fxs", sends #[\s1, \s2]), since ~fxState is
// seeded from ~fxConf at ndef-mixer.scd load time — reassigning ~fxConf here
// would NOT retroactively update ~fxState[\sends]. Use ~fxAddSend for that.
(
// ---- channel strip constructor ----
// Adds level (amp) + mute + pan + HPF/LPF filter stages to a Ndef, in that
// order. Safe to call before a source exists — forces the bus to stereo
// audio via initBus first. Without this, a filter added to a still-neutral
// proxy gets probed with a channel-less Silent.ar (defaults to mono) to
// infer its output shape, locking the whole proxy to 1 channel — then
// Balance2.ar's in[0]/in[1] blows up because `in` is a scalar, not a
// 2-element array.
//
// \amp and \mute are DELIBERATELY separate controls, not one. If \amp is
// being driven by a pattern or LFO for musical effect (a hi-hat's rhythmic
// gain pattern, a tremolo LFO via .map, etc.), calling .set(\amp, 0) to mute
// gets silently overwritten by the very next pattern event/LFO cycle — the
// mute doesn't stick, because the pattern still owns \amp. \mute is a
// second, independent multiplier nothing else should ever touch, so
// .set(\mute, 1) reliably silences the voice regardless of whatever \amp is
// doing for musical reasons. Same convention as ~fxg[\bitcrush]'s own
// mix/mute split in ilfx_cores.scd.
~ndefChanMk = { |name, hasPan = true|
    var nd = Ndef(name);
    nd.initBus(\audio, 2);
    nd[1] = \filter -> { |in, amp = 1, mute = 0| in * amp * (1 - mute) };
    if(hasPan) { nd[2] = \filter -> { |in, pan = 0| Balance2.ar(in[0], in[1], pan) } };
    nd[3] = \filter -> { |in, hpfreq = 40, lpfreq = 18000| HPF.ar(LPF.ar(in, lpfreq), hpfreq) };
    nd
};

// ================= TRACKS =================
// ins1..ins12 — plug a voice in later, e.g.:
//   Ndef(\ins1).source = { PlayBuf.ar(2, buf, loop: 0) };
//   Ndef(\ins2).source = Pbind(\instrument, \pBm, \bufnum, buf, \dur, 1);
~insNames = (1..12).collect { |i| ("ins" ++ i).asSymbol };
~insNames.do { |nm| ~ndefChanMk.(nm) };

// ================= RETURNS =================
// fxsVerb (reverb, reads s1_sum), fxsDelay (delay, reads s2_sum) — no pan.
// Named controls match the ddwMixerChannel return FX for muscle-memory parity.
Ndef(\fxsVerb, {
    var sig = Ndef.ar(\s1_sum, 2);
    FreeVerb2.ar(sig[0], sig[1], \mix.kr(0.5), \room.kr(0.6), \damp.kr(0.4))
});
~ndefChanMk.(\fxsVerb, hasPan: false);

Ndef(\fxsDelay, {
    var sig = Ndef.ar(\s2_sum, 2);
    CombL.ar(sig, 0.4, \dt.kr(0.375), \dec.kr(1.5))
});
~ndefChanMk.(\fxsDelay, hasPan: false);

// ================= INIT =================
// ~fxInit auto-discovers ins1-12 (insPrefix scan) and fxsVerb/fxsDelay
// (fxPrefix scan) since they already exist in Ndef.all by this point —
// no separate ~fxAddFX calls needed for these two. Use ~fxAddFX later if you
// add a NEW return after this file has already run once.
~fxInit.();

// ================= DEFAULT LEVELS =================
~insNames.do { |nm| Ndef(nm).set(\amp, 1, \pan, 0, \hpfreq, 40, \lpfreq, 18000) };
Ndef(\fxsVerb).set(\amp, 0.6, \hpfreq, 40, \lpfreq, 18000);
Ndef(\fxsDelay).set(\amp, 0.6, \hpfreq, 40, \lpfreq, 18000);
Ndef(\master).set(\dry, 1, \wet, 1, \amp, 1);

// ================= SUBMIX EXAMPLE (drums) =================
// Pattern from the submix conversation: voices NOT prefixed "ins" so ~fxInit
// doesn't double-count them; the submix Ndef IS one of the ins1-12 strips
// above and gets the normal channel-strip treatment (fader/pan/HPF/LPF/send)
// for free. Uncomment and point at real buffers to try it:
//
// Ndef(\voxKick,  { PlayBuf.ar(1, ~sTree[\808][\kick],  loop: 0) ! 2 });
// Ndef(\voxSnare, { PlayBuf.ar(1, ~sTree[\808][\snare], loop: 0) ! 2 });
// Ndef(\ins7).source = { Mix([Ndef.ar(\voxKick, 2), Ndef.ar(\voxSnare, 2)]) };

"Ndef channel strips initialized (ins1-12, fxsVerb, fxsDelay).".postln;
)
