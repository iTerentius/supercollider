
(
Ndef(\s1, { | freq=100, m=1 |
  var sig, env;
  sig = Saw.ar([freq, freq +2]) * m;
  sig;
});
)
Ndef(\s1).play;
Ndef(\s1).stop;
Ndef(\s1).clear;

Ndef(\k1, { |mod=9| SinOsc.kr(mod)});
Ndef(\s1).map(\mod, Ndef(\k1));

Ndef(\s1).set(\modu, 20);

~ccb.(\b0_s1_r1, Ndef(\s1), \m, #[1, 100] );

(
// 2025-09-25  inspect lcxl router state v2
var d, keys, uid;

d = ~lcxlLite;
if(d.isNil) { "[lcxl] router is nil".postln; ^nil };

keys = d.keys.as(Array);
"lcxl dict keys".postln; keys.sort.postln;
["bank", d[\bank]].postln;
["inChan0", d[\cfg].at(\inChan), "strict", d[\cfg].at(\strict)].postln;
["bankNotes", d[\bankNotes]].postln;
["r1_cc", d[\r1_cc]].postln;
["r2_cc", d[\r2_cc]].postln;
["f_cc",  d[\f_cc ]].postln;
uid = d[\srcID].notNil.if({ d[\srcID].uid }, { nil });
["srcID uid", uid].postln;
)

(
// 2025-09-25  cc sniffer by uid v2
var lcxlUID;

MIDIdef.free(\peek_cc_all);
lcxlUID = (~lcxlLite.notNil and: { ~lcxlLite[\srcID].notNil }).if({ ~lcxlLite[\srcID].uid }, { nil });

MIDIdef.cc(\peek_cc_all, { |val, cc, chan, src|
    var tag, uid;
    uid = src.notNil.if({ src.uid }, { -1 });
    tag = (lcxlUID.notNil and: { uid == lcxlUID }).if({ "LCXL" }, { "other" });
    ["cc", tag, "cc", cc, "val", val, "chan0", chan, "uid", uid].postln;
});
)
(
// 2025-09-25  tee ccEmit v2
var old;

if(~ccEmit.notNil) {
    old = ~ccEmit;
    ~ccEmit = { |key, val|
        ["~ccEmit", key, val].postln;
        old.(key, val);
    };
    "ccEmit tee installed".postln;
} {
    "[hub] ~ccEmit is nil. load cc_bind_hub first".postln;
}
)
(
// 2025-09-25  cc sniffer by uid safe
var lcxlUID;

MIDIdef.free(\peek_cc_all);

lcxlUID = (~lcxlLite.notNil and: { ~lcxlLite[\srcID].notNil })
    .if({ ~lcxlLite[\srcID].uid }, { nil });

MIDIdef.cc(\peek_cc_all, { |val, cc, chan, src|
    var uid, tag;
    uid = src.respondsTo(\uid).if({ src.uid }, { src.asInteger });  // handle Integer src
    tag = (lcxlUID.notNil and: { uid == lcxlUID }).if({ "LCXL" }, { "other" });
    ["cc", tag, "cc", cc, "val", val, "chan0", chan, "uid", uid].postln;
});
)
(
// 2025-09-25  tee ~ccEmit
var old;
if(~ccEmit.notNil) {
    old = ~ccEmit;
    ~ccEmit = { |key, val|
        ["~ccEmit", key, val].postln;
        old.(key, val);
    };
    "ccEmit tee installed".postln;
} {
    "[hub] ~ccEmit is nil. load cc_bind_hub first".postln;
}
)

(
// 2025-09-25  quick binding demo
var spec;
Ndef(\s1, { |amp = 0.2| PinkNoise.ar(amp) }).play;
spec = ControlSpec(0, 1, \lin, 0, 0);

// row-1 knob 1 on bank 0
~ccBindParam.(\b0_r1_1, \s1, \amp, spec);

// if you want strip1 fader instead, use:
// ~ccBindParam.(\b0_f1, \s1, \amp, spec);
)

MIDIdef.free(\peek_cc_lcxl);
(
// 2025-09-25  free old lcxl handlers, then re-arm
var names, freed;

names = MIDIdef.all.keys.as(Array);
"all MIDIdef keys".postln; names.sort.postln;

// free any defs whose names look lcxl related
freed = names.select { |k| k.asString.contains("lcxl") or: { k.asString.contains("lite") } };
"freeing".postln; freed.do { |k| MIDIdef.free(k) };

// also free our peeks to avoid noise
MIDIdef.free(\peek_cc_all);
MIDIdef.free(\peek_cc_lcxl);
MIDIdef.free(\peek_cc_lcn);

// re-arm the current router only
~lcxlLite[\armBank].value;
~lcxlLite[\armCC].value;

// optional strict channel, if your LCXL sends only on ch 9 one-based
~lcxlLite[\cfg].put(\strict, true);
"[lcxl] re-armed, strict channel on".postln;
)
(
// 2025-09-25  minimal proof bind for the exact control you moved
var spec;
Ndef(\s1, { |amp = 0.2| PinkNoise.ar(amp) }).play;
spec = ControlSpec(0, 1, \lin, 0, 0);
~ccBindParam.(\b0_r1_1, \s1, \amp, spec);
"[hub] bound b0_r1_1 -> s1:amp".postln;
)
(
// 2025-09-25  different target on bank 1
var spec;
Ndef(\s2, { |cutoff = 1000| RLPF.ar(WhiteNoise.ar(0.2), cutoff, 0.2) }).play;
spec = ControlSpec(100, 8000, \exp, 0, 1000);
~ccBindParam.(\b1_r1_1, \s2, \cutoff, spec);
"[hub] bound b1_r1_1 -> s2:cutoff".postln;
)
