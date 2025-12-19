
~loadSamps.("~/Music/supercollider/_samples/_mono/");
~sTree;
~fbufs;

~loadSamps.("~/Music/supercollider/_samples/_mono/hoarder_mono/");
~loadSamps.("~/Music/supercollider/_samples/Codeine_Drum_Kit/DrumLoops/");
~samp= ~sTree[\_mono][\Ya_Ya_125bpm_Vox];
~samp= ~sTree[\jttcot][\04];
~samp= ~sTree.at(\jttcot).asArray;
~samp= ~sTree.at(\hoarder_mono).asArray[20];
~samp= ~sTree[\drumloops][\DrumLoop_DeepSea_93BPM];
~samp= ~sTree[\drumloops][\DrumLoop_Sprite1_120BPM];

~samp= ~fbufs[\jttcot][0].postln;
~buffers.postln;
~sTree[\jttcot][\01];

/////////////////////////////////////////////////////////////
// Stretched Grain
/////////////////////////////////////////////////////////////
(
// ~buffers = ~sTree[\jttcot][\00];
// ~buffers = ~sTree.at(\jttcot).asArray;
~buffers= ~sTree.at(\_mono).asArray;
// ~bufnums = ~fbufs[\jtccot];
Pdef(\c000, Pbind( 
    \instrument, \stretchedFragments,
    \buf,  Pseq(~buffers, inf),   
    \bufnum,  Pfunc{|ev| ev[\buf].bufnum},
    \start, Pfunc{|ev| (ev[\buf].numFrames * 0.7).rand},
    \delta, Pwhite(0.2, 1.5, inf),
    \time, Pkey(\delta),
    \stretch, Pexprand(1.0, 4.4, inf),
    \amp, 0.4,
    \attack, 0.3,
    \decay, 0.2,  
    \dur,  Pseq([1/2, \, ], inf),   
    // \dur,  Pn(Pdefn(\a000_durs),  inf),   
    \out,  2, 
  )
);
)
Pdef(\c000).play(out:2);
Pdef(\c000).stop;
Pdef(\c000).clear;

/////////////////////////////////////////////////////////////
// Chopped Grain
/////////////////////////////////////////////////////////////
(
var env = Env.new([0, 1, 0], [0.01, 1], [0, -4]);
~grainenv = Buffer.loadCollection(s, env.discretize(8192));
)
~loadSamps.("~/Music/supercollider/_samples/_mono/");
~samp1 = ~sTree.at(\hoarder_mono).asArray[4];
~samp1 = ~sTree.at(\hoarder_mono).asArray;
~samp1 = ~sTree.at(\jttcot).asArray;
~samp1 = ~sTree.at(\_mono).asArray;
~samp1 = ~getSample.(\_mono, \Ya_Ya_125bpm_Vox);
~samp1 = ~getSample.(\hoarder_mono, \n);
~samp1 = ~sTree[\jttcot][\00];
(
Pdef(\c100, 
  Pbind(
    \instrument, \gb1, 
    \dur, Pseq([4, Rest()],inf), 
    \amp, 1, 
    \trig_rate, 32, 
    \buf, Pseq(~samp1,  inf).stutter(1), 
    \env, ~grainenv, 
    \grain_dur, Prand([0.05, 0.125, 0.25, 0.5],inf), 
    \rate, Prand([-3, 2, -1, 2],inf), 
    \out, 2,  
  )
);
)
s.plotTree;
Pdef(\c100).play(~link,  quant:4, out: 2);
Pdef(\c100).stop;

