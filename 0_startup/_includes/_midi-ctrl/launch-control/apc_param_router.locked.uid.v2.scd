/* 2025-10-18 10:22 — apc_param_router.locked.uid.v2.scd pads only, self-arming */
/* rules: one block eval, no ) in comments, vars declared at top of functions */

(
~apcParam = ~apcParam ? IdentityDictionary.new.putAll((
    gridChan: 0,
    palette: IdentityDictionary.new.putAll((on: 127, unselected: 10, off: 0))
));

~apcPadMap = ~apcPadMap ? IdentityDictionary.new;
~apcNoteDown = ~apcNoteDown ? IdentityDictionary.new;
~apcNoteUp   = ~apcNoteUp   ? IdentityDictionary.new;

~apcEnsureServerAndGroup = ~apcEnsureServerAndGroup ? {
    var g;
    if(s.serverRunning.not) { s.boot; };
    g = s.defaultGroup; g
};

~apcEnsurePatternGroup = ~apcEnsurePatternGroup ? {
    var g, alive;
    g = ~apcPdefGroup;
    alive = g.notNil and: { g.server === s } and: { g.isPlaying };
    if(alive.not) {
        ~apcEnsureServerAndGroup.();
        g = Group.head(s, s.defaultGroup);
        ~apcPdefGroup = g;
        "[APC] pattern group refreshed".postln;
    };
    g
};

~apcEnsureOut = ~apcEnsureOut ? {
    var name, out, idx;
    if(~apcOut.notNil) { ^~apcOut };
    name = "APC40 mkII";
    idx = nil;
    MIDIClient.destinations.do { |ep, i|
        if(idx.isNil and: { ep.device.notNil and: { ep.device.asString.contains("APC40") } }) { idx = i };
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

~apcInstallGridListener = ~apcInstallGridListener ? {
    var c, nameOn, nameOff;
    c = ~apcParam[\gridChan] ? 0;
    nameOn = \apc40_grid_on; nameOff = \apc40_grid_off;
    MIDIdef.free(nameOn); MIDIdef.free(nameOff);
    MIDIdef.noteOn(nameOn, { |vel, num, chan, src|
        if(chan == c) {
            var f; f = ~apcNoteDown[num]; if(f.notNil) { f.value(vel) };
        }
    });
    MIDIdef.noteOff(nameOff, { |vel, num, chan, src|
        if(chan == c) {
            var f; f = ~apcNoteUp[num]; if(f.notNil) { f.value(vel) };
        }
    });
    "[APC grid note-mode armed]".postln;
    true
};

~apcArmGrid = ~apcArmGrid ? {
    var ok; ok = ~apcInstallGridListener.(); ok
};

~apcPadPlay = { |key|
    var g; g = ~apcEnsurePatternGroup.(); Pdef(key).play(target: g);
};
~apcPadStop = { |key| Pdef(key).stop; };

~apcLEDByState = ~apcLEDByState ? { |num, key|
    var playing, amber, green, palette, color;
    palette = ~apcParam ? IdentityDictionary.new;
    amber = (palette[\palette] ? IdentityDictionary.new)[\unselected] ? 10;
    green = (palette[\palette] ? IdentityDictionary.new)[\on] ? 127;
    playing = Pdef(key).isPlaying;
    color = playing.if(green, amber);
    ~apcPadLED.(num, color);
};

~apcBindNote = ~apcBindNote ? { |num, onDown, onUp|
    ~apcNoteDown[num] = onDown; ~apcNoteUp[num] = onUp;
};

~apcAssignPad = { |num, key|
    var onDown, onUp;
    onDown = {
        var playing;
        playing = Pdef(key).isPlaying;
        if(playing) { ~apcPadStop.(key); } { ~apcPadPlay.(key); };
        ~apcLEDByState.(num, key);
    };
    onUp = { };
    ~apcPadMap[num] = key;
    ~apcBindNote.(num, onDown, onUp);
    ~apcLEDByState.(num, key);
    ["map[" ++ num ++ "], " ++ key].postln;
};

)

