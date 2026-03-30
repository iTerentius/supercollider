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
  SynthDescLib.global.at(\neutron).postln;   // nil = SynthDef not on
  server                                                                  
  Pdefn(\ntron_out).source.postln;           // nil or wrong = bad bus
  Synth(\neutron, [\out, ~t7.inbus.index, \freq, 220, \amp, 0.5]);        
  Pbindef(\pbd_ntron).patterns.postln;                      
    MIDIClient.sources.do { |ep, i| [i, ep.device, ep.name, ep.uid].postln }

  [                                                                       
    "apcMidiUID:", ~apcMidiUID,
    "apcOut:", ~apcOut,                                                   
    "apcPadMap size:", ~apcPadMap.size,
    "apcBanks[0] size:", ~apcBanks[0].size                                
  ].postln
                                                                          
  // 4. Raw MIDI test — press any pad on either controller after running
  this                                                                    
  MIDIdef.noteOn(\dbg, { |v, n, c, s| ["NOTE", v, n, c, s].postln })
  MIDIIn.disconnectAll;
  MIDIClient.sources.do { |ep, i|
      if(ep.device.containsi("IAC Driver").not) {                         
          MIDIIn.connect(i);
          ("Connected: " ++ ep.device ++ " / " ++ ep.name).postln;        
      };          
  };                                                                       
  ~roll_phrA_fnA.(); 
  ~roll_phrA_fnB.();  

  ~r5.postSends.do { |s| s.postSettings };
  ~r5.inbus.index.postln;
  ~t8.inbus.index.postln;

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
Ndef(\s1, { 
  | out, sustain=1, freq=110, speed=1, begin=0, end=1, pan, accelerate, offest, freqmod=1, gate=1, noise=4 |
	var e, f, s;
	f = Array.fill(5, { | i | i + freqmod/freq * 10});
	e = EnvGen.kr(Env.adsr(releaseTime: gate/2), gate, doneAction: 2);
	s = Pulse.ar(f/2*Pulse.kr(LFNoise0.kr(noise)).range(0, 10) * LFPulse.kr([0.5, 0.01, 2]/freqmod, 0.5).range(1, 10))* e;
	s = Splay.ar(s * e );
	Out.ar(out, s *0.5);
});
Ndef(\s1)[1] = \pset -> Pbind(
    \instrument, \s1,
    \octave, 5,
    \freqMod,   4, 
    \dur, Pseq([0.125, 0.125, 0.25, 0.25], inf),
    \degree, Pseq([0, 2, 4, 2, 5, 4, 2, 0], inf),
    \legato, 0.8,
    \amp, 0.15,

    // per‑event aux‑send amounts (0..1); these are read by a filter tap below
    \verbSend, Pwhite(0.0, 0.5, inf),
    \delSend,  Pseg(Pseq([0.0, 0.6, 0.2, 0.8], inf), 4, \lin)
); 
)

Ndef(\s1).play;
Ndef(\s1).clear;
