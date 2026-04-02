
(
SynthDef(\kik808, ~ufn[\808][\kik]).add;
)

(
Pdef(\k808,  Pbind(
  \instrument,  \kik808,  
  \scale, Scale.minor,  
  \octave,  2,  
  \root,  1,  
  \rel, 1,
  \clickAmp,  0.5,  
  \pitchMod,  1,  
  // \pitchMod,  Pseg([1,  2], [1],  \lin, inf),  
  // \dist,  Pseg([10, 2], [1],  \lin, inf),  
  \dist,  10, 
  \degree,  Pseq([0, \, \, \, 0,  \, 0, \, 0, \, \, 0, 1, \, \, \], inf), 
  \pitchRel,  0.5,  
  \out, ~t1.inbus.index,  
  \dur, 1/4,  
  // \stretch, Pseq([1,  2, 1/8!4].flat, inf), 
));
)
Pdef(\k808).play(~link);
Pdef(\k808).stop;

~k808_rev = ~ensurePostSend.(~t1,   ~r1, 1);
~k808_rev.tryPerform(\free);
~k808_bis = ~ensurePostSend.(~t1,   ~r3, 0.3);
~k808_bis.tryPerform(\free);
~k808_chor = ~ensurePostSend.(~t1,   ~r4, 1);
~k808_chor.tryPerform(\free);
~k808_chor = ~ensurePostSend.(~t1,   ~r5, 1);
