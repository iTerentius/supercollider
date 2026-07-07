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

// --- auto-scan kits: drop a folder of wav files under _samples/_kits/<name>/
// and it becomes a playable kit at boot -- no code edit needed. Kit name is
// the folder name, canonicalized the same way sample_loader.scd's ~canon
// does (lowercase, spaces/dashes/dots -> underscore). Self-contained (own
// canon fn, not sample_loader.scd's ~canon) for the same reason the rest of
// this file is self-contained -- see the top-of-file comment on why.
//
// Also writes a matching touchscreen preset dir (zynconfig.yml, copied from
// Hoarder/JTTCOT's identical generic template -- same knobs for every kit)
// under zynthian-sc-engine's presets/sc/Slice/<name>/ if one doesn't already
// exist there, so a new folder shows up in the "Add Instrument Chain" preset
// list too, not just as a live-codeable ~zynPatches entry. Safe to run every
// boot: skips any kit that already has a zynconfig.yml (so a manually-tuned
// preset is never clobbered), and zynthian-ui's get_bank_list/get_preset_list
// scan this directory live (os.listdir per browse, not cached like
// engine_config.json), so no zynthian.service restart is needed for a new
// kit to appear -- just (re)booting SC to run this scan is enough.
{
    var kitsRoot, canon, presetsRoot, yamlTemplate;

    canon = { |str|
        str.asString.toLower.replace($ , $_).replace($-, $_).replace($., $_).asSymbol;
    };

    kitsRoot = PathName("/root/Music/supercollider/_samples/_kits");
    presetsRoot = "/root/zynthian-sc-engine/presets/sc/Slice";

    yamlTemplate = "Slice:\n"
        "  amp:\n"
        "    name: \"Amp\"\n"
        "    value: 0.5\n"
        "    value_min: 0.0\n"
        "    value_max: 1.0\n"
        "    osc_path: \"/scengine/amp\"\n"
        "  nSlices:\n"
        "    name: \"Num Slices\"\n"
        "    value: 8\n"
        "    value_min: 1\n"
        "    value_max: 32\n"
        "    is_integer: true\n"
        "    osc_path: \"/scengine/nSlices\"\n"
        "  rate:\n"
        "    name: \"Rate\"\n"
        "    value: 1.0\n"
        "    value_min: 0.25\n"
        "    value_max: 4.0\n"
        "    osc_path: \"/scengine/rate\"\n"
        "  pan:\n"
        "    name: \"Pan\"\n"
        "    value: 0.0\n"
        "    value_min: -1.0\n"
        "    value_max: 1.0\n"
        "    osc_path: \"/scengine/pan\"\n"
        "  spread:\n"
        "    name: \"Spread\"\n"
        "    value: 0.0\n"
        "    value_min: 0.0\n"
        "    value_max: 1.0\n"
        "    osc_path: \"/scengine/spread\"\n"
        "  rev:\n"
        "    name: \"Reverse\"\n"
        "    value: 0\n"
        "    value_min: 0\n"
        "    value_max: 1\n"
        "    is_toggle: true\n"
        "    osc_path: \"/scengine/rev\"\n"
        "  mode:\n"
        "    name: \"Seq/Rand\"\n"
        "    value: 0\n"
        "    value_min: 0\n"
        "    value_max: 1\n"
        "    is_toggle: true\n"
        "    osc_path: \"/scengine/mode\"\n";

    if(kitsRoot.isFolder) {
        kitsRoot.folders.do { |folder|
            var kitName, presetDir, configPath, f;
            kitName = canon.(folder.folderName);
            ~zynMakeMultiSlicePatch.(kitName, folder.fullPath);

            presetDir = presetsRoot ++ "/" ++ kitName;
            configPath = presetDir ++ "/zynconfig.yml";
            if(File.exists(configPath).not) {
                ("mkdir -p " ++ presetDir.quote).unixCmdGetStdOut;
                f = File(configPath, "w");
                if(f.notNil) {
                    f.write(yamlTemplate);
                    f.close;
                    ("[slice-multi-patch] wrote touchscreen preset for " ++ kitName ++ " -> " ++ configPath).postln;
                } {
                    ("[slice-multi-patch] could not open " ++ configPath ++ " for writing").postln;
                };
            };
        };
        ("[slice-multi-patch] auto-registered " ++ kitsRoot.folders.size ++ " kit(s) from " ++ kitsRoot.fullPath).postln;
    } {
        ("[slice-multi-patch] no _kits folder at " ++ kitsRoot.fullPath ++ " -- create subfolders of wav files there to add kits without editing code.").postln;
    };
}.value;
