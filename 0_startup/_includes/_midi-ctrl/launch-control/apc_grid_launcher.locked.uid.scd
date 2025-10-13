// Usage:
//
// the same pad via exact note
// ~apcGL2AssignNote.(32, \kick);
// top row:    32 33 34 35 36 37 38 39
// row 2:      24 25 26 27 28 29 30 31
// row 3:      16 17 18 19 20 21 22 23
// row 4:       8  9 10 11 12 13 14 15
// bottom row:  0  1  2  3  4  5  6  7

// 2025-10-12 19:20 CDT  APC40 mkII grid → Pdef launcher  device-scoped  top row 32..39  no cross-controller takeover

(
// list connected MIDI sources with their uids to help you find the APC
~apcGridListSrc = {
    var i, srcs, s;
    i = 0; srcs = MIDIClient.sources;
    while { i < srcs.size } {
        s = srcs[i];
        [i, s.device, s.name, \uid, s.uid].postln;
        i = i + 1;
    };
    "[apcGrid] look above for APC40 mkII uid".postln;
};

// main init  pass apcSrcUID and apcDestIdx  nothing else is touched
~apcGridInit = { |apcSrcUID, apcDestIdx|
    var rows, cols, baseNote, pal, rgbChan, out, clamp5x8, mkNote;

    rows     = 5;                     // 5 rows
    cols     = 8;                     // 8 columns
    baseNote = 32;                    // top-left pad maps to note 32 on mkII
    pal      = (on: 21, assigned: 126, off: 0);  // green 21  amber 126  off 0
    rgbChan  = 0;                     // RGB primary color type channel
    out      = MIDIOut.new(apcDestIdx);

    // store state in a namespaced dict
    ~apcGrid = IdentityDictionary[
        \srcUID  -> apcSrcUID,
        \destIdx -> apcDestIdx,
        \rows    -> rows,
        \cols    -> cols,
        \base    -> baseNote,
        \pal     -> pal,
        \rgbChan -> rgbChan,
        \out     -> out,
        \map     -> IdentityDictionary.new,   // note:int -> Pdef symbol
        \on      -> IdentitySet.new           // running notes
    ];

    // put device in Generic Mode once
    out.sysex(Int8Array[0xF0,0x47,0x7F,0x29,0x60,0x00,0x04,0x40,0x01,0x00,0x00,0xF7]);
    "[apcGrid armed] uid % dest %".format(apcSrcUID, apcDestIdx).postln;

    // helpers
    ~apcGridLED = { |note, vel|
        var n, v, o, ch;
        o = ~apcGrid[\out];
        ch = ~apcGrid[\rgbChan];
        n = note.asInteger.clip(0, 127);
        v = vel.asInteger.clip(0, 127);
        o.noteOn(ch, n, v);
    };

    // row-col to note using mkII numbering  top row col 0..7 → 32..39
    // formula  note = base + col - row*cols
    mkNote = { |row, col|
        var r, c, rowsLocal, colsLocal, base, n;
        rowsLocal = ~apcGrid[\rows];
        colsLocal = ~apcGrid[\cols];
        base      = ~apcGrid[\base];
        r = row.clip(0, rowsLocal - 1);
        c = col.clip(0, colsLocal - 1);
        n = base + c - (r * colsLocal);
        ^n
    };

    clamp5x8 = { |n|
        var rowsLocal, colsLocal;
        rowsLocal = ~apcGrid[\rows];
        colsLocal = ~apcGrid[\cols];
        ^((n >= 0) and: { n < (rowsLocal * colsLocal) })
    };

    // public API
    ~apcGridAssignNote = { |note, pdefSym|
        var n, map, palLocal;
        n = note.asInteger;
        map = ~apcGrid[\map];
        palLocal = ~apcGrid[\pal];
        map[n] = pdefSym;
        ~apcGridLED.(n, palLocal[\assigned]);  // amber immediately
        ["[apcGrid map]", n, "->", pdefSym].postln;
        ^n
    };

    ~apcGridAssignRC = { |row, col, pdefSym|
        var n;
        n = mkNote.(row, col);
        ^~apcGridAssignNote.(n, pdefSym)
    };

    ~apcGridDump = {
        var map;
        map = ~apcGrid[\map];
        if(map.size == 0) { "[apcGrid DUMP] no mappings".postln }{
            map.keysValuesDo { |k, v| ["  ", k, "->", v].postln };
            "[apcGrid DUMP] mappings above".postln
        };
    };

    ~apcGridRefresh = {
        var map, palLocal, runningSet, total, n;
        map = ~apcGrid[\map];
        palLocal = ~apcGrid[\pal];
        runningSet = ~apcGrid[\on];
        total = (~apcGrid[\rows] * ~apcGrid[\cols]) - 1;
        n = 0;
        while { n <= total } {
            ~apcGridLED.(n, palLocal[\off]);
            n = n + 1;
        };
        map.keysDo { |k|
            var isRunning;
            isRunning = runningSet.includes(k);
            ~apcGridLED.(k, if(isRunning) { palLocal[\on] } { palLocal[\assigned] });
        };
        "[apcGrid] refreshed".postln;
    };

    // free everything related to this launcher
    ~apcGridFree = {
        var palLocal, rowsLocal, colsLocal, total, n;
        palLocal = ~apcGrid[\pal];
        rowsLocal = ~apcGrid[\rows];
        colsLocal = ~apcGrid[\cols];
        MIDIdef.free(\apcGrid_note_on);
        MIDIdef.free(\apcGrid_note_off);
        total = (rowsLocal * colsLocal) - 1;
        n = 0; while { n <= total } { ~apcGridLED.(n, palLocal[\off]); n = n + 1 };
        "[apcGrid] freed".postln;
    };

    // device-scoped MIDIdefs  only trigger from APC srcUID
    MIDIdef.free(\apcGrid_note_on);
    MIDIdef.free(\apcGrid_note_off);

    MIDIdef.noteOn(\apcGrid_note_on, { |vel, num, chan, src|
        var map, palLocal, running, nm, isOn;
        if(clamp5x8.(num).not) { ^nil };
        map      = ~apcGrid[\map];
        palLocal = ~apcGrid[\pal];
        running  = ~apcGrid[\on];
        nm       = map[num];
        isOn     = running.includes(num);
        if(nm.notNil and: { Pdef.all[nm].notNil }) {
            if(isOn.not) {
                running.add(num);
                ~apcGridLED.(num, palLocal[\on]);      // green
                Pdef(nm).play;
                ["[apcGrid play]", nm, 'note', num].postln;
            }{
                running.remove(num);
                ~apcGridLED.(num, palLocal[\assigned]); // amber
                Pdef(nm).stop;
                ["[apcGrid stop]", nm, 'note', num].postln;
            };
        }{
            ["[apcGrid no-assign] note", num].postln;
        };
    }, nil, nil, apcSrcUID);  // filter by source uid

    MIDIdef.noteOff(\apcGrid_note_off, { |vel, num, chan, src|
        var mapped, running, palLocal;
        mapped  = ~apcGrid[\map].includesKey(num);
        running = ~apcGrid[\on].includes(num);
        palLocal = ~apcGrid[\pal];
        if(mapped and: { running.not }) { ~apcGridLED.(num, palLocal[\assigned]) };
        nil;
    }, nil, nil, apcSrcUID);  // filter by source uid

    // cold start
    ~apcGrid[\on].clear;
    ~apcGridRefresh.();
};
)

