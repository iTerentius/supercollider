// 2025-09-19 18:45 America-Chicago  mixer36 test  smooth fx + predictable state
// note  declare vars at top of functions  wrapped in ( ) for eval  no ) in comments

(
// ---------- core helpers  reset  levels  inspect ----------
var ensureTapDict;

// print quick bus map for track i and return j
~m36_busMap = { |ti=0, si=0|
    var tr, fx, ma;
    tr = ~m36_tracks.wrapAt(ti);
    fx = ~m36_fxchans.wrapAt(si);
    ma = ~m36_master;
    ["tr", ti, "in", tr.inbus.index, "out", tr.outbus.index,
     "fx", si, "in", fx.inbus.index, "out", fx.outbus.index,
     "master in", ma.inbus.index, "master out", ma.outbus.index].postln;
};

// set comfortable levels so sends are audible
~m36_safeLevels = {
    var tr, fx, ma;
    tr = ~m36_tracks[0];
    fx = ~m36_fxchans[0];
    ma = ~m36_master;
    tr.level_(0.6);
    fx.level_(1.0);
    ma.level_(0.9);
    ["levels  tr", tr.level, "fx", fx.level, "master", ma.level].postln;
};

// zero all post sends and clear all return effectgroups (+ master FX if any)
~m36_allReset = {
    var i, tr, fx;
    if(~m36_sends.notNil) {
        ~m36_sends.do({ |row| row.do({ |s| s.level_(0) }) });
    };
    ~m36_fxchans.do({ |r| if(r.notNil and: { r.effectgroup.notNil }) { r.effectgroup.freeAll } });
    if(~m36_master.notNil and: { ~m36_master.effectgroup.notNil }) { ~m36_master.effectgroup.freeAll };
    if(~m36_taps.notNil) { ~m36_taps.values.do({ |syn| syn.tryPerform(\free) }); ~m36_taps = IdentityDictionary.new };
    "sends zeroed  all return FX cleared  taps cleared".postln;
};

// show only non-zero sends
~m36_showNonZeroSends = {
    var rows;
    rows = ~m36_sends.collect({ |row, ti|
        var nz;
        nz = row.collect({ |s, si| [si, s.level] }).select({ |p| p[1] > 0.0001 });
        [ti, nz]
    });
    rows.postln;
};
)

(
// ---------- smooth FX installers on a return (ddw-correct read/write) ----------

// smooth tremolo (no clicks): SinOsc.kr as modulator
~m36_fxInstallTremSmooth = { |sendIndex=0, rate=3, depth=0.8|
    var ch;
    ch = ~m36_fxchans.wrapAt(sendIndex);
    if(ch.isNil) { "no such return".postln; ^nil };
    ch.effectgroup.freeAll;
    ch.play({ |i_out|
        var src, mod, wet;
        src = In.ar(ch.inbus.index, 2);
        mod = (1 - depth) + depth * ((SinOsc.kr(rate) * 0.5) + 0.5); // smooth 0..1
        wet = src * mod;
        ReplaceOut.ar(i_out, wet);
    });
    "tremolo installed on return ".post; sendIndex.postln;
};

// ping-pong delay with crossfeed  clear repeats
~m36_fxInstallPingPong = { |sendIndex=0, dt=0.33, fb=0.5|
    var ch;
    ch = ~m36_fxchans.wrapAt(sendIndex);
    if(ch.isNil) { "no such return".postln; ^nil };
    ch.effectgroup.freeAll;
    ch.play({ |i_out|
        var src, l, r, mx;
        src = In.ar(ch.inbus.index, 2);
        mx  = 1.0;
        l = DelayC.ar(src[0] + (DelayC.ar(src[1], mx, dt) * fb), mx, dt);
        r = DelayC.ar(src[1] + (DelayC.ar(src[0], mx, dt) * fb), mx, dt);
        ReplaceOut.ar(i_out, [l, r]);
    });
    "pingpong installed on return ".post; sendIndex.postln;
};

// quick kill for one return  frees effectgroup and zeros all tracks' sends to it
~m36_fxKill = { |sendIndex=0|
    var si;
    si = sendIndex.asInteger;
    ~m36_fxchans.wrapAt(si).effectgroup.freeAll;
    if(~m36_sends.notNil) {
        ~m36_sends.do({ |row| row.wrapAt(si).level_(0) });
    };
    "return ".post; si.post; " killed and sends to it zeroed".postln;
};
)

