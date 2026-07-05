// slice-multi-patch.scd — multi-sample buffer-slice player: like slice1
// (\slice_m from _synthdefs/synths_common.scd), but backed by a FOLDER of
// sample files rather than one fixed buffer. Each MIDI note-on picks a
// buffer from that folder (per the \mode param: seq = cycle in order like
// Pseq, rand = pick randomly without an immediate repeat like Pxrand), then
// slices it exactly like slice1 does (note number -> slice index).
//
// ~zynMakeMultiSlicePatch is a reusable builder, not a patch itself — call
// it once per "kit" (one folder = one preset). Each call captures its own
// buffer list / seq-index / last-rand-index, so switching between kits
// never mixes up their sequencing state, even though only one is ever
// ~zynPatchNoteOn at a time. To add another kit: one more call at the
// bottom of this file + a matching preset directory (see reference doc).
//
// Auto mono/stereo: this is exactly what ~bufInstr picked between \pBs and
// \pBm for plain buffer playback elsewhere in this repo — same idea here,
// choosing \slice_m vs \slice_s per buffer's own channel count, since
// JTTCOT (mono files) and Hoarder (stereo files) both use this same code.
//
// Adding more files to an existing kit's folder needs an SC restart (the
// folder is scanned once at boot) but NOT a code change — that's the whole
// point of this being folder-driven rather than a fixed file list.

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

SynthDef(\slice_s, { |out=0, bufnum=0, sliceIndex=0, nSlices=8, amp=0.5, rate=1, pan=0, spread=0, rev=0|
    var sig, numFrames, sliceFrames, sliceDur, playRate, startPos, altSign, panCalc, l, r;
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
    sig = PlayBuf.ar(2, bufnum, rate: playRate, startPos: startPos, loop: 0, doneAction: 0);
    sig = sig * EnvGen.kr(Env.linen(0.001, sliceDur, 0.05), doneAction: 2);
    l = sig[0]; r = sig[1];
    sig = Balance2.ar(l, r, panCalc, amp);
    Out.ar(out, sig);
}).add;

~zynMakeMultiSlicePatch = { |patchName, folderPath|
    var buffers, bufInstr, seqIndex, lastRandIndex;

    buffers = PathName(folderPath).files.select { |pf| pf.extension.asString.toLower == "wav" }
        .collect { |pf| Buffer.read(s, pf.fullPath) };
    bufInstr = { |buf| if(buf.numChannels == 2) { \slice_s } { \slice_m } };
    seqIndex = 0;
    lastRandIndex = -1;

    ~zynPatches[patchName] = {
        ~zynPatchNoteOn = { |note, vel|
            var idx, buf, synthName;
            if(~zynCurrentParams[\mode] < 0.5) {
                // seq: cycle through in order, like Pseq
                idx = seqIndex % buffers.size;
                seqIndex = seqIndex + 1;
            } {
                // rand: like Pxrand — never the same buffer twice in a row
                idx = buffers.size.rand;
                if(buffers.size > 1) {
                    while { idx == lastRandIndex } { idx = buffers.size.rand };
                };
                lastRandIndex = idx;
            };
            buf = buffers[idx];
            synthName = bufInstr.(buf);
            Synth(synthName, [
                \out, 0,
                \bufnum, buf.bufnum,
                \sliceIndex, (note - 60) % ~zynCurrentParams[\nSlices].max(1),
                \nSlices, ~zynCurrentParams[\nSlices],
                \amp, (vel / 127) * ~zynCurrentParams[\amp],
                \rate, ~zynCurrentParams[\rate],
                \pan, ~zynCurrentParams[\pan],
                \spread, ~zynCurrentParams[\spread],
                \rev, ~zynCurrentParams[\rev]
            ]);
        };

        // One-shot instrument (same as slice1) — no live voice to .set(),
        // ~zynCurrentParams tracking is what actually matters here.
        ~zynRegisterParam.(\amp,     {}, 0.5);
        ~zynRegisterParam.(\nSlices, {}, 8);
        ~zynRegisterParam.(\rate,    {}, 1.0);
        ~zynRegisterParam.(\pan,     {}, 0.0);
        ~zynRegisterParam.(\spread,  {}, 0.0);
        ~zynRegisterParam.(\rev,     {}, 0.0);
        ~zynRegisterParam.(\mode,    {}, 0.0);   // 0 = seq, 1 = rand
    };

    ("[slice-multi-patch] registered \\" ++ patchName ++ " with " ++ buffers.size ++ " buffers from " ++ folderPath).postln;
};

~zynMakeMultiSlicePatch.(\JTTCOT,  "/root/Music/supercollider/_samples/_mono/jttcot");
~zynMakeMultiSlicePatch.(\Hoarder, "/root/Music/supercollider/_samples/Hoarder/hoarder");
