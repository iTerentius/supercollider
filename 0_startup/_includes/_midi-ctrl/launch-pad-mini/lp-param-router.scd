(
// -----------------------------------------------------------------------------
// Launchpad Mini [MK3] Universal Launcher (v14)
// Fix: Scene Launch keys are now strictly Integers (fixes lookup failure)
// -----------------------------------------------------------------------------

var pickSrcIdx, pickDest, srcIdx;

if(MIDIClient.initialized.not) { MIDIClient.init };

pickSrcIdx = {
    MIDIClient.sources.detectIndex { |ep|
        ep.device == "Launchpad Mini MK3" and: { ep.name.contains("MIDI") }
    }
};
pickDest = {
    MIDIClient.destinations.detect { |ep|
        ep.device == "Launchpad Mini MK3" and: { ep.name.contains("MIDI") }
    }
};

~lpMini = IdentityDictionary.new;
srcIdx = pickSrcIdx.();
if(srcIdx.notNil) {
    ~lpMini[\src] = MIDIClient.sources[srcIdx];
    // Use connectAll for cross-platform compatibility (ALSA on Linux needs this)
    MIDIIn.connectAll;
    ["[LP Mini] MIDIIn connectAll, found device:", ~lpMini[\src].device].postln;
} {
    ~lpMini[\src] = nil;
};
~lpMini[\dst] = pickDest.();

if (~lpMini[\src].isNil) { "CRITICAL: LP Mini MIDI not found!".warn; };

~lpMini[\out] = ~lpMini[\dst].notNil.if({ MIDIOut.newByName(~lpMini[\dst].device, ~lpMini[\dst].name) }, { nil });
~lpMini[\uid] = ~lpMini[\src].tryPerform(\uid);

~lpMini[\bindings] = IdentityDictionary.new;     
~lpMini[\ledCache] = IdentityDictionary.new;     

~lpMini[\colors] = (
    empty:       0, pdefDefault: 9, ndefDefault: 95, 
    funcDefault: 13, trigger: 21
);

// --- HARDWARE CONTROL ---
~lpMini[\setProgrammerMode] = {
    if(~lpMini[\out].notNil) {
        ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
    };
};

~lpMini[\clearGrid] = {
    if(~lpMini[\out].notNil) {
        fork {
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x00, 0xF7]);
            0.05.wait; 
            ~lpMini[\out].sysex(Int8Array[0xF0, 0x00, 0x20, 0x29, 0x02, 0x0D, 0x0E, 0x01, 0xF7]);
            ~lpMini[\ledCache] = IdentityDictionary.new; 
            "LP Mini Grid Cleared".postln;
        }
    };
};

// --- OBJECT RESOLVER ---
~lpMini[\getObj] = { |key|
    var obj;
    if(key.isKindOf(Function) or: { key.isString }) {
        obj = key;
    } {
        if(Pdef.all[key].notNil) { obj = Pdef(key) } {
            if(Tdef.all[key].notNil) { obj = Tdef(key) } {
                var proxySpace = Ndef.dictFor(Server.default);
                if(proxySpace.notNil and: { proxySpace.envir.at(key).notNil }) {
                    obj = Ndef(key)
                }
            }
        }
    };
    obj
};

// --- LED PAINTER ---
~lpMini[\paint] = { |note, bindData|
    var obj, isPlaying, color, channel, key, assignedColor;
    
    if (bindData.isKindOf(Event)) {
        key = bindData[\key]; assignedColor = bindData[\color];
    } {
        key = bindData; assignedColor = nil;
    };

    if(note.isInteger) {
        obj = ~lpMini[\getObj].(key);
        
        if(obj.isNil) {
            color = ~lpMini[\colors][\empty];
            channel = 0;
        } {
            isPlaying = false;
            if(obj.isKindOf(Pdef) or: { obj.isKindOf(EventPatternProxy) } or: { obj.isKindOf(TaskProxy) }) { isPlaying = obj.isPlaying };
            if(obj.isKindOf(NodeProxy)) { isPlaying = obj.isMonitoring };

            if(isPlaying) {
                channel = 2; // Pulse
                if(assignedColor.notNil) { color = assignedColor } {
                    if(obj.isKindOf(NodeProxy)) { color = ~lpMini[\colors][\ndefDefault] } { color = ~lpMini[\colors][\pdefDefault] };
                };
            } {
                channel = 0; // Static
                if(assignedColor.notNil) { color = assignedColor } {
                    if(obj.isKindOf(Function) or: { obj.isString }) { color = ~lpMini[\colors][\funcDefault] } {
                        if(obj.isKindOf(NodeProxy)) { color = ~lpMini[\colors][\ndefDefault] } { color = ~lpMini[\colors][\pdefDefault] };
                    };
                };
            };
        };

        if(~lpMini[\ledCache][note] != [channel, color]) {
            if(~lpMini[\out].notNil) {
                ~lpMini[\out].noteOn(channel, note, color);
                ~lpMini[\ledCache][note] = [channel, color];
            };
        };
    };
};