(
// ---------- optional direct tap if you want to bypass post-sends temporarily ----------

var ensureTapDict;

SynthDef(\m36_tapIn2Fx, { |srcbus=0, dstbus=0, level=0.6|
    var sig;
    sig = In.ar(srcbus, 2) * level;
    Out.ar(dstbus, sig);
}).add;

ensureTapDict = { if(~m36_taps.isNil) { ~m36_taps = IdentityDictionary.new } };

// make or replace a tap  trackIndex -> sendIndex  installed at head of the return group
~m36_tapMake = { |trackIndex=0, sendIndex=0, level=0.6|
    var tr, fx, key, syn;
    ensureTapDict.();
    tr = ~m36_tracks.wrapAt(trackIndex);
    fx = ~m36_fxchans.wrapAt(sendIndex);
    if(tr.isNil or: { fx.isNil }) { "tap make  bad index".postln; ^nil };
    key = [trackIndex, sendIndex];
    ~m36_taps.removeAt(key).tryPerform(\free);
    syn = Synth(\m36_tapIn2Fx, [\srcbus, tr.inbus.index, \dstbus, fx.inbus.index, \level, level], target: fx.effectgroup, addAction:\addToHead);
    ~m36_taps.put(key, syn);
    "tap made  tr ".post; trackIndex.post; " -> fx ".post; sendIndex.post; "  level ".post; level.postln;
    syn
};

~m36_tapFree = { |trackIndex=0, sendIndex=0|
    var key;
    ensureTapDict.();
    key = [trackIndex, sendIndex];
    ~m36_taps.removeAt(key).tryPerform(\free);
    "tap freed  tr ".post; trackIndex.post; " -> fx ".postln; sendIndex;
};
)

(
// ---------- simple instrument and pattern ----------
SynthDef(\mcTone, { |out=0, freq=220, amp=0.18, pan=0, sustain=0.18|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.005, sustain), doneAction:2);
    sig = SinOsc.ar(freq) * amp * env;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

Pdef(\mc_ex1, Pbind(
    \instrument, \mcTone,
    \dur, 0.25,
    \legato, 0.9,
    \degree, Pseq([0, 2, 4, 7].mirror1, inf),
    \octave, 4,
    \amp, 0.15,
    \pan, 0,
    \out, ~m36_in.(0)         // into track 1 (zero-based)
));
)

// ---------- recommended sequence to test ----------

// 0  reset and set levels
( ~m36_allReset.(); ~m36_safeLevels.(); ~m36_busMap.(0, 0); )

// 1  start source
( Pdef(\mc_ex1).play; )

// 2  install an FX on return 1 (zero-based 0). pick ONE of these:

// smooth tremolo (no clicks)
// ( ~m36_fxInstallTremSmooth.(0, 3, 0.85); )

// or ping-pong delay
// ( ~m36_fxInstallPingPong.(0, 0.33, 0.55); )

// 3  connect track 1 to return 1. pick ONE routing:

// A  normal post-send path
// ( ~m36_setSend.(0, 0, 0.5); ~m36_showNonZeroSends.(); )

// B  explicit tap path (ignores track fader, purely for testing)
// ( ~m36_tapMake.(0, 0, 0.7); )

// ---------- swapping / stopping ----------

// swap FX while running (example: switch to tremolo)
// ( ~m36_fxInstallTremSmooth.(0, 2.5, 0.9); )

// kill the return and zero its sends
// ( ~m36_fxKill.(0); )

