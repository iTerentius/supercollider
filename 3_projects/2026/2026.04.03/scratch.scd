// scratch.scd — experimental workspace, not loaded by score.scd

// Quick inline FX deploy/swap:
~ilfx[\v2_crush] = ~fxLib[\bitcrush].(~t5);
~ilfx[\v2_crush].set(\bits, 6, \rate, 8000);
~ilfx[\v2_crush].free; ~ilfx[\v2_crush] = nil;
~ilfx[\v2_ringmod] = ~fxLib[\ringmod].(~t5);
~ilfx[\v2_ringmod].set(\freq, 80, \mix, 0.5);
~ilfx[\v2_ringmod].free; ~ilfx[\v2_ringmod] = nil;
~ilfx[\v2_fold] = ~fxLib[\fold].(~t5);
~ilfx[\v2_fold].set(\gain, 3, \mix, 1.0);
~ilfx[\v2_fold].free; ~ilfx[\v2_fold] = nil;
~ilfx[\v2_glitch] = ~fxLib[\glitch].(~t5);
~ilfx[\v2_glitch].set(\rate, 0.1);
~ilfx[\v2_glitch].free; ~ilfx[\v2_glitch] = nil;
// Pitch shimmer — two detuned, pitch-shifted delay lines
// Params: \shift (semitones offset, e.g. 12), \time (0.01–0.5), \mix (0–1)
~ilfx[\v2_shimmer] = ~fxLib[\shimmer].(~t5);
~ilfx[\v2_shimmer].set(\mix, 0.3,  \shift, 24,  \time, 0.5  );
~ilfx[\v2_shimmer].free; ~ilfx[\v1_shimmer] = nil;
// Stutter — tape-stop/freeze-style repeating buffer
// Params: \rate (0.5–4 repeats/beat), \mix (0–1)
// Note: uses TGrains, approximate stutter not quantized
~ilfx[\v2_stutter] = ~fxLib[\stutter].(~t5);
~ilfx[\v2_stutter].set(\mix, 0.9,  \amp,  4,  \rate, 8, );
~ilfx[\v2_stutter].free; ~ilfx[\v2_stutter] = nil;
~ilfx[\v2_stutter].set(\mix, 0.5,  \rate, 16);
~ilfx[\v2_stutter].free; ~ilfx[\v1_stutter] = nil;

~ilfx[\v5_spec] = ~ufn[\spectral].(~t5);

~ilfx[\v5_duck] = ~fxLib[\duck].(~t5, ~t1);
~ilfx[\v5_duck].free; ~ilfx[\v5_duck] = nil;

~ilfx[\v2_shimmerStutter] = ~fxLib[\stutter].(~t5);
~ilfx[\v2_shimmerStutter].set(\speed, 4,  \pStart,  0, \pEnd, -12 );
~shimmer.set(\speed, 4);      // Faster rhythm
~shimmer.set(\pStart, 12);    // Start an octave up
~shimmer.set(\pEnd, 0);       // Drop down to original pitch
~shimmer.set(\width, 0.2);    // Short, stabby stutters
// Check what's running:
// Pdef.all;
// ~ilfx;
// ~fxSendStop;

// Manual send (bypass LP/APC toggle):
// ~ensurePostSend.(~t1, ~r1, 0.3);
//
(
~ilfx[\v2_crush].free; ~ilfx[\v2_crush] = nil;
~ilfx[\v2_crush] = ~fxLib[\bitcrush].(~t1);
Pdef(\crush,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v2_crush].nodeID }), 
  \args,  #[\rate,  \bits,  \mix, \amp],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  // \mix, Pseg([0.01,  1.0], [2],  \lin, inf),  
  \mix,  Pbjorklund(3, 8,  inf)/2, 
  // \mix, Pwhite(0.5, 1.0,  inf), 
  \amp, 0.8,  
  \rate,  Pseg([2500, 80000], [2],  \sin, inf),  
  \bits,  4,  
  \dur, Pseq([1/4!2, 1/2,   1,  1/8!4].flat, inf), 
  \stretch, Pn(Pdefn(\v1_808k_strs),  inf),  
));
Pdef(\crush).play;
)
Pdef(\crush).stop; ~ilfx[\v2_crush].free; ~ilfx[\v2_crush] = nil;
~toscStateSave.(\t0403);
  

