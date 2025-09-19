// 2025-09-19 15:55 America-Chicago  lcxl bank mapping plan A v3  simplified logs
(
var describeBank, setBank, nextBank, prevBank, banks, panSpec;
var tracks, fxs;

tracks = ~m36_tracks ? [];
fxs    = ~m36_fxchans ? [];

banks = [
    [ (kind:\master), (kind:\track, idx:0), (kind:\track, idx:1), (kind:\track, idx:2),
      (kind:\track, idx:3), (kind:\track, idx:4), (kind:\track, idx:5), (kind:\track, idx:6) ],
    [ (kind:\track, idx:7), (kind:\track, idx:8), (kind:\fx, idx:0), (kind:\fx, idx:1),
      (kind:\fx, idx:2), (kind:\fx, idx:3), (kind:\fx, idx:4), (kind:\fx, idx:5) ],
    [ (kind:\fx, idx:6), (kind:\fx, idx:7), nil, nil, nil, nil, nil, nil ]
];

~m36_bankIndex = ~m36_bankIndex ? 0;
panSpec = ControlSpec(-1, 1, \lin);

describeBank = {
    var row;
    "bank ".post; (~m36_bankIndex ? 0).post; " slots ".post;
    row = banks.wrapAt(~m36_bankIndex ? 0);
    (0..7).collect({ |i|
        var c; c = row[i];
        if(c.isNil) { "-" } {
            switch(c[\kind],
                \master, { "master" },
                \track,  { "tr" ++ (c[\idx] + 1) },
                \fx,     { "fx" ++ (c[\idx] + 1) }
            )
        }
    }).postln;
};

8.do({ |slot|
    var fKey, pKey;
    fKey = ("f" ++ (slot + 1)).asSymbol;
    pKey = ("t" ++ (slot + 1) ++ "r3").asSymbol;

    ~ccBindFunc.(fKey, { |v|
        var c, b, k, i;
        b = ~m36_bankIndex ? 0;
        c = banks.wrapAt(b)[slot];
        if(c.isNil) { ^nil };
        k = c[\kind]; i = c[\idx];
        switch(k,
            \master, { ~m36_master.tryPerform(\level_, v) },
            \track,  { if(i.notNil and: { i < tracks.size }) { tracks[i].tryPerform(\level_, v) } },
            \fx,     { if(i.notNil and: { i < fxs.size })    { fxs[i].tryPerform(\level_, v) } }
        );
    });

    ~ccBindFunc.(pKey, { |v|
        var c, b, k, i;
        b = ~m36_bankIndex ? 0;
        c = banks.wrapAt(b)[slot];
        if(c.isNil) { ^nil };
        k = c[\kind]; i = c[\idx];
        switch(k,
            \track,  { if(i.notNil and: { i < tracks.size }) { tracks[i].tryPerform(\pan_, v) } },
            \fx,     { if(i.notNil and: { i < fxs.size })    { fxs[i].tryPerform(\pan_, v) } },
            \master, { nil }
        );
    }, panSpec);
});

setBank = { |b=0|
    var maxB;
    maxB = (banks.size - 1).max(0);
    ~m36_bankIndex = b.asInteger.clip(0, maxB);
    describeBank.();
};
nextBank = { setBank.((~m36_bankIndex ? 0) + 1) };
prevBank = { setBank.((~m36_bankIndex ? 0) - 1) };

~installCCByNameRouter.();

MIDIdef.free(\lcxl_bank_prev);
MIDIdef.free(\lcxl_bank_next);

MIDIdef.cc(\lcxl_bank_prev, { |val, cc, chan|
    if((chan == 8) and: { cc == 106 } and: { val >= 64 }) { prevBank.() };
});

MIDIdef.cc(\lcxl_bank_next, { |val, cc, chan|
    if((chan == 8) and: { cc == 107 } and: { val >= 64 }) { nextBank.() };
});

describeBank.();
"[ lcxl plan A mapping installed ]".postln;
)