// full stop and clean
// ( Pdef(\mc_ex1).stop; ~m36_allReset.(); )
// 1) start the simple test pattern into mixer track 1
(
SynthDef(\mcTone, { |out=0, freq=220, amp=0.18, pan=0, sustain=0.18|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.005, sustain), doneAction:2);
    sig = SinOsc.ar(freq) * amp * env;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

Pdef(\mc_ex1, Pbind(
    \instrument, \mcTone, \dur, 0.25, \legato, 0.9,
    \degree, Pseq([0,2,4,7].mirror1, inf), \octave, 4,
    \amp, 0.15, \pan, 0, \out, ~m36_in.(8)  // track 1
)).play;
)
Pdef(\mc_ex1).stop;
// 2025-09-20 America/Chicago
currentEnvironment.at(\ccBindFuncAdd).postln;    // should print a Function
currentEnvironment.at(\ccBindFuncRm).postln;     // should print a Function
~ccBindFuncAdd.(\__probe, { |x| ("probe got:" + x).postln });  // should not error

~m36_master.level_(0.9)

Pbind(\instrument, \syn1, \dur, 0.25, \degree, Pseq([0,2,4,7].mirror1, inf), \octave, 4, \amp, 0.15, \pan, 0, \out, ~m36_in.(0)).play;
// show current LCXL MIDI chan, bank, and how many keys are mapped
~lcxl_config[\midiChan].postln;         // expect 9
~setBank.(0);                           // bank 0
~printMapAll.();                        // should include b0_f1..b0_f8 and b0_t*_r3 keys

// 2) set safe fader levels
(
var tr, fx, ma;
tr = ~m36_tracks[0]; fx = ~m36_fxchans[0]; ma = ~m36_master;
tr.level_(0.6); fx.level_(1.0); ma.level_(0.9);
)

// 3) install ONE return FX and feed it with a post send

// a) smooth tremolo (no clicks)
( ~m36_fxInstallTremSmooth.(0, 3, 0.85); )

// or b) ping-pong delay
( ~m36_fxInstallPingPong.(0, 0.33, 0.55); )

// feed track 1 → return 1 at 50 percent
( ~m36_setSend.(0, 0, 0.5); )

// swap to a FreeVerb on the same return (obvious reverb)
(
~m36_fxSwap.(0, { |i_out|
    var ch, src, mix=0.3, room=0.8, damp=0.3, wet;
    ch = ~m36_fxchans[0];
    src = In.ar(ch.inbus.index, 2);
    wet = FreeVerb.ar(src, mix, room, damp);
    ReplaceOut.ar(i_out, wet);
});
)

// swap to a FreeVerb on the same return (obvious reverb)
(
~m36_fxSwap.(0, { |i_out|
    var ch, src, mix=0.3, room=0.8, damp=0.3, wet;
    ch = ~m36_fxchans[0];
    src = In.ar(ch.inbus.index, 2);
    wet = FreeVerb.ar(src, mix, room, damp);
    ReplaceOut.ar(i_out, wet);
});
)

// kill only that return and zero all sends to it
( ~m36_fxKill.(0); )

// full stop and reset everything (sends, returns, taps)
(
Pdef(\mc_ex1).stop;
~m36_allReset.();
)
// 2025-09-19 19:25 America/Chicago  force-clean and set levels
(
var si, tr, fx, ma;
si = 0;                             // return index 0
tr = ~m36_tracks[0];
fx = ~m36_fxchans[si];
ma = ~m36_master;

// stop pattern if you want, then restart later
// Pdef(\mc_ex1).stop;

~m36_sends.do({ |row| row.wrapAt(si).level_(0) });  // zero all sends to that return

// clear returns + master FX
~m36_fxchans.do({ |r| if(r.notNil and: { r.effectgroup.notNil }) { r.effectgroup.freeAll } });
if(ma.notNil and: { ma.effectgroup.notNil }) { ma.effectgroup.freeAll };

// clear any test taps
if(~m36_taps.notNil) { ~m36_taps.values.do({ |syn| syn.tryPerform(\free) }); ~m36_taps = IdentityDictionary.new };

// healthy faders
tr.level_(0.6);
fx.level_(1.0);
ma.level_(0.9);

["clean done  tr0 in", tr.inbus.index, "tr0 out", tr.outbus.index,
 "fx0 in", fx.inbus.index, "fx0 out", fx.outbus.index].postln;
)
// 2025-09-19 19:25  install wet-only-ish reverb on return 1 and feed from track 1
(
var si, fx, mix, room, damp;
si = 0; fx = ~m36_fxchans[si];

fx.effectgroup.freeAll;          // nothing else can linger
mix = 0.95; room = 0.90; damp = 0.30;

fx.play({ |i_out|
    var src, wet;
    src = In.ar(fx.inbus.index, 2);                 // read return input
    wet = FreeVerb.ar(src, mix, room, damp);        // almost fully wet
    ReplaceOut.ar(i_out, wet);                      // write to return output
});

// feed track 1 → return 1
~m36_setSend.(0, si, 0.6);

// make sure source is running
Pdef(\mc_ex1).play;

"reverb forced on return 1  send set 0.6".postln;
)
// 2025-09-19 19:25  swap to pingpong
(
var si, fx, dt, fb, mx;
si = 0; fx = ~m36_fxchans[si];
dt = 0.33; fb = 0.55; mx = 1.0;
fx.effectgroup.freeAll;
fx.play({ |i_out|
    var src, l, r;
    src = In.ar(fx.inbus.index, 2);
    l   = DelayC.ar(src[0] + (DelayC.ar(src[1], mx, dt) * fb), mx, dt);
    r   = DelayC.ar(src[1] + (DelayC.ar(src[0], mx, dt) * fb), mx, dt);
    ReplaceOut.ar(i_out, [l, r]);
});
"pingpong active".postln;
)

