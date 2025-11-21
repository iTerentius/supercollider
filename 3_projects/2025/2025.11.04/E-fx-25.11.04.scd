/////////////////////////////////////////////////////////////////////////////
// PDEF GRAIN IN TEST (working the best)
/////////////////////////////////////////////////////////////////////////////

// grain buf
(
~g1envbuf.tryPerform(\free);
~g1envbuf = Buffer.loadCollection(
  s,
  Env([0,1,0],[0.05,1.0],[0,-4]).asSignal(512)  // power-of-two size
);
)

// synth
(
SynthDef(\st, {|out=0, freq=130, amp=0.4| 
  var sig, env;
  env = EnvGen.kr(Env.perc, doneAction: 2);
  sig = LFPulse.ar([freq, freq+2], FSinOsc.ar(0.05, 3pi/2)) * amp * env;
  Out.ar(out, sig);
}).add;
)

// synth pdef
(
Pdef(\pst, Pbind(
  \instrument, \st,
  // \amp, Pseq([1, 1, 1, 0], inf),
  \octave, Pseq([3,4], inf),
  \scale, Scale.minor, 
  \degree, Pxrand((0..7), inf),
  \dur, Pseq([[0.25!3, 0.125!6].choose, Rest(1.25)].flat,inf),
  // \legato, 0.5,
  \out, ~t6.inbus.index
));
)
Pdef(\pst).play;
Pdef(\pst).clear;
~t6_st = ~t6.play(\st);
~t6.pan_(0)

// synth channel fx
~t6_gin = ~t6.playfx(\gin1, [\envbufnum, ~g1envbuf.bufnum]);
~t6_gin.tryPerform(\free);
~t6_gin.set(\trigRate, 100, \grainDur, 0.05, \envbufnum, ~g1envbuf.bufnum, \fxMix, 1.8, \amp, 1.5);
~t6_gin.set(\level, 1);

// possible fx pdef
(
Pdef(\pgin1, Pbind(
  \instrument, \gin1,
  \trigRate, Prand((1..100), inf),
  \grainDur, Prand((0.01..1), inf),
  \dur, 0.125
));
)
Pdef(\pgin1).play;
(
SynthDef(\mcDebugMuteReturn, { |out|
    var dry;
    dry = In.ar(out, 2);
    ReplaceOut.ar(out, dry * 0);  // silence
}).add;
)
~r3_fx.free;
~r3_fx = ~r3.playfx(\gin1r);

// synth send fx
~t6_gin1 = ~t6.newPostSend(~r3, 1);
~r3.level_(1);
~r3_fx.set(\envbufnum, ~g1envbuf.bufnum);
~r3_fx.set(\trigRate, 30, \grainDur, 0.08, \amp, 1);
~t6_gin1.level_(1.2);
~t6_gin1.tryPerform(\free);
~t6_gin1.free;
////////////////////////////////////////////////////////////////////////////////
// NDEF TEST (breaks mixer channel on re-eval)
////////////////////////////////////////////////////////////////////////////////
(
var envnum = ~g1envbuf.bufnum;
Ndef(\st).clear;
Ndef(\st).fadeTime_(2);
Ndef(\st, {|freq=130, amp=0.4| LFPulse.ar([freq, freq+2], FSinOsc.ar(0.05, 3pi/2)) * amp * 0.4});
Ndef(\st)[1] = \pset -> Pbind(
  \amp, Pseq([1, 1, 1, 0], inf),
  \octave, 4,
  \scale, Scale.minor, 
  \t_gate, 0.25, 
  // \trigRate, 40,
  // \grainDur, 0.18,
  \degree, Prand([0, 2, 4, 7], inf),
  \dur, 0.25 
);
Ndef(\st)[2] = \filter -> { |in, trigRate = 40, grainDur = 0.08, pan = 0.0, amp = 0.5, envbufnum |
    var mono, wet;  // declare vars at top
    mono = in.isArray.if({ Mix(in) }, { in });   // GrainIn expects mono
    wet  = GrainIn.ar(
        numChannels: 2,
        trigger: Dust.kr(trigRate),
        dur: grainDur,
        in: mono,
        pan: pan,
        envbufnum: envnum   // must be a bufnum
    );
    wet * amp
};
)
(
Ndef(\t6, {\in1.ar([0,0])});
Ndef(\t6) <<>.in1 Ndef(\st);
)
~t6.play(Ndef(\t6));
~t6.tryPerform(\free);
Ndef(\st)[2] = nil;
Ndef(\st).set(\wet2, 1.0);
Ndef(\st).clear;
~t6.tryPerform(\free);
~t6_fx.free;
~t6_verb = ~t6.newPostSend(~r1, 1);
~t6_verb.free;
~t6_delay = ~t6.newPostSend(~r2, 1);
~t6_delay.free; 