(
SynthDef(\harpy, ~ufn[\harpy1]).add;
)
(
Pdef(\harpy,  Pbind(
  \instrument,  \harpy,  
  \scale,  Scale.minor,  
  \octave,  Pseq([3,  4,  5], inf), 
  \root,  Pdup(8, Pseq([0,  1,  4], inf)), 
  \amp, 0.2,  
  \dur, Pseq([1/4!8, 1/2!2].flat,  inf),  
  \degree, Pif(Pkey(\dur) < 0.5,  
              Ppatlace([
                  Pseq([-7,  -2,  0], inf), 
                  Pslide((0..7),  inf,  3, 2),  
                ],  inf),  
              Pseq([0,  1], inf)),  
  \degree,  Ppatlace([
    Pslide((0..7),  inf,  3, 2),  
    Pseq([-7,  -2,  0], inf), 
  ],  inf), 
  // \stretch, Pseg([1,  1/2,  2]*2,  [2,  4],  \step, inf), 
  \out,  ~t3.inbus.index,  
));
) 
Pdef(\harpy).play;
Pdef(\harpy).stop;

(
~ilfx[\v2_stutter].free; ~ilfx[\v2_stutter] = nil;
~ilfx[\v2_stutter] = ~fxLib[\stutter].(~t5);
Pdef(\h_test, Pbind( 
  \type,   \set,  
  \id,  Pfunc({ ~ilfx[\v2_stutter].nodeID }),  
  \args,  #[\rate,  \mix, \amp],
  \amp, 2,  
  \rate,   Pseg([2, 80],[4], \step, inf ),  
  // \mix,  Pseg([1, 0.5],[4], \sin,  inf), 
  \mix, 0.8,  
  \dur,  1/2, 
  \stretch, Pwhite(1/2, 2,  inf), 
));
)
Pdef(\h_test).play;
Pdef(\h_test).stop;

(
~stemStop = ~stemDiskStart.(
  tracks:  [~t1, ~t2, ~t3 ],    // MixerChannels to record
  returns: [~r1, ~r2, ~r3,  ~r4,  ~r5],               // return channels
  fileBase: "bldr",                   // filename prefix
  dirPath: "~/Music/recordings",     // output directory (auto-created)
  clock: ~link,                      // for beat-synced start (nil = default)
  autoSplit: true,                   // auto-split interleaved WAV into stems via ffmpeg
  splitCodec: \pcm_s24le,            // codec for split files
  captureHistory: true,              // saves jam_<timestamp>.history.scd (live code log)
  captureMidi: true                  // saves jam_<timestamp>.mid (one track per stem)
);
)

// --- Stop recording (scheduled, on beat) ---
~stemStop.();                 // stop 4 beats from now
// Create a control bus
~busBits = Bus.control(s, 1);
~busRate = Bus.control(s, 1);


// Run a synth that just puts Mouse data onto that bus
~mBits = { Out.kr(~busBits, MouseX.kr(4, 24, 1)) }.play;
~mRate = { Out.kr(~busRate, MouseY.kr(100, 2000, 1)) }.play;

// Map your synth's frequency argument to that bus
~mySynth = Synth(\default);
~mySynth.map(\freq, ~bus); 

// Now you can 'unmap' it later or .set it manually to override
~mySynth.set(\freq, 440);

~ilfx[\v2_crush].map(\bits, ~busBits, \rate, ~busRate);

