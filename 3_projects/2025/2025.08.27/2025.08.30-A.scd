Ndef(\track).play;

Ndef(\track)[\mel] = Pdef(\melody);

(
Pdef(\melody, Pbind(
        \instrument, \bass8,
        \dur, 0.25,
        \legato, 0.9,
        \amp, 0.02,
        \scale, Scale.minor,
        \degree, Pseq([0, 2, 4,  8], inf),
        \octave, 5
    ));
)

~ccBind.(\b0_t1_r1, \track, \amp);  // defaults spec inside ~ccBind body
~ccBind.(\b0_f1, \track, \amp);  // defaults spec inside ~ccBind body


// Sample Loader
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
s.sync;

~printTree.();

~listKeys.();

(
// Ndef chop (seconds-aware position)
Ndef(\chop, { |buf=0, out=0, chop=4, hz=4, shuffle=0, slice=(-1),
    start=0, stop=1, width=0.9, rate=1, amp=1, pan=0|
    var chopSafe = chop.max(1);
    var winSpan  = (stop - start).clip(0.0001, 1);
    var durTot   = BufDur.kr(buf);
    var durWin   = durTot * winSpan;
    var gdur     = (durWin / chopSafe * width).clip(0.02, 1.0);

    var trig   = Impulse.kr(hz);
    var idxOrd = PulseCount.kr(trig) % chopSafe;
    var idxShuf= TRand.kr(0, (chopSafe - 1).max(0), trig);
    var idx    = Select.kr(slice >= 0, [ Select.kr(shuffle > 0, [ idxOrd, idxShuf ]), slice.clip(0, chopSafe - 1) ]);
    var posFrac= idx / chopSafe;                 // 0..1 within the window
    var posNorm= start + (posFrac * winSpan);    // still 0..1 of full file
    var posSec = posNorm * durTot;               // <<< convert to SECONDS (required)

    var sig = GrainBuf.ar(
        2, trig, gdur, buf,
        rate * BufRateScale.kr(buf),
        posSec,                       // <<< seconds
        2, pan, ~grainEnvBuf.bufnum
    );

    Out.ar(out, sig * amp)
});
)
~buf = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
Ndef(\chop).set(\buf, ~buf.bufnum);
Ndef(\chop).play;
Ndef(\chop).set(\chop, 18, \shuffle, 10);
Ndef(\chop).set(\trigRate, 18, \chop, 18, \shuffle, 1, \amp, 0.8);

// ---------- Quick examples (uncomment to try) ----------
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~buf = ~getSample.(\Storm_05_11_2022_01);

x = ~chopPlay.(~buf, 0, 16, 16, 1, -1, 0, 1, 0.95, 1, 0.9);
x.set(\shuffle, 1, \trigRate, 32, \chop, 32);
x.set(\gate, 0);

(
// Debug: list what SC actually sees in your folder
{
    var root, dir, entries;
    root = "~/Music/supercollider/_samples/Field/".standardizePath;
    dir  = PathName(root);
    [\root, root].postln;
    [\isFolder, dir.isFolder].postln;
    entries = dir.entries;
    [\entriesCount, entries.size].postln;
    entries.do { |pn| [\item, pn.fileName, pn.isFolder, pn.extension].postln };
}.value;
)
// 1 Persistent player (one-shot):
// correct for your current root (Field/)
~buf = ~getSample.(\Storm, \Storm_05_11_2022_01);
Ndef(\chop).play;
Ndef(\chop).set(\buf, ~buf.bufnum, \out, 0, \amp, 1, \chop, 8, \hz, 4, \shuffle, 1);

~playNdgccef.(\looper, ~getSample.(\Roland_TR_909, \Snare1_1), loop: 1, amp: 0.4);

// 3 Triggerable sampler:
~makeTrigNdef.(\hit, ~getSample.(\Roland_TR_808, \Kick_short), rel: 0.15, amp: 0.9);
Ndef(\hit).set(\trig, 1); // fire
Ndef(\hit).set(\trig, 1); // fire again
Ndef(\hit).stop;

