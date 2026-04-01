// Scratch
(
~stemStop = ~stemDiskStart.(
  tracks:  [~t1, ~t2, ~t3, ~t4, ~t6,  ~t7],    // MixerChannels to record
  returns: [~r1, ~r2, ~r3,  ~r4,  ~r5],               // return channels
  fileBase: "kiom",                   // filename prefix
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
(
~m1_ilfx_1.free;
~m1_ilfx_1 = ~m1.playfx({|in|
    var sig = In.ar(~m1.inbus, 2);
    var mod = \mod.kr(1);
    var mix = \mix.kr(0);      // 0 = dry, 1 = wet
    var amp = \amp.kr(1);
    var gate = K2A.ar(LFPulse.kr(mod).lag(0.005));
    var wet = gate * sig;
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
});
)
~m1_ilfx_1.set(\level,  0);
(
Pdef(\modCtl, Pbind(
  \type,   \set,  
  \id,   ~m1_ilfx_1.nodeID,  
  \args,  #[\mod, \width, \mix, \amp],  
  \mod, Pser((10..30), inf),
  \width,  Pseg([0.1, 1.0,  0.1],[2,  4], \sin, inf ),  
  \amp,  1, 
  \mix, Pseg([0.0,  0.5,  1.0], [2, 4],  \sin, inf),  
  // \mix,  0, 
  // \delta, 1/4,  
  \dur,  1/32, 
));
)
Pdef(\modCtl).play;
Pdef(\modCtl).stop;

// Create a control bus
~lfoBus = Bus.control(s, 1);

// LFO synth — runs before the target synth in node order
~lfoSynth = {
    arg rate = 0.5, lo = 400, hi = 600;
    Out.kr(~lfoBus, LFTri.kr(rate).range(lo, hi));
}.play(s, addAction: \addToHead);

// Target synth reads from the bus via `In.kr`
SynthDef(\bussedSynth, {
    arg freqBus = 0;
    var freq = In.kr(freqBus);
    var sig = SinOsc.ar(freq);
    Out.ar(0, sig * 0.2 ! 2);
}).add;

~targetSynth = Synth(\bussedSynth, [\freqBus, ~lfoBus]);

~bd1_ilfx_1.set(\lpfreq,  1000,  \rq, 2.0,  \hpfreq,  500,  \hprq,  2.0);
// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~

(
~m1_revs_fx.free;
~m1_revs_fx = ~m1.playfx({|in|
  var sig = In.ar(~m1.inbus,  2);
  var wet = Greyhole.ar(
    in:  sig,
    delayTime: 2.5,  
    damp:  0.0,  
    size:  3.0,  
    diff:  0.707,  
    feedback:  0.1,  
    modDepth:  0.1,  
    modFreq: 2.0,  
  );
  wet;
});)
~bd1_revs_fx.level_(0.5);

OSCFunc.trace(true, hideStatusMsg: true);
OSCFunc.trace(false)
~r3fx[\biscuit].postln;
  ~r3fx[\biscuit].set(\drive, 0.0);

~inlineFX[\r3].set(\hpfreq,  0,  \lpfreq,  18000);
(
// ~outs = ~m1_ilfx_1.nodeID;
~outs = ~r5_ilfx_1;
// ~outs = [~m1_ilfx_1,  ~r5_ilfx_1];

Pdef(\modCtl, Pbind(
  \type,   \set,  
  \id,   ~outs,    
  \args,  #[\freeze, \mix, \amp,  \chunk],  
  \chunk, Pseq([512,  1024, 2048, 4096],  inf), 
  \freeze,   Pwhite(0,  1,  inf), 
  \amp,  0.7, 
  // \mix, Pseg([0.0,  0.5,  1.0], [2, 4],  \sin, inf),  
  \mix,  1, 
  // \delta, Pkey(\dur)/4,  
  // \dur,  Pseq([1/4, 1/2,  1,  2], inf),  
  // \dur,  pbjorklund(3, 8,  inf), 
  \dur,  Pseg([1/2,   1, 1/4], [2, 4], \sin,  inf), 
  // \dur, 1/16, 
));
)
Pdef(\modCtl).play;
Pdef(\modCtl).stop;

~m1_ilfx_1.set(\level,  0.1);

  Pdef.all[\neutron].postln;                                
  ~lpMini[\bindings].select { |b| b[\key] == \neutron }.postln;
~t7.level

  ~r5.postSends.do { |s| s.postSettings };
  ~r5.inbus.index.postln;
  ~t8.inbus.index.postln;

(
[~t1,~t2,~t3,~t4,~t5,~t6,~t7,~t8,~t9].do {
  |ch|
      ch.postSends.do { |s|
          if(s.outbus.index ==
  ~r5.inbus.index) {
              ("→ ~r5 from " ++ ch.name ++ "
  level=" ++ s.level).postln
          }
      }
  };

  ~r5.level_(1)
)
(
Tdef(\tempo, {
  var bpms = [50,  100, 200].scramble;
  var durs = [4,  8,  16].scramble;
  loop {
    bpms.do { |bpm, i|
      ~link.tempo = bpm / 60;
      durs[i].wait;  // wait 4 beats
    };
  };
};)
)
Tdef(\tempo).play(~link);
Tdef(\tempo).stop;

~r3fx[\biscuit].nodeID;

Pdef(\bCtl).stop;
MIDIFunc.trace(true); // Turn on
MIDIFunc.trace(false); // Turn off

// Duck ~t1 (e.g. pads/synths) when ~t3 (e.g. kick) hits
(
~duck_r3_bd1.free;
~duck_r3_bd1 = Synth(\duck, [
  \in,      ~r3.inbus.index,   // signal to duck
  \side,    ~t1.inbus.index,   // sidechain trigger source
  \out,     ~r3.inbus.index,   // replace in place
  \thresh,  0.88,              // onset threshold (0–1 amp scale)
  \ratio,   4,                // compression ratio
  \attack,  0.003,             // duck onset (seconds)
  \release, 0.25,              // duck release (seconds)
  \makeup,  1.0
], ~r3.synthgroup, \addToTail);  // runs after input synths, before fader
)
~duck_r3_bd1.free;

  // Free it
(
~duck_t7_bd1.free;
~duck_t7_bd1 = Synth(\duck, [
  \in,      ~t7.inbus.index,   // signal to duck
  \side,    ~t1.inbus.index,   // sidechain trigger source
  \out,     ~t7.inbus.index,   // replace in place
  \thresh,  0.08,              // onset threshold (0–1 amp scale)
  \ratio,   12,                // compression ratio
  \attack,  0.03,             // duck onset (seconds)
  \release, 0.35,              // duck release (seconds)
  \makeup,  1.0
], ~t7.synthgroup, \addToTail);  // runs after input synths, before fader
)
~duck_t7_bd1.free;

(
SynthDef(\s2, { 
  | out, freq=110, gate=1, freqmod=1, amp=0.2,  conv=1|
	var sig, lf,  env;
  env = EnvGen.ar(Env.asr( 0.01, 0.3, 1.0), gate: gate, doneAction: 2 ); 
  // sig = VarSaw.ar([freq, freq+2], env*0.1,  freqmod) * LFPulse.ar(freq/2, LFPulse.ar([freqmod-1, freqmod])) * 0.7;
  sig = LFPulse.ar([freq, freq+2], env,  freqmod) * SinOsc.ar(freq/2, LFPulse.ar([freqmod-1, freqmod])) * 0.7;
  // sig = sig * Convolution.ar(~t10.inbus.index, ~t1.inbus.index, 2048, 0.8);
  sig = sig * env;
	Out.ar(out, sig * amp);
}).add;
)
(
SynthDef(\s3, { 
  | out, freq=110, gate=1, freqmod=1, amp=0.2,  conv=1|
	var sig, lf,  env;
  env = EnvGen.ar(Env.asr( 0.01, 0.7, 1.0), gate: gate, doneAction: 2 ); 
  // sig = VarSaw.ar([freq, freq+2], env*0.1,  freqmod) * LFPulse.ar(freq/2, LFPulse.ar([freqmod-1, freqmod])) * 0.7;
  sig = LFPulse.ar([freq, freq+2], env,  freqmod) * SinOsc.ar(freq/2, LFPulse.ar([freqmod-1, freqmod])) * 0.7;
  // sig = sig * Convolution.ar(~t10.inbus.index, ~t1.inbus.index, 2048, 0.8);
  sig = sig * env;
	Out.ar(out, sig * amp);
}).add;
)
(
SynthDef(\dynklangDemo, {
    arg out = 0, gate = 1, amp = 0.3,
        freq0 = 220, freq1 = 440, freq2 = 660,
        lfoRate = 0.3, lfoDepth = 0.15,
        attackTime = 0.01, releaseTime = 2.0;

    var lfo, f0, f1, f2, a0, a1, sig, env;

    lfo = SinOsc.kr(lfoRate);

    // Compute each modulated freq/amp as a named UGen, not inside an Array
    f0 = freq0 * (1 + (lfo * lfoDepth));
    f1 = freq1 * (1 + (lfo.neg * lfoDepth * 0.7));
    f2 = freq2 * (1 + (lfo * lfoDepth * 0.5));

    a0 = 0.5 + (lfo * 0.1);
    a1 = 0.3 + (lfo.neg * 0.05);

    // DynKlang: freqs, amps, rings as flat compile-time Arrays
    // Each slot can be a UGen, but the Array *structure* must be literal
    sig = DynKlang.ar(
        `[ [f0, f1, f2], [a0, a1, 0.2], [2.0, 1.5, 0.8] ]
    );

    env = EnvGen.kr(Env.asr(attackTime, 1.0, releaseTime), gate, doneAction: 2);

    Out.ar(out, (sig * env * amp).dup);
}).add;
)

(
Pdef(\s2,  Pbind(
    \instrument, \dynklangDemo, 
    \octave, Pseq([7, 4,  5,  6], inf),
    \scale,  Scale.minor, 
    \freqmod,   Pseg([Pkey(\dur).midicps/Pwhite(2,  4,  1),  Pwhite(0.5, 5.5,  2)], [3],  \sin,   inf), 
    \freq0,  Pseq([
      Scale.minor.degreeToFreq(-7,  60.midicps, 0),  
      Scale.minor.degreeToFreq(-5,  60.midicps, 0),  
  ],  inf),    
    \freq1,  Pseq([
      Scale.minor.degreeToFreq(-2,  60.midicps, 1),  
      Scale.minor.degreeToFreq(0,  60.midicps, 1),  
  ],  inf),    
    \freq2,  Pseq([
      Scale.minor.degreeToFreq(5,  60.midicps, 0),  
      Scale.minor.degreeToFreq(0,  60.midicps, 1),  
  ],  inf),    
    \lfoRate,  Pseg([0.01, 0.1, 0.01],  [4, 8],  \step, inf),  
    // \freq2,  (Pkey(\degree)+1).midicps, 
    // \dur, Pseq([0.125, 0.125, 0.25, 0.25], inf),
    \dur,  1/2, 
    \stretch,  Pseq([4, 8,  2]/1, inf), 
    // \degree,  Pseq([0,  1,  2,  4,  9], inf), 
    \degree, Pseq([Prand([[0, 1,  4], [0, 2,  4]],  1), Pn(Rest(), 2)], inf),
    // \degree,  Pseq([[2, 4,  0], [0, 5,  7], [1, 4,  0]], inf), 
    \strum, Pseq([1/2!4,  1/4!4].flat, inf),    
    \legato, 0.8, 
    \amp, 0.1,
    \out, ~t10.inbus.index,  
)); 
)
(
Pdef(\s3,  Pbind(
    \instrument, \s3, 
    \octave, Pseq([7, 4,  5,  6], inf),
    \scale,  Scale.minor, 
    \freqmod,   Pseg([Pkey(\dur).midicps/Pwhite(2,  4,  1),  Pwhite(0.5, 5.5,  2)], [3],  \sin,   inf), 
    \dur,  1/2, 
    \stretch,  Pseq([4, 8,  2]/1, inf), 
    // \degree,  Pseq([0,  1,  2,  4,  9], inf), 
    // \degree, Pseq([Prand([[0, 1,  4], [0, 2,  4]],  1), Pn(Rest(), 2)], inf),
    \degree,  Pseq([[2, 4,  0], [0, 5,  7], [1, 4,  0]], inf), 
    \strum, Pseq([1/2!4,  1/4!4].flat, inf),    
    \legato, 0.9, 
    \amp, 0.08,
    \out, ~t10.inbus.index,  
));
)
(
Pdef(\both, Ppar([
   Pn(Pdef(\s2), inf), 
   // Pdef(\s3), 
], inf));
)
Pdef(\both).play;
Pdef(\both).stop;


~s2fx_rev = ~ensurePostSend.(~t10,   ~r1, 1);
~s2fx_rev.tryPerform(\free);
~s2fx_bis = ~ensurePostSend.(~t10,   ~r3, 1);
~s2fx_bis.tryPerform(\free);
~s2fx_chor = ~ensurePostSend.(~t10,   ~r4, 1);
~s2fx_chor.tryPerform(\free);
~s2fx_chor = ~ensurePostSend.(~t10,   ~r5, 1);

Pdef(\s2).play;
Pdef(\s2).stop;
(
Pdef(\s1,  Pbind(
    \instrument, \s1,
    \octave, 5,
    \freqMod,   40, 
    \dur, Pseq([0.125, 0.125, 0.25, 0.25], inf),
    \degree, Pseq([0, 2, 4, 2, 5, 4, 2, 0], inf),
    \legato, 0.8,
    \amp, 0.15,
    \out, ~t1.inbus.index,  

    // per‑event aux‑send amounts (0..1); these are read by a filter tap below
    \verbSend, Pwhite(0.0, 0.5, inf),
    \delSend,  Pseg(Pseq([0.0, 0.6, 0.2, 0.8], inf), 4, \lin)
)); 
)
Pdef(\s1).stop;