// swap back to reverb
(
var si, fx, mix, room, damp;
si = 0; fx = ~m36_fxchans[si];
fx.effectgroup.freeAll;
mix = 0.95; room = 0.90; damp = 0.30;
fx.play({ |i_out|
    var src, wet;
    src = In.ar(fx.inbus.index, 2);
    wet = FreeVerb.ar(src, mix, room, damp);
    ReplaceOut.ar(i_out, wet);
});
"reverb active".postln;
)
(
// --- clean any prior test defs ---
MIDIdef.free(\cc_chan_probe);
MIDIdef.free(\cc_match_probe);

// --- pretend "learned" entry from your printout ---
~learned = (
    name: \b1_f2,       // just a label
    cc: 78,             // from your table
    chan1: 9            // 1-based channel stored by "learn"
);

// --- probe: print both 0-based and 1-based views ---
MIDIdef.cc(\cc_chan_probe, { |val, cc, chan, src|
    var chan0 = chan;           // what SC reports (0-based)
    var chan1 = chan + 1;       // normalized 1-based
    var matches0 = (cc == ~learned.cc) and: { chan0 == (~learned.chan1 - 1) };
    var matches1 = (cc == ~learned.cc) and: { chan1 ==  ~learned.chan1 };

    // plain visibility
    ("[probe] cc:% cc:"+cc+"  val:%".format(cc, val)).postln;
    ("         raw chan0:%   normalized chan1:%".format(chan0, chan1)).postln;

    // quick truth table against your learned entry

    ("         matches0 (0-based compare): %".format(matches0)).postln;
    ("         matches1 (1-based compare): %".format(matches1)).postln;
});

// --- optional: fire only when we match the learned entry ---
MIDIdef.cc(\cc_match_probe, { |val, cc, chan|
    "[MATCH] cc/chan matched learned map -> do your action here".postln;
}, ccNum: ~learned.cc, chan: (~learned.chan1 - 1) /* note: 0-based here */);

"[cc channel test armed] Move LCXL Fader 2 (cc 78)".postln;
)
(
// ======== MINI AUTOBIND: LCXL → MIXER (LEVEL & PAN) ========
// Assumptions you can edit inline:
//   1) Your learned CC map uses 1-based channels and keys like b1_f1 / b1_t1_r2.
//   2) Your mixer has per-track setters: ~m36_setLevel.(trackIndex, level) and ~m36_setPan.(trackIndex, pan).
//      If you use different calls, replace the two lambdas below.
// -----------------------------------------------------------

// --- cleanup previous test binds ---
MIDIdef.free(\lcxl_mix_level);
MIDIdef.free(\lcxl_mix_pan);

// --- define how to set your mixer (EDIT THESE TWO IF NEEDED) ---
~setLevel = { |track, x|  // x in 0..1
    // EXAMPLE A: if you expose helper funcs
    if(~m36_setLevel.notNil) {
        ~m36_setLevel.(track, x);
    }{
        // EXAMPLE B: if you address MixerChannel objects directly
        // (uncomment and adapt your object names)
        // ~m36_tracks[track].set(\level, x);
    };
    ("[mixer] tr% level -> %".format(track, x.round(0.001))).postln;
};

~setPan = { |track, x| // x in -1..1
    if(~m36_setPan.notNil) {
        ~m36_setPan.(track, x);
    }{
        // ~m36_tracks[track].set(\pan, x);
    };
    ("[mixer] tr% pan -> %".format(track, x.round(0.001))).postln;
};

// --- pull the bits we need from your learned table (replace if you store it elsewhere) ---
~lcxlLearn = IdentityDictionary.new;

// Minimal map for Bank 1 (use your printed values)
~lcxlLearn[\b1] = (
    chan1: 9,               // 1-based channel (your learn uses 9)
    f: [77,78,79,80,81,82,83,84],            // fader CCs tr1..tr8
    r2: [29,30,31,32,33,34,35,36]            // row-2 knob CCs (pan) tr1..tr8
);

// --- scaling helpers ---
~to01 = { |val| val / 127 };                         // 0..1
~toPan = { |val| (val / 127) * 2 - 1 };              // -1..1

// --- bind LEVELS for Bank 1 ---
{
    var bank = \b1;
    var cfg = ~lcxlLearn[bank];
    var chan0 = cfg[\chan1] - 1;  // MIDIdef expects 0-based
    cfg[\f].do { |cc, i|
        var track = i + 1; // 1..8
        MIDIdef.cc(
            (\lcxl_mix_level ++ bank ++ track).asSymbol,
            { |val, ccNum, chan|
                if(chan == chan0) { ~setLevel.(track, ~to01.(val)) };
            },
            ccNum: cc,
            chan: chan0
        );
    };
}.value;

// --- bind PAN for Bank 1 (row-2 knobs) ---
{
    var bank = \b1;
    var cfg = ~lcxlLearn[bank];
    var chan0 = cfg[\chan1] - 1;
    cfg[\r2].do { |cc, i|
        var track = i + 1; // 1..8
        MIDIdef.cc(
            (\lcxl_mix_pan ++ bank ++ track).asSymbol,
            { |val, ccNum, chan|
                if(chan == chan0) { ~setPan.(track, ~toPan.(val)) };
            },
            ccNum: cc,
            chan: chan0
        );
    };
}.value;

"[lcxl→mixer autobind test ready | bank 1 | chan 9 learned / chan 8 incoming]".postln;

// ===========================================================
)
(
// ------------------------------------------------------------
// LCXL → Mixer (levels + pan) — minimal, syntax-safe drop-in
//  - Banks: b1 & b2 (switch with CC106/107)
//  - Channel: learned 1-based (9) → incoming 0-based (8)
//  - Faders: 77..84  → level (0..1)
//  - Row-2:  29..36  → pan  (-1..1)
//  - Edit ~setLevel / ~setPan to call your mixer
// ------------------------------------------------------------

// Clean bank switchers from prior runs (others will overwrite by name)
MIDIdef.free(\lcxl_bank_left);
MIDIdef.free(\lcxl_bank_right);

// ---- State (Event) ----
~lcxlState = (
    bank: \b1, // start on Bank 1
    learn: (
        b1: (chan1: 9,  f: [77,78,79,80,81,82,83,84],  r2: [29,30,31,32,33,34,35,36]),
        b2: (chan1: 9,  f: [77,78,79,80,81,82,83,84],  r2: [29,30,31,32,33,34,35,36])
    )
);

// ---- Helpers ----
~to01  = { |val| val / 127 };
~toPan = { |val| (val / 127) * 2 - 1 };

~setLevel = { |track, x|
    if(~m36_setLevel.notNil) {
        ~m36_setLevel.(track, x);
    }{
        ("[mixer] tr% level -> %".format(track, x.round(0.001))).postln;
    };
};

~setPan = { |track, x|
    if(~m36_setPan.notNil) {
        ~m36_setPan.(track, x);
    }{
        ("[mixer] tr% pan -> %".format(track, x.round(0.001))).postln;
    };
};

~showBank = {
    var msg = "=== LCXL BANK: % ===".format(~lcxlState[\bank].asString.toUpper);
    "\n".postln; msg.postln; "".postln;
};

// ---- Bank buttons (Device left/right) ----
MIDIdef.cc(\lcxl_bank_left, { |val, cc, chan|
    if(val > 0) { ~lcxlState[\bank] = \b1; ~showBank.() };
}, 106); // CC 106 = left

MIDIdef.cc(\lcxl_bank_right, { |val, cc, chan|
    if(val > 0) { ~lcxlState[\bank] = \b2; ~showBank.() };
}, 107); // CC 107 = right

// ---- Bind both banks; gate by active bank at runtime ----
[ \b1, \b2 ].do { |bank|
    var cfg = ~lcxlState[\learn][bank];
    var chan0 = cfg[\chan1] - 1; // SC MIDIdef uses 0-based

    // Faders → Level
    cfg[\f].do { |ccNum, i|
        var track = i + 1;
        var defName = ("lcxl_" ++ bank.asString ++ "_f" ++ track).asSymbol;
        MIDIdef.cc(defName, { |val, cc, chan|
            if( (chan == chan0) and: { ~lcxlState[\bank] == bank } ) {
                ~setLevel.(track, ~to01.(val));
            };
        }, ccNum, chan0);
    };

    // Row-2 knobs → Pan
    cfg[\r2].do { |ccNum, i|
        var track = i + 1;
        var defName = ("lcxl_" ++ bank.asString ++ "_r2_" ++ track).asSymbol;
        MIDIdef.cc(defName, { |val, cc, chan|
            if( (chan == chan0) and: { ~lcxlState[\bank] == bank } ) {
                ~setPan.(track, ~toPan.(val));
            };
        }, ccNum, chan0);
    };
};

"[lcxl→mixer] armed. Active bank -> ".post; ~lcxlState[\bank].postln;
)
(
// ============================================================
// LCXL binder → audible test rig (8 tracks via Ndef)
// - Safe: only defines ~m36_setLevel/~m36_setPan if they don't exist
// - Each track is a quiet tone with unique frequency
// - Start/stop helpers: ~soundTestStart.() / ~soundTestStop.()
// ============================================================

var freqs, makeTrack, names;

// distinct freqs per track so your ear can tell them apart
freqs = [220, 246.94, 277.18, 293.66, 329.63, 369.99, 392.00, 440.00];
names = (1..8).collect { |i| ("test_tr" ++ i).asSymbol };

// synth body: gentle saw/tri blend
makeTrack = { |name, freq|
    Ndef(name, {
        var amp = \amp.kr(0);           // binder will set 0..1
        var pan = \pan.kr(0);           // binder will set -1..1
        var sig = (VarSaw.ar(freq, 0, 0.25) + LFTri.ar(freq*0.5)) * 0.15;
        // final gain is 'amp' (so fader really is level)
        Pan2.ar(sig, pan, amp);
    });
    Ndef(name).fadeTime = 0.1;
};

// build proxies with amp=0 to start silent
names.do { |nm, i| makeTrack.(nm, freqs[i]); };

// expose start/stop helpers
~soundTestStart = {
    names.do { |nm|
        Ndef(nm).set(\amp, 0, \pan, 0);  // start from silence, center pan
        Ndef(nm).play;
    };
    "▶︎ sound test started (8 tracks). Move LCXL faders/row-2 knobs.".postln;
};
~soundTestStop = {
    names.do { |nm| Ndef(nm).stop; };
    "■ sound test stopped.".postln;
};

// bind mixer-style setters only if not already defined
~m36_setLevel = ~m36_setLevel ? { |track, x|
    var nm = ("test_tr" ++ track).asSymbol;
    if(Ndef(nm).notNil) { Ndef(nm).set(\amp, x.clip(0,1)) };
};

~m36_setPan = ~m36_setPan ? { |track, p|
    var nm = ("test_tr" ++ track).asSymbol;
    if(Ndef(nm).notNil) { Ndef(nm).set(\pan, p.clip(-1,1)) };
};

"Ready: call ~soundTestStart.() then use the LCXL (banks b0/b1/b2).".postln;
)
~soundTestStart.();