// 4 Triggerable with random-from-folder:
~makeTrigNdef.(\hat, ~randomFromDeep.(\Roland_TR_707), rel: 0.08, amp: 0.6);
Ndef(\hat).set(\trig, 1);

Ndef(\chop).set(
    \trigRate, 18,   // absolute Hz
    \chop, 8,
    \shuffle, 0,     // start ordered
    \slice, -1,      // follow sequence (don’t force a fixed slice)
    \rate, 1,
    \width, 0.95,
    \start, 0,
    \stop, 1,
    \amp, 1,
    \pan, 0
);
Ndef(\chop).set(\chop, 4, \trigRate, 2, \shuffle, 0, \slice, 0);
Ndef(\chop).set(\slice, -1, \shuffle, 1, \chop, 16, \trigRate, 16);

(
// wipe and confirm we can hear *anything* from this Ndef
Ndef(\chop).clear;
Ndef(\chop, { |hz=4, amp=0.2|
    var trig = Impulse.kr(hz);
    var beep = Decay2.kr(trig, 0.005, 0.08) * SinOsc.ar(880);
    // if you hear a fast 880Hz tick, routing is fine
    beep!2 * amp
});
Ndef(\chop).play(0, 2);   // force to main out, 2ch
)
(
// Chop/slice with GrainBuf (no arrays; fixed stereo)
// Ndef chop (seconds-aware position)
Ndef(\chop, { |buf=0, chop=8, start=0, stop=1, rate=1, trigRate=0,
    shuffle=1, slice=(-1), width=0.95, amp=0.8, pan=0|
    var dur, startSec, sliceDur, gdur, tempo, trigHz, trig;
    var chopSafe, idxOrdered, idxShuf, idx, posFrac, posSec, sig;

    // derived
    chopSafe = chop.max(1);
    dur      = (BufDur.kr(buf) * (stop - start)).max(0.0001);
    startSec = BufDur.kr(buf) * start;
    sliceDur = dur / chopSafe;
    gdur     = (sliceDur * width).clip(0.002, sliceDur);

    // clock
    tempo  = TempoClock.default.tempo;     // captured as scalar at build
    trigHz = Select.kr(trigRate > 0, [ chopSafe * tempo, trigRate ]);
    trig   = Impulse.kr(trigHz);

    // slice index per trigger
    idxOrdered = (PulseCount.kr(trig) % chopSafe).floor;           // 0..chop-1
    idxShuf    = TRand.kr(0, (chopSafe - 1).max(0), trig).floor;   // random 0..chop-1
    idx = Select.kr(slice >= 0, [
        Select.kr(shuffle > 0, [ idxOrdered, idxShuf ]),
        slice.clip(0, chopSafe - 1)
    ]);

    posFrac = idx / chopSafe;
    posSec  = startSec + (posFrac * dur);

    // IMPORTANT: literal integer channel count (2 = stereo)
    sig = TGrains.ar(2, trig, buf, rate, posSec, gdur, pan) * amp;

    sig
});
)
(
// assuming your loader returned a Buffer in ~buf:
Ndef(\chop).set(
    \buf, ~buf.bufnum,   // use the integer bufnum
    \start, 0, \stop, 1,
    \rate, 1, \amp, 0.9,
    \chop, 8, \shuffle, 0,
    \trigRate, 8         // 8 grains per sec (audible immediately)
);
Ndef(\chop).play(0, 2);

// then try “tidal-ish” behavior:
Ndef(\chop).set(\trigRate, 0, \bps, 1, \chop, 16, \shuffle, 1);  // 16 chops per beat at 60 BPM
// fixed slice test (should clearly tick):
// Ndef(\chop).set(\slice, 0, \shuffle, 0, \chop, 4, \bps, 1);
)
[ ~buf, ~buf.bufnum, ~buf.duration, ~buf.numChannels ].postln;

