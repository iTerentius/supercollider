// =============================================================================
// LAUNCHPAD MINI MK3  (lp-param-router.scd)
// =============================================================================
// Globals: ~lpMini, ~lpBind

// --- Bind a Pdef/Tdef/Ndef to a grid pad ---
// Pads addressed as [row, col] where row 1 = bottom, col 1 = left
// Or as raw MIDI note number
~lpBind.([1, 1], \myPdef);            // bottom-left pad
~lpBind.([2, 3], \myNdef, 81);        // with custom LED color
~lpBind.([1, 4], \myTdef, nil, ~link, 4);  // with clock and quant

// Full signature:
// ~lpBind.(ref, key, color=nil, clock=nil, quant=nil)
//   ref   = [row, col] or MIDI note (11-88)
//   key   = \pdefName, \ndefName, \tdefName, a Function, or a String
//   color = LED velocity color (0-127), nil for default
//   clock = TempoClock for play (default ~link)
//   quant = quantization (default 4)

// --- Bind a function or code string ---
~lpBind.([3, 1], { "hello".postln });
~lpBind.([3, 2], "Pdef(\\x).play");   // evaluated on press

// --- Scene / column launch ---
// Right-side buttons launch all pads in that row (scene)
// Top buttons launch all pads in that column

// --- Stateful FX send toggle (single pad, flashes when active) ---
// Use a Tdef so the LP Mini watcher can track isPlaying for LED state.
// protect{} ensures the send is freed when the Tdef is stopped.
Tdef(\bd1_fxSend, {
    protect {
        ~bd1_t.free;
        ~bd1_t = ~ensurePostSend.(~pbd1, ~r4, 1);
        inf.wait;
    } {
        ~bd1_t.tryPerform(\free);
        ~bd1_t = nil;
    }
});
~lpBind.([8, 1], \bd1_fxSend, 35);  // pulses when on, static when off
// The same Tdef can also be bound on the APC40 — both LEDs stay in sync:
// ~apcBind.(32, \bd1_fxSend, 4, \amber, \green);

// --- Clear grid ---
~lpMini[\clearGrid].();

// --- LED colors (built-in palette) ---
// ~lpMini[\colors] = (empty: 0, pdefDefault: 9, ndefDefault: 95,
//                     funcDefault: 13, trigger: 21)
// Playing pads pulse, stopped pads are static
