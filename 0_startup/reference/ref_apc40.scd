// =============================================================================
// APC40 mkII  (_midi-ctrl/apc40/apc40mk2_loader.scd)
// =============================================================================
// Globals: ~apcOut, ~apcPadMap, ~apcColors, ~apcBank, ~apcParamBindings
// Loads: apc_boot_all.scd, apc_device_knobs.scd, apc_pad_extensions.scd

// --- Grid Layout ---
// 5 rows x 8 columns of clip launch pads (notes 0-39)
// Row 0 (top):    32,33,34,35,36,37,38,39
// Row 1:          24,25,26,27,28,29,30,31
// Row 2:          16,17,18,19,20,21,22,23
// Row 3:           8, 9,10,11,12,13,14,15
// Row 4 (bottom):  0, 1, 2, 3, 4, 5, 6, 7

// --- Bind a Pdef/Tdef/Ndef/Function to a pad ---
~apcAssignPad.(32, \myPdef);          // top-left pad
~apcBind.(33, \myNdef, 4, \blue);     // with quant and color
~apcBind.(34, \myTdef, 4, \red, \brightRed);  // stopped/playing colors
~apcBind.(35, { "triggered".postln });        // function (one-shot)

// Full signature:
// ~apcBind.(note, key, quant=4, color=nil, playColor=nil)
//   note      = pad note number (0-39)
//   key       = \pdefName, \ndefName, \tdefName, Function, or String
//   quant     = quantization (default 4)
//   color     = LED color when stopped (Symbol or 0-127)
//   playColor = LED color when playing (optional, defaults to brighter)

// --- Available colors ---
~apcShowColors.();                    // list all color names
// Common: \off, \red, \orange, \yellow, \green, \cyan, \blue, \purple, \pink
// Each has \dim* and \bright* variants (e.g., \dimRed, \brightRed)
// Hot colors: \hotRed, \hotOrange, \hotYellow, \hotGreen

// --- Scene launch (right-side buttons) ---
// Notes 82-86 trigger rows 0-4 (all pads in row toggle together)
~apcAssignScene.(82, 0);              // scene button -> row 0
// Default: scenes 82-86 auto-assigned to rows 0-4

// --- Stop buttons ---
// Note 52 on channels 0-7 stops columns 0-7
// Note 81 = stop all
~apcAssignStopColByChan.(0, 0);       // chan 0 -> col 0
~apcAssignStopAll.(81);               // stop-all button
// Defaults auto-assigned at boot

// --- Bank switching (8 banks) ---
// Bank buttons (note 50 on channels 0-7) select current bank
// ~apcBank holds current bank (0-7)
// All fader/knob bindings are bank-relative

// --- Fader bindings ---
// Keys: \b<bank>_s<strip>_f  (bank 0-7, strip 1-8)
// Master fader: \master_f
// Callback receives normalized 0.0-1.0:
~apcBindParam.(\b0_s1_f, { |x| ~t1.level_(x) });
~apcBindParam.(\b0_s2_f, { |x| ~t2.level_(x) });
~apcBindParam.(\master_f, { |x| ~m1.level_(x * 4) });

// --- Knob bindings (top row, 3 virtual rows) ---
// Keys: \b<bank>_s<strip>_r<row>  (row 1=Pan, 2=Sends, 3=User)
// Select row via hardware buttons: Pan=87, Sends=88, User=89
// ~apcKnobRow holds current row (1-3)
~apcBindParam.(\b0_s1_r1, { |x| ~t1.pan_(x.linlin(0, 1, -1, 1)) });
~apcBindParam.(\b0_s1_r2, { |x| ~ensurePostSend.(~t1, ~r1, x) });

// --- Device knobs (CC 16-23) ---
// Keys: \b<bank>_d<1-8>
~apcBindParam.(\b0_d1, { |x| ~r1_fx.set(\room, x) });

// --- Stateful FX send toggle (single pad, color reflects active state) ---
// Use a Tdef so ~apcToggleObj can track isPlaying for LED color.
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
~apcBind.(32, \bd1_fxSend, 4, \amber, \green);  // amber=off, green=on
// The same Tdef can be bound on the LP Mini too — both LEDs stay in sync:
// ~lpBind.([8, 1], \bd1_fxSend, 35);

// --- Repaint LEDs ---
~apcRepaintAll.();
