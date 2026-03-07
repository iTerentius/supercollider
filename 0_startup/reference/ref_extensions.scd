// =============================================================================
// EXTENSION: stopQ  (Extensions/ext_stopQ.sc)
// =============================================================================
// Adds .stopQ(quant) to TaskProxy (Tdef)
// Stop quantized to next grid boundary:
Tdef(\myTask).stopQ(4);               // stop on next 4-beat boundary
Tdef(\myTask).stopQ;                  // stop immediately (same as .stop)

// =============================================================================
// EXTENSION: Pswing  (Extensions/Pswing.sc)
// =============================================================================
// Wraps a pattern and pushes off-beat events forward in time (swing feel).
//
// Pswing(pattern, amount, quant)
//   pattern - source event pattern (e.g. Pbind)
//   amount  - timing offset in beats applied to off-beats (default: 0.05)
//   quant   - grid subdivision that defines the off-beat (default: 0.25)
//             e.g. 0.25 = 16th-note grid, swing lands on the 2nd 16th of each pair
//
// The swing offset is added to \timingOffset, so it stacks with any existing
// timing offsets in the source pattern.

// Basic 16th-note swing on a quarter-note pattern:
Pswing(
    Pbind(\degree, Pseq([0, 2, 4, 7], inf), \dur, 0.25),
    0.05,   // amount: nudge off-beats by 0.05 beats
    0.25    // quant:  16th-note grid
).play;

// 8th-note shuffle (swing every other 8th):
Pswing(myPdef, 0.04, 0.5).play;

// Wrap an existing Pdef in place:
Pdef(\beat, Pswing(Pdef(\beat), 0.06, 0.25));

// =============================================================================
// EXTENSION: Psection  (Extensions/Psection.sc)
// =============================================================================
// Runs a list of patterns in parallel for a fixed duration, then stops.
// Useful for composing sections from named Pdefs.
//
// Psection(list, dur, init, sync, quant)
//   list  - array of patterns or Symbols (Symbols resolved to Pdefs)
//   dur   - duration in beats; can be:
//             Number   - fixed beat count
//             Function - evaluated at embed time  ({ ~myDur.value })
//             Symbol   - resolved via Pdefn or currentEnvironment
//   init  - optional Function called before patterns start (default: nil)
//   sync  - if true, use Psync (waits for quant boundary); default: false
//   quant - Psync quantisation grid (default: 4); only used when sync: true

// Two Pdefs in parallel for 8 beats:
Psection([\beat, \bass], 8).embedInStream(());

// With init function and fixed duration:
Psection(
    [\drums, \melody, \chords],
    16,
    init: { ~t1.set(\amp, 0.8) }
).embedInStream(());

// Sync to next 4-beat boundary instead of hard cut:
Psection([\beat, \bass], 8, sync: true, quant: 4).embedInStream(());

// Duration from a global variable:
~sectionLen = 32;
Psection([\beat, \bass], \sectionLen).embedInStream(());

// Sequence two sections back-to-back inside a Pdef:
Pdef(\song, Pseq([
    Psection([\intro_drums], 8),
    Psection([\drums, \bass, \lead], 32),
], 1)).play(~link, quant: 4);