~lcxlParam[\b1_s6_r1] = {|x| Ndef(\st).set(\grainDur, x.linlin(0, 127, 0.01, 1.0))};
~lcxlParam[\b1_s6_r2] = {|x| Ndef(\st).set(\trigRate, x.linlin(0, 127, 40, 140))};

~r2_fx.set(\mdt, 1, \dlt, 1, \dct, 1);
(
// make a good envelope table once
~g1envbuf.tryPerform(\free);
~g1envbuf = Buffer.loadCollection(
  s,
  Env([0,1,0],[0.05,1.0],[0,-4]).asSignal(512)  // power-of-two size
);

// track FX on ~t6 — use 'in', sum to mono for GrainIn
~t6_fx.tryPerform(\free);
~t6_fx = ~t6.playfx({ |in, trigRate=40, grainDur=0.08, pan=0.0, amp=0.7|
  var sig, mono, wet;
  sig  = In.ar(~t6.inbus.index, 2);
  mono = (sig[0] + sig[1]) * 0.5;
  wet  = GrainIn.ar(2, Dust.kr(trigRate), grainDur, mono, pan, ~g1envbuf.bufnum);
  wet * amp
});
)

~t6_fx.free;
~t6_fx.set(\trigRate, 50, \grainDur, 0.1);

~test.play(~t1.inbus.index);
~test.stop;
(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\in_grain_test, { |out, gate = 1, amp = 1, envbuf|
    var pan, env;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: Done.freeSelf);
    Out.ar(out,
        GrainIn.ar(2, Impulse.kr(32), 1, PinkNoise.ar * 0.05, pan, envbuf) * env)
}).add;

)

// use built-in env
x = Synth(\in_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 0);

~r1_fx = ~r1.playfx({ |in|
    var sig, wet;  // declare vars at top
    sig = In.ar(~r1.inbus.index, 2);
    wet = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.2);
    wet
});
(
// 2025-11-10 21:xx CST — GrainIn on ddwMixerChannel return, fixed

var envSig;

// make a nice grain envelope buffer (explicit size is safer)
envSig = Env([0, 1, 0], [0.5, 0.5], [8, -8]).asSignal(512);

~g1envbuf.tryPerform(\free);
~g1envbuf = Buffer.loadCollection(s, envSig);

// (Re)build the FX. Use the 'in' that playfx supplies. Keep it running (no doneAction).
~r3_fx.tryPerform(\free);
~r3_fx = ~r3.playfx({ |in, trigRate = 32, grainDur = 0.08, pan = 0.5, amp = 1|
    var mono, grains;

    // ddwMixerChannel hands you the incoming signal as 'in' (usually 2ch)
    mono = Mix(in);  // GrainIn expects mono source

    grains = GrainIn.ar(
        numChannels: 2,
        trigger: Impulse.kr(trigRate),
        dur: grainDur,
        in: mono,
        pan: pan,
        envbufnum: ~g1envbuf.bufnum
    );

    // return 2ch audio; no free-self envelope here so the FX stays alive
    grains * amp;
});
)

