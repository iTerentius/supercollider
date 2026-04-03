

(
Pdefn(\kik_dur, ~p.("xx--x---x---x---"));
Pdefn(\sn_dur,  ~p.("--------x-------"));
Pdefn(\hh_dur,  ~p.("-x-x-x-x-x-x-x-x"));
Pdefn(\kik_q, Pstep(Pseq([2,  ], 1), 8));
Pdefn(\sn_q, Pstep(Pseq([2, ], 1), 8));
Pdefn(\hh_q, 2  );
)


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
  \out, ~perc.inbus.index,  
  \dur, Pn(Pdefn(\kik_dur)/Pn(Pdefn(\kik_q),  inf),  inf),  
  // \stretch, Pseq([1/4!4, 1/2!2,  2!2].flat, inf), 
));
)
Pdef(\k808).play(~link);
Pdef(\k808).stop;

~perc.level_(2);

~k808_rev = ~ensurePostSend.(~perc,   ~r1, 1);
~k808_rev.tryPerform(\free);
~k808_del = ~ensurePostSend.(~perc,   ~r2, 1);
~k808_del.tryPerform(\free);
~k808_bis = ~ensurePostSend.(~perc,   ~r3, 0.3);
~k808_bis.tryPerform(\free);
~k808_chor = ~ensurePostSend.(~perc,   ~r4, 1);
~k808_chor.tryPerform(\free);
~k808_spec = ~ensurePostSend.(~perc,   ~r5, 1);
~k808_spec.tryPerform(\free);

(
Pdef(\sn808,  Pbind(
  \instrument,  \sn808,  
  \scale, Scale.minor,  
  \octave,  2,  
  \root,  1,  
  \rel, 0.2,
  \amp,  0.4, 
  \snapRel, Pwhite(0.1, 0.8,  inf), 
  \toneFreq,  100,  
  \snappy,  Pwhite(0.2, 0.6,  inf), 
  // \degree,  Pseq([0, \, \, \, 0,  \, \, \, 0, \, \, 0, \, \, 0, \], inf), 
  \out, ~perc.inbus.index,  
  \dur, Pn(Pdefn(\sn_dur)/Pn(Pdefn(\sn_q),  inf),  inf),  
  // \stretch, Pseq([1/4!4, 1/2!2,  2!2].flat, inf), 
));
)
Pdef(\sn808).play(~link);
Pdef(\sn808).stop;

~sn808_rev = ~ensurePostSend.(~t1,   ~r1, 1);
~sn808_rev.tryPerform(\free);
~sn808_del = ~ensurePostSend.(~t1,   ~r2, 1);
~sn808_del.tryPerform(\free);
~sn808_bis = ~ensurePostSend.(~t1,   ~r3, 0.3);
~sn808_bis.tryPerform(\free);
~sn808_chor = ~ensurePostSend.(~t1,   ~r4, 1);
~sn808_chor.tryPerform(\free);
~sn808_spec = ~ensurePostSend.(~t1,   ~r5, 1);
~sn808_spec.tryPerform(\free);

(
Pdef(\hh808,  Pbind(
  \instrument,  \hh808,  
  \scale, Scale.minor,  
  \octave,  9,  
  \root,  1,  
  // \rel, 0.8,
  // \amp,  Pseq([0.4, 0.1!14, 0.3].flat, inf), 
  \degree,  Pseq([0!8,  2].flat, inf), 
  \rel,  Pseq([1/16!8,  1].flat, inf), 
  \out, ~perc.inbus.index,  
  \dur, Pn(Pdefn(\hh_dur)/Pn(Pdefn(\hh_q),  inf),  inf),  
  // \stretch, Pseq([1,  1/2].flat, inf), 
));
)
Pdef(\hh808).play(~link);
Pdef(\hh808).stop;
(
Pdef(\kit808, Ppar([
  Pdef(\k808),  
  Pdef(\sn808),  
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
~hh808_spec = ~ensurePostSend.(~t1,   ~r5, 1);
~hh808_spec.tryPerform(\free);
