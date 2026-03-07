// =============================================================================
// LAUNCH CONTROL XL  (lc-lcxl-router-revamp.scd)
// =============================================================================
// Globals: ~lcxlParam, ~lcxlOut, ~lcxlUID, ~lcxlBindPdef

// --- Param binding (faders, knobs) ---
// Keys: \b<bank>_s<strip>_<slot>
//   bank  = 1-8
//   strip = 1-8
//   slot  = f (fader), r1 (knob row 1), r2 (row 2), r3 (row 3 / pan)
//
// Callback receives raw MIDI value 0-127:
~lcxlParam[\b1_s1_f] = { |val|
    ~t1.level_(val.linlin(0, 127, 0.0, 1.0));
};
~lcxlParam[\b1_s1_r3] = { |val|
    ~t1.pan_(val.linlin(0, 127, -1, 1));
};

// Use r1/r2 for send levels or FX params:
~lcxlParam[\b1_s1_r1] = { |val|
    // e.g. reverb send level for track 1
    ~t1r1send.level_(val.linlin(0, 127, 0.0, 1.0));
};

// --- Pdef launcher (pad buttons) ---
// Keys: \b<bank>_s<strip>_p
// Bind a Pdef to a pad button:
~lcxlBindPdef.(\b1_s1_p, \myPattern);
// Press the pad to toggle play/stop. LEDs reflect state.

// --- Bank switching ---
// Banks 1-8 selected via hardware buttons (notes 73-76, 89-92)
// ~lcxlParam[\bankIdx] holds current bank (1-based)

// --- LED refresh ---
~lcxlParam[\refreshLEDs].();
