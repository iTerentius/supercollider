// =============================================================================
// MIXER CHANNELS  (_includes/mixer-channel-16s.scd)
// =============================================================================
// Requires: ddwMixerChannel quark
//
// Topology:
//   ~m1 (master, outbus 0)
//     ~t1..~t12 (tracks -> master)
//     ~r1..~r4  (returns -> master)
//     ~perc (submix -> ~t1)
//       ~pbd1,~pbd2 ~psd1,~psd2 ~phh1,~phh2 ~pcp1,~pcp2
//       ~ptm1,~ptm2,~ptm3 ~pcr1,~pcr2 ~pex1,~pex2

// --- Route a synth into a mixer channel ---
Synth(\pBs, [\out, ~t1.inbus.index, \bufnum, buf]);

// --- Route a Pbind into a channel ---
Pdef(\myPat, Pbind(
    \instrument, \pBm,
    \out, ~t3.inbus.index,
    \bufnum, Pseq([buf1, buf2], inf),
    \dur, 0.25
));
Pdef(\myPat).play(~link);

// --- Level and pan ---
~t1.level_(0.8);                      // 0.0 - 1.0+ (master default is 4.0)
~t1.pan_(-0.5);                       // -1 to 1

// --- Get bus index safely ---
~busOf.(~t1);                         // -> integer bus index (0 if nil)

// --- FX on a channel (insert, replaces signal) ---
~t1.playfx({ |in|
    var sig = In.ar(~t1.inbus.index, 2);
    var wet = FreeVerb2.ar(sig[0], sig[1], mix: 0.3, room: 0.6, damp: 0.4);
    wet
});

// --- Inline FX with wet/dry mix + named controls ---
~t1_fx = ~t1.playfx({ |in|
    var sig = In.ar(~t1.inbus.index, 2);
    var mix = \fxMix.kr(0.5);
    var wet = Decimator.ar(sig, \sampleRate.kr(22050), \bits.kr(8));
    (sig * (1 - mix)) + (wet * mix)
});

~t1_fx.set(\bits, 4, \fxMix, 0.3);   // tweak params live
~t1_fx.free;                          // remove the FX

// --- Pattern control of playfx params ---
// Option 1: Control buses (best for multi-source control)
~r4_freq1 = Bus.control(s, 1).set(220);
~r4_freq2 = Bus.control(s, 1).set(222);

~r4_fx = ~r4.playfx({ |in|
    var freq1 = In.kr(~r4_freq1);
    var freq2 = In.kr(~r4_freq2);
    var sig = SinOsc.ar([freq1, freq2]) * In.ar(~r4.inbus.index, 2);
    sig
});

Pdef(\r4ctrl, Pbind(
    \type, \set,
    \id, ~r4_freq1.index,
    \args, [\value],
    \value, Pseq([220, 330, 440], inf),
    \dur, 1
)).play;

// Option 2: Named controls (simpler, use .set)
~r4_fx = ~r4.playfx({ |in|
    var freq1 = \freq1.kr(220);
    var freq2 = \freq2.kr(222);
    var sig = SinOsc.ar([freq1, freq2]) * In.ar(~r4.inbus.index, 2);
    sig
});

~r4_fx.set(\freq1, 330);              // direct set

Pdef(\r4ctrl, Pbind(                  // pattern control
    \type, \set,
    \id, ~r4_fx.nodeID,
    \args, #[\freq1, \freq2],
    \freq1, Pwhite(200, 600),
    \freq2, Pkey(\freq1) + 2,
    \dur, 0.25
)).play;

// --- Post-fader sends (e.g. track -> return) ---
~ensurePostSend.(~t1, ~r1, 0.3);     // fromChan, toChan, level

// --- Built-in return FX (r1/r2) ---
// Returns already have FX wired with named controls:
//   ~r1 = FreeVerb2 (reverb)   controls: \mix \room \damp
//   ~r2 = CombL (delay)        controls: \dt \dec
//   ~r3, ~r4 = dry (wire your own with the pattern below)
//
// Direct set via helper (pass nil to skip a param):
~setR1.(mix: 0.6, room: 0.9, damp: 0.3);
~setR2.(dt: 0.375, dec: 1.5);
//
// Or set named controls directly on the synth:
~r1_fx.set(\room, 0.95);
~r2_fx.set(\dt, 0.5);

// --- Design pattern: song-specific FX on a return ---
// Use this when wiring ~r3 or ~r4 with params you want to set/pattern later.
// Note: playfx is async, so bus mapping at init time is unreliable.
//       Store the returned synth and use .set on it instead.
//
// Step 1: use named controls inside playfx, store the returned synth
~r3_fx = ~r3.playfx({ |in|
    var sig = In.ar(~r3.inbus.index, 2);
    var wet = Decimator.ar(sig, 44100, \crush.kr(8));
    XFade2.ar(sig, wet, (\mix.kr(0.7) * 2) - 1)
});
// Step 2: expose a setter (optional but keeps song files tidy)
~setR3 = { |crush, mix|
    crush.notNil.if { ~r3_fx.set(\crush, crush) };
    mix.notNil.if   { ~r3_fx.set(\mix,   mix)   };
};

// --- Pattern control of return FX params ---
// Use \type \set targeting the synth's nodeID:
Pdef(\r3mod, Pbind(
    \type, \set,
    \id,   ~r3_fx.nodeID,
    \args, #[\crush, \mix],
    \crush, Pseq([4, 6, 8, 12], inf),
    \mix,   Pwhite(0.3, 0.9, inf),
    \dur,   2
)).play(~link);
// Same pattern works for r1/r2:
Pdef(\r1sweep, Pbind(
    \type, \set,
    \id,   ~r1_fx.nodeID,
    \args, #[\room, \damp],
    \room, Pwhite(0.5, 0.99, inf),
    \damp, Pseq([0.1, 0.4, 0.8], inf),
    \dur,  Pseq([4, 2, 2], inf)
)).play(~link);

// --- Cleanup song-specific FX ---
~r3_fx.free;
~r3.effectgroup.freeAll;
