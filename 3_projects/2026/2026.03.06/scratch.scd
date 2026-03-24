// Scratch
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

OSCFunc.trace(true)
OSCFunc.trace(false)

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
  \amp,  0.1, 
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
