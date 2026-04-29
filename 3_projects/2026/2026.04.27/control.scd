// v1
Pdef(\v1).play(~link);
Pdef(\v1).stopQ(4);
~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1,  [\bits, 6,  \rate,  8000, \mix, 0.5]);
~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;

~ilfx[\v1_ringmod] = ~fxLib[\ringmod].(~t1, [\freq, 10, \mix, 0.1]);
~ilfx[\v1_ringmod].free; ~ilfx[\v1_ringmod] = nil;

~ilfx[\v1_fold] = ~fxLib[\fold].(~t1, [\gain, 3,  \mix, 0.5]);
~ilfx[\v1_fold].free; ~ilfx[\v1_fold] = nil;

~ilfx[\v1_glitch] = ~fxLib[\glitch].(~t1, [\rate, 0.5,  \mix, 0.5]);
~ilfx[\v1_glitch].free; ~ilfx[\v1_glitch] = nil;

~ilfx[\v1_shimmer] = ~fxLib[\shimmer].(~t1, [\shift, 24,  \time,  0.5,  \mix, 0.9]);
~ilfx[\v1_shimmer].free; ~ilfx[\v1_shimmer] = nil;

~ilfx[\v1_stutter] = ~fxLib[\stutter].(~t1, [\amp, 4,  \rate,  16,  \mix, 0.9]);
~ilfx[\v1_stutter].free; ~ilfx[\v1_stutter] = nil;
// v2
Pdef(\v2).play(~link);
Pdef(\v2).stopQ(4);
~ilfx[\v2_crush] = ~fxLib[\bitcrush].(~t2,  [\bits, 6,  \rate,  8000, \mix, 0.5]);
~ilfx[\v2_crush].free; ~ilfx[\v2_crush] = nil;

~ilfx[\v2_ringmod] = ~fxLib[\ringmod].(~t2, [\freq, 20, \mix, 0.9]);
~ilfx[\v2_ringmod].free; ~ilfx[\v2_ringmod] = nil;

~ilfx[\v2_fold] = ~fxLib[\fold].(~t2, [\gain, 3,  \mix, 0.5]);
~ilfx[\v2_fold].free; ~ilfx[\v2_fold] = nil;

~ilfx[\v2_glitch] = ~fxLib[\glitch].(~t2, [\rate, 0.5,  \mix, 0.5]);
~ilfx[\v2_glitch].free; ~ilfx[\v2_glitch] = nil;

~ilfx[\v2_shimmer] = ~fxLib[\shimmer].(~t2, [\shift, 12,  \time,  0.5,  \mix, 0.5]);
~ilfx[\v2_shimmer].free; ~ilfx[\v2_shimmer] = nil;

~ilfx[\v2_stutter] = ~fxLib[\stutter].(~t2, [\amp, 5,  \rate,  32,  \mix, 1.5]);
~ilfx[\v2_stutter].free; ~ilfx[\v2_stutter] = nil;
//v3
Pdef(\v3).play(~link);
Pdef(\v3).stopQ(4);
~ilfx[\v3_crush] = ~fxLib[\bitcrush].(~t3,  [\bits, 6,  \rate,  8000, \mix, 0.5]);
~ilfx[\v3_crush].free; ~ilfx[\v3_crush] = nil;

~ilfx[\v3_ringmod] = ~fxLib[\ringmod].(~t3, [\freq, 20, \mix, 0.9]);
~ilfx[\v3_ringmod].free; ~ilfx[\v3_ringmod] = nil;

~ilfx[\v3_fold] = ~fxLib[\fold].(~t3, [\gain, 3,  \mix, 0.5]);
~ilfx[\v3_fold].free; ~ilfx[\v3_fold] = nil;

~ilfx[\v3_glitch] = ~fxLib[\glitch].(~t3, [\rate, 0.5,  \mix, 0.5]);
~ilfx[\v3_glitch].free; ~ilfx[\v3_glitch] = nil;

~ilfx[\v3_shimmer] = ~fxLib[\shimmer].(~t3, [\shift, 12,  \time,  0.5,  \mix, 1.5]);
~ilfx[\v3_shimmer].free; ~ilfx[\v3_shimmer] = nil;

