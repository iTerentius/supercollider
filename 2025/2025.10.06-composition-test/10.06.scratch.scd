
// 2025-09-22
(
SynthDef(\pitchEnv, { |out=0, freq=110, amp=0.2|
    var env, sig;
    // Envelope goes from 200Hz -> 1000Hz -> 300Hz over 1 second
    env = EnvGen.kr(
        Env([freq * 2, freq, freq], [0.2, 0.5, 1.0], \sin),
        doneAction: 2
    );
    freq = env;
    sig = SinOsc.ar(freq!2) * amp;
    Out.ar(out, sig);
}).add;
)

x = Synth(\pitchEnv);

// 2025-10-06
(
SynthDef(\glissMono, { |out=0, freq=440, glide=0.15, amp=0.2, gate=1|
    var sig, ampEnv, f;
    f = VarLag.kr(freq, glide, -0.5);  // 0 curvature = linear, try +/- for curves
    ampEnv = EnvGen.kr(Env.asr(0.01, 1, 0.2), gate, doneAction: 2);
    sig = LFPulse.ar([f+SinOsc.kr(glide), f+LFSaw.kr(glide)]) * amp * ampEnv;
    Out.ar(out, sig ! 2);
}).add;
)

// 2025-10-06
(
Pdef(\gliss, Pmono(
    \glissMono,
    \amp, Pseq([0.2, 0, 0.2, 0.2, Rest(1)], inf),
    \glide, 0.05,     // increase for slower slide
    \dur, Pseq([0.125, 0.125, 0.25, Rest(0.25)], inf),
    \scale, Scale.minor, \root, 0, \octave, 0,
    // \freq, Pseq([220, 330, 294, 392, 370, 523, 440], 2)
    // \degree, Pseq([0, 1, 4, 7, Rest()], inf);
    \degree, Pser(\C1m.asNotes, inf)
)).play;
)

Pdef(\gliss).stop;
Pdef.clear;
(
Pdef(\glissb, Pbind(
    \instrument, \syn1,
    // \amp, Pseq([0.2, 0, 0.2, 0.2, Rest(1)], inf),
    \amp, 0.4,
    \dur, Pseq([0.125, 0.125, 0.25, Rest(0.25)], inf),
    \scale, Scale.minor, \root, 0, \octave, Pseq([3, 4, 2], inf),
    // \freq, Pseq([220, 330, 294, 392, 370, 523, 440], 2)
    // \degree, Pseq([0, 1, 4, 7, Rest()], inf);
    \degree, Pser([\Cm_eb, \Fm, \Gm, \Cm_g, \Cm_eb, \Fm, \Gm_d, \Cm].chordProg.flat, inf)
    // \degree, Pser((\Cm.asNotes, \A.asNotes).flat, inf)
)).play;
)

Pdef(\glissb).stop;

// My test!!!
(
var amps = [0, 1, 5, -7, 1, 0];
~b = Buffer.allocConsecutive(4, s, 16384);
// ~wt = [
//   // Signal.chebyFill(8192, Array.rand(7, -7, 7), false, true),
//   // Signal.chebyFill(8192, Array.rand(7, -7, 7), false, true),
//   // Signal.chebyFill(8192, Array.rand(7, -7, 7), false, true),
//   // Signal.chebyFill(8192, Array.rand(7, -7, 7), false, true),
//   // Signal.chebyFill(8192, Array.rand(7, -7, 7), false, true),
//   Signal.sineFill(8192, amps.scramble, false, true),
//   Signal.chebyFill(8192, amps.scramble, true, true),
//   Signal.sineFill(8192, amps.scramble, false, false),
//   Signal.chebyFill(8192, amps.scramble, true, false)
// ];
~wt

~b.do({| buf, i| buf.loadCollection(~wt[1].asWavetable)});
)
~wt.plot;
(
SynthDef(\wavtab, { | out=0, freq=0, amp=1 |
	var sig1, sig2, bufmod;
	bufmod = SinOsc.ar(0.1, 3pi/2).unipolar(2.999);
	// bufmod = LFSaw.kr(0.05).unipolar(2.999);
	sig1 = VOsc.ar(~b[0].bufnum + bufmod, freq) * amp;
	sig2 = VOsc.ar(~b[0].bufnum + bufmod, freq-0.1) * amp;
	// sig = sig * 0.2 ;
  Splay.ar([sig1, sig2]);
}).add;
)
Pdef(\wt_pat, Pbind(\degree, Prand([0, 2, 4, 7],inf), \dur, 0.25, \octave, 4, \sustain, 1, \out, ~t2.inbus.index)).play;
Pdef(\wt_pat).stop;

Ndef(\mod, {SinOsc.kr(1, 3pi/2)});
~t2_filt = ~t2.playfx({|outbus| BPF.ar(In.ar(outbus, 2), SinOsc.ar(0.05, 3pi/2).unipolar.exprange(100, 1500), 0.1) * 0.5});
~t2_filt.set(\level, 1);
~t2_filt.set(\wet, 0.5);
~t2_filt.free;
FreqScope.new;
(
Ndef(\wavtab, { | freq=0 |
	var sig1, sig2, bufmod;
	bufmod = SinOsc.ar(0.1, 3pi/2).unipolar(2.999);
	// bufmod = LFSaw.kr(0.05).unipolar(2.999);
	sig1 = VOsc.ar(~b[0].bufnum + bufmod, freq);
	sig2 = VOsc.ar(~b[0].bufnum + bufmod, freq-0.1);
	// sig = sig * 0.2 ;
  Splay.ar([sig1, sig2], 1, 3.3);
});
Ndef(\wavtab)[1] = Pbind(\degree, Prand([0, 2, 4, 7],inf), \dur, 0.25, \octave, 4, \sustain, 1);
Ndef(\wavtab)[2] = \filter -> {|in| BPF.ar(in, SinOsc.ar(0.05, 3pi/2).unipolar.exprange(100, 1500), 0.1)};
)
Ndef(\wavtab)[2] = nil;
Ndef(\wavtab).set(\bmod, Ndef(\mod));
Ndef(\wavtab).play;
Ndef(\wavtab).clear;
Ndef(\mod, {SinOsc.kr(1, 3pi/2)});



Quarks.uninstall("https://github.com/triss/ChordSymbol");
Quarks.install("https://github.com/madskjeldgaard/HarmonicToolkitSC");Quarks.install("Bjorklund");
// 2025-10-07
(
Ppar([
    ~peuc.(\default, 0.0833333333, 5, 12, 0, [-12], 0.22, 0.02, ()),           // 1/12 beat steps
    ~peuc.(\default, 0.125,        3,  8, 1,   [0], 0.18, 0.00, (pan: -0.25))  // 1/8 beat steps
]).play;
)
// 2025-10-07
(
~peuc.(\default, 0.3333333333, 4, 9, 2, [7, 9, 11, 12], 0.14, 0.0, (octave: 6)).play;
)
// 2025-10-07
(
Ppar([
    ~peuc.(\default, 0.0833333333, 5, 12, 0, [-12], 0.22, 0.02, ()),           // 1/12 beat steps
    ~peuc.(\default, 0.125,        3,  8, 1,   [0], 0.18, 0.00, (pan: -0.25))  // 1/8 beat steps
]).play;
)
(
Pbind(
    \instrument, \default,
    \degree, Pser([0,2,4,7,9], inf),
    \dur, 0.25,
    \isRest, ~peucmask.(5, 16, 3),   // five hits spread over sixteen
    \amp, 0.16
).play;
)
