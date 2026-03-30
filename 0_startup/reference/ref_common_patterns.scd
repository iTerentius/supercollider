// =============================================================================
// COMMON PATTERNS
// =============================================================================

// --- Full signal chain: load samples -> pattern -> mixer -> FX -> record ---
(
// 1. load samples
~loadSamps.("~/Music/samples/drums");

// 2. define a pattern routed to a mixer channel
Pdef(\kicks, Pbind(
    \instrument, \pBm,
    \out, ~t1.inbus.index,
    \bufnum, Pfunc({ ~getSample.(\drums, \kick_01).bufnum }),
    \dur, 1,
    \amp, 0.6
));

// 3. send track to reverb return
~ensurePostSend.(~t1, ~r1, 0.2);

// 4. play
Pdef(\kicks).play(~link, quant: 4);

// 5. record stems
~stemStop = ~stemDiskStart.(
    tracks: [~t1], returns: [~r1],
    fileBase: "kick_take", clock: ~link
);

// 6. stop after 16 bars
~stemStop.(beats: 64);
)

// --- Bind LCXL knobs to FX params ---
~lcxlParam[\b5_s1_r1] = { |val|
    ~r1_fx.set(\room, val.linlin(0, 127, 0.0, 1.0));
};
~lcxlParam[\b5_s1_r2] = { |val|
    ~r1_fx.set(\damp, val.linlin(0, 127, 0.0, 1.0));
};

// --- Sidechain ducking with multi-source ~scBus ---
// ~scBus is a shared audio bus created in mixer-channel-16s.scd.
// Route any sources into it with Out.ar (additive mix), then point
// \side at ~scBus.index in a \duck Synth on the channel to duck.
(
// Route kick (t1) and snare (psd1) as combined sidechain trigger
~sc_bd  = { Out.ar(~scBus, In.ar(~t1.inbus.index,   2)) }.play;
~sc_sn  = { Out.ar(~scBus, In.ar(~psd1.inbus.index, 2)) }.play;

// Duck the biscuit return (~r3) from combined kick+snare
~duck_r3 = Synth(\duck, [
    \in,      ~r3.inbus.index,
    \side,    ~scBus.index,
    \out,     ~r3.inbus.index,
    \thresh,  0.08,
    \ratio,   4,
    \attack,  0.003,
    \release, 0.25,
    \makeup,  1.0
], ~r3.synthgroup, \addToTail);
)

// Remove a source from the sidechain without changing the duck synth
~sc_sn.free;

// Add a new source
~sc_hh = { Out.ar(~scBus, In.ar(~phh1.inbus.index, 2)) }.play;

// Adjust duck parameters live
~duck_r3.set(\ratio, 8, \release, 0.15);

// Tear down
(
~duck_r3.free;
~sc_bd.free; ~sc_sn.free; ~sc_hh.free;
)

// --- Launchpad + mixer + Pdef workflow ---
(
Pdef(\beat, Pbind(
    \instrument, \pBs,
    \out, ~t1.inbus.index,
    \bufnum, Pfunc({ ~getSample.(\breaks, \amen).bufnum }),
    \dur, 0.25
));
~lpBind.([1, 1], \beat);  // toggle from launchpad
)
