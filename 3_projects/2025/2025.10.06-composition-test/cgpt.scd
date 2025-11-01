
/* Fills and breaks with segmented patterns - 2025-09-18 America-Chicago */

    ~scale = Scale.dorian;
    ~root = 0;
(
    // ------ SynthDefs ------
    SynthDef(\kick, { |out=0, amp=0.9, f=48, rel=0.35|
        var sig, env, penv, click, cenv;
        env  = Env.perc(0.001, rel).kr(doneAction:2);
        penv = Env([f*2, f], [0.05]).kr;
        cenv = Env.perc(0.001, 0.02).kr;
        sig  = SinOsc.ar(penv) * env;
        click = BPF.ar(WhiteNoise.ar, 4000, 0.6) * cenv * 0.25;
        sig  = LPF.ar(tanh((sig + click) * 4), 700);
        Out.ar(out, (sig ! 2) * amp);
    }).add;
  )
  (
    SynthDef(\sn, { |out=0, amp=0.6|
        var env, tone, noise, sig;
        env  = Env.perc(0.001, 0.22).kr(doneAction:2);
        tone = SinOsc.ar(190) * Env.perc(0.001, 0.07).kr * 0.25;
        noise = HPF.ar(BPF.ar(WhiteNoise.ar, 6000, 0.6), 200) * 0.9;
        sig = (tone + noise) * env;
        Out.ar(out, (sig ! 2) * amp);
    }).add;
  )
  (
    SynthDef(\hat, { |out=0, amp=0.22, rel=0.07|
        var env, src;
        env = Env.perc(0.001, rel).kr(doneAction:2);
        src = HPF.ar(BPF.ar(WhiteNoise.ar, 9000, 0.5), 6000);
        Out.ar(out, (src ! 2) * env * amp);
    }).add;
  )
  (
    SynthDef(\bass, { |out=0, freq=55, amp=0.22, sus=0.35|
        var env, sig;
        env = Env.perc(0.01, sus).kr(doneAction:2);
        sig = LPF.ar(LFSaw.ar([freq, freq*0.999]) * 0.5, 1200) * env;
        Out.ar(out, sig * amp);
    }).add;
  )
    s.sync;
      
    // ------ One bar building blocks ------
    // Bar length here is 1 beat of total \dur = 1 since we use sixteenths at 0.25
    // Main groove for each voice
    ~kGroove = Pbind(
        \instrument, \kick,
        \dur, 0.25,
        \legato, 1,
        \amp, 0.6,
        \degree, Pseq([ \rest,  \rest,  \rest,  \rest,
                        0,       \rest,  \rest,  \rest,
                        0,       \rest,  \rest,  \rest,
                        0,       \rest,  \rest,  \rest ], 1)
    );

    ~sGroove = Pbind(
        \instrument, \sn,
        \dur, 0.25,
        \amp, 0.8,
        \degree, Pseq([ \rest, \rest, \rest, \rest,
                        \rest, \rest, \rest, \rest,
                        7,     \rest, \rest, \rest,
                        \rest, \rest, \rest, \rest ], 1)
    );

    ~hGroove = Pbind(
        \instrument, \hat,
        \dur, 0.25,
        \amp, Pseq([0.28, 0.14, 0.22, 0.16, 0.26, 0.14, 0.22, 0.16, 0.28, 0.14, 0.22, 0.16, 0.28, 0.14, 0.22, 0.18], 1)
    );

    ~bGroove = Pbind(
        \instrument, \bass8,
        \scale, ~scale, \root, ~root,
        \octave, 4,
        \dur, 0.5,
        \degree, Pseq([0, 0], 1),
        \amp, 0.22
    );

    // One bar fill variants
    ~kFill = Pbind(
        \instrument, \kick,
        \dur, Pseq([0.25, 0.25, 0.25, 0.25,  0.25, 0.25, 0.25, 0.25,  0.125, 0.125, 0.125, 0.125,  0.5], 1),
        \degree, 0,
        \amp, 0.8 
    );

    ~sFill = Pbind(
        \instrument, \sn,
        \dur, 0.25,
        \amp, 0.8,
        \degree, Pseq([ \rest, \rest, \rest, \rest,
                        \rest, 7,     \rest, 7,
                        \rest, 7,     \rest, 7,
                        \rest, 7,     7,     7 ], 1)
    );

    ~hFill = Pbind(
        \instrument, \hat,
        \dur, Pseq([0.25, 0.25, 0.25, 0.25,  0.125, 0.125, 0.125, 0.125,  0.5], 1),
        \amp, 0.24
    );

    ~bFill = Pbind(
        \instrument, \bass8,
        \scale,  ~scale, \root, ~root,
        \octave, 5,
        \dur, Pseq([0.5, 0.5], 1),
        \degree, Pseq([0, -1], 1),  // walk down into next phrase
        \amp, 0.24
    );

    ~bGroove.play;
    ~bFill.play;
    // ------ Assemble sections ------
    // A section is 1 bar of the Ppar below
    ~grooveBar = Ppar([~kGroove, ~sGroove, ~hGroove, ~bGroove]);
    ~fillBar   = Ppar([~kFill,   ~sFill,   ~hFill,   ~bFill]);
(
    // Seven bars groove then one bar fill, loop forever
    Pdef(\band, Pseq([
        Pfindur(7, ~grooveBar),   // 7 bars main groove
        Pfindur(1, ~fillBar)      // 1 bar fill
        // To insert a clean break bar instead of the fill, swap the previous line with:
        // Pfindur(1, Psilence())  // full one bar rest for all voices
    ], inf));
  )  
    Pdef(\band).play(quant:4);

