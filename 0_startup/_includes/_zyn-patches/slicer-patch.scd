// slicer-patch.scd — ONE dynamic sample-slicer whose buffer folder is chosen
// LIVE from the touchscreen (an is_path controller — see
// zynthian-sc-engine/presets/sc/Slice/slicer/zynconfig.yml). Renamed from
// "sampler" 2026-07-08 once it replaced the old fixed-kit presets (JTTCOT,
// Hoarder, the _kits/ auto-scan feature, and the single-hardcoded-file
// slice1) entirely — those were sound-specific and no longer needed now
// that any folder can be picked live. Self-contained (defines its own
// \slice_m/\slice_s here, previously split across slice1-patch.scd and
// slice-multi-patch.scd, now both deleted) per the usual "each patch defines
// its own SynthDef(s)" convention — see the reference doc's shared-synthdefs
// gotcha for why (a missing UGen class in one shared file would silently
// abort every SynthDef in it, not just the one that needs it).
//
// The touchscreen's file browser only ever calls back with a FILE path
// (tapping a folder just navigates into it — there's no "select this
// folder" action), so /scengine/samplefolder takes the PARENT DIRECTORY of
// whatever file got tapped as the folder to load. Point it at any one file
// inside the folder you actually want.
//
// Swapping folders frees the previous buffers first, so repeated swaps in
// one session don't leak SC's buffer pool (1024 buffers total, per
// startup.scd's server boot options).
//
// nSlices=1 plays the whole buffer as one "slice" (no dividing) — works well
// for anything you'd rather hear as a complete clip rather than chopped up.
// If per-note keymapping or a true non-slicing whole-clip player is ever
// needed instead (e.g. for a folder of unrelated drum one-shots rather than
// a single longer recording), that would be a separate patch — deliberately
// not built yet, this one covers both cases well enough via nSlices for now.

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

~zynSlicerBuffers = [];
~zynSlicerSeqIndex = 0;
~zynSlicerLastRandIndex = -1;

~zynSlicerLoadFolder = { |folderPath|
    var pn, newBuffers;
    pn = PathName(folderPath);
    if(pn.isFolder) {
        newBuffers = pn.files.select { |pf|
            var ext = pf.extension.asString.toLower;
            // NOT .includes() — confirmed unreliable for Strings in this SC
            // build (["wav"].includes("wav") returns false even though
            // "wav" == "wav" is true) — use direct == instead.
            ["wav", "aiff", "aif", "flac", "ogg"].any { |e| ext == e }
        }.collect { |pf| Buffer.read(s, pf.fullPath) };

        if(newBuffers.size > 0) {
            ~zynSlicerBuffers.do { |buf| buf.free };
            ~zynSlicerBuffers = newBuffers;
            ~zynSlicerSeqIndex = 0;
            ~zynSlicerLastRandIndex = -1;
            ("[slicer-patch] loaded " ++ newBuffers.size ++ " buffers from " ++ folderPath).postln;
        } {
            ("[slicer-patch] no audio files found in " ++ folderPath).postln;
        };
    } {
        ("[slicer-patch] not a folder: " ++ folderPath).postln;
    };
};

~zynPatches[\slicer] = {
    ~zynPatchNoteOn = { |note, vel|
        var idx, buf, synthName, bufInstr;
        if(~zynSlicerBuffers.size > 0) {
            bufInstr = { |b| if(b.numChannels == 2) { \slice_s } { \slice_m } };
            if(~zynCurrentParams[\mode] < 0.5) {
                // seq: cycle through in order, like Pseq
                idx = ~zynSlicerSeqIndex % ~zynSlicerBuffers.size;
                ~zynSlicerSeqIndex = ~zynSlicerSeqIndex + 1;
            } {
                // rand: like Pxrand — never the same buffer twice in a row
                idx = ~zynSlicerBuffers.size.rand;
                if(~zynSlicerBuffers.size > 1) {
                    while { idx == ~zynSlicerLastRandIndex } { idx = ~zynSlicerBuffers.size.rand };
                };
                ~zynSlicerLastRandIndex = idx;
            };
            buf = ~zynSlicerBuffers[idx];
            synthName = bufInstr.(buf);
            // .register(true): lets noteOff's isPlaying guard
            // (zyn-engine-bridge.scd) correctly detect this one-shot voice
            // already freed itself, instead of wrongly calling .set() on a
            // stale node ID (server-side "Node not found" failure).
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
            ]).register(true);
        };
    };

    // One-shot instrument — no live voice to .set(), ~zynCurrentParams
    // tracking is what actually matters here.
    ~zynRegisterParam.(\amp,     {}, 0.5);
    ~zynRegisterParam.(\nSlices, {}, 8);
    ~zynRegisterParam.(\rate,    {}, 1.0);
    ~zynRegisterParam.(\pan,     {}, 0.0);
    ~zynRegisterParam.(\spread,  {}, 0.0);
    ~zynRegisterParam.(\rev,     {}, 0.0);
    ~zynRegisterParam.(\mode,    {}, 0.0);   // 0 = seq, 1 = rand
};

// NOT run through ~zynRegisterParam: that machinery normalizes numeric/
// boolean knob values (see zyn-engine-bridge.scd's Boolean.asFloat gotcha) —
// correct for knobs, but it would mangle a file-path string. Same reasoning
// as why /scengine/loadpatch (zyn-engine-bridge.scd) gets its own dedicated
// OSCdef instead of going through the generic param table.
OSCdef(\zynSlicerFolder, { |msg|
    var filePath = msg[1].asString;
    var folderPath = PathName(filePath).pathOnly;
    ~zynSlicerLoadFolder.(folderPath);
}, "/scengine/samplefolder");

"[slicer-patch] loaded — dynamic folder-picker slicer ready, registered as \\slicer.".postln;
