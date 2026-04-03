// analog_synthdefs.scd — SynthDef wrappers around ~ufn functions (defined in ufn_defs.scd)
// Each SynthDef is just Out.ar + ~ufn call — all params live in ufn_defs.scd.
// Requires ufn_defs.scd to be loaded first.
//
// To prototype any of these in an Ndef:
//   Ndef(\x, ~ufn[\moogLead]);
//   Ndef(\x).set(\freq, 880, \cutoff, 1200);
//
// doneAction: Pbind's default event sends \doneAction=2 → synth self-frees after envelope.

(
SynthDef(\moogLead,   { Out.ar(\out.kr(0), ~ufn[\moogLead].())   }).add;
SynthDef(\junoChord,  { Out.ar(\out.kr(0), ~ufn[\junoChord].())  }).add;
SynthDef(\prophetLead,{ Out.ar(\out.kr(0), ~ufn[\prophetLead].())}).add;
SynthDef(\acidBass,   { Out.ar(\out.kr(0), ~ufn[\acidBass].())   }).add;
SynthDef(\ms20Bass,   { Out.ar(\out.kr(0), ~ufn[\ms20Bass].())   }).add;
SynthDef(\sh101Lead,  { Out.ar(\out.kr(0), ~ufn[\sh101Lead].())  }).add;
SynthDef(\kik808, ~ufn[\808][\kik]).add;
SynthDef(\sn808, ~ufn[\808][\sn]).add;
SynthDef(\hh808, ~ufn[\808][\hh]).add;
"analog_synthdefs loaded.".postln;
)
