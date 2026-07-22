// 2025-09-26 23:05 CDT  Ndef send FX factory v5  safe order  explicit sums  no link ops

(
// config  change as needed
~fxConf = (
    insPrefix: "ins",     // instruments start with this
    fxPrefix:  "fxs",     // FX returns start with this
    sends: #[\s1, \s2],   // any symbols any count
    master: \master,      // master Ndef name
    out: 0                // hardware out index
);

// state
~fxState = (tracks: [], sends: ~fxConf[\sends].asArray.copy);

// helpers  name builders
~fxSendSumName = { |sendSym| var nm; nm = (sendSym.asSymbol ++ "_sum").asSymbol; nm };
~fxTapName     = { |trackSym, sendSym| var nm; nm = (trackSym.asSymbol ++ "_to_" ++ sendSym.asSymbol).asSymbol; nm };

// init or rebuild everything visible right now
~fxInit = {
    var insPrefix, fxPrefix, sends, master, out;
    var tracks, sumName, tapName, fxNames;

    insPrefix = ~fxConf[\insPrefix];
    fxPrefix  = ~fxConf[\fxPrefix];
    sends     = ~fxState[\sends];
    master    = ~fxConf[\master];
    out       = ~fxConf[\out];

    sumName = ~fxSendSumName;
    tapName = ~fxTapName;

    // discover current instruments
    // Ndef.all is keyed by SERVER NAME (server.name -> ProxySpace), not by Ndef
    // name — scanning it directly always finds nothing. Actual Ndef keys live
    // one level deeper, in that server's ProxySpace .envir.
    tracks = Ndef.dictFor(s).envir.keys.asArray.select({ |k| k.asString.beginsWith(insPrefix) });
    ~fxState[\tracks] = tracks.copy;

    // taps  set source first then play
    tracks.do { |tr|
        sends.do { |s|
            var tn;
            tn = tapName.(tr, s);
            if(Ndef.all[tn].isNil) { Ndef(tn) };
            Ndef(tn).fadeTime = 0.02;
            Ndef(tn).source = { |amt = 0|
                var src;
                src = Ndef.ar(tr, 2) * amt;
                src
            };
        };
    };

    // send sums  explicit Mix of taps  source first then play
    sends.do { |s|
        var sn, tapsForSend;
        sn = sumName.(s);
        if(Ndef.all[sn].isNil) { Ndef(sn) };
        Ndef(sn).fadeTime = 0.02;
        tapsForSend = tracks.collect({ |tr| tapName.(tr, s) });
        Ndef(sn).source = { |amp = 1|
            var items, mix;
            items = tapsForSend.collect({ |tn| Ndef.ar(tn, 2) });
            mix = if(items.isEmpty, { Silent.ar(2) }, { Mix(items) });
            mix * amp
        };
    };

    // dry mix from instruments
    if(Ndef.all[\dry_mix].isNil) { Ndef(\dry_mix) };
    Ndef(\dry_mix).fadeTime = 0.02;
    Ndef(\dry_mix).source = { |amp = 1|
        var items, mix;
        items = ~fxState[\tracks].collect({ |tr| Ndef.ar(tr, 2) });
        mix = if(items.isEmpty, { Silent.ar(2) }, { Mix(items) });
        mix * amp
    };

    // buses and master
    if(Ndef.all[\dry_bus].isNil) { Ndef(\dry_bus) };
    Ndef(\dry_bus).fadeTime = 0.02;
    Ndef(\dry_bus).source = { Ndef.ar(\dry_mix, 2) };

    if(Ndef.all[\wet_bus].isNil) { Ndef(\wet_bus) };
    Ndef(\wet_bus).fadeTime = 0.02;
    fxNames = Ndef.dictFor(s).envir.keys.asArray.select({ |k| k.asString.beginsWith(fxPrefix) });
    Ndef(\wet_bus).source = {
        var items, mix;
        items = fxNames.collect({ |fx| Ndef.ar(fx, 2) });
        mix = if(items.isEmpty, { Silent.ar(2) }, { Mix(items) });
        mix
    };

    if(Ndef.all[master].isNil) { Ndef(master) };
    Ndef(master).fadeTime = 0.02;
    Ndef(master).source = { |dry = 1, wet = 1, amp = 1|
        var drySig, wetSig, outSig;
        drySig = Ndef.ar(\dry_bus, 2) * dry;
        wetSig = Ndef.ar(\wet_bus, 2) * wet;
        outSig = LeakDC.ar(drySig + wetSig) * amp;
        outSig
    };
    Ndef(master).play(out: out, vol: 1);
    "fxInit complete".postln;
};

// set or change a send amount  auto registers tracks and keeps sums updated
~fxSetSend = { |trackSym, sendSym, amt|
    var sends, tracks, tn, sn, tapsForSend, isNewTrack;

    sends  = ~fxState[\sends];
    tracks = ~fxState[\tracks];
    isNewTrack = tracks.includes(trackSym).not;

    if(isNewTrack) {
        ~fxState[\tracks] = tracks.add(trackSym);
        Ndef(\dry_mix).source = { |amp = 1|
            var items = ~fxState[\tracks].collect({ |tr| Ndef.ar(tr, 2) });
            (if(items.isEmpty, { Silent.ar(2) }, { Mix(items) })) * amp
        };

        sends.do { |s|
            var tnm = ~fxTapName.(trackSym, s);
            if(Ndef.all[tnm].isNil) {
                Ndef(tnm).fadeTime = 0.02;
                Ndef(tnm).source = { |amt = 0| Ndef.ar(trackSym, 2) * amt };
            };
        };
    };

    tn = ~fxTapName.(trackSym, sendSym);
    if(Ndef.all[tn].isNil) {
        Ndef(tn).fadeTime = 0.02;
        Ndef(tn).source = { |amt = 0| Ndef.ar(trackSym, 2) * amt };
    };
    Ndef(tn).set(\amt, amt);   // <- only this runs on repeat calls, no rebuild

    sn = ~fxSendSumName.(sendSym);
    if(isNewTrack or: { Ndef.all[sn].isNil }) {
        if(Ndef.all[sn].isNil) { Ndef(sn).fadeTime = 0.02 };
        tapsForSend = ~fxState[\tracks].collect({ |tr| ~fxTapName.(tr, sendSym) });
        Ndef(sn).source = { |amp = 1|
            var items = tapsForSend.collect({ |tname| Ndef.ar(tname, 2) });
            (if(items.isEmpty, { Silent.ar(2) }, { Mix(items) })) * amp
        };
    };
    amt
};

// add a new send at runtime
~fxAddSend = { |sendSym|
    var sends, sn;
    sends = ~fxState[\sends];
    if(sends.includes(sendSym).not) {
        ~fxState[\sends] = sends.add(sendSym);
        sn = ~fxSendSumName.(sendSym);
        if(Ndef.all[sn].isNil) { Ndef(sn) };
        Ndef(sn).fadeTime = 0.02;
        Ndef(sn).source = { Silent.ar(2) };

        // create taps for existing tracks (wake through dry_mix/sum references)
        ~fxState[\tracks].do { |tr|
            var tn;
            tn = ~fxTapName.(tr, sendSym);
            if(Ndef.all[tn].isNil) { Ndef(tn) };
            Ndef(tn).fadeTime = 0.02;
            Ndef(tn).source = { |amt = 0| var src; src = Ndef.ar(tr, 2) * amt; src };
        };
    };
    sendSym
};

// manually add or re add an FX to the wet bus by rebuilding wet bus mix
~fxAddFX = { |fxSym|
    var fxPrefix, fxNames;
    fxPrefix = ~fxConf[\fxPrefix];
    fxNames = Ndef.dictFor(s).envir.keys.asArray.select({ |k| k.asString.beginsWith(fxPrefix) });
    Ndef(\wet_bus).fadeTime = 0.02;
    Ndef(\wet_bus).source = {
        var items, mix;
        items = fxNames.collect({ |fx| Ndef.ar(fx, 2) });
        mix = if(items.isEmpty, { Silent.ar(2) }, { Mix(items) });
        mix
    };
    fxSym
};

// convenience getters
~fxTracks = { var st; st = ~fxState; if(st.notNil) { st[\tracks].copy } { [] } };
~fxSends  = { var st; st = ~fxState; if(st.notNil) { st[\sends].copy } { [] } };
~fxTaps   = {
    var st, tr, sd;
    st = ~fxState;
    if(st.isNil) { ^[] };
    tr = st[\tracks]; sd = st[\sends];
    tr.collect { |t| sd.collect { |s| (t.asSymbol ++ "_to_" ++ s.asSymbol).asSymbol } }.flatten
};
)

