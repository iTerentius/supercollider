/* 2025-10-18 11:45 — apc_param_router.locked.uid.v2.scd pads only with Generic Mode + group-safe play (no waits) */
/* rules: one block eval, no ) in comments, vars declared at top of functions */

(
~apcParam = ~apcParam ? IdentityDictionary.new.putAll((
    gridChan: 0,
    colors: IdentityDictionary.new.putAll((off: 0, amber: 126, green: 21))
));

~apcPadMap = ~apcPadMap ? IdentityDictionary.new;
~apcNoteDown = ~apcNoteDown ? IdentityDictionary.new;
~apcNoteUp   = ~apcNoteUp   ? IdentityDictionary.new;

~apcEnsureServerAndGroup = ~apcEnsureServerAndGroup ? {
    var g;
    if(s.serverRunning.not) { s.boot; };
    g = s.defaultGroup;
    if(g.isPlaying.not) { s.sendMsg(\g_new, 1, 0, 0); g = Group.basicNew(s, 1); };
    g
};

~apcEnsurePatternGroup = ~apcEnsurePatternGroup ? {
    var g, alive, dg;
    dg = ~apcEnsureServerAndGroup.();
    g = ~apcPdefGroup;
    alive = g.notNil and: { g.server === s } and: { g.isPlaying };
    if(alive.not) {
        g = Group.head(s, dg);
        ~apcPdefGroup = g;
        "[APC] pattern group refreshed".postln;
    };
    g
};

~apcEnsureOut = ~apcEnsureOut ? {
    var idx, out;
    if(~apcOut.notNil) { ^~apcOut };
    if(MIDIClient.initialized.not) { MIDIClient.init; };
    MIDIIn.connectAll;
    idx = nil;
    MIDIClient.destinations.do { |ep, i|
        var ok;
        ok = ep.device.notNil and: { ep.device.asString.contains("APC40") };
        if(idx.isNil and: { ok }) { idx = i };
    };
    if(idx.notNil) {
        out = MIDIOut.newByName(MIDIClient.destinations[idx].device, MIDIClient.destinations[idx].name);
        ~apcOut = out;
    };
    ~apcOut
};

~apcPadLED = ~apcPadLED ? { |note, color, chan = (~apcParam[\gridChan] ? 0)|
    var out;
    out = ~apcEnsureOut.();
    if(out.notNil) { out.noteOn(chan, note, color); };
};

/* grid listener — accept any channel, handle vel 0 as release on noteOn */
~apcInstallGridListener = ~apcInstallGridListener ? {
    var nameOn, nameOff;
    nameOn = \apc40_grid_any_on; nameOff = \apc40_grid_any_off;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        var f;
        if(vel > 0) {
            f = ~apcNoteDown[num]; if(f.notNil) { f.value(vel); };
        } {
            f = ~apcNoteUp[num]; if(f.notNil) { f.value(vel); };
        };
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        var f; f = ~apcNoteUp[num]; if(f.notNil) { f.value(vel); };
    });
    "[APC grid note-mode armed]".postln; true
};

~apcArmGrid = ~apcArmGrid ? { var ok; ok = ~apcInstallGridListener.(); ok };

~apcPadPlay = { |key|
    var g; g = ~apcEnsurePatternGroup.(); Pdef(key).play(protoEvent: (group: g));
};
~apcPadStop = { |key| Pdef(key).stop; };

~apcLEDByState = ~apcLEDByState ? { |num, key|
    var playing, colors;
    colors = ~apcParam[\colors] ? IdentityDictionary.new;
    playing = Pdef(key).isPlaying;
    AppClock.sched(0.05, { ~apcPadLED.(num, playing.if(colors[\green], colors[\amber])); });
};

~apcBindNote = ~apcBindNote ? { |num, onDown, onUp|
    ~apcNoteDown[num] = onDown; ~apcNoteUp[num] = onUp;
};

~apcAssignPad = { |num, key|
    var onDown, onUp, colors;
    colors = ~apcParam[\colors];
    onDown = {
        var playing;
        playing = Pdef(key).isPlaying;
        if(playing) { ~apcPadStop.(key); ~apcPadLED.(num, colors[\amber]); } { ~apcPadPlay.(key); ~apcPadLED.(num, colors[\green]); };
        ~apcLEDByState.(num, key);
    };
    onUp = { ~apcLEDByState.(num, key); };
    ~apcPadMap[num] = key;
    ~apcBindNote.(num, onDown, onUp);
    ~apcLEDByState.(num, key);
    ["map[" ++ num ++ "], " ++ key].postln;
};

)

