

SynthDef(\kik808, ~ufn[\808][\kik]).add;
SynthDef(\hh808, ~ufn[\808][\hh]).add;

(
~p = { |str| 
  var array = str.collectAs({ |char| 
    if(char == $x, { 1 }, { Rest(1) }) 
  }, Array);
  Pseq(array, inf);
};
)
// Test it:
Pdefn(\kik_rhythm, ~p.("x--x-x--xx--x---"));
Pdefn(\hh_rhythm,  ~p.("xxxxxxxxxxxxxxxx"));


(
Pdef(\k808,  Pbind(
  \instrument,  \kik808,  
  \scale, Scale.minor,  
  \octave,  2,  
  \root,  1,  
  \rel, 0.8,
  \amp,  0.8, 
  \clickAmp,  0.2,  
  \pitchMod,  2,  
  // \pitchMod,  Pseg([1,  2], [1],  \lin, inf),  
  // \dist,  Pseg([10, 2], [1],  \lin, inf),  
  \dist,  1, 
  // \degree,  Pseq([0, \, \, \, 0,  \, \, \, 0, \, \, 0, \, \, 0, \], inf), 
  \pitchRel,  0.2,  
  \out, ~t1.inbus.index,  
  \dur, Pn(Pdefn(\kik_rhythm)/4,  inf),  
  // \stretch, Pseq([1,  2, 1/8!4].flat, inf), 
));
)
Pdef(\k808).play(~link);
Pdef(\k808).stop;

~k808_rev = ~ensurePostSend.(~t1,   ~r1, 1);
~k808_rev.tryPerform(\free);
~k808_del = ~ensurePostSend.(~t1,   ~r2, 1);
~k808_del.tryPerform(\free);
~k808_bis = ~ensurePostSend.(~t1,   ~r3, 0.3);
~k808_bis.tryPerform(\free);
~k808_chor = ~ensurePostSend.(~t1,   ~r4, 1);
~k808_chor.tryPerform(\free);
~k808_chor = ~ensurePostSend.(~t1,   ~r5, 1);

(
Pdef(\hh808,  Pbind(
  \instrument,  \hh808,  
  \scale, Scale.minor,  
  \octave,  9,  
  \root,  1,  
  // \rel, 0.8,
  \amp,  Pseq([0.4, 0.1!14, 0.3].flat, inf), 
  // \degree,  Pseq([0, \, \, \, 0,  \, \, \, 0, \, \, 0, \, \, 0, \], inf), 
  \out, ~t1.inbus.index,  
  \dur, Pn(Pdefn(\hh_rhythm)/4,  inf),  
  // \stretch, Pseq([1,  2, 1/8!4].flat, inf), 
));
)
Pdef(\hh808).play(~link);
Pdef(\hh808).stop;
(
Pdef(\kit808, Ppar([
  Pdef(\k808),  
  Pdef(\hh808), 
],  inf));
)
Pdef(\kit808).play;
Pdef(\kit808).stop;
~hh808_rev = ~ensurePostSend.(~t1,   ~r1, 1);
~hh808_rev.tryPerform(\free);
~hh808_del = ~ensurePostSend.(~t1,   ~r2, 1);
~hh808_del.tryPerform(\free);
~hh808_bis = ~ensurePostSend.(~t1,   ~r3, 0.3);
~hh808_bis.tryPerform(\free);
~hh808_chor = ~ensurePostSend.(~t1,   ~r4, 1);
~hh808_chor.tryPerform(\free);
~hh808_chor = ~ensurePostSend.(~t1,   ~r5, 1);
