// midi-in-play.scd
// General-purpose "any incoming MIDI drives a synth" router — PER-CHANNEL,
// so e.g. Deluge track 1 -> one SC voice, track 2 -> a different SC voice,
// all live simultaneously. Not filtered by device (srcID) by default.
//
// NOT loaded by default. Load manually:
//   "_includes/midi-in-play.scd".loadRelative;
//
// DELIBERATE TRADEOFF, not an oversight: unlike every other MIDIdef in this
// codebase (which filters by srcID specifically so IAC/DAW loopback traffic
// can't trigger controller bindings — see midi-setup.scd's header comment),
// this file does NOT filter by srcID by default. Any connected source can
// drive it. If you need to scope this to one device (e.g. only the Deluge,
// not a norns/Zynthian DIN-MIDI passthrough sharing the same channel
// numbers), set ~midiInSrcID to that device's uid before mapping any
// channels — see "SCOPING TO ONE DEVICE" below.
//
// CHANNEL NUMBERING: this API takes 1-16 (matching what you read on the
// Deluge/hardware), NOT SC's native 0-15 MIDIdef convention — the conversion
// happens internally. Don't pass 0.
//
// Globals: ~midiInMap, ~midiInUnmap, ~midiInStopAll, ~midiInVoices, ~midiInCC,
//          ~midiInPset, ~midiInPsetStop
//
// Usage:
//   ~midiInMap.(1, \bass8,     out: Ndef(\ins3).index);
//   ~midiInMap.(2, \ks_string, out: Ndef(\ins4).index, args: [\delayTime, 0.3]);
//   ~midiInUnmap.(2);              // stop just that channel
//   ~midiInStopAll.();             // release everything + free MIDIdefs
//
// CC: any incoming CC N on a MAPPED channel automatically becomes a live
// .set() of \ccN on every currently-sounding voice on THAT channel only
// (channels don't leak CC into each other). No mapping table needed — a
// SynthDef just opts in by declaring an arg with that name:
//   SynthDef(\bass8, { |out=0, amp=0.1, gate=1, pan=0, freq=200, cc1=0, cc74=0|
//       ... use cc1/cc74 like any other control ...
//   }).add;
// ~midiInCC keeps the latest 0-1 value of every CC# per channel, so a freshly
// triggered voice can read current knob state even if it wasn't sounding
// when the CC last moved: ~midiInCC[chan-1][ccNum]
//
// PATTERN CONTROL: these voices are raw Synths, not NodeProxy sources, so
// Ndef's `\pset ->` role can't reach them (it only broadcasts across indices
// of ITS OWN proxy's nodeMap). ~midiInPset is the equivalent for this file —
// same "loop over currently-sounding voices and .set()" mechanism as the CC
// handler above, just driven by a pattern instead of incoming CC:
//   ~midiInPset.(3, [\stretch, \time], Pbind(
//       \stretch, Pseg([1, 4], [32], \sin, inf),
//       \time,    Pseq((4..1), inf),
//       \dur,     1/32
//   ));
//   ~midiInPsetStop.(3);   // stop just that channel's pattern control(s)
// `keys` must be listed explicitly — Pbind's stream fills in the rest of
// Event.default (\freq, \amp, \instrument, ...) on every step regardless of
// what you actually wrote in the Pbind, so there's no way to infer "only the
// keys this Pbind sets" from the event alone.

