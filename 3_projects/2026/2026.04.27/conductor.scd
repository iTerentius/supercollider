(
~sc = ();
~sc[\reset] = {
  "parts/all2.scd".loadRelative;
  Pdef(\v1_crush).stop;
  ~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;
  ~v1_2_r1.free; ~v1_2_r1 = nil;
  ~v1_2_r1 = ~t1.newPostSend(~r1, 0.8);
  ~allMul = (kick: 4, sn: 1, hh: 1, bass: 4);
  Pbindef(\all_sn,  \amp, 0);
  Pbindef(\all_bass,  \amp, 0);
  Pbindef(\all_hh,  \amp, 0,  \instrument,  \hh808);
  "reset".postln;
};

~sc[\intro] = {

  Pbindef(\all_kick, \degree, Pseq([
    Pn(~deg.("00000---0---0---"), 1), 
    Pn(~deg.("0-------0---0000"), 8), 
  ], inf));
};

~sc[\vrs1] = {
  Pbindef(\all_sn,  \amp, 0.3);
  Pbindef(\all_bass,  \amp, 0.14);
  Pbindef(\all_hh,  \amp, 0.4,  \instrument,  Pseq([\hh808, \t1002],  inf));
  Pbindef(\all_kick, \amp, 0.7);
  ~allMul[\kick] = 2;
  Pbindef(\all_kick, \degree, Pseq([
    Pn(~deg.("0-------0-------"), 1),
    Pn(~deg.("0-------0-0-----"), 1),
  ], inf));
  ~mkCut = { Pseq([3, 5, 3, 9].mirror, inf).asStream };
  ~kickCut = ~mkCut.(); ~bassCut = ~mkCut.();
};

~sc[\bass_solo1] = {
  Pbindef(\all_sn,  \amp, 0);
  Pbindef(\all_hh,  \amp, 0);
  Pbindef(\all_kick,\amp, 0); 
};

Tdef(\seq, {
  ~sc[\reset].value;
  Pdef(\all).play(~link,  quant:4);

  /* section 1 */
  ~sc[\intro].value;
  4.wait;

  Pbindef(\all_hh,  \amp, 0.4);
  4.wait;
  
  /* section 2 */
  ~sc[\vrs1].value;
  16.wait;

  ~sc[\bass_solo1].value;
  4.wait;
  
  ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1,  [\bits, 6,  \rate,  8000, \mix, 0.8]);
  1.wait;
  Pdef(\v1_crush).play(~link);

  ~sc[\vrs1].value;
  16.wait;
  Pdefn(\bass_str,  1);
  Pdefn(\kick_str,  1/4);
  12.wait;
  Pdefn(\bass_str,  2);
  Pdefn(\kick_str,  1/2);
  4.wait;
  Pdef(\v1_crush).stop;
  ~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;
  Pbindef(\all_bass,  \degree,  Pn(~deg.("0101-"),  1));
  16.wait;
  ~sc[\bass_solo1].value;
  Pdefn(\bass_str,  Pseq([1,  2], inf).stutter(4));
  Pbindef(\all_bass,  \degree,  Pn(~deg.("7420-----4702-40"),  1));
  8.wait;
  ~sc[\vrs1].value;
  16.wait;
  ~sc[\intro].value;
});
);

Tdef(\seq).play(~link,  quant: 4);
Pdef(\all).stop; Tdef(\seq).stop;

(
Tdef(\alt1, {
  // ~sc[\reset].value;
  // 1.wait;
  Pbindef(\all_sn,  \amp, 0);
  Pbindef(\all_hh,  \amp, 0);
  Pbindef(\all_bass,  \amp, 0);
  Pdefn(\kick_str,  4); 
  Pbindef(\all_kick,  
    \degree,  Pseq((0..0), inf), 
    \dist,  0.6,  
    \clickAmp, 0.4, 
    \pitchMod,  0.0,  
    \pitchRel,  0.1,  
    \rel,  Pseq([0.5!3, 2].flat,   inf),   
    // \rel, 0.5,  
    \subAmp,  1.2,  
    \amp,     0.8,
  );

  Pdef(\all).play(~link);
});
)
Tdef(\alt1).play(~link,  quant: 4);
Pdef(\all).stop; Tdef(\alt1).stop;
~allMul  = (kick: 4, sn: 1, hh: 1, bass: 4);
  Pbindef(\all_sn,  \amp, 0.4);
  Pbindef(\all_hh,  \amp, 0.4);
  Pbindef(\all_bass,  \amp, 0.1);
  Pdefn(\kick_str,  1/2); 
  Pdefn(\bass_str,  1);
  Pbindef(\all_kick, \degree,  Pseq([4, 2,  1], inf), \stretch,  Pseg([1,  2,  4, 1],[4, 1, 5], \sin,  inf)/2, \dist,  0.4, \subAmp,  0.2,  \rel, 1);
  Pbindef(\all_kick, \degree,  Pseq([0, 1], inf), \stretch,  Pseq([1,  2,  4],  inf));
  Pbindef(\all_bass, \degree,  Pseq([0, 1,  2], inf), \stretch,  Place([1,  [2,  1,  3]],  inf),  \dur, 1/4);

s.freqscope;
