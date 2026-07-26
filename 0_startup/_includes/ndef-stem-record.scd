// ndef-stem-record.scd
// Lets Ndefs use ~stemDiskStart (mixer-channel-stem-record.scd) UNCHANGED —
// same autoSplit, captureHistory, captureMidi, beat-quantized start/stop as
// ddwMixerChannel gets. No Ndef-specific reimplementation needed.
//
// Requires mixer-channel-stem-record.scd loaded first (defines ~stemDiskStart).
//
// HOW IT WORKS: ~stemDiskStart only ever calls two things on each track/return
// you give it — `mc.inbus.index` (to get a bus number) and `mc.name` (for the
// stem filename) — everything else it does (scheduling, DiskOut, the ffmpeg
// split script, History/MIDI hooks) only ever touches the bus INDEX it
// extracted, not the object itself. So a tiny stand-in Event that answers
// those same two messages is all it takes:
//   (inbus: someNdef, name: "someName")
//     .inbus  -> someNdef        (Event key lookup, returns the Ndef itself)
//     .inbus.index -> someNdef.index   (Ndef's real bus number)
//     .name   -> "someName"      (whatever string you gave it)
// ~stemDiskStart can't tell this apart from a real MixerChannel — it never
// asks for anything else.
//
// Globals: ~ndefAsChan
//
// Usage — identical to the ddwMixerChannel call, just wrap each Ndef first:
//   ~stemStop = ~stemDiskStart.(
//       tracks:  [~ndefAsChan.(Ndef(\ins1)), ~ndefAsChan.(Ndef(\ins2))],
//       returns: [~ndefAsChan.(Ndef(\fxsVerb))],
//       fileBase: "jam",
//       dirPath: "~/Music/recordings",
//       clock: ~link,              // beat-quantized start/stop — works exactly
//                                   // as with MixerChannels, since scheduling
//                                   // only needs the bus indices, extracted
//                                   // once at call time, not the objects.
//       autoSplit: true,
//       captureHistory: true,
//       captureMidi: true          // see caveat below — nothing to do with
//                                   // Ndefs, applies identically on either system
//   );
//   ~stemStop.(beats: 4);          // or ~stemStopNow.()
//
// captureMidi CAVEAT (orthogonal to Ndefs entirely — same on ddwMixerChannel):
// ~stemDiskStart's MIDI capture only accepts events where ev[\type] is nil or
// exactly \note. A pattern using \type, \grain (e.g. the sustain/legato-race
// fix from earlier) will NOT show up in the captured .mid file — verified via
// Event.sc source: the generic ~callback hook DOES fire for \grain events
// same as \note (it's invoked by the shared play wrapper after dispatching to
// either type handler), so the hook itself isn't the problem — it's
// ~stemDiskStart's own type filter deliberately excluding non-\note events.
// Plain \type \note patterns (the default — anything that doesn't set \type
// at all) capture correctly regardless of whether they're Ndef- or
// MixerChannel-routed.
(
~ndefAsChan = { |ndef| (inbus: ndef, name: ndef.key.asString) };
)
