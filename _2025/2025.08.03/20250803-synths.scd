(
SynthDef.new(\sineTest, {
	arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, offset, noise=0, ph=1, noiseHz=2;
	var sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) *amp;
	Out.ar(0, Pan2.ar(sig, pan, amp));
}).add
)

(
SynthDef.new(\simpSine, {
  arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, attack = 0.01, release = 1.0, offset = 0;
  var env, sig;
  env = EnvGen.kr(Env.circle([0.1, 0.25, 0.5], [0.15, 0.75]), 1);
  sig = Pulse.ar(freq + LFPulse.kr(2).exprange(freq, freq * env)) * env * amp;
  Out.ar(out, Pan2.ar(sig, pan, amp));
}).add
)

(
// 1) HARD MUTE — proves swapping instantly
SynthDef(\fx_mute_bus, { |inBus, outBus|
    var n = ~dirt.numChannels;
    In.ar(inBus, n);                   // read & ignore
    Out.ar(outBus, Silent.ar(n));      // pure silence
}).add;

// 2) CRUNCHY LOFI — brutal SR & bit-ish crush
SynthDef(\fx_crunch_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    var holdRate = 800;                      // lower = nastier
    var held = Latch.ar(sig, Impulse.ar(holdRate));
    var q = 12;                              // fewer steps = harsher
    var crushed = (held * q).round / q;
    Out.ar(outBus, crushed * 0.9);
}).add;

// 3) CHOP GATE — on/off at ~3 Hz
SynthDef(\fx_chop_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    var gate = LFPulse.kr(3, 0, 0.5).lag(0.01);
    Out.ar(outBus, sig * gate);
}).add;

// 4) PITCH UP OCTAVE — unmistakable
SynthDef(\fx_pitchUp_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    Out.ar(outBus, PitchShift.ar(sig, 0.2, 2.0, 0.0, 0.0));
}).add;

// 5) “TELEPHONE” BANDLIMIT — thin & nasally
SynthDef(\fx_phone_bus, { |inBus, outBus|
    var n = ~dirt.numChannels, sig = In.ar(inBus, n);
    sig = BHiPass.ar(sig, 500, 0.8);
    sig = BLowPass.ar(sig, 2500, 0.8);
    Out.ar(outBus, sig * 1.2);
}).add;
); s.sync;


// 1) Tell SuperDirt about a new effect module named \bitgrit
(
// Register a pattern-scoped module \bitgrit
~dirt.addModule(\bitgrit, { |ev|
    var e = ev.event;
    var grit = e[\grit];
    var rate = e[\rate];

    // Only spawn if one of our params is present
    if(grit.notNil or: { rate.notNil }) {
        var args = [
            \out, (e[\out] ? 0),                 // <-- use event dict
            \sustain, (e[\sustain] ? 1.0),       // <-- use event dict
            \grit, (grit ? 0.0),
            \rate, (rate ? 8000)
        ];
        ev.sendSynth("bitgrit" ++ (~dirt.numChannels ? 2), args);
    };
});
)

(
// Reorder modules so \bitgrit sits right after \sound
var names, i;

// Convert modules -> names (symbols)
names = ~dirt.modules.collect { |m|
    if(m.respondsTo(\name)) { m.name } { m }   // DirtModule('sound') -> \sound
};

// Ensure we don't duplicate \bitgrit
names = names.reject({ |k| k == \bitgrit });

// Find \sound and insert \bitgrit right after it (or append if \sound missing)
i = names.indexOf(\sound);
names = if(i.notNil) { names.insert(i + 1, \bitgrit) } { names.add(\bitgrit) };

// Apply new order
~dirt.orderModules(names);

// Sanity print
("Module order:\n" ++ names).postln;
)

// 2) Define the effect itself for all possible channel counts
// Build defs for the channel counts you actually use
(
// one SynthDef matching your active channel count
var n = (~dirt.numChannels ? 2);
SynthDef("bitgrit" ++ n, { |out=0, sustain=1, grit=0.0, rate=8000|
    var sig   = In.ar(out, n);
    var bits  = (1 + (grit.clip(0, 1) * 15)).round;    // 1..16 bits
    var crush = Decimator.ar(sig, rate.clip(100, 48000), bits);
    var mix   = XFade2.ar(sig, crush, (grit * 2) - 1); // -1 dry .. +1 wet
    var env   = EnvGen.kr(Env.asr(0, 1, 0), gate: 1, timeScale: sustain, doneAction: 2);
    ReplaceOut.ar(out, mix * env);
}).add;
)




// (optional) put your effect before/after others
// ~dirt.orderModules([\bitgrit, \shape, \crush, \delay, \reverb, \out]);


// Route orbit 0 through myCustomFX
~dirt.orbits[0].effect = \myFX;

