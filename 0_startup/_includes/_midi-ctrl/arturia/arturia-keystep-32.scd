(
// arturia-keystep-32.scd
// Helper to map Arturia KeyStep 32 noteOn/noteOff to any SynthDef.
// Handles polyphonic voice tracking and cleanup.
//
// Usage:
//   ~ks32Play.(\bass8, out: ~busOf.(~t3));
//   ~ks32Play.(\ks_string, out: ~busOf.(~t4), args: [\delayTime, 0.3]);
//   ~ks32Stop.();   // release all notes + free MIDIdefs
//   ~ks32Swap.(\cello);  // stop current, switch to new synth
//
// Supports any SynthDef with: freq, amp, gate, out

var srcs, ksEp, ksIdx, ksSrcUid;

MIDIClient.init;
srcs = MIDIClient.sources;

ksIdx = srcs.detectIndex { |ep|
    ep.device.containsi("KeyStep 32") or: { ep.name.containsi("KeyStep 32") }
};

if(ksIdx.isNil) {
    "[KeyStep 32] Not detected — skipping".postln;
} {
    ksEp = srcs[ksIdx];
    ksSrcUid = ksEp.uid;

    // Linux: connect the MIDI input
    if(Platform.case(\linux, { true }, { false })) {
        MIDIIn.connect(ksIdx);
    };

    ("[KeyStep 32] Connected: " ++ ksEp.device ++ " / " ++ ksEp.name
        ++ " (uid " ++ ksSrcUid ++ ")").postln;

    // Voice tracking: 128 slots, one per MIDI note
    ~ks32Voices = Array.newClear(128);
    ~ks32Synth = nil;
    ~ks32Out = 0;
    ~ks32Args = [];
    ~ks32Chan = nil;  // nil = any channel

    ~ks32Play = { |synthName, out=0, chan=nil, args=#[]|
        // Stop previous if active
        if(~ks32Synth.notNil) { ~ks32Stop.() };

        ~ks32Synth = synthName;
        ~ks32Out = out;
        ~ks32Args = args;
        ~ks32Chan = chan;

        MIDIdef.noteOn(\ks32_on, { |vel, num, ch, src|
            var synth;
            // Release existing voice on same note (retrigger)
            ~ks32Voices[num] !? { |s| s.set(\gate, 0) };
            synth = Synth(~ks32Synth,
                [\freq, num.midicps, \amp, vel / 127, \gate, 1,
                 \out, ~ks32Out, \pan, 0] ++ ~ks32Args
            );
            ~ks32Voices[num] = synth;
        }, nil, ~ks32Chan, ksSrcUid).permanent_(true);

        MIDIdef.noteOff(\ks32_off, { |vel, num, ch, src|
            ~ks32Voices[num] !? { |s|
                s.set(\gate, 0);
                ~ks32Voices[num] = nil;
            };
        }, nil, ~ks32Chan, ksSrcUid).permanent_(true);

        ("[KeyStep 32] Playing: \\" ++ synthName ++ " → out " ++ out).postln;
    };

    ~ks32Stop = {
        MIDIdef(\ks32_on).free;
        MIDIdef(\ks32_off).free;
        ~ks32Voices.do { |s| s !? { s.set(\gate, 0) } };
        ~ks32Voices = Array.newClear(128);
        if(~ks32Synth.notNil) {
            ("[KeyStep 32] Stopped: \\" ++ ~ks32Synth).postln;
        };
        ~ks32Synth = nil;
    };

    ~ks32Swap = { |synthName, out, args|
        ~ks32Stop.();
        ~ks32Play.(synthName,
            out: out ? ~ks32Out,
            chan: ~ks32Chan,
            args: args ? ~ks32Args
        );
    };
};
)
