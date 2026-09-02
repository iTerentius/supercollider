NetAddr.langPort.postln;
// 1. Allocate a control bus the same way the bridge itself does (via
  // Bus.control), so it can't collide with anything bridge-owned. Note the
  // printed index - that's what goes into External Control In's "sourceBus".
  b = Bus.control(s);
  b.index.postln;

  // 2a. Continuous CV test - a slow 0..1 sweep. Good for cabling the module's
  // "out" into something like VCF's cutoff_cv to see a smooth modulation:
  x = {Out.kr(b, SinOsc.kr(0.2).range(0, 1))}.play;
  // x.free; // stop when done

  // 2b. Gate/trigger test instead - fires the bus high/low on a beat. Good
  // for cabling into Envelope's gate_cv or Sample Player's trigger_cv:
  (
  t = Task({
      loop {
          b.set(1);
          0.05.wait;
          b.set(0);
          0.45.wait;
      };
  }).play;
  )
  t.stop; // stop when done

  // Define once, reuse for any Pbind/Pdef:
  (
  Event.addEventType(\busSetMulti, { |server|
      ~busMap.keysValuesDo { |key, busIndex|
          var val = currentEnvironment[key];
          if(val.notNil) { Bus.new(\control, busIndex, 1, server).set(val) };
      };
  });
  )

  // Per pattern: allocate one bus per key you want to expose, map them, and
  // add \type, \busSetMulti alongside your normal generative keys.
(
  ~b_freq = Bus.control(s); ~b_freq.index.postln;
  ~b_amp = Bus.control(s); ~b_amp.index.postln;

  ~busMap = (freq: ~b_freq.index, amp: ~b_amp.index);
  ~busMap = (freq: ~b_freq.index);  // request \freq, not \degree
)
(
  Pdef(\b_control, Pbind(
      \type, \busSetMulti,
      \busMap, ~busMap,   // <- add this: makes it part of the event itself
      // \freq, Pwhite(10, 50),
      \octave,  1,  
      \degree,  Pseq([0,  2,  4],  inf), 
      \amp, Pwhite(0.1, 0.5),
      \dur, 8,
  ));
)
Pdef(\b_control).play;
Pdef(\b_control).stop;

~extAudio = Bus.audio(s, 1);
~extAudio.index.postln;  // <- this number never changes regardless of Ndef edits
(

SynthDef(\myVoice, { |out,  freq=440|
    var sig = SinOsc.ar(freq) * 0.2;
    var e = EnvGen.ar(Env.perc(doneAction:2));
    sig = sig * e;
    Out.ar(~extAudio.index, sig);
}).add;
)
Pdef(\myVoice,  Pbind(\instrument,  \myVoice, \degree,  Pseq((0..7),  inf),  \octave, 2), \dur, 1).play;
Pdef(\myVoice).stop;
x = Synth(\myVoice);
  x.free; // stop when done
(
Ndef(\myVoice, { SinOsc.ar(110) * 0.2 });
Ndef(\myVoice).play;  // starts it running (also monitors to hardware out by default)
)
Ndef(\myVoice).clear;
Ndef(\myVoice).bus.index.postln;  // <- plug this into External Audio In's sourceBus
