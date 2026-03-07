(
// lumi-m-piano.scd
// Helper to map Roli LUMI Keys BLOCK noteOn/noteOff to any SynthDef.
// Handles polyphonic voice tracking and cleanup.
//
// Usage:
//   ~lumiPlay.(\bass8, out: ~busOf.(~t3));
//   ~lumiPlay.(\ks_string, out: ~busOf.(~t4), args: [\delayTime, 0.3]);
//   ~lumiStop.();   // release all notes + free MIDIdefs
//   ~lumiSwap.(\cello);  // stop current, switch to new synth
//
// Supports any SynthDef with: freq, amp, gate, out

var srcs, lumiEp, lumiIdx, lumiSrcUid;

MIDIClient.init;
srcs = MIDIClient.sources;

lumiIdx = srcs.detectIndex { |ep|
    ep.device.containsi("LUMI Keys BLOCK") or: { ep.name.containsi("LUMI Keys BLOCK") }
};

if(lumiIdx.isNil) {
    "[LUMI] Not detected — skipping".postln;
} {
    lumiEp = srcs[lumiIdx];
    lumiSrcUid = lumiEp.uid;

    // Linux: connect the MIDI input
    if(Platform.case(\linux, { true }, { false })) {
        MIDIIn.connect(lumiIdx);
    };

    ("[LUMI] Connected: " ++ lumiEp.device ++ " / " ++ lumiEp.name
        ++ " (uid " ++ lumiSrcUid ++ ")").postln;

    // Voice tracking: 128 slots, one per MIDI note
    ~lumiVoices = Array.newClear(128);
    ~lumiSynth = nil;
    ~lumiOut = 0;
    ~lumiArgs = [];
    ~lumiChan = nil;  // nil = any channel

    ~lumiPlay = { |synthName, out=0, chan=nil, args=#[]|
        // Stop previous if active
        if(~lumiSynth.notNil) { ~lumiStop.() };

        ~lumiSynth = synthName;
        ~lumiOut = out;
        ~lumiArgs = args;
        ~lumiChan = chan;

        MIDIdef.noteOn(\lumi_on, { |vel, num, ch, src|
            var synth;
            // Release existing voice on same note (retrigger)
            ~lumiVoices[num] !? { |s| s.set(\gate, 0) };
            synth = Synth(~lumiSynth,
                [\freq, num.midicps, \amp, vel / 127, \gate, 1,
                 \out, ~lumiOut, \pan, 0] ++ ~lumiArgs
            );
            ~lumiVoices[num] = synth;
        }, nil, ~lumiChan, lumiSrcUid).permanent_(true);

        MIDIdef.noteOff(\lumi_off, { |vel, num, ch, src|
            ~lumiVoices[num] !? { |s|
                s.set(\gate, 0);
                ~lumiVoices[num] = nil;
            };
        }, nil, ~lumiChan, lumiSrcUid).permanent_(true);

        ("[LUMI] Playing: \\" ++ synthName ++ " → out " ++ out).postln;
    };

    ~lumiStop = {
        MIDIdef(\lumi_on).free;
        MIDIdef(\lumi_off).free;
        ~lumiVoices.do { |s| s !? { s.set(\gate, 0) } };
        ~lumiVoices = Array.newClear(128);
        if(~lumiSynth.notNil) {
            ("[LUMI] Stopped: \\" ++ ~lumiSynth).postln;
        };
        ~lumiSynth = nil;
    };

    ~lumiSwap = { |synthName, out, args|
        ~lumiStop.();
        ~lumiPlay.(synthName,
            out: out ? ~lumiOut,
            chan: ~lumiChan,
            args: args ? ~lumiArgs
        );
    };
};
)
