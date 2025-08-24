/*  midi-setup.scd
    --------------------------------------------------------------------
    Full, robust MIDI event printer for SuperCollider
    Datestamp: 2025-08-23 18:20 CDT
    -------------------------------------------------------------------- */

MIDIClient.init;
MIDIIn.connectAll;

// Optional: list available MIDI I/O
"--- MIDI Sources ---".postln;
MIDIClient.sources.do { |src, i|
    (i.asString ++ ": " ++ src.device ++ " (" ++ src.name ++ ") uid:" ++ src.uid).postln
};
"--- MIDI Dests ---".postln;
MIDIClient.destinations.do { |dst, i|
    (i.asString ++ ": " ++ dst.device ++ " (" ++ dst.name ++ ")").postln
};

// Helpers --------------------------------------------------------------------
~stamp = { Date.getDate.stamp };
~pp = { |tag, data|
    ("[" ++ ~stamp.() ++ "] " ++ tag ++ "  " ++ data.asString).postln
};

// Merge two Events/IdentityDictionaries safely
~merge = { |a, b|
    var e = a.copy;
    e.putAll(b);
    e
};

// Resolve source whether it's a UID (Integer) or an endpoint object
~srcInfo = { |src|
    var uid, ep;

    if(src.respondsTo(\uid)) {
        uid = src.uid;
    }{
        uid = src.asInteger;
    };

    ep = MIDIClient.sources.detect { |m| m.uid == uid };

    if(ep.notNil) {
        (src: (device: ep.device, name: ep.name, uid: uid))
    }{
        (src: (uid: uid))
    }
};

// Note on/off ----------------------------------------------------------------
MIDIdef.noteOn(\printNoteOn, { |vel, note, chan, src|
    var kind;
    if(vel == 0) { kind = "noteOff*viaOn"; } { kind = "noteOn"; };
    ~pp.(kind, ~merge.(~srcInfo.(src), (chan: chan, note: note, vel: vel, vel01: vel/127)));
});

MIDIdef.noteOff(\printNoteOff, { |vel, note, chan, src|
    ~pp.("noteOff", ~merge.(~srcInfo.(src), (chan: chan, note: note, vel: vel)));
});

// CC / Pitch Bend / Program / Aftertouch -------------------------------------
MIDIdef.cc(\printCC, { |val, num, chan, src|
    ~pp.("cc", ~merge.(~srcInfo.(src), (chan: chan, cc: num, val: val, val01: val/127)));
});

// If your SC uses 'bend' (most builds): 
MIDIdef.bend(\printBend, { |val, chan, src|
    ~pp.("pitchBend", ~merge.(~srcInfo.(src), (chan: chan, raw: val, norm: (val - 8192) / 8192.0)));
});

// Use 'program' (your build doesn’t define 'prog')
MIDIdef.program(\printProgram, { |prog, chan, src|
    ~pp.("program", ~merge.(~srcInfo.(src), (chan: chan, program: prog)));
});

MIDIdef.touch(\printChAT, { |val, chan, src|
    ~pp.("channelAftertouch", ~merge.(~srcInfo.(src), (chan: chan, val: val, val01: val/127)));
});

// MIDIdef.polyTouch(\printPolyAT, { |val, note, chan, src|
//     ~pp.("polyAftertouch", ~merge.(~srcInfo.(src), (chan: chan, note: note, val: val, val01: val/127)));
// });

// Realtime: clock + transport ------------------------------------------------
// MIDIdef.midiClock(\printClock, { |srcID|
//     ~pp.("midiClock", ~srcInfo.(srcID));   // 24 PPQN pulses
// });

MIDIdef.tick(\printTick, { |srcID|
    ~pp.("tick", ~srcInfo.(srcID));
});

MIDIdef.start(\printStart, { |srcID| ~pp.("start", ~srcInfo.(srcID)); });
MIDIdef.stop(\printStop,   { |srcID| ~pp.("stop",  ~srcInfo.(srcID)); });
MIDIdef.continue(\printCont, { |srcID| ~pp.("continue", ~srcInfo.(srcID)); });

// Cleanup --------------------------------------------------------------------
// MIDIdef.freeAll; MIDIIn.disconnectAll;

