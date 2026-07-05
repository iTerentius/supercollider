// slice1-patch.scd — buffer-slice player, using \slice_m verbatim from
// 0_startup/_synthdefs/synths_common.scd (copied here rather than loading
// that whole file — it also defines a \cello SynthDef using Decimator, a
// UGen class not compiled into this box's SC build, and .load compiles a
// whole file as one unit, so that one missing class would silently abort
// every SynthDef in the file, \slice_m included — same reason gb1-patch.scd
// and subtractive1-patch.scd are self-contained too).
//
// One-shot instrument: \slice_m computes its start position and slice
// envelope ONCE at synth-creation (.ir-rate buffer reads, no retrigger), so
// there's no "sustained note, tweak knobs live" behavior the way
// subtractive1's gate-held voice has — each MIDI note-on is a short,
// self-freeing one-shot. ~zynRegisterParam's ~zynCurrentParams tracking
// already gives "next triggered note picks up the current knob values" for
// free, so every param's setterFunc here is just a no-op — nothing to
// .set() on a synth that's already finished playing by the time you'd want
// to. Note-off's ~zynVoice.set(\gate, 0) (zyn-engine-bridge.scd) harmlessly
// no-ops too: \slice_m has no \gate argument, and SC silently ignores .set
// on unknown control names.

SynthDef(\slice_m, { |out=0, bufnum=0, sliceIndex=0, nSlices=8, amp=0.5, rate=1, pan=0, spread=0, rev=0|
    var sig, numFrames, sliceFrames, sliceDur, playRate, startPos, altSign, panCalc;

    numFrames   = BufFrames.ir(bufnum);
    sliceIndex  = sliceIndex % max(1, nSlices);
    sliceFrames = numFrames / nSlices;

    altSign  = Select.kr(sliceIndex % 2, [-1, 1]);
    panCalc  = Clip.kr(pan + (spread * altSign), -1, 1);

    playRate = BufRateScale.kr(bufnum) * (rev > 0.5).if(rate.abs.neg, rate.abs);
    startPos = (rev > 0.5).if(
        ((sliceIndex + 1) / nSlices) * numFrames - 1,
        (sliceIndex / nSlices) * numFrames
    );

    sliceDur = (sliceFrames / BufSampleRate.ir(bufnum)) / max(0.0001, rate.abs);

    sig = PlayBuf.ar(1, bufnum, rate: playRate, startPos: startPos, loop: 0, doneAction: 0);
    sig = sig * EnvGen.kr(Env.linen(0.001, sliceDur, 0.05), doneAction: 2);
    sig = Pan2.ar(sig, panCalc, amp);
    Out.ar(out, sig);
}).add;

~zynSliceBuf = Buffer.read(s, "/root/Music/supercollider/_samples/_mono/jttcot/00.wav");

~zynPatches[\slice1] = {
    // note -> slice index: SC's % is a true modulo (always non-negative),
    // so this wraps cleanly whether note is above or below 60. \slice_m's
    // own body re-wraps defensively too (sliceIndex % max(1, nSlices)).
    ~zynPatchNoteOn = { |note, vel|
        Synth(\slice_m, [
            \out, 0,
            \bufnum, ~zynSliceBuf.bufnum,
            \sliceIndex, (note - 60) % ~zynCurrentParams[\nSlices].max(1),
            \nSlices, ~zynCurrentParams[\nSlices],
            \amp, (vel / 127) * ~zynCurrentParams[\amp],
            \rate, ~zynCurrentParams[\rate],
            \pan, ~zynCurrentParams[\pan],
            \spread, ~zynCurrentParams[\spread],
            \rev, ~zynCurrentParams[\rev]
        ]);
    };

    ~zynRegisterParam.(\amp,     {}, 0.5);
    ~zynRegisterParam.(\nSlices, {}, 8);
    ~zynRegisterParam.(\rate,    {}, 1.0);
    ~zynRegisterParam.(\pan,     {}, 0.0);
    ~zynRegisterParam.(\spread,  {}, 0.0);
    ~zynRegisterParam.(\rev,     {}, 0.0);
};

"[slice1-patch] loaded — slice_m SynthDef ready, registered as \\slice1.".postln;