~mySynth = nil;
// Only listen to the device at this specific IP
~tablet = NetAddr("192.168.1.15", nil); 
~ilfx[\v1_crush].free;
(
// ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1);

OSCdef(\v5_shimmer, { |msg| 
    var shift = msg[1].linexp(0, 1,  -24,  24);
    var time = msg[2].linexp(0, 1,  0.01, 50);
    // var val = msg[1].linlin(0, 1, 4, 12);
    ~ilfx[\v5_shimmer].set(\shift, shift, \time,  time);
}, '/2/xy3', srcID: ~toscAddr);
OSCdef(\v5_shimmer, { |msg| 
    var mix = msg[1].linlin(0, 1,  0, 1);
    ~ilfx[\v5_shimmer].set(\mix, mix);
}, '/2/fader2', srcID: ~toscAddr);
OSCdef(\v5_ringmod, { |msg| 
    var freq = msg[1].linexp(0, 1,  0.01, 30);
    // var val = msg[1].linlin(0, 1, 4, 12);
    ~ilfx[\v5_ringmod].set(\freq, freq );
}, '/2/fader3', srcID: ~toscAddr);
OSCdef(\v5_ringmod, { |msg| 
    var mix = msg[1].linlin(0, 1,  0, 1);
    ~ilfx[\v5_ringmod].set(\mix, mix);
}, '/2/fader4', srcID: ~toscAddr);
)

