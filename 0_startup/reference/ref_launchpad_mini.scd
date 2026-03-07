// =============================================================================
// LAUNCHPAD MINI MK3  (lp-param-router.scd v15)
// =============================================================================
// Globals: ~lpMini, ~lpBind, ~lpBindB

// --- Bind to ACTIVE bank (unchanged API) ---
~lpBind.([1, 1], \myPdef);                        // bottom-left pad, active bank
~lpBind.([2, 3], \myNdef, 81);                    // with custom LED color
~lpBind.([1, 4], \myTdef, nil, ~link, 4);         // with clock and quant
~lpBind.([5, 1], \fxTdef, 41, nil, nil, stopFn);  // with onStop function

// Full signature:
// ~lpBind.(ref, key, color=nil, clock=nil, quant=nil, onStop=nil)
//   ref    = [row, col] (row 1=bottom, col 1=left) or raw MIDI note 11-88
//   key    = \pdefName, \tdefName, \ndefName, a Function, or a String
//   color  = LED velocity color (0-127), nil for default
//   clock  = TempoClock for play (default ~link)
//   quant  = quantization (default 4)
//   onStop = Function called instead of obj.stop when toggling off

// --- Bind to a SPECIFIC bank ---
// ~lpBindB.(bank, ref, key, color=nil, clock=nil, quant=nil, onStop=nil)
~lpBindB.(1, [1, 1], \kick,  9);     // bank 1, pad [1,1]
~lpBindB.(2, [1, 1], \snare, 21);    // bank 2, same pad position → different binding
~lpBindB.(3, [3, 4], \myNdef, 95);   // bank 3

// Switch banks programmatically:
~lpMini[\switchBank].(2);            // jump to bank 2
~lpMini[\bank].postln;               // read current bank index (1-8)

// Hardware bank navigation:
// Left button  (CC 93) → bank - 1  (lit white when bank > 1, off at boundary)
// Right button (CC 94) → bank + 1  (lit white when bank < 8, off at boundary)

// --- Scene / column launch ---
// Right-side buttons (CC 89,79..19) → launch all pads in that row (scene)
// Top buttons (CC 91,92,95-98)      → launch all pads in that column
//   CC 93 (Left) and CC 94 (Right) are reserved for bank navigation

// --- Stateful FX send toggle (onStop pattern) ---
// protect{} does NOT fire on thread kill — use ~makeFxSendTdef instead:
~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1));

// --- Utilities ---
~lpMini[\clearGrid].();              // clear all LEDs (repaints bank LEDs after)
~lpMini[\paintBankLEDs].();          // re-light Left/Right nav buttons

// --- LED colors (built-in) ---
// ~lpMini[\colors] = (empty: 0, pdefDefault: 9, ndefDefault: 95,
//                     funcDefault: 13, trigger: 21, bankOn: 17, bankOff: 0)
// Playing pads pulse (channel 2), stopped pads are static (channel 0)

// --- Bank layout tip ---
// Use ~lpBindB to set up all 8 banks at project load time, e.g.:
// ~lpBindB.(1, [1,1], \kick);  ~lpBindB.(1, [1,2], \snare);  // bank 1 = drums
// ~lpBindB.(2, [1,1], \bass);  ~lpBindB.(2, [1,2], \melody); // bank 2 = synths
// Then Left/Right buttons navigate between them live.
