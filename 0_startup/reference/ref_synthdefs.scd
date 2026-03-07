// =============================================================================
// SYNTHDEFS  (_synthdefs/synths_common.scd)
// =============================================================================

// --- One-shot sample players (main workhorses) ---
// \pBs  stereo PlayBuf   args: out, bufnum, amp, rate, pan, startPos, loop, rev
// \pBm  mono PlayBuf     args: out, bufnum, amp, rate, pan, startPos, loop

Synth(\pBs, [\out, ~t1.inbus.index, \bufnum, buf, \amp, 0.5, \rate, 1, \pan, 0]);
Synth(\pBm, [\out, ~t2.inbus.index, \bufnum, monoBuf, \amp, 0.4]);

// Helper: pick correct instrument for a buffer
~bufInstr.(buf);                      // -> \pBs or \pBm
// Helper: wrap a Pbind to auto-select instrument
~pBuf.(Pbind(\buf, Pseq([buf1, buf2], inf), \dur, 0.25));

// --- Slice players ---
// \slice_m  mono slice    args: out, bufnum, sliceIndex, nSlices, amp, rate, pan, spread, rev
// \slice_s  stereo slice  args: (same)
Synth(\slice_s, [\out, ~t1.inbus.index, \bufnum, buf, \sliceIndex, 3, \nSlices, 16]);

// --- Granular ---
// \gb1  GrainBuf          args: out, buf, env, amp, trig_rate, grain_dur, rate, pan_rate, trig_enable, gate
// \gin1 GrainIn insert FX args: out, fxMix, trigRate, grainDur, pan, amp, envbufnum
// \gin1r GrainIn return   args: out, trigRate, grainDur, pan, amp, envbufnum

// GrainBuf player:
Synth(\gb1, [\out, ~t1.inbus.index, \buf, buf, \env, ~g1envbuf,
    \trig_rate, 20, \grain_dur, 0.05, \rate, 0, \amp, 0.5]);

// GrainIn as channel insert:
~t1.playfx({ |in| // the \gin1 synthdef function body });
// or use the synthdef directly on a return channel

// --- Sidechain ducker ---
// \duck  args: in, side, out, thresh, ratio, attack, release, makeup
Synth(\duck, [
    \in, ~t2.inbus.index,   // signal to duck
    \side, ~t1.inbus.index,  // sidechain source (e.g. kick)
    \out, ~m1.inbus.index,
    \thresh, 0.1, \ratio, 10, \attack, 0.01, \release, 0.1
]);

// --- Slice FX (live buffer slicer as channel insert) ---
~sliceFX_makeCtrlBuses.();            // create control buses (done at boot)
// Control buses: ~slice_idx, ~slice_rev, ~slice_sp, ~slice_rate, ~slice_mix, ~slice_pan
~slice_idx.set(3);                    // select slice index
~slice_mix.set(0.5);                  // wet/dry
~t1.playfx(~sliceFX_playfx_s.(bufSecs: 2, nSlices: 8));

// --- Other synthdefs ---
// \bass8      FM bass      args: out, amp, gate, pan, freq
// \cello      bowed string args: out, amp, gate, pan, freq, rq, atk, dcy, sustain, rls, dur
// \ks_string  Karplus      args: out, amp, gate, pan, freq, rand, delayTime, sustain
// \t1002      FM percuss   args: out, amp, gate, pan, freq, noise, ph
// \test       sine test    args: out, sustain, freq, pan, noise
// \stretchedFragments      args: out, buf, start, time, stretch, amp, attack, decay