~setAuxFx.(\fx_hall_bus,   [\roomBus, ~ctl[\auxroom], \dampBus, ~ctl[\auxdamp]]);
~setAuxFx.(\fx_chorus_bus, [\rateBus, ~ctl[\auxrate], \depthBus, ~ctl[\auxdepth]]);
~setAuxFx.(\fx_tape_bus,   [\timeBus, ~ctl[\auxtime], \fbBus,   ~ctl[\auxfb], \wowBus, ~ctl[\auxwow]]);

~setAuxFx.(\fx_crunch_bus);
~setAuxFx.(\fx_chop_bus);
~setAuxFx.(\fx_pitchUp_bus);
~setAuxFx.(\fx_phone_bus);
~setAuxFx.(\fx_mute_bus);    // should go completely silent

topEnvironment.use { ~setAuxFx.(\fx_chop_bus) };

~setAuxFx.(\fx_chorus_bus);   // should be obvious

~mixer.set(\xfade, 0);  // listen to slot A
~mixer.set(\xfade, 1);  // listen to slot B

~ctl[\auxret].set(0.8);


(
// capture orbit bus indexes at define time
~orbDryB = ~dirt.orbits.collect({ |o| o.dryBus }); // pre global FX
~orbOutB = ~dirt.orbits.collect({ |o| o.outBus }); // post global FX

// PRE-FX reader: reads o.dryBus
SynthDef(\orb_bitcrush, { |out=0, orb=0, sr=1200, bits=8, mix=1, amp=1, sustain=1|
    var b    = ~orbDryB;
    var pick = Select.kr(orb.clip(0, b.size-1), b);
    var n    = ~dirt.numChannels;
    var src  = InFeedback.ar(pick, n);

    // sample-rate reduce
    var held = Latch.ar(src, Impulse.ar(sr.max(20)));
    // bit-ish quantize (levels = 2^bits)
    var levels = (2 ** bits).clip(2, 2**24);
    var step   = (2.0 / levels);                   // −1..1 range
    var crushed= (held / step).round * step;

    var wet   = crushed;
    var env   = EnvGen.kr(Env.linen(0.001, sustain, 0.05), doneAction: 2);

    Out.ar(out, XFade2.ar(src, wet, (mix*2-1)) * amp * env);
}).add;

// POST-FX reader: reads o.outBus (after orbit global effects)
SynthDef(\orb_bitcrush_post, { |out=0, orb=0, sr=1200, bits=8, mix=1, amp=1, sustain=1|
    var b    = ~orbOutB;
    var pick = Select.kr(orb.clip(0, b.size-1), b);
    var n    = ~dirt.numChannels;
    var src  = InFeedback.ar(pick, n);

    var held = Latch.ar(src, Impulse.ar(sr.max(20)));
    var levels = (2 ** bits).clip(2, 2**24);
    var step   = (2.0 / levels);
    var crushed= (held / step).round * step;

    var wet   = crushed;
    var env   = EnvGen.kr(Env.linen(0.001, sustain, 0.05), doneAction: 2);

    Out.ar(out, XFade2.ar(src, wet, (mix*2-1)) * amp * env);
}).add;

s.sync;

// Register so Tidal can trigger them:
[\orb_bitcrush, \orb_bitcrush_post].do { |nm| ~dirt.soundLibrary.addSynth(nm) };
)
(
// capture orbit dry buses once (pre global FX)
~orbDryB = ~dirt.orbits.collect(_.dryBus);

// stereo ping-pong that reads an orbit's *dry* bus
SynthDef(\orb_pingpong, { |out=0, orb=0, n=0, time=0.25, fb=0.45, mix=1, amp=1, sustain=2|
    var b    = ~orbDryB ?? { ~dirt.orbits.collect(_.dryBus) };
    var idx  = (orb != 0).if({ orb }, { n }).clip(0, b.size-1);     // allow both # orb and :n
    var src  = InFeedback.ar(Select.kr(idx, b), ~dirt.numChannels); // read orbit audio
    var stereo = (src.size >= 2).if({ src }, { [src, src] });       // duplicate if mono

    // cross-feedback ping-pong (L feeds R, R feeds L)
    var li     = LocalIn.ar(2);
    var fbSafe = fb.clip(0, 0.95);
    var lIn    = stereo[0] + li[1] * fbSafe;
    var rIn    = stereo[1] + li[0] * fbSafe;
    var dl     = DelayC.ar(lIn, 2, time.clip(0.01, 1));
    var dr     = DelayC.ar(rIn, 2, (time * 1.5).clip(0.01, 1));
    
    var wet    = LeakDC.ar([dl, dr]);
    var outSig = XFade2.ar(stereo, wet, (mix * 2 - 1));             // 0=dry, 1=wet
    var env    = EnvGen.kr(Env.linen(0.001, sustain, 0.2), doneAction: 2);
    
    LocalOut.ar([dl, dr]);
    Out.ar(out, Limiter.ar(outSig * amp * env, 0.98));
}).add;

s.sync;
~dirt.soundLibrary.addSynth(\orb_pingpong); // makes s "orb_pingpong" available
)