(
~midiInChanMap = Array.newClear(16);                       // [0..15] -> (synth:, out:, args:) or nil
~midiInVoices  = Array.fill(16, { Array.newClear(128) });  // [chan][note] -> Synth
~midiInCC      = Array.fill(16, { Array.fill(128, 0.0) }); // [chan][ccNum] -> normalized 0-1
~midiInSrcID   = nil;   // nil = any device. Set before mapping to scope to one source.
~midiInInited  = false;
~midiInPsetTasks = Array.fill(16, { [] });  // [chan] -> array of running Routines

// ---- SCOPING TO ONE DEVICE ----
// ~midiInSrcID = MIDIClient.sources.detect { |ep| ep.device.containsi("Deluge") }.uid;
// Set this BEFORE your first ~midiInMap call — the MIDIdefs are registered
// once, on first use, using whatever ~midiInSrcID is at that time.

~midiInInit = {
    if(~midiInInited.not) {
        MIDIdef.noteOn(\midiIn_on, { |vel, num, ch, src|
            var map = ~midiInChanMap[ch];
            if(map.notNil) {
                var synth;
                ~midiInVoices[ch][num] !? { |s| s.set(\gate, 0) };
                synth = Synth(map[\synth],
                    [\freq, num.midicps, \amp, vel / 127, \gate, 1,
                     \out, map[\out], \pan, 0] ++ map[\args]
                );
                ~midiInVoices[ch][num] = synth;
            };
        }, nil, nil, ~midiInSrcID).permanent_(true);

        MIDIdef.noteOff(\midiIn_off, { |vel, num, ch, src|
            ~midiInVoices[ch][num] !? { |s|
                s.set(\gate, 0);
                ~midiInVoices[ch][num] = nil;
            };
        }, nil, nil, ~midiInSrcID).permanent_(true);

        MIDIdef.cc(\midiIn_cc, { |val, num, ch, src|
            var norm = val / 127;
            ~midiInCC[ch][num] = norm;
            ~midiInVoices[ch].do { |s| s !? { s.set(("cc" ++ num).asSymbol, norm) } };
        }, nil, nil, ~midiInSrcID).permanent_(true);

        ~midiInInited = true;
        ("[midiInPlay] MIDIdefs active (srcID: " ++ (~midiInSrcID ? "any") ++ ")").postln;
    };
};

~midiInMap = { |chan1based, synthName, out=0, args=#[]|
    var ch = chan1based - 1;   // -> SC's 0-15
    ~midiInInit.();
    // release any voices currently active on this channel before remapping
    ~midiInVoices[ch].do { |s| s !? { s.set(\gate, 0) } };
    ~midiInVoices[ch] = Array.newClear(128);
    ~midiInChanMap[ch] = (synth: synthName, out: out, args: args);
    ("[midiInPlay] chan " ++ chan1based ++ " -> \\" ++ synthName ++ " (out " ++ out ++ ")").postln;
};

~midiInUnmap = { |chan1based|
    var ch = chan1based - 1;
    ~midiInPsetStop.(chan1based);
    ~midiInVoices[ch].do { |s| s !? { s.set(\gate, 0) } };
    ~midiInVoices[ch] = Array.newClear(128);
    ~midiInChanMap[ch] = nil;
    ("[midiInPlay] chan " ++ chan1based ++ " unmapped").postln;
};

~midiInStopAll = {
    MIDIdef(\midiIn_on).free;
    MIDIdef(\midiIn_off).free;
    MIDIdef(\midiIn_cc).free;
    ~midiInPsetTasks.do { |tasks| tasks.do(_.stop) };
    ~midiInPsetTasks = Array.fill(16, { [] });
    ~midiInVoices.do { |chanVoices| chanVoices.do { |s| s !? { s.set(\gate, 0) } } };
    ~midiInVoices  = Array.fill(16, { Array.newClear(128) });
    ~midiInChanMap = Array.newClear(16);
    ~midiInInited  = false;
    "[midiInPlay] stopped, all channels unmapped".postln;
};

// ---- PATTERN-DRIVEN CONTROLS (~midiInPset) ----
// Broadcasts pattern-driven values as live .set() calls onto every
// currently-sounding voice on a channel. See header comment for usage.
~midiInPset = { |chan1based, keys, pattern|
    var ch = chan1based - 1;
    var task = Routine {
        var stream = pattern.asStream;
        var ev = stream.next(Event.default);
        while { ev.notNil } {
            ~midiInVoices[ch].do { |s| s !? { keys.do { |k| s.set(k, ev[k]) } } };
            ev[\dur].wait;
            ev = stream.next(Event.default);
        };
    }.play(~link);
    ~midiInPsetTasks[ch] = ~midiInPsetTasks[ch].add(task);
    task;
};

~midiInPsetStop = { |chan1based|
    var ch = chan1based - 1;
    ~midiInPsetTasks[ch].do(_.stop);
    ~midiInPsetTasks[ch] = [];
};
)