~ilfx[\v3_stutter] = ~fxLib[\stutter].(~t3, [\amp, 5,  \rate,  32,  \mix, 0.9]);
~ilfx[\v3_stutter].free; ~ilfx[\v3_stutter] = nil;
// v4
Pdef(\v4).play(~link);
Pdef(\v4).stopQ(4);
~ilfx[\v4_crush] = ~fxLib[\bitcrush].(~t4,  [\bits, 6,  \rate,  8000, \mix, 0.5]);
~ilfx[\v4_crush].free; ~ilfx[\v4_crush] = nil;

~ilfx[\v4_ringmod] = ~fxLib[\ringmod].(~t4, [\freq, 20, \mix, 0.9]);
~ilfx[\v4_ringmod].free; ~ilfx[\v4_ringmod] = nil;

~ilfx[\v4_fold] = ~fxLib[\fold].(~t4, [\gain, 3,  \mix, 0.5]);
~ilfx[\v4_fold].free; ~ilfx[\v4_fold] = nil;

~ilfx[\v4_glitch] = ~fxLib[\glitch].(~t4, [\rate, 0.5,  \mix, 0.5]);
~ilfx[\v4_glitch].free; ~ilfx[\v4_glitch] = nil;

~ilfx[\v4_shimmer] = ~fxLib[\shimmer].(~t4, [\shift, 12,  \time,  0.5,  \mix, 0.5]);
~ilfx[\v4_shimmer].free; ~ilfx[\v4_shimmer] = nil;

~ilfx[\v4_stutter] = ~fxLib[\stutter].(~t4, [\amp, 5,  \rate,  8,  \mix, 0.5]);
~ilfx[\v4_stutter].free; ~ilfx[\v4_stutter] = nil;

(
Pdef(\v1_crush,  Pbind(
  \type,   \set,  
  \id,    Pfunc({ ~ilfx[\v1_crush].nodeID }), 
  \args,  #[\rate,  \bits,  \mix, \amp],
  // \rate,  Pseg([800,  8000],  [2],  \lin, inf), 
  \mix, Pseg([0.01,  1.0, 0.01], [4,  4],  \exp, inf),  
  // \mix,  Pbjorklund2(3, 8,  inf), 
  // \mix, Pseg([0.0, 1.0],[1],  \step, inf), 
  \amp, 0.8,  
  \rate,  Pseg([2500, 20000], [1],  \sin, inf),  
  \bits,  Pseg([4,  6], [3], \step,  inf),  
  // \dur, Pseq([1/4!2, 1/2,   1,  1/8!4].flat, inf), 
  \dur, Pseg([1,  1/8], [3],  \step, inf), 
  \stretch, Pn(Pdefn(\v1_durs),  inf),  
));
)
Pdef(\v1_crush).play(~link);
Pdef(\v1_crush).stopQ(4);
Pdef(\v1).clear;

~v1_2_r1.free; ~v1_2_r1 = nil;
~v1_2_r1 = ~t1.newPostSend(~r1, 0.6);
~v1_2_r3.free; ~v1_2_r3 = nil;
~v1_2_r3 = ~t1.newPostSend(~r3, 1.0);
~v2_2_r1.free; ~v2_2_r1 = nil;
~v2_2_r1 = ~t2.newPostSend(~r1, 1.0);
~v3_2_r3.free; ~v3_2_r3 = nil;
~v2_2_r3 = ~t3.newPostSend(~r3, 1.0);

~ilfx[\r1_stutter] = ~fxLib[\stutter].(~r1, [\amp, 4,  \rate,  16,  \mix, 0.9]);
Pdef(\bCtl).play(~link);
Pdef(\bCtl).stopQ(4);

(
var cut = Pseq([3,  11,  7, 5], inf).asStream;
Pdef(\all,  
  Ppar([                                                    
    Pn(Pfindur(3, Pdef(\v1)), inf),
    Pn(Pfindur(7, Pdef(\v2)), inf),                          
    Pn(Pfindur(3, Pdef(\v3)), inf),                          
  ])
);
)
Pdef(\all).play(~link);
Pdef(\all).stopQ(4);
                
