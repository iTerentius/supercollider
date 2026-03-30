// ndef2mixer-channel.scd — route Ndefs into ddwMixerChannel strips
// Load after mixer-channel-16s.scd (needs MixerChannels to exist).
//
// API:
//   ~ndefmRoute.(key, chan)         — play Ndef(key) into chan (stereo)
//   ~ndefmRoute.(key, chan, 1)      — mono Ndef
//   ~ndefmFree.(key)                — stop + remove from chan
//   ~ndefmFreeAll.()                — free all routed Ndefs
//   ~ndefmMap                       — IdentityDict: key → (chan, synth)
//
// Example:
//   Ndef(\pad, { SinOsc.ar([440, 441]) * 0.2 });
//   ~ndefmRoute.(\pad, ~t2);
//   ~ndefmFree.(\pad);
(
~ndefmMap = IdentityDictionary.new;

~ndefmRoute = { |key, chan, chans = 2|
    var k = key.asSymbol;
    var syn;
    ~ndefmFree.(k);   // replace if already routed
    syn = chan.playfx({ |outbus|
        var sig = Ndef(k).ar(chans);
        Out.ar(outbus, sig.flat)
    });
    ~ndefmMap[k] = (chan: chan, synth: syn);
    ("~ndefmRoute: \\" ++ k ++ " → " ++ chan.name).postln;
};

~ndefmFree = { |key, stopNdef = true|
    var k   = key.asSymbol;
    var rec = ~ndefmMap[k];
    if(rec.notNil) {
        rec[\synth].tryPerform(\free);
        ~ndefmMap.removeAt(k);
        ("~ndefmFree: \\" ++ k).postln;
    };
    if(stopNdef) { Ndef(k).stop };
};

~ndefmFreeAll = {
    ~ndefmMap.keys.asArray.do { |k| ~ndefmFree.(k) };
};

CmdPeriod.doOnce({ ~ndefmMap = IdentityDictionary.new });

"ndef2mixer-channel loaded. (~ndefmRoute, ~ndefmFree, ~ndefmFreeAll)".postln;
)
