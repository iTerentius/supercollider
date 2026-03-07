// thingA — custom synth
// Re-eval this file to reset voice to defaults (story overrides live in arrangement.scd).
(
///////////////////////////////////////////////////////////////
// SYNTHDEF
///////////////////////////////////////////////////////////////
SynthDef(\thingA, { |freq=110, amp=0.1, gate=1, mod1=1, mod2=1, out=0|
    var sig    = SinOsc.ar([freq, freq+2] * mod1);
    var sigMod = VarSaw.ar([freq*0.25, freq*0.75] * LFPulse.ar(mod2 / mod1.sqrt), mod2);
    sig = sig * sigMod;
    sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001, 0, 1, 0.01, 1, -1)), gate, doneAction: 2);
    sig = sig * AmpComp.kr(freq);
    Out.ar(out, sig * 0.1);
}).add;

///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////
Pdef(\thingA,
    Pbind(
        \instrument, \thingA,
        \scale,      Pn(Pdefn(\thingA_scale), inf),
        \octave,     Pn(Pdefn(\thingA_octs),  inf),
        \degree,     Pn(Pdefn(\thingA_degs),  inf),
        \mod1,       Pn(Pdefn(\thingA_mod1),  inf),
        \mod2,       Pn(Pdefn(\thingA_mod2),  inf),
        \amp,        Pn(Pdefn(\thingA_amps),  inf),
        \delta,      Pn(Pdefn(\thingA_delta), inf),
        \stretch,    Pn(Pdefn(\thingA_strs),  inf),
        \dur,        Pn(Pdefn(\thingA_durs),  inf),
        \out,        Pn(Pdefn(\thingA_out),   inf),
    )
);

///////////////////////////////////////////////////////////////
// PDEFNS
///////////////////////////////////////////////////////////////
Pdefn(\thingA_out,   ~t4.inbus.index);
Pdefn(\thingA_scale, Scale.minor);

// OCTS — words
Pdefn(\thingA_oct_0, 3);
// story
Pdefn(\thingA_octs, Pseq([Pn(Pdefn(\thingA_oct_0), 4)], 1));

// AMPS — words
Pdefn(\thingA_amp_0, 1);
Pdefn(\thingA_amp_1, Pwhite(0.5, 0.8, 1));
// story
Pdefn(\thingA_amps, Pseq([Pn(Pdefn(\thingA_amp_0), 4)], 1));

// DEGS — words
Pdefn(\thingA_deg_0, 0);
Pdefn(\thingA_deg_1, Pseq([Pseq([0, 1, 4, 2], 1), Rest()*4], 1));
// sentences
Pdefn(\thingA_degs_A, Pseq([Pn(Pdefn(\thingA_deg_1), 4)], 1));  // riff
Pdefn(\thingA_degs_B, Pseq([Pn(Pdefn(\thingA_deg_0), 4)], 1));  // held root
// story
Pdefn(\thingA_degs, Pseq([Pn(Pdefn(\thingA_degs_A), 1)], 1));

// DURS — words
Pdefn(\thingA_dur_0, 4);
// sentences
Pdefn(\thingA_durs_A, Pseq([Pn(Pdefn(\thingA_dur_0), 4)], 1));  // whole phrases
// story
Pdefn(\thingA_durs, Pseq([Pn(Pdefn(\thingA_durs_A), 1)], 1));

// DELTA — words
Pdefn(\thingA_delta_0, 1);
Pdefn(\thingA_delta_1, 1/(Pkey(\dur) * 2));
// story
Pdefn(\thingA_delta, Pseq([Pn(Pdefn(\thingA_delta_1), 4)], 1));

// STRS — words
Pdefn(\thingA_str_0, 1/2);
// story
Pdefn(\thingA_strs, Ppatlace([
    Pn(Pdefn(\thingA_str_0), 4),
    Pn(Pdefn(\bd1_strs),     4),
], 1));

// MODS — words
Pdefn(\thingA_mod1_0, 1);
Pdefn(\thingA_mod1_1, Pseg([1, 5.0, 3.5], [2, 4], \sin, 1));
Pdefn(\thingA_mod1_2, Pseq([0.1, 8.0, 2.5], 1));
Pdefn(\thingA_mod1, Pseq([Pn(Pdefn(\thingA_mod1_1), 4)], 1));

Pdefn(\thingA_mod2_0, 1);
Pdefn(\thingA_mod2_1, Pseg([5, 3.0, 0.5], [3, 4], \sin, 1));
Pdefn(\thingA_mod2_2, Pseq([0.5, 8.0, 3.5], 1));
Pdefn(\thingA_mod2, Pseq([Pn(Pdefn(\thingA_mod2_1), 4)], 1));
)