// --- TOGGLE HANDLER ---
~lpMini[\toggle] = { |note, bindData|
    var key = bindData[\key];
    var obj = ~lpMini[\getObj].(key);
    var clock = bindData[\clock] ?? { ~link ?? { TempoClock.default } };
    var quant = bindData[\quant] ?? { 4 };
    
    if(obj.notNil) {
        if(obj.isKindOf(Function)) {
            obj.value;
            if(~lpMini[\out].notNil) { ~lpMini[\out].noteOn(0, note, ~lpMini[\colors][\trigger]) };
            ~lpMini[\ledCache][note] = nil;
        } {
            if(obj.isString) {
                obj.interpret;
                if(~lpMini[\out].notNil) { ~lpMini[\out].noteOn(0, note, ~lpMini[\colors][\trigger]) };
                ~lpMini[\ledCache][note] = nil;
            } {
                var isRunning = false;
                if(obj.isKindOf(NodeProxy)) { isRunning = obj.isMonitoring } { isRunning = obj.isPlaying };

                if(isRunning) {
                    if(bindData[\onStop].notNil) {
                        bindData[\onStop].value;
                    } {
                        if(obj.respondsTo(\stopQ)) { obj.stopQ(quant) } { obj.stop };
                    };
                    "[%] Stopping: %".format(note, key).postln;
                } {
                    if(obj.isKindOf(NodeProxy)) {
                        obj.quant = quant; obj.play;
                    } {
                        obj.play(clock, quant: quant);
                    };
                    "[%] Playing: %".format(note, key).postln;
                };
            };
        };
    } {
        ~lpMini[\ledCache][note] = nil; 
        ~lpMini[\paint].(note, bindData);
    };
};

// --- GROUP LAUNCHER ---
~lpMini[\launchList] = { |noteList|
    var bindList = List.new;
    var anyPlaying = false;
    
    noteList.do { |n|
        var b = ~lpMini[\bindings][n];
        if(b.notNil) {
            var obj = ~lpMini[\getObj].(b[\key]);
            if(obj.notNil) {
                var running = false;
                if(obj.isKindOf(NodeProxy)) { running = obj.isMonitoring }; 
                if(obj.isKindOf(Pdef) or: {obj.isKindOf(Tdef)}) { running = obj.isPlaying };
                if(running) { anyPlaying = true };
                bindList.add( (note: n, bind: b, obj: obj, running: running) );
            };
        };
    };

    if(bindList.size > 0) {
        if(anyPlaying) {
            "--- Group Stop (% items) ---".format(bindList.size).postln;
            bindList.do { |item|
                if(item[\running]) {
                    var q = item[\bind][\quant] ?? { 4 };
                    if(item[\obj].respondsTo(\stopQ)) { item[\obj].stopQ(q) } { item[\obj].stop };
                };
            };
        } {
            "--- Group Play (% items) ---".format(bindList.size).postln;
            bindList.do { |item|
                var obj = item[\obj];
                if(obj.isKindOf(Function)) { obj.value; };
                if(obj.isString) { obj.interpret; };
                
                if(item[\running].not) {
                    var clk = item[\bind][\clock] ?? { ~link ?? { TempoClock.default } };
                    var q = item[\bind][\quant] ?? { 4 };
                    
                    if(obj.isKindOf(NodeProxy)) {
                        obj.quant = q; obj.play;
                    } {
                        if(obj.isKindOf(Pdef) or: {obj.isKindOf(Tdef)}) {
                            obj.play(clk, quant: q);
                        };
                    };
                };
            };
        };
    };
};

// --- WATCHER ---
~lpMini[\watcher] = Routine {
    loop {
        ~lpMini[\bindings].keysValuesDo { |note, bindData| ~lpMini[\paint].(note, bindData); };
        0.1.wait; 
    }
}.play(AppClock);

