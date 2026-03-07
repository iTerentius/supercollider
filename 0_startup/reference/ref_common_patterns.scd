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
