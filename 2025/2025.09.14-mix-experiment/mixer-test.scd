
// 2025-09-19 16:20 America-Chicago  mixer36 + LCXL summary  one-track one-fx + midi

// what you have loaded
// - mixer36 drop-in  gives ~m36_master  ~m36_tracks[0..8]  ~m36_fxchans[0..7]  ~m36_in.(i)
// - lcxl router      by-name CC mapping and file save-load for CC map
// - core bridge v5   safe function targets and a router installer that returns ~ccRouter
// - plan A v3        faders map to levels per bank  row-3 knobs map to pan  track-select buttons bank

// plan A mapping
// - bank 0 faders   f1 master  f2..f8 tracks 1..7  row-3 pans those same slots
// - bank 1 faders   f1..f2 tracks 8..9  f3..f8 returns 1..6  row-3 pans those slots
// - bank 2 faders   f1..f2 returns 7..8  row-3 pans those two
// - track-select    chan 8  cc 106 prev  cc 107 next  press val >= 64

// quick start  make one simple instrument on track 1  make one reverb return  send to it


// redefine mcTone with a per-event perc envelope
(
SynthDef(\mcTone, { |out=0, freq=220, amp=0.2, pan=0, sustain=0.2|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.005, sustain), doneAction:2);
    sig = SinOsc.ar(freq) * amp * env;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// pattern — sustain defaults to dur * legato
(
Pdef(\mc_ex1, Pbind(
    \instrument, \mcTone,
    \dur, 0.25,
    \legato, 0.9,            // 90 percent of dur becomes sustain
    \degree, Pseq([0, 2, 4, 7].mirror1, inf),
    \octave, 4,
    \amp, 0.25,              // keep headroom
    \pan, 0,
    \out, ~m36_in.(0)
)).play;
)

// 2025-09-19 16:55 America-Chicago  return FX hot swap  effectgroup aware
(
~m36_fxSwap = { |sendIndex=0, fxFunc|
    var ch;
    ch = ~m36_fxchans.wrapAt(sendIndex);
    if(ch.isNil) { "fxSwap no such return".postln; ^nil };
    // this clears the actual FX nodes for that return
    ch.effectgroup.freeAll;
    ch.play(fxFunc);   // ddw MixerChannel will place this in the effectgroup as an FxPatch
    "fx swapped on return ".post; sendIndex.postln;
};

~m36_fxInfo = { |sendIndex=0|
    var ch;
    ch = ~m36_fxchans.wrapAt(sendIndex);
    if(ch.isNil) { "no such fx return".postln }{
        ["return", sendIndex, "effectgroup", ch.effectgroup, "faderSynth", ch.synth].postln
    };
};
)
// load a reverb on return 1  ddw style read bus and replace
(
~m36_fxSwap.(0, { |i_out|
    var src, wet, mix=0.30, room=0.80, damp=0.30;
    src = In.ar(i_out, 2);
    wet = FreeVerb.ar(src, mix, room, damp);
    ReplaceOut.ar(i_out, wet);
});
~m36_fxInfo.(0);
)

~m36_setSend.(0, 0, 0.35);    // track 0 to send 0 at 35 percent

// swap to clear tempo repeats so you can hear the change
(
~m36_fxSwap.(0, { |i_out|
    var src, wetL, wetR, max=1.0, dt=0.375, decay=2.0;
    src = In.ar(i_out, 2);
    wetL = CombC.ar(src[0], max, dt, decay);
    wetR = CombC.ar(src[1], max, dt, decay);
    ReplaceOut.ar(i_out, [wetL, wetR]);
});
~m36_fxInfo.(0);
)


// give yourself headroom while auditioning FX
(
~m36_master.level_(0.85);
~m36_tracks[0].level_(0.6);
)

// level and pan hands-on  these match your mapped controls too

~m36_master.level_(0.9);
~m36_tracks[0].level_(0.5);
~m36_tracks[0].pan_(0);       // -1 left  0 center  1 right


// swap or stop the fx return
(
// replace the effect   just call play again on the same return
~m36_fxchans[0].play({ |i_out|
    var src, wet;
    src = In.ar(i_out, 2);
    wet = DelayC.ar(src, 0.8, 0.7); // example alt effect
    ReplaceOut.ar(i_out, wet);
});
)
// or stop that return entirely
( ~m36_fxchans[0].stop; )

// Ndef source example  if you prefer a live-coded node instead of Pbind
(
Ndef(\mc_src1, { |amp=0.15|
    var sig;
    sig = LFTri.ar([110, 111]) * amp;
    Out.ar(~m36_in.(0), sig);
}).play;
)

// midi mapping recap
// - faders f1..f8 control whatever each bank slot is assigned to  levels only
// - row 3 t1r3..t8r3 control pan for the same slots
// - track select hardware buttons move banks  bank labels are printed on install
// - rows 1 and 2 are free for your own params in the router or another include

// useful one-liners
// - change a send from code     ~m36_setSend.(trackIdx, sendIdx, level);
// - check levels                ~m36_tracks[0].level.postln;
// - mute by level               ~m36_tracks[0].level_(0);

// if you do not hear fx
// - confirm the return channel is playing      ~m36_fxchans[0].postln
// - confirm send amount is above zero          ~m36_setSend.(0, 0, 0.35)
// - confirm the track fader is not at zero     ~m36_tracks[0].level_(0.7)