// --- BINDING API ---
~lpBind = { |ref, key, color=nil, clock=nil, quant=nil, onStop=nil|
    var note, storedKey;
    if(ref.isArray) {
        note = ((9 - ref[0]) * 10) + ref[1];
    } {
        note = ref;
    };

    if(key.isKindOf(Function) or: { key.isString }) { storedKey = key; } { storedKey = key.asSymbol; };

    ~lpMini[\bindings][note] = (
        key: storedKey, color: color, clock: clock, quant: quant, onStop: onStop
    );
    
    ~lpMini[\ledCache][note] = nil; 
    ~lpMini[\paint].(note, ~lpMini[\bindings][note]);
    "LP Bound Pad %".format(note).postln;
};

// --- MIDI LISTENERS ---
MIDIdef.free(\lpMini_note);
MIDIdef.free(\lpMini_cc);

MIDIdef.noteOn(\lpMini_note, { |vel, note, chan, src|
    if(vel > 0) {
        // Grid Hits (Notes 11-88)
        var bindData = ~lpMini[\bindings][note];
        if(bindData.notNil) {
            ~lpMini[\toggle].(note, bindData);
        };
    };
}, nil, nil, nil);  // nil chan & srcID for cross-platform compatibility

MIDIdef.cc(\lpMini_cc, { |val, cc, chan, src|
    if(val > 0) {
        // 1. Column Launch (Top Buttons 91..98)
        if(cc >= 91 and: { cc <= 98 }) {
            var col = cc - 90; 
            var noteList = (1..8).collect { |r| ((9-r)*10) + col };
            "Column Launch Col %".format(col).postln;
            ~lpMini[\launchList].(noteList);
        };
        
        // 2. Scene Launch (Right Buttons 89..19)
        // Fixed: Ensure row math results in Integer for lookup
        if( (cc % 10) == 9 and: { cc >= 19 and: { cc <= 89 } }) {
            var row = (9 - (cc / 10).floor).asInteger; // Cast to Integer
            if(row >= 1 and: { row <= 8 }) {
                var rowBase = (9 - row) * 10; 
                var noteList = (1..8).collect { |c| rowBase + c };
                "Scene Launch Row %".format(row).postln;
                ~lpMini[\launchList].(noteList);
            };
        };
    };
}, nil, nil, nil);  // nil chan & srcID for cross-platform compatibility

// --- RECOVERY ---
CmdPeriod.add({
    {
        if(~lpMini[\dst].notNil) {
             ~lpMini[\out] = MIDIOut.newByName(~lpMini[\dst].device, ~lpMini[\dst].name);
             ~lpMini[\out].latency = 0;
        };
        ~lpMini[\setProgrammerMode].();
        if(~lpMini[\watcher].isPlaying.not) { ~lpMini[\watcher].reset.play(AppClock) };
        "LP Mini Refreshed".postln;
    }.defer(0.5);
});

"--- Launchpad Mini MK3 Universal Launcher Loaded (v14) ---".postln;
)
// -----------------------------------------------------------------------------
// EXAMPLES
// -----------------------------------------------------------------------------

// // 1. Create some patterns
// Pdef(\beat, Pbind(\degree, Pseq([0, 2, 4], inf), \dur, 0.25));
// Pdef(\beat2, Pbind(\degree, Pseq([0, 2, 4], inf), \dur, 0.125));
// Ndef(\drone, { SinOsc.ar([100, 102], 0, 0.1) });
//
// // 2. Bind them
// // Bottom-left pad (Row 1, Col 1) -> Pdef(\beat)
// ~lpBind.([1, 1], \beat, 45);
//
// // Row 1, Col 2 -> Ndef(\drone)
// ~lpBind.([1, 2], \beat2);
// ~lpBind.([1, 3], \drone,  81);
//
// // 3. Play manually to see LED update
// Pdef(\beat).play;
// Pdef(\beat).stop;
// Pdef(\kick, Pbind(\degree, 0)); // Create a dummy pattern
// ~lpBind.([1, 1], \kick);        // Should light up RED (stopped)
// Pdef(\kick).play;
// Pdef(\kick).stop;
// Ndef(\drone).play;
// Ndef(\drone).stop;
// ~lpMini[\clearGrid].();
