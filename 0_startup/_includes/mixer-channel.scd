// 2025-09-14 17:38 America/Chicago  mixer36 with master channel

(
s.waitForBoot({
    // -------- config --------
    var totalMono, totalStereo, numTracks, numSends, hwOut, sendBusses;
    var fxSynths, trackChans, master;

    totalMono   = 36;
    totalStereo = (totalMono / 2).asInteger;  // 18
    numTracks   = 9;                          // stereo instrument tracks
    hwOut       = 0;                          // hardware 0 1
    numSends    = (totalStereo - (1 + numTracks)).max(0); // 18 - 10 = 8

    ("[mixer36] stereo pairs:" + totalStereo ++ " tracks:" + numTracks
        ++ " sends:" + numSends).postln;

    // -------- synthdefs --------
    SynthDef(\m36_fxVerb, { |inBus=0, out=0, mix=0.25, room=0.85, damp=0.25|
        var sig;
        sig = In.ar(inBus, 2);
        sig = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
        Out.ar(out, sig);
    }).add;

    SynthDef(\m36_fxDelay, { |inBus=0, out=0, time=0.33, fb=0.42, wet=0.35|
        var sig, dl;
        sig = In.ar(inBus, 2);
        dl  = DelayC.ar(sig + (LocalIn.ar(2) * fb), 1.0, [time, time * 1.12]);
        LocalOut.ar(dl);
        sig = (sig * (1 - wet)) + (dl * wet);
        sig = Limiter.ar(sig, 0.95);
        Out.ar(out, sig);
    }).add;

    SynthDef(\m36_fxPass, { |inBus=0, out=0, gain=1.0|
        var sig;
        sig = In.ar(inBus, 2) * gain;
        Out.ar(out, sig);
    }).add;

    s.sync;

    // -------- master channel --------
    // master feeds hardware outs 0 1
    master = MixerChannel("m36_master", s, 2, outbus: hwOut, level: 0.9);

    // -------- send busses and fx tails --------
    // each FX reads from its send bus and writes into master.inbus
    sendBusses = Array.fill(numSends, { Bus.audio(s, 2) });
    fxSynths   = Array.newClear(numSends);

    numSends.do { |i|
        var defName, args;
        defName = switch(i,
            0, { \m36_fxVerb },
            1, { \m36_fxDelay },
            { \m36_fxPass }
        );
        args = [\inBus, sendBusses[i], \out, master.inbus];
        fxSynths[i] = Synth.tail(s, defName, args);
    };

    // -------- mixer channels for tracks --------
    // each track outputs into the master channel
    trackChans = Array.fill(numTracks, { |n|
        MixerChannel(
            "m36_tr" ++ (n + 1),
            s,
            2,
            outbus: master.inbus,
            sendbusses: sendBusses,
            level: 0.8
        )
    });

    // -------- publish handles --------
    ~m36_master     = master;
    ~m36_hwOut      = hwOut;          // hardware out index for master
    ~m36_tracks     = trackChans;     // array of MixerChannel
    ~m36_sendBusses = sendBusses;     // array of Bus.audio for sends
    ~m36_fxSynths   = fxSynths;       // array of running FX synths

    // route helper
    ~m36_in = { |trackIndex=0|
        var ch;
        ch = ~m36_tracks.wrapAt(trackIndex);
        ch.inbus
    };

    // set a send level for a given track and send index
    ~m36_setSend = { |trackIndex=0, sendIndex=0, level=0.3|
        var ch;
        ch = ~m36_tracks.wrapAt(trackIndex);
        ch.sendLevel_(sendIndex, level.clip(0, 1));
    };

    // master helpers
    ~m36_masterLevel = { |level=0.9| ~m36_master.level_(level.clip(0, 2)) };
    ~m36_masterMute  = { ~m36_master.mute };
    ~m36_masterUnmute= { ~m36_master.unmute };

    // cleanup
    ~m36_freeAll = {
        var chans;
        chans = ~m36_tracks ? [];
        chans.do { |ch| ch.notNil.if({ ch.free }) };
        (~m36_fxSynths ? []).do { |fx| fx.notNil.if({ fx.free }) };
        (~m36_sendBusses ? []).do { |b| b.notNil.if({ b.free }) };
        ~m36_master.notNil.if({ ~m36_master.free });
        ~m36_tracks = nil; ~m36_fxSynths = nil; ~m36_sendBusses = nil; ~m36_master = nil;
        "[mixer36] freed".postln;
    };

    "[mixer36] ready  master 0 1  tracks 9  sends ".post;
    numSends.postln;
});
)

