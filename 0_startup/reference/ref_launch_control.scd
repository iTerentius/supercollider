// =============================================================================
// LAUNCH CONTROL (small)  (lc-lcxl-router-revamp.scd)
// =============================================================================
// Globals: ~lcn, ~lcOut, ~lcUID
//
// Hardware notes:
//   - Factory template 1 uses MIDI channel 8 (stored in ~lcn[\chan0])
//   - Bank buttons send noteOff (not noteOn): notes 9,10,11,12,25,26,27,28
//   - Knobs send CC on channel 8: row 1 = CC 21-28, row 2 = CC 41-48
//   - Callback receives raw MIDI value 0-127

// --- Param binding (knobs, 2 rows of 8) ---
// Keys: \b<bank>_s<strip>_r1  and  \b<bank>_s<strip>_r2
//   bank  = 1-8
//   strip = 1-8
~lcn[\b1_s1_r1] = { |val| ("knob row 1, strip 1: " ++ val).postln };
~lcn[\b1_s1_r2] = { |val| ("knob row 2, strip 1: " ++ val).postln };

// Map a knob to a synth param:
~lcn[\b1_s3_r1] = { |val|
    ~r1_fx.set(\room, val.linlin(0, 127, 0.0, 1.0));
};

// --- Bank switching ---
// Banks 1-8 selected via top row buttons (noteOff: 9-12, 25-28)
// ~lcn[\bankIdx] holds current bank (1-based)

// --- LED control ---
// LEDs addressed on channel 8 (same as device), velocity = color
// ~lcn[\palette] = (selected: 127, unselected: 10)
~lcn[\refreshLEDs].();
// Manual LED: ~lcOut.noteOn(8, noteNum, colorVelocity);
