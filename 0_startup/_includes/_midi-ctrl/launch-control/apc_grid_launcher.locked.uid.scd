(
// apc_router.locked.uid.scd
// timestamp: 2025-10-15 21:50 CDT — SC 3.14-compatible

var srcOK, destOK;

// ---------- GLOBAL PARAMS ----------
~apcParam = ~apcParam ? IdentityDictionary[
    \pdefMap -> IdentityDictionary.new,
    \ccMap   -> IdentityDictionary.new,
    \srcID   -> nil,
    \destIdx -> 4,
    \srcIdx  -> nil,
    \out     -> nil,
    \gridChan -> 0,
    \palette -> IdentityDictionary[
        \on -> 127,   // green
        \off -> 0,
        \bound -> 10  // amber
    ]
];

~apcSay = { |msg| ("[APC] " ++ msg).postln };

// ---------- MIDI OUTPUT ----------
~apcEnsureMIDIOut = {
    var out, dest;
    if(~apcParam[\out].notNil) { ^~apcParam[\out] };
    dest = MIDIClient.destinations.at(~apcParam[\destIdx]);
    if(dest.isNil) { ~apcSay.("no dest at index" + ~apcParam[\destIdx]); ^nil };
    out = MIDIOut.newByName(dest.device, dest.name);
    if(out.isNil) { out = MIDIOut(~apcParam[\destIdx]); };
    ~apcParam[\out] = out;
    ^out
};

// ---------- LED CONTROL ----------
~apcSetGridLED = { |num, state=\off|
    var out, val, chan;
    out = ~apcEnsureMIDIOut.();
    if(out.isNil) { ^nil };
    val = (~apcParam[\palette][state]) ? 0;
    chan = ~apcParam[\gridChan];
    out.noteOn(chan, num, val);
    ^val
};

~apcGridPlayLED = { |num| ~apcSetGridLED.(num, \on) };
~apcGridStopLED = { |num| ~apcSetGridLED.(num, \bound) };

// ---------- INIT ----------
~apcGridInit = { |srcUID=nil, destIndex=4|
    var out, srcIndex;
    ~apcParam[\srcID] = srcUID;
    ~apcParam[\destIdx] = destIndex;

    // detect by UID or name
    srcIndex = MIDIClient.sources.detectIndex({ |ep|
        ep.uid == srcUID or: { ep.device == "APC40 mkII" }
    });
    ~apcParam[\srcIdx] = srcIndex;

    srcOK = srcIndex.notNil;
    destOK = MIDIClient.destinations.at(destIndex).notNil;

    out = MIDIOut.newByName("APC40 mkII","APC40 mkII");
    if(out.isNil) { out = MIDIOut(destIndex) };
    ~apcParam[\out] = out;

    "[APC] init ok — srcOK:% destOK:%"
    .format(srcOK, destOK).postln;

    ~apcGridRearm.();  // auto-arm inputs
    ^(srcOK:srcOK, destOK:destOK, midiOutReady:out.notNil,
      srcIndex:srcIndex, destIndex:destIndex,
      pdefCount:~apcParam[\pdefMap].size)
};

// ---------- GRID ASSIGN ----------
~apcGL2AssignNote = { |num, key|
    var was, now;
    was = ~apcParam[\pdefMap][num];
    ~apcParam[\pdefMap][num] = key;
    ~apcSetGridLED.(num, \bound);
    now = ~apcParam[\pdefMap][num];
    ("[APC] assigned note " ++ num ++ " -> " ++ key).postln;
    ^(num:num, key:now, replaced:was, size:~apcParam[\pdefMap].size)
};

// ---------- CC / FADER / KNOB BIND ----------
~apcBindCC = { |ccNum, func, spec|
    var specFunc;
    specFunc = spec ?? { ControlSpec(0,1,\lin,0,0) };
    ~apcParam[\ccMap][ccNum] = func;
    ("[APC] bound CC " ++ ccNum).postln;
    MIDIdef.cc(("apc_cc_" ++ ccNum).asSymbol,
        { |val, cc, chan, src|
            var norm = specFunc.unmap(val/127);
            func.value(norm);
        },
        ccNum,
        0,                               // chan 0
        ~apcParam[\srcIdx]               // source index
    );
    ^ccNum
};

// ---------- INPUT REARM ----------
~apcGridRearm = {
    var srcIdx = ~apcParam[\srcIdx], chan = ~apcParam[\gridChan];
    if(srcIdx.isNil) {
        "[APC] no MIDI source found".postln;
        ^nil;
    };

    MIDIdef.freeAll;

    // GRID BUTTON HANDLER
    MIDIdef.noteOn(\apc40_grid_on, { |val, num, chan, src|
        var key = ~apcParam[\pdefMap][num];
        if(key.notNil) {
            if(val > 0) {
                ~apcGridPlayLED.(num);
                Pdef(key).play;
            }{
                ~apcGridStopLED.(num);
                Pdef(key).stop;
            };
            ("[APC] button " ++ num ++ " -> " ++ key).postln;
        }{
            ("[APC] unbound note " ++ num).postln;
        };
    }, nil, chan, srcIdx);

    // CC HANDLER
    MIDIdef.cc(\apc40_cc, { |val, cc, chan, src|
        var fn = ~apcParam[\ccMap][cc];
        if(fn.notNil) { fn.value(val / 127) };
    }, nil, chan, srcIdx);

    "[APC] input defs armed".postln;
    ^srcIdx
};

"[APC] unified router loaded ok (SC3.14)".postln;
)

