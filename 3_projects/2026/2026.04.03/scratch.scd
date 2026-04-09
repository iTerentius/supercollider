// scratch.scd — experimental workspace, not loaded by score.scd

// Quick inline FX deploy/swap:
~ilfx[\v2_crush] = ~fxLib[\bitcrush].(~t1);
~ilfx[\v2_crush].set(\bits, 6, \rate, 8000);
~ilfx[\v2_crush].free; ~ilfx[\v2_crush] = nil;
~ilfx[\v2_ringmod] = ~fxLib[\ringmod].(~t3);
~ilfx[\v2_ringmod].set(\freq, 80, \mix, 0.5);
~ilfx[\v2_ringmod].free; ~ilfx[\v2_ringmod] = nil;
~ilfx[\v2_fold] = ~fxLib[\fold].(~t1);
~ilfx[\v2_fold].set(\gain, 3, \mix, 1.0);
~ilfx[\v2_fold].free; ~ilfx[\v2_fold] = nil;
~ilfx[\v2_glitch] = ~fxLib[\glitch].(~t3);
~ilfx[\v2_glitch].set(\rate, 0.5);
~ilfx[\v2_glitch].free; ~ilfx[\v2_glitch] = nil;
// Pitch shimmer — two detuned, pitch-shifted delay lines
// Params: \shift (semitones offset, e.g. 12), \time (0.01–0.5), \mix (0–1)
~ilfx[\v2_shimmer] = ~fxLib[\shimmer].(~t3);
~ilfx[\v2_shimmer].set(\mix, 0.3,  \shift, 24,  \time, 0.5  );
~ilfx[\v2_shimmer].free; ~ilfx[\v1_shimmer] = nil;
// Stutter — tape-stop/freeze-style repeating buffer
// Params: \rate (0.5–4 repeats/beat), \mix (0–1)
// Note: uses TGrains, approximate stutter not quantized
~ilfx[\v2_stutter] = ~fxLib[\stutter].(~t3);
~ilfx[\v2_stutter].set(\mix, 0.9,  \amp,  1,  \rate, 16, );
~ilfx[\v2_stutter].free; ~ilfx[\v2_stutter] = nil;
~ilfx[\v2_biscuit] = ~ufn[\spectral].(~t10);
~ilfx[\v2_stutter].set(\mix, 0.5,  \rate, 16);
~ilfx[\v2_stutter].free; ~ilfx[\v1_stutter] = nil;
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
Pdef(\h_glitch, Pbind( 
  \type,   \set,  
  \id,  Pfunc({ ~ilfx[\v2_glitch].nodeID }),  
  \args,  #[\rate,  \mix], 
  \rate,   Pseg([0.5, 1,  1.5],[1,  2], \step, inf ),  
  \mix,  Pseg([1, 0],[2], \lin,  inf), 
  \dur,  1/16, 
));
)
Pdef(\h_glitch).play;
Pdef(\h_glitch).stop;

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