Ndef(\chop).isPlaying.postln;
s.queryAllNodes;    // confirm node exists under default group
Ndef(\chop).
( 
SynthDef(\bufPing, { |out=0, buf=0, amp=0.5|
    var sig = PlayBuf.ar(~buf.numChannels ? 1, buf, BufRateScale.kr(buf), doneAction:2);
    Out.ar(out, sig * amp);
}).add;
 )
x = Synth(\bufPing, [\buf, ~buf.bufnum]);  // should play and freescope;  // should show meters bouncing

~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~buf = ~getSample.(\Storm, \Storm_05_11_2022_01);
~buf = ~getSample.(\Field, \cat_food);
~playBuf.(~buf, out: 0, amp: 0.8);   // if silent, try out: 2, 4, 6...

x = ~chopPlay.(~buf, out: 0, chop: 4, hz: 2, shuffle: 0, amp: 1);
x.set(\gate, 0);


(
// 1 make sure the window exists
~grainEnvBuf = ~grainEnvBuf ?? {
    var sig = Signal.hanningWindow(512);
    Buffer.sendCollection(s, sig, 1)
};
)
(
// 2 simple GrainBuf player — fixed position, audible settings
Ndef(\gtest, { |buf=0, hz=2, gdur=0.15, rate=1, amp=0.7, pan=0, out=0|
    var trig = Impulse.kr(hz);
    var sig  = GrainBuf.ar(
        2, trig, gdur, buf,
        rate * BufRateScale.kr(buf),
        0.25,          // pos: quarter of the file
        2, pan, ~grainEnvBuf.bufnum
    );
    Out.ar(out, sig * amp)
}).play;
)
// set your buffer + try a couple outs if needed
Ndef(\gtest).set(\buf, ~buf.bufnum, \out, 0);

s.boot;
( 
// define once
SynthDef(\_tone, { |out=0, freq=330, amp=0.08|
    var sig;
    sig = SinOsc.ar(freq) * amp;
    Out.ar(out, sig ! 2);  // stereo pair starting at 'out'
}).add;
 )
// try a few pairs until you hear it; note the first 'out' that works (call it AUDOUT)
Synth(\_tone, [\out, 0]);   // (0,1)
Synth(\_tone, [\out, 2]);   // (2,3)
Synth(\_tone, [\out, 4]);   // (4,5)
// stop test tones:
s.freeAll;
( 
// make sure your grain window exists (from the one-file drop-in)
~grainEnvBuf = ~grainEnvBuf ?? {
    var sig;
    sig = Signal.hanningWindow(512);
    Buffer.sendCollection(s, sig, 1)
};
 )
// IMPORTANT: use the correct keys you saw in [ready] logs.
// Example: [ready] Storm  Storm_05_11_2022_01  → folder = \Storm, file = \Storm_05_11_2022_01
~buf = ~getSample.(\Storm, \Storm_05_11_2022_01);

// audition buffer on the *same* AUDOUT you found above
~playBuf.(~buf, out: 0, amp: 0.8);


s.boot;
~sampleLog = true;  // set false later if spammy

~silenceAll.();  // clears any thumping nodes
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

// When you see [ready] lines, pick one:
~buf = ~getSample.(\Field, \cat_food);  // or flat: ~getSample.(\cat_food)

// Confirm your audible output (try 0, then 2, 4… if needed)
~playBuf.(~buf, out: 0, amp: 0.8);

// Chopped playback on SAME out:
Ndef(\chop).play;
Ndef(\chop).set(\buf, ~buf.bufnum, \out, 0, \amp, 1, \chop, 8, \hz, 4, \shuffle, 1);
// Kill all running nodes & proxies (safe to run)
s.freeAll; Ndef.all.do(_.clear);



// load synths_common.scd first, then this file
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

// inspect
~listKeys.();           // e.g. [ \Field, \Bambu, \Storm ]
~keysIn.(\Field).postln;

