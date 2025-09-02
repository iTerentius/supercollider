~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

// exact keys
~storm = ~samplesTree[\Storm][\Storm_05_11_2022_01];

// decide instrument name based on channel count in language
~chopInstr = (~storm.numChannels == 1).if(\chop_pb_m, \chop_pb_s);
~chopInstr.postln;  // should print chop_pb_s for your Storm file

( 
Synth(~chopInstr, [
    \out, 0,
    \buf, ~storm.bufnum,  // bufnum for SynthDef
    \chop, 8, \slice, 0, \start, 0.0, \stop, 1.0,
    \rate, 1.0, \amp, 0.35, \pan, 0.0,
    \useInternal, 0, \gate, 1, \atk, 0.005, \rel, 0.06
]);
 )


Pdef(\stormChop_clean).stop.clear;
( 
Pdef(\stormChop_clean,
    Pbind(
        \type, \note,
        \instrument, Pfunc { ~chopInstr },    // mono or stereo chosen here
        \out, 0,
        \buf, ~storm.bufnum,
        \chop, 8,
        \slice, Pseq((0..7), inf),
        \start, 0.0,
        \stop, 1.0,
        \rate, 1.0,
        \amp, 0.35,
        \pan, 0.0,
        \useInternal, 0,                     // pattern controls gate
        \atk, 0.005,
        \rel, 0.06,
        \dur, 0.25,
        \legato, 0.9
    )
).play;   // trace first to confirm instrument and buf values 
)

// show what you have
~samplesTree.keys.postln;                // should include \storm
~samplesTree[\storm].keys.postln;        // file keys inside storm

// quick exact access with the lowercase folder
~storm = ~samplesTree[\storm][\Storm_05_11_2022_01];
~playBuf.(~storm, amp: 0.6);

(
// ensure chop synthdefs exist  mono and stereo
~ensureChopDefs = {
    var haveM, haveS;
    haveM = SynthDescLib.global.at(\chop_pb_m).notNil;
    haveS = SynthDescLib.global.at(\chop_pb_s).notNil;

    if(haveM.not) {
        SynthDef(\chop_pb_m, { |out=0, buf=0, chop=8, slice=0, start=0.0, stop=1.0,
            rate=1.0, amp=0.3, pan=0.0, atk=0.005, rel=0.06|
            var frames, lo, hi, segLen, sidx, pos, env, sig;
            frames = BufFrames.kr(buf);
            lo     = (start.clip(0, 1) * frames).round(1);
            hi     = (stop.clip(0, 1) * frames).round(1).max(lo + 2);
            segLen = (hi - lo) / chop.max(1);
            sidx   = (slice % chop) * segLen + lo;
            pos    = sidx;
            env    = EnvGen.kr(Env.perc(atk, rel, 1, -4), doneAction: 2);
            sig    = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, startPos: pos, loop: 0);
            sig    = Pan2.ar(sig, pan);
            OffsetOut.ar(out, sig * amp * env);
        }).add;
    };

    if(haveS.not) {
        SynthDef(\chop_pb_s, { |out=0, buf=0, chop=8, slice=0, start=0.0, stop=1.0,
            rate=1.0, amp=0.3, pan=0.0, atk=0.005, rel=0.06|
            var frames, lo, hi, segLen, sidx, pos, env, pair, outPair;
            frames = BufFrames.kr(buf);
            lo     = (start.clip(0, 1) * frames).round(1);
            hi     = (stop.clip(0, 1) * frames).round(1).max(lo + 2);
            segLen = (hi - lo) / chop.max(1);
            sidx   = (slice % chop) * segLen + lo;
            pos    = sidx;
            env    = EnvGen.kr(Env.perc(atk, rel, 1, -4), doneAction: 2);
            pair   = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: pos, loop: 0);
            outPair = Balance2.ar(pair[0], pair[1], pan);
            OffsetOut.ar(out, outPair * amp * env);
        }).add;
    };
};
)
(
// pick the right instrument for a given buffer
~chopInstrFor = { |buf|
    var chs;
    chs = if(buf.notNil and: { buf.numChannels.notNil }) { buf.numChannels } { 2 };
    if(chs == 1) { \chop_pb_m } { \chop_pb_s };
};
)
(
// convenience  default out pair if not given
~chopDefaultOut = { |out|
    var outBus;
    outBus = out;
    if(outBus.isNil) { outBus = ~auditionOut };
    outBus;
};
)

~ensureChopDefs.();

// helpers for chop  lives in your project file
( 
~chopInstrFor = { |buf|
    var chs;
    chs = if(buf.notNil and: { buf.numChannels.notNil }) { buf.numChannels } { 2 };
    if(chs == 1) { \chop_pb_m } { \chop_pb_s };
};
 )
( 
~chopDefaultOut = { |out|
    var outBus;
    outBus = out;
    if(outBus.isNil) { outBus = ~auditionOut };
    outBus;
};
)
(
// pick a buffer by tolerant lookup and store it for patterns
~useSample = { |folder, file|
    var b;
    b = ~getSampleSmart.(folder, file);
    if(b.isNil) { "[useSample] not found".postln } { ~chopBuf = b };
    ~chopBuf
};
)

// load samples if needed
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

// choose the Storm file  tolerant to case and separators
~useSample.(\Storm, \Storm_05_11_2022_01);

// start patterns
Pdef(\stormChop_seq).play;
// or
Pdef(\stormChop_rand).play;
// or
Pdef(\stormChop_rotate).play;

// stop
Pdef(\stormChop_seq).stop;
Pdef(\stormChop_rand).stop;
Pdef(\stormChop_rotate).stop;