(
SynthDef(\dynklangDemo, {
    arg out = 0, gate = 1, amp = 0.3, freq=110, 
        freq0 = 220, freq1 = 440, freq2 = 660,
        lfoRate = 0.3, lfoDepth = 0.15,
        attackTime = 0.01, releaseTime = 2.0;

    var lfo, freqs, amps, rings, sig, env;

    freq0 = freq;
    freq1 = freq0 *1.2;
    freq2 = freq1 *1.5;
    // Slow LFO modulating the partials
    lfo = LFPulse.kr(lfoRate);

    // Frequencies: base + LFO-warped harmonics
    freqs = [
        freq0 * (1 + (lfo * lfoDepth)),
        freq1 * (1 + (lfo.neg * lfoDepth * 0.7)),
        freq2 * (1 + (lfo * lfoDepth * 0.5))
    ];

    // Amplitudes: slowly breathe
    amps = [
        0.5 + (lfo * 0.1),
        0.3 + (lfo.neg * 0.05),
        0.2
    ];

    // Ring times: fixed is fine here
    rings = [2.0, 1.5, 0.8];

    // DynKlang takes flat Arrays, not the backtick `[] syntax
    sig = DynKlang.ar(`[freqs, amps, rings]);
    // sig = 
    env = EnvGen.kr(Env.asr(attackTime, 1.0, releaseTime), gate, doneAction: 2);

    Out.ar(out, (sig * env * amp).dup);
}).add;
)

// Play it
~k = Synth(\dynklangDemo, [freq0: 110, freq1: 330, freq2: 550, lfoRate: 0.2]);

// Modulate live
~k.set(\freq0, 165, \lfoRate, 0.6, \lfoDepth, 0.25);

// Release
~k.set(\gate, 0);

(
// Pdef(\dk, Pbind(
//   \instrument,  \dynklangDemo,  
//   \scale, Scale.minor,  
//   \octave,  Pseq([4,  3,  2], inf),  
//   \degree,  Pslide((0..7), inf, 2,  4), 
//   \amp, 0.3,  
//   \mix, Pstep(Pseq([1,  0,], inf),   
//   // \gate,  Pseq([0,  1], inf), 
//   \lfoRate, Pseg([1,  80],  [4],  \step, inf), 
//   \lfoDepth,  Pseg([1.5, 0.5], [4],  \step, inf), 
//   \dur, 4,  
//   \releaseTime, Pkey(\dur), 
//   \stretch, Pseq([1/4,  1,  2], inf),  
//   \out,  ~t4.inbus.index, 
// ));
Pdef(\dk, 
  // Pbindef(mk.("_pb"),
  Pbind(
    // \type,  \mono, 
    \instrument,  Pseq([\neutron],  inf),   
    \scale, Scale.minor,
    \octave, Pstep(Pseq([3, [4]], inf), Pkey(\stretch)), // Hold octave for 4 beats
    // \root,  Pstep(Pseq([0,  4,  2,  1], inf), 16),  
    // \degree, Pslide([0,  2, 1,  0],  inf, 1,  3),  
    \degree,  Pseg([7,  -0], [2],  \lin, inf),  
    \ctranspose, Pn(PHarmony(\minor)),
    // \legato,  Pseq([Pkey(\stretch)/2, Pkey(\stretch)*1.1],  inf), 
    \gate, Pn(Pstep(Pseq([1, 0], 1), 2), inf),   
    \amp,  Pstep(Pseq([0.1, 0.2], inf), Pkey(\stretch)),   
    \osc1Blend, 0, \osc2Blend,  0,     
    \osc1PW,  Pseg([0.0,  1.0], [Pkey(\stretch)],  \wel, inf),  
    \osc2Track, 1,  
    \osc2Oct, Pkey(\octave)-3,    
    \oscMix,  Pwhite(0.0, 1.0,  inf), 
    \sync,  0,  
    \cutoff, Pseg([2000,  400,  2000], [Pkey(\stretch)],  \sin, inf), 
    \noiceLvl,  0.8,  
    \env1Amt, Pseg([0.0,  1.0], [Pkey(\stretch)], \sin, inf), 
    \subLvl,  0.8,  
    \drive, Pkey(\amp)*1.1,  
    \filterMode,  Pstep(Pseq([0,  0,  0,  2], inf), Pkey(\stretch)*2),   
    // \res, Pseg([0.2,  0.6], [Pkey(\dur)*Pkey(\div)],  \wel, inf), 
    \lfoRate, Pseg([1, 2,  4], [Pkey(\stretch)/2, Pkey(\stretch)], \sqr, inf), 
    \lfoDepth, Pseg([1.5, 1.0], [Pkey(\stretch)], \lin, inf),
    \lfoToOsc1, 0,  
    \lfoToOsc2, 0,  
    \lfoToFilter, 1,  
    \releaseTime, Pkey(\stretch), 
    // \ctranspose, Pn(PHarmony(\minor)),
    // \strum, 0.5,  
    // The "Engine" speed
    // \dur, Pseq([1/4!2, 1/2!2, Pn(Rest(),  1+1/2)].flat, inf),  
    \dur, Pbjorklund(Pstep(Pseq([3,  5,  7],inf),  8), 8, inf), 

    // Optional: stretch still works, but it will stretch the 0.5
    \stretch, 1,  
    // \stretch, Pstep(Pseq([1/2,  1], inf), 1),  
    // \stretch, Pseg([1, 1/4], [8],  \lin,  inf), 
    
    \out, ~t4.inbus.index,
));
)

Pdef(\dk).play;
Pdef(\dk).stop;

// Simple chord progression
// (
// Pbind(
//   \instrument,  \
// 	\degree, Prand([0,2,4,5], inf),
//     \ctranspose, Pn(PHarmony(\minor)),
//     \dur, 0.5
// ).play;
// )
//
// // Complex arpeggiation
// (
// Pbind(
//     \ctranspose, PHarmony(
//         [\major, \minor7, \diminished],
//         [\blossomup, \updown, \random]
//     ),
//     \dur, 0.125
// ).play;
// )
//
// // Combining with other patterns
// (
// Pbind(
//     \ctranspose, Pseq([
//
//         // Major chord
//         PHarmony(\major),
//
//         // Major 9
//         PHarmony(\major9),
//
//         // Major 9 with chord operations
//         PHarmony(Harmony(\major9).withDouble(\root, octaves: -1).withInversion(\first))
//     ], inf).trace,
//     \dur, 0.25
// ).play;
// )
// )stop;