// tolerant lookup works for dots dashes spaces
~buf = ~getSampleSmart.(\Storm, \Storm_05_11_2022_01);

// or exact if you prefer
// ~buf = ~getSample.(\Field, \cat_food);

// returns the Synth immediately
~playBuf.(~buf, out: 4, amp: 0.8);

~buf.numChannels.postln;
s.options.numOutputBusChannels.postln;


(
// finite debug runner — all vars declared at top

var out, pathStr, normStr, tag,
    sub, klist, bufExact, bufSmart;

// config
out     = 0;
pathStr = "~/Music/supercollider/_samples/Field/".standardizePath;

// simple normalizer (lowercase, space/dot/dash -> underscore, collapse doubles)
normStr = { |x|
    var s;
    s = x.asString.toLower;
    s = s.replace($ , $_).replace($., $_).replace($-, $_);
    while({ s.contains("__") }, { s = s.replace("__", "_") });
    s
};

// little label helper
tag = { |t| ("=== " ++ t ++ " ===").postln };

// 1 set output
tag.("SET DEFAULT OUT");
~setDefaultOut.(out);

// 2 load
tag.("LOAD SAMPLES");
("[load] -> " ++ pathStr).postln;
~loadSamplesRecursive.(pathStr);

// 3 inspect
tag.("FOLDER LIST");
~samplesTree.keys.asArray.sort.postln;

tag.("STORM SUBTREE");
sub = ~samplesTree[\Storm];
sub.postln;

tag.("STORM KEYS");
klist = sub.notNil.if({ sub.keys.asArray.sort }, { [] });
klist.postln;

// 4 direct exact (ground truth)
tag.("DIRECT EXACT");
bufExact = sub.notNil.if({ sub[\Storm_05_11_2022_01] }, { nil });
bufExact.postln;

// 5 redefine a minimal, instrumented smart lookup
tag.("REDEFINE getSampleSmart");
~getSampleSmart = { |folderSym, fileSym|
    var tree, subLocal, buf, canon, fs, ks;

    // declare helpers at top of the function
    canon = { |y| normStr.(y).asSymbol };
    tree  = ~samplesTree;

    if(tree.isNil) { "[smart] tree nil".postln; ^nil };

    // A) exact folder + exact file
    "[A] exact folder: ".post; folderSym.postln;
    subLocal = tree[folderSym];
    if(subLocal.notNil) {
        "[A] exact file: ".post; fileSym.postln;
        buf = subLocal[fileSym];
        if(buf.notNil) { "[A] exact hit".postln; ^buf } { "[A] exact miss".postln };
    }{
        "[A] exact folder miss".postln;
    };

    // B) canonical folder + exact file
    fs = canon.(folderSym);
    "[B] canonical folder token: ".post; fs.postln;
    subLocal = nil;
    tree.keysDo { |k|
        if(canon.(k) == fs) { subLocal = tree[k] };
    };
    "[B] folder resolved? ".post; (subLocal.notNil).postln;
    if(subLocal.isNil) { ^nil };

    "[B] exact file in canonical folder: ".post; fileSym.postln;
    buf = subLocal[fileSym];
    if(buf.notNil) { "[B] exact hit".postln; ^buf } { "[B] exact miss".postln };

    // C) canonical file inside canonical folder
    ks = canon.(fileSym);
    "[C] canonical file token: ".post; ks.postln;
    buf = nil;
    subLocal.keysDo { |k|
        if(canon.(k) == ks) { buf = subLocal[k] };
    };
    "[C] canonical file hit? ".post; (buf.notNil).postln;
    ^buf
};

// 6 smart lookup
tag.("SMART LOOKUP");
bufSmart = ~getSampleSmart.(\Storm, \Storm_05_11_2022_01);
bufSmart.postln;

// 7 play something so you hear audio even if smart lookup failed
tag.("PLAY (direct exact if smart is nil)");
~playBuf.(bufSmart ? bufExact, amp: 0.9);

tag.("DEBUG COMPLETE");
)

